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
        "Access-Control-Allow-Headers": "Content-Type",
      },
    });
  }

  try {
    const { path, args, isMutation } = await request.json();
    
    const [moduleName, functionName] = path.split(":");
    let result;
    
    // Quick hack for this project to route dynamic names to the actual functions.
    // Instead of full dynamic routing which TS doesn't like, we match explicitly or somewhat dynamically.
    const mod = (api as any)[moduleName];
    if (!mod || !mod[functionName]) {
      return new Response("Not found", { status: 404 });
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
