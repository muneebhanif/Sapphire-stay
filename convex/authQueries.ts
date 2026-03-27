import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// Simple ID hashing helper for mock passwords since true bcrypt isn't standard in Edge
// In a full production app you can use Node built-ins or webcrypto via httpAction
const hashPassword = async (password: string) => {
  const encoder = new TextEncoder();
  const data = encoder.encode(password + "sapphire_salt");
  const hash = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(hash))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
};

export const login = mutation({
  args: { email: v.string(), password: v.string() },
  handler: async (ctx, args) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", args.email))
      .first();

    if (!user) {
      throw new Error("Invalid credentials");
    }

    if (!user.isActive) {
      throw new Error("Account is deactivated");
    }

    // Since we originally didn't hash passwords, we allow either exact match or hashed match
    // to prevent breaking existing generated seed users.
    const hashed = await hashPassword(args.password);
    if (user.password !== args.password && user.password !== hashed) {
      throw new Error("Invalid credentials");
    }

    // 2 weeks expiration
    const expiresAt = Date.now() + 1000 * 60 * 60 * 24 * 14;
    const token = crypto.randomUUID();

    await ctx.db.insert("sessions", {
      token,
      userId: user._id,
      createdAt: Date.now(),
      expiresAt,
    });

    return {
      token,
      user: {
        id: user._id.toString(),
        name: user.name,
        email: user.email,
        phone: user.phone || "",
        role: user.role,
        avatar_url: null,
        created_at: new Date(user.createdAt).toISOString(),
        is_active: user.isActive,
      },
    };
  },
});

export const logout = mutation({
  args: { token: v.string() },
  handler: async (ctx, args) => {
    const session = await ctx.db
      .query("sessions")
      .withIndex("by_token", (q) => q.eq("token", args.token))
      .first();
    if (session) {
      await ctx.db.delete(session._id);
    }
  },
});

export const getSessionUser = query({
  args: { token: v.string() },
  handler: async (ctx, args) => {
    const session = await ctx.db
      .query("sessions")
      .withIndex("by_token", (q) => q.eq("token", args.token))
      .first();

    if (!session || session.expiresAt < Date.now()) {
      return null; // Invalid or expired session
    }

    const user = await ctx.db.get(session.userId);
    if (!user || !user.isActive) return null;

    return { role: user.role, id: user._id.toString() };
  },
});
