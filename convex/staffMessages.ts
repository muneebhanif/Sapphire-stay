// @ts-nocheck
import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

export const sendMessage = mutation({
  args: {
    bookingRequestId: v.id("bookingRequests"),
    fromUserId: v.id("users"),
    toUserId: v.id("users"),
    text: v.string(),
    attachments: v.optional(v.array(v.string())),
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert("staffMessages", {
      ...args,
      createdAt: Date.now(),
    });
  },
});

export const getThread = query({
  args: { bookingRequestId: v.id("bookingRequests") },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("staffMessages")
      .withIndex("by_bookingRequest", (q) =>
        q.eq("bookingRequestId", args.bookingRequestId),
      )
      .collect();
  },
});
