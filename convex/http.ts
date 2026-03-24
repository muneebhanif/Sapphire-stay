// @ts-nocheck
import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";

const http = httpRouter();

http.route({
  path: "/uploadImage",
  method: "POST",
  handler: httpAction(async (ctx, request) => {
    // Read the body as a Blob and get its buffer
    const blob = await request.blob();
    const storageId = await ctx.storage.store(blob);
    return new Response(JSON.stringify({ storageId }), {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Vary": "origin",
      },
    });
  }),
});

// Add OPTIONS route for CORS
http.route({
  path: "/uploadImage",
  method: "OPTIONS",
  handler: httpAction(async (_, request) => {
    return new Response(null, {
      status: 204,
      headers: {
         "Access-Control-Allow-Origin": "*",
         "Access-Control-Allow-Methods": "POST, OPTIONS",
         "Access-Control-Allow-Headers": "Content-Type, Authorization",
         "Access-Control-Max-Age": "86400",
      },
    });
  }),
});



http.route({
  path: "/getImage",
  method: "GET",
  handler: httpAction(async (ctx, request) => {
    const { searchParams } = new URL(request.url);
    const storageId = searchParams.get("storageId");
    if (storageId === null) {
      return new Response("Missing storageId", {
        status: 400,
        headers: { "Access-Control-Allow-Origin": "*" },
      });
    }
    const blob = await ctx.storage.get(storageId as string);
    if (blob === null) {
      return new Response("Image not found", {
        status: 404,
        headers: { "Access-Control-Allow-Origin": "*" },
      });
    }
    return new Response(blob, {
      status: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
    });
  }),
});



import { callEndpoint } from "./apiProxy";

http.route({
  path: "/api",
  method: "POST",
  handler: callEndpoint,
});

http.route({
  path: "/api",
  method: "OPTIONS",
  handler: callEndpoint,
});
export default http;
