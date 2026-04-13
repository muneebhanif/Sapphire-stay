// @ts-nocheck
import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

// ─── Messages ────────────────────────────────────────────────────

/** Send a message (staff↔customer or admin→anyone) */
export const sendMessage = mutation({
  args: {
    bookingRequestId: v.id("bookingRequests"),
    fromUserId: v.id("users"),
    toUserId: v.id("users"),
    text: v.string(),
  },
  handler: async (ctx, args) => {
    const id = await ctx.db.insert("staffMessages", {
      bookingRequestId: args.bookingRequestId,
      fromUserId: args.fromUserId,
      toUserId: args.toUserId,
      text: args.text,
      createdAt: Date.now(),
    });

    // Create a notification for the recipient
    const sender = await ctx.db.get(args.fromUserId);
    await ctx.db.insert("notifications", {
      userId: args.toUserId,
      type: "new_message",
      title: "New Message",
      body: `${sender?.name || "Someone"} sent you a message`,
      bookingRequestId: args.bookingRequestId,
      createdAt: Date.now(),
    });

    return id;
  },
});

export const editMessage = mutation({
  args: { messageId: v.id("staffMessages"), newText: v.string() },
  handler: async (ctx, args) => {
    await ctx.db.patch(args.messageId, { text: args.text }); // wait, I meant text: args.newText
  }
});
// let me fix that argument instantly
export const editMessage = mutation({
  args: { messageId: v.id("staffMessages"), newText: v.string() },
  handler: async (ctx, args) => {
    await ctx.db.patch(args.messageId, { text: args.newText });
  }
});

export const deleteMessage = mutation({
  args: { messageId: v.id("staffMessages") },
  handler: async (ctx, args) => {
    await ctx.db.delete(args.messageId);
  }
});

/** Get messages for a booking request */
export const getMessagesByBooking = query({
  args: { bookingRequestId: v.id("bookingRequests") },
  handler: async (ctx, args) => {
    const messages = await ctx.db
      .query("staffMessages")
      .withIndex("by_bookingRequest", (q) =>
        q.eq("bookingRequestId", args.bookingRequestId),
      )
      .collect();

    // Enrich with user names
    const enriched = await Promise.all(
      messages.map(async (m) => {
        const from = await ctx.db.get(m.fromUserId);
        const to = await ctx.db.get(m.toUserId);
        return {
          _id: m._id,
          bookingRequestId: m.bookingRequestId,
          fromUserId: m.fromUserId as string,
          toUserId: m.toUserId as string,
          fromName: from?.name || "Unknown",
          toName: to?.name || "Unknown",
          fromRole: from?.role || "customer",
          text: m.text,
          createdAt: m.createdAt,
          readAt: m.readAt,
        };
      }),
    );

    return enriched.sort((a, b) => a.createdAt - b.createdAt);
  },
});

/** Get all conversations for a user (grouped by bookingRequestId) */
export const getConversationsForUser = query({
  args: { userId: v.string() },
  handler: async (ctx, args) => {
    // Get all messages where user is sender or recipient
    const allMessages = await ctx.db.query("staffMessages").collect();
    const userMessages = allMessages.filter(
      (m) =>
        (m.fromUserId as string) === args.userId ||
        (m.toUserId as string) === args.userId,
    );

    // Group by bookingRequestId
    const grouped: Record<string, any[]> = {};
    for (const m of userMessages) {
      const key = m.bookingRequestId as string;
      if (!grouped[key]) grouped[key] = [];
      grouped[key].push(m);
    }

    // Build conversation summaries
    const conversations = await Promise.all(
      Object.entries(grouped).map(async ([brId, msgs]) => {
        const lastMsg = msgs[msgs.length - 1];
        const otherUserId =
          (lastMsg.fromUserId as string) === args.userId
            ? lastMsg.toUserId
            : lastMsg.fromUserId;
        const otherUser = await ctx.db.get(otherUserId);
        const unread = msgs.filter(
          (m) =>
            (m.toUserId as string) === args.userId && !m.readAt,
        ).length;

        return {
          bookingRequestId: brId,
          otherUserId: otherUserId as string,
          otherUserName: otherUser?.name || "Unknown",
          otherUserRole: otherUser?.role || "customer",
          lastMessage: lastMsg.text,
          lastMessageAt: lastMsg.createdAt,
          unreadCount: unread,
          totalMessages: msgs.length,
        };
      }),
    );

    return conversations.sort((a, b) => b.lastMessageAt - a.lastMessageAt);
  },
});

