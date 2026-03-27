import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";
import { api } from "./_generated/api";

export const callEndpoint = httpAction(async (ctx, request) => {
  if (request.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    });
  }

  try {
    const { path, args, isMutation } = await request.json();
    
    // Auth Token Parsing
    const authHeader = request.headers.get("Authorization");
    let userRole: string | null = null;
    let userId: string | null = null;

    if (authHeader && authHeader.startsWith("Bearer ")) {
      const token = authHeader.substring(7);
      const sessionUser = await ctx.runQuery(api.authQueries.getSessionUser, { token });
      if (!sessionUser) {
        return new Response(JSON.stringify({ error: "Invalid or expired session" }), {
          status: 401,
          headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
        });
      }
      userRole = sessionUser.role;
      userId = sessionUser.id;
    }

    // Role-Based Access Control (RBAC) mapping
    const adminStaffRestricted = new Set([
      "data:createRoom",
      "data:updateRoom",
      "data:deleteRoom",
      "data:createGuest",
      "data:updateGuest",
      "data:deleteGuest",
      "data:createStaff",
      "data:updateStaff",
      "data:deactivateStaff",
      "data:getStaff",
      "data:getReports",
      "bookingRequests:reviewPaymentProof",
      "bookingRequests:getAllPaymentProofs",
      "bookingRequests:getPendingPaymentProofs",
      "bookingRequests:getAllBookingRequests",
    ]);

    if (adminStaffRestricted.has(path)) {
      if (userRole !== "admin" && userRole !== "staff") {
        return new Response(JSON.stringify({ error: "Forbidden: Requires Admin or Staff role" }), {
          status: 403,
          headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
        });
      }
    }
    
    // Auto-inject userId for endpoints that require it instead of hacking with getFirstUsers
    if (userId) {
       // if an argument isn't explicitly defined it will be stripped or throw, 
       // but we can just leave it to args. For now, pass token so backend can use it.
    }

    const [moduleName, functionName] = path.split(":");
    let result;
    
    // Quick hack for this project to route dynamic names to the actual functions.
    // Instead of full dynamic routing which TS doesn't like, we match explicitly or somewhat dynamically.
    const mod = (api as any)[moduleName];
    if (!mod || !mod[functionName]) {
      return new Response(JSON.stringify({ error: `Not found: ${path}` }), { 
        status: 404,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
      });
    }
    
    if (isMutation) {
      result = await ctx.runMutation(mod[functionName], args);
    } else {
      result = await ctx.runQuery(mod[functionName], args);
    }

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  }
});
