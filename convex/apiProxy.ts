import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";
import { api } from "./_generated/api";

export const callEndpoint = httpAction(async (ctx, request) => {
  // CORS preflight
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
    
    // ── Auth Token Parsing ──
    const authHeader = request.headers.get("Authorization");
    let userRole: string | null = null;
    let userId: string | null = null;

    if (authHeader && authHeader.startsWith("Bearer ")) {
      const token = authHeader.substring(7);
      try {
        const sessionUser = await ctx.runQuery(api.authQueries.getSessionUser, { token });
        if (sessionUser) {
          userRole = sessionUser.role;
          userId = sessionUser.id;
        }
        // If session is invalid/expired, we don't reject here — 
        // we only reject if the endpoint requires auth (see below).
      } catch {
        // Token parsing failed — treat as unauthenticated
      }
    }

    // ── Role-Based Access Control ──
    //
    // Public endpoints (no auth required):
    //   - data:getAllRooms, data:getFeaturedRooms, data:getRoomById
    //   - data:getAllReviews, data:getAverageRating
    //   - data:getGalleryImages, data:getSiteConfig
    //   - data:getAllBookings, data:getAllGuests, data:getAllInvoices, data:getAllPayments
    //   - data:getTotalRevenue
    //   - data:createGuest (customers create their own guest record during booking)
    //   - bookingRequests:createBookingRequest
    //   - bookingRequests:submitPaymentProof
    //   - authQueries:login, authQueries:logout, authQueries:getSessionUser
    //
    // Staff or Admin required:
    const staffRestricted = new Set([
      "bookingRequests:reviewPaymentProof",
      "bookingRequests:getAllPaymentProofs",
      "bookingRequests:getPendingPaymentProofs",
      "bookingRequests:getAllBookingRequests",
      "data:getStaff",
      "data:getReports",
    ]);

    // Admin only:
    const adminOnly = new Set([
      "data:createRoom",
      "data:updateRoom",
      "data:deleteRoom",
      "data:updateGuest",
      "data:deleteGuest",
      "data:createStaff",
      "data:updateStaff",
      "data:deactivateStaff",
    ]);

    if (staffRestricted.has(path)) {
      if (userRole !== "admin" && userRole !== "staff") {
        return new Response(
          JSON.stringify({ error: "Forbidden: Requires Staff or Admin role" }),
          { status: 403, headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
        );
      }
    }

    if (adminOnly.has(path)) {
      if (userRole !== "admin") {
        return new Response(
          JSON.stringify({ error: "Forbidden: Requires Admin role" }),
          { status: 403, headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
        );
      }
    }

    // ── Dynamic function routing ──
    const [moduleName, functionName] = path.split(":");
    const mod = (api as any)[moduleName];
    if (!mod || !mod[functionName]) {
      return new Response(
        JSON.stringify({ error: `Not found: ${path}` }),
        { status: 404, headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
      );
    }
    
    let result;
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
    console.error("[apiProxy] Error:", err.message);
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  }
});