/** Get all conversations (admin monitoring) */
export const getAllConversations = query({
  handler: async (ctx) => {
    const allMessages = await ctx.db.query("staffMessages").collect();

    const grouped: Record<string, any[]> = {};
    for (const m of allMessages) {
      const key = m.bookingRequestId as string;
      if (!grouped[key]) grouped[key] = [];
      grouped[key].push(m);
    }

    const conversations = await Promise.all(
      Object.entries(grouped).map(async ([brId, msgs]) => {
        const lastMsg = msgs[msgs.length - 1];
        const from = await ctx.db.get(lastMsg.fromUserId);
        const to = await ctx.db.get(lastMsg.toUserId);

        // Get all unique participants
        const participantIds = new Set<string>();
        msgs.forEach((m) => {
          participantIds.add(m.fromUserId as string);
          participantIds.add(m.toUserId as string);
        });

        const participants = await Promise.all(
          Array.from(participantIds).map(async (id) => {
            const u = await ctx.db.get(id as any);
            return { id, name: u?.name || "Unknown", role: u?.role || "customer" };
          }),
        );

        return {
          bookingRequestId: brId,
          participants,
          lastMessage: lastMsg.text,
          lastMessageFrom: from?.name || "Unknown",
          lastMessageAt: lastMsg.createdAt,
          totalMessages: msgs.length,
        };
      }),
    );

    return conversations.sort((a, b) => b.lastMessageAt - a.lastMessageAt);
  },
});

/** Mark messages as read */
export const markMessagesRead = mutation({
  args: {
    bookingRequestId: v.id("bookingRequests"),
    userId: v.string(),
  },
  handler: async (ctx, args) => {
    const messages = await ctx.db
      .query("staffMessages")
      .withIndex("by_bookingRequest", (q) =>
        q.eq("bookingRequestId", args.bookingRequestId),
      )
      .collect();

    const now = Date.now();
    for (const m of messages) {
      if ((m.toUserId as string) === args.userId && !m.readAt) {
        await ctx.db.patch(m._id, { readAt: now });
      }
    }
  },
});

// ─── Notifications ───────────────────────────────────────────────

/** Get notifications for a user */
export const getNotifications = query({
  args: { userId: v.string() },
  handler: async (ctx, args) => {
    const all = await ctx.db.query("notifications").collect();
    const userNotifs = all
      .filter((n) => (n.userId as string) === args.userId)
      .sort((a, b) => b.createdAt - a.createdAt);

    return userNotifs.map((n) => ({
      _id: n._id as string,
      type: n.type,
      title: n.title,
      body: n.body,
      bookingRequestId: n.bookingRequestId
        ? (n.bookingRequestId as string)
        : null,
      readAt: n.readAt || null,
      createdAt: n.createdAt,
    }));
  },
});

/** Get unread notification count */
export const getUnreadCount = query({
  args: { userId: v.string() },
  handler: async (ctx, args) => {
    const all = await ctx.db.query("notifications").collect();
    return all.filter(
      (n) => (n.userId as string) === args.userId && !n.readAt,
    ).length;
  },
});

/** Mark notification as read */
export const markNotificationRead = mutation({
  args: { notificationId: v.id("notifications") },
  handler: async (ctx, args) => {
    await ctx.db.patch(args.notificationId, { readAt: Date.now() });
  },
});

/** Mark all notifications as read for a user */
export const markAllNotificationsRead = mutation({
  args: { userId: v.string() },
  handler: async (ctx, args) => {
    const all = await ctx.db.query("notifications").collect();
    const now = Date.now();
    for (const n of all) {
      if ((n.userId as string) === args.userId && !n.readAt) {
        await ctx.db.patch(n._id, { readAt: now });
      }
    }
  },
});

/** Create a notification (called from other mutations) */
export const createNotification = mutation({
  args: {
    userId: v.id("users"),
    type: v.string(),
    title: v.string(),
    body: v.string(),
    bookingRequestId: v.optional(v.id("bookingRequests")),
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert("notifications", {
      userId: args.userId,
      type: args.type as any,
      title: args.title,
      body: args.body,
      bookingRequestId: args.bookingRequestId,
      createdAt: Date.now(),
    });
  },
});
