// @ts-nocheck
import { query } from "./_generated/server";

export const getFirstUsers = query({
  args: {},
  handler: async (ctx) => {
    const customer = await ctx.db.query("users").withIndex("by_role", q => q.eq("role", "customer")).first();
    const staff = await ctx.db.query("users").withIndex("by_role", q => q.eq("role", "staff")).first();
    const room = await ctx.db.query("rooms").first();
    return { 
      customerId: customer?._id, 
      staffId: staff?._id,
      roomId: room?._id
    };
  },
});
