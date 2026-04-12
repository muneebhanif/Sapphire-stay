// @ts-nocheck
import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

export const createBookingRequest = mutation({
  args: {
    customerId: v.id("users"),
    roomId: v.optional(v.id("rooms")),
    checkIn: v.number(),
    checkOut: v.number(),
    guestsCount: v.number(),
    requestedTotalPkr: v.number(),
    notes: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const customer = await ctx.db.get(args.customerId);
    if (!customer || !customer.isActive) {
      throw new Error("Authenticated customer not found");
    }
    if (customer.role !== "customer") {
      throw new Error("Only customer accounts can create booking requests");
    }

    const now = Date.now();
    return await ctx.db.insert("bookingRequests", {
      ...args,
      status: "pending_payment",
      createdAt: now,
      updatedAt: now,
    });
  },
});

export const submitPaymentProof = mutation({
  args: {
    bookingRequestId: v.id("bookingRequests"),
    customerId: v.id("users"),
    senderNumber: v.string(),
    transactionId: v.optional(v.string()),
    amountPkr: v.number(),
    screenshotStorageId: v.string(),
    message: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const request = await ctx.db.get(args.bookingRequestId);
    if (!request) throw new Error("Booking request not found");

    const now = Date.now();

    const proofId = await ctx.db.insert("paymentProofs", {
      bookingRequestId: args.bookingRequestId,
      customerId: args.customerId,
      method: "easypaisa",
      senderNumber: args.senderNumber,
      transactionId: args.transactionId,
      amountPkr: args.amountPkr,
      screenshotStorageId: args.screenshotStorageId,
      message: args.message,
      verificationStatus: "pending",
      createdAt: now,
      updatedAt: now,
    });

    await ctx.db.patch(args.bookingRequestId, {
      status: "payment_submitted",
      updatedAt: now,
    });

    return proofId;
  },
});

export const reviewPaymentProof = mutation({
  args: {
    proofId: v.id("paymentProofs"),
    staffId: v.id("users"),
    action: v.union(v.literal("approve"), v.literal("reject")),
    rejectionReason: v.optional(v.string()),
    invoiceTaxPercent: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const proof = await ctx.db.get(args.proofId);
    if (!proof) throw new Error("Payment proof not found");

    const request = await ctx.db.get(proof.bookingRequestId);
    if (!request) throw new Error("Booking request not found");

    const now = Date.now();

    if (args.action === "reject") {
      await ctx.db.patch(args.proofId, {
        verificationStatus: "rejected",
        verifiedBy: args.staffId,
        verifiedAt: now,
        updatedAt: now,
      });
      await ctx.db.patch(request._id, {
        status: "rejected",
        updatedAt: now,
      });
      if (args.rejectionReason) {
        await ctx.db.insert("staffMessages", {
          bookingRequestId: request._id,
          fromUserId: args.staffId,
          toUserId: request.customerId,
          text: `Payment proof rejected: ${args.rejectionReason}`,
          createdAt: now,
        });
      }

      // Notify the customer about rejection
      await ctx.db.insert("notifications", {
        userId: request.customerId,
        type: "booking_rejected",
        title: "Booking Update",
        body: args.rejectionReason
          ? `Your payment proof was rejected: ${args.rejectionReason}`
          : "Your payment proof could not be verified. Please submit a new one.",
        bookingRequestId: request._id,
        createdAt: now,
      });

      return { status: "rejected" as const };
    }

    if (!request.roomId) throw new Error("Room must be assigned before approval");

    await ctx.db.patch(args.proofId, {
      verificationStatus: "approved",
      verifiedBy: args.staffId,
      verifiedAt: now,
      updatedAt: now,
    });
    await ctx.db.patch(request._id, {
      status: "verified",
      updatedAt: now,
    });

    const bookingId = await ctx.db.insert("bookings", {
      bookingRequestId: request._id,
      customerId: request.customerId,
      staffId: args.staffId,
      roomId: request.roomId,
      checkIn: request.checkIn,
      checkOut: request.checkOut,
      totalPkr: request.requestedTotalPkr,
      status: "confirmed",
      createdAt: now,
    });

    const taxPercent = args.invoiceTaxPercent ?? 16;
    const subtotal = Math.round(request.requestedTotalPkr / (1 + taxPercent / 100));
    const tax = request.requestedTotalPkr - subtotal;
    const invoiceId = await ctx.db.insert("invoices", {
      bookingId,
      subtotalPkr: subtotal,
      taxPkr: tax,
      totalPkr: request.requestedTotalPkr,
      status: "paid",
      issuedAt: now,
      dueAt: now,
    });

    const paymentId = await ctx.db.insert("payments", {
      bookingId,
      invoiceId,
      proofId: proof._id,
      amountPkr: proof.amountPkr,
      method: "easypaisa",
      status: "completed",
      recordedBy: args.staffId,
      createdAt: now,
    });

    // Notify the customer
    await ctx.db.insert("notifications", {
      userId: request.customerId,
      type: "booking_approved",
      title: "Booking Confirmed! 🎉",
      body: "Your booking has been approved and confirmed. We look forward to welcoming you!",
      bookingRequestId: args.bookingRequestId,
      createdAt: now,
    });

    return { status: "approved" as const, bookingId, invoiceId, paymentId };
  },
});

export const getCustomerBookingRequests = query({
  args: { customerId: v.id("users") },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("bookingRequests")
      .withIndex("by_customer", (q) => q.eq("customerId", args.customerId))
      .collect();
  },
});

export const getAllPaymentProofs = query({
  args: {},
  handler: async (ctx) => {
    const proofs = await ctx.db.query("paymentProofs").order("desc").collect();
    return Promise.all(
      proofs.map(async (p) => {
        const customer = await ctx.db.get(p.customerId);
        let reviewedBy = null;
        if (p.verifiedBy) {
          const staff = await ctx.db.get(p.verifiedBy);
          reviewedBy = staff?.name;
        }
        return {
          ...p,
          customerName: customer?.name || "Unknown",
          reviewedByName: reviewedBy,
        };
      })
    );
  },
});

export const getPendingPaymentProofs = query({
  args: {},
  handler: async (ctx) => {
    const proofs = await ctx.db
      .query("paymentProofs")
      .withIndex("by_status", (q) => q.eq("verificationStatus", "pending"))
      .order("desc")
      .collect();
    return Promise.all(
      proofs.map(async (p) => {
        const customer = await ctx.db.get(p.customerId);
        return {
          ...p,
          customerName: customer?.name || "Unknown",
        };
      })
    );
  },
});

export const getAllBookingRequests = query({
  args: {},
  handler: async (ctx) => {
    const requests = await ctx.db.query("bookingRequests").order("desc").collect();
    return Promise.all(
      requests.map(async (r) => {
        const customer = await ctx.db.get(r.customerId);
        const room = r.roomId ? await ctx.db.get(r.roomId) : null;
        return {
          ...r,
          customerName: customer?.name || "Unknown",
          customerEmail: customer?.email || "",
          customerPhone: customer?.phone || "",
          roomNumber: room?.roomNumber || "Unassigned",
        };
      })
    );
  },
});
