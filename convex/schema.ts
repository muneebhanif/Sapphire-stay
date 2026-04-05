// @ts-nocheck
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  users: defineTable({
    role: v.union(v.literal("customer"), v.literal("staff"), v.literal("admin")),
    name: v.string(),
    email: v.string(),
    password: v.optional(v.string()),
    phone: v.optional(v.string()),
    isActive: v.boolean(),
    createdAt: v.number(),
  })
    .index("by_email", ["email"])
    .index("by_role", ["role"]),

  sessions: defineTable({
    token: v.string(),
    userId: v.id("users"),
    createdAt: v.number(),
    expiresAt: v.number(),
  }).index("by_token", ["token"]),

  rooms: defineTable({
    roomNumber: v.string(),
    type: v.string(),
    floor: v.number(),
    capacity: v.number(),
    pricePkr: v.number(),
    status: v.union(
      v.literal("available"),
      v.literal("occupied"),
      v.literal("reserved"),
      v.literal("maintenance"),
    ),
    amenities: v.array(v.string()),
    imageUrls: v.array(v.string()),
    createdAt: v.number(),
  })
    .index("by_roomNumber", ["roomNumber"])
    .index("by_status", ["status"]),

  bookingRequests: defineTable({
    customerId: v.id("users"),
    roomId: v.optional(v.id("rooms")),
    checkIn: v.number(),
    checkOut: v.number(),
    guestsCount: v.number(),
    requestedTotalPkr: v.number(),
    status: v.union(
      v.literal("pending_payment"),
      v.literal("payment_submitted"),
      v.literal("verified"),
      v.literal("rejected"),
      v.literal("expired"),
    ),
    notes: v.optional(v.string()),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_customer", ["customerId"])
    .index("by_status", ["status"]),

  paymentProofs: defineTable({
    bookingRequestId: v.id("bookingRequests"),
    customerId: v.id("users"),
    method: v.literal("easypaisa"),
    senderNumber: v.string(),
    transactionId: v.optional(v.string()),
    amountPkr: v.number(),
    screenshotStorageId: v.string(),
    message: v.optional(v.string()),
    verificationStatus: v.union(
      v.literal("pending"),
      v.literal("approved"),
      v.literal("rejected"),
    ),
    verifiedBy: v.optional(v.id("users")),
    verifiedAt: v.optional(v.number()),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index("by_bookingRequest", ["bookingRequestId"])
    .index("by_status", ["verificationStatus"]),

  staffMessages: defineTable({
    bookingRequestId: v.id("bookingRequests"),
    fromUserId: v.id("users"),
    toUserId: v.id("users"),
    text: v.string(),
    attachments: v.optional(v.array(v.string())),
    createdAt: v.number(),
    readAt: v.optional(v.number()),
  }).index("by_bookingRequest", ["bookingRequestId"]),

  bookings: defineTable({
    bookingRequestId: v.id("bookingRequests"),
    customerId: v.id("users"),
    staffId: v.id("users"),
    roomId: v.id("rooms"),
    checkIn: v.number(),
    checkOut: v.number(),
    totalPkr: v.number(),
    status: v.union(
      v.literal("confirmed"),
      v.literal("checked_in"),
      v.literal("completed"),
      v.literal("cancelled"),
    ),
    createdAt: v.number(),
  })
    .index("by_customer", ["customerId"])
    .index("by_room", ["roomId"]),

  invoices: defineTable({
    bookingId: v.id("bookings"),
    subtotalPkr: v.number(),
    taxPkr: v.number(),
    totalPkr: v.number(),
    status: v.union(
      v.literal("draft"),
      v.literal("issued"),
      v.literal("paid"),
      v.literal("overdue"),
      v.literal("cancelled"),
    ),
    issuedAt: v.number(),
    dueAt: v.optional(v.number()),
  }).index("by_booking", ["bookingId"]),

  payments: defineTable({
    bookingId: v.id("bookings"),
    invoiceId: v.optional(v.id("invoices")),
    proofId: v.optional(v.id("paymentProofs")),
    amountPkr: v.number(),
    method: v.literal("easypaisa"),
    status: v.union(
      v.literal("pending"),
      v.literal("completed"),
      v.literal("failed"),
      v.literal("refunded"),
    ),
    recordedBy: v.id("users"),
    createdAt: v.number(),
  }).index("by_booking", ["bookingId"]),


  reviews: defineTable({
    customerId: v.id("users"),
    roomId: v.id("rooms"),
    rating: v.number(),
    comment: v.string(),
    createdAt: v.number(),
  }).index("by_room", ["roomId"]),

  galleryImages: defineTable({
    url: v.string(),
    caption: v.string(),
    sortOrder: v.number(),
    createdAt: v.number(),
  }).index("by_sortOrder", ["sortOrder"]),

  siteConfig: defineTable({
    key: v.string(),
    value: v.string(),
    createdAt: v.number(),
  }).index("by_key", ["key"]),
});
