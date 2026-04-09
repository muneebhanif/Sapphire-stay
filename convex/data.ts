// @ts-nocheck
import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

const idOf = (value: unknown) => {
  if (typeof value === "string") return value;
  return String(value ?? "");
};

const statusToBookingModelStatus = (status: string) => {
  if (status === "checked_in") return "checkedIn";
  return status;
};

const asIso = (millis: number | undefined) =>
  new Date(millis ?? Date.now()).toISOString();

const localRoomImages = {
  standard: "assets/imgs/room1.jpeg",
  deluxe: "assets/imgs/room2.jpeg",
  suite: "assets/imgs/room3.jpeg",
  presidential: "assets/imgs/room6.jpeg",
};

const localGalleryImages = [
  "assets/imgs/turf.jpeg",
  "assets/imgs/room.jpeg",
  "assets/imgs/balcony.jpeg",
  "assets/imgs/room5.jpeg",
  "assets/imgs/bathroom.jpeg",
  "assets/imgs/room1.jpeg",
  "assets/imgs/room2.jpeg",
  "assets/imgs/room3.jpeg",
  "assets/imgs/room6.jpeg",
  "assets/imgs/banner.jpeg",
];

const localSiteMediaByKey: Record<string, string> = {
  hero_image: "assets/imgs/banner.jpeg",
  hotel_exterior: "assets/imgs/turf.jpeg",
  hotel_lobby: "assets/imgs/room.jpeg",
};

const normalizeMediaUrl = (url: string | undefined | null, fallback: string) => {
  if (!url || url.trim().length === 0) return fallback;
  const value = url.trim();
  if (value.includes("images.unsplash.com")) return fallback;
  return value;
};

const normalizeImageUrls = (imageUrls: string[] | undefined) => {
  if (!imageUrls || imageUrls.length === 0) return [];
  return imageUrls
    .map((u) => (u ?? "").trim())
    .filter((u) => u.length > 0)
    .slice(0, 6);
};

const mapRoomData = (r, featuredIds = new Set<string>()) => ({
  id: idOf(r._id),
  number: r.roomNumber,
  type: r.type,
  name: `Room ${r.roomNumber}`,
  description: `Experience luxury in our beautifully appointed ${r.type} room.`,
  price_per_night: r.pricePkr, // Send PKR directly, no conversion
  capacity: r.capacity,
  floor: r.floor,
  size_sq_ft: 400.0,
  status: r.status,
  amenities: r.amenities || [],
  image_urls: (r.imageUrls && r.imageUrls.length > 0)
    ? r.imageUrls.map((u) => normalizeMediaUrl(u, localRoomImages[r.type] || "assets/imgs/room.jpeg"))
    : [localRoomImages[r.type] || "assets/imgs/room.jpeg"],
  is_featured: featuredIds.has(idOf(r._id)),
});

// ───────────────────────────────────────────────────────────
// ROOM QUERIES
// ───────────────────────────────────────────────────────────

export const getAllRooms = query({
  args: {},
  handler: async (ctx) => {
    const rooms = await ctx.db.query("rooms").collect();
    const featuredIds = new Set(
      [...rooms]
        .sort((a, b) => b.pricePkr - a.pricePkr)
        .slice(0, 3)
        .map((r) => idOf(r._id)),
    );
    return rooms.map((r) => mapRoomData(r, featuredIds));
  }
});

export const getFeaturedRooms = query({
  args: {},
  handler: async (ctx) => {
    const rs = await ctx.db.query("rooms").collect();
    const featured = [...rs].sort((a, b) => b.pricePkr - a.pricePkr).slice(0, 3);
    const featuredIds = new Set(featured.map((r) => idOf(r._id)));
    return featured.map((r) => mapRoomData(r, featuredIds));
  }
});

export const getRoomById = query({
  args: { id: v.id("rooms") },
  handler: async (ctx, args) => {
    const r = await ctx.db.get(args.id);
    if (!r) throw new Error("Not found");
    return mapRoomData(r);
  }
});

// ───────────────────────────────────────────────────────────
// ROOM MUTATIONS (CRUD)
// ───────────────────────────────────────────────────────────

export const createRoom = mutation({
  args: {
    roomNumber: v.string(),
    type: v.string(),
    floor: v.number(),
    capacity: v.number(),
    pricePkr: v.number(),
    status: v.string(),
    amenities: v.array(v.string()),
    imageUrls: v.array(v.string()),
  },
  handler: async (ctx, args) => {
    const imageUrls = normalizeImageUrls(args.imageUrls);
    const id = await ctx.db.insert("rooms", {
      roomNumber: args.roomNumber,
      type: args.type,
      floor: args.floor,
      capacity: args.capacity,
      pricePkr: args.pricePkr,
      status: args.status,
      amenities: args.amenities,
      imageUrls,
      createdAt: Date.now(),
    });
    const r = await ctx.db.get(id);
    return mapRoomData(r);
  },
});

export const updateRoom = mutation({
  args: {
    id: v.id("rooms"),
    roomNumber: v.optional(v.string()),
    type: v.optional(v.string()),
    floor: v.optional(v.number()),
    capacity: v.optional(v.number()),
    pricePkr: v.optional(v.number()),
    status: v.optional(v.string()),
    amenities: v.optional(v.array(v.string())),
    imageUrls: v.optional(v.array(v.string())),
  },
  handler: async (ctx, args) => {
    const { id, ...updates } = args;
    const normalizedUpdates = {
      ...updates,
      imageUrls:
        updates.imageUrls === undefined
          ? undefined
          : normalizeImageUrls(updates.imageUrls),
    };
    const filtered = Object.fromEntries(
      Object.entries(normalizedUpdates).filter(([_, val]) => val !== undefined),
    );
    await ctx.db.patch(id, filtered);
    const r = await ctx.db.get(id);
    return mapRoomData(r);
  },
});

export const deleteRoom = mutation({
  args: { id: v.id("rooms") },
  handler: async (ctx, args) => {
    await ctx.db.delete(args.id);
  },
});

// ───────────────────────────────────────────────────────────
// BOOKING QUERIES
// ───────────────────────────────────────────────────────────

export const getAllBookings = query({
  args: {},
  handler: async (ctx) => {
    const bs = await ctx.db.query("bookings").collect();
    return Promise.all(bs.map(async b => {
      const room = await ctx.db.get(b.roomId);
      const user = await ctx.db.get(b.customerId);
      const request = await ctx.db.get(b.bookingRequestId);
      return {
        id: idOf(b._id),
        guest_name: user?.name || "Unknown",
        guest_email: user?.email || "",
        guest_phone: user?.phone || "",
        room_id: idOf(b.roomId),
        room_number: room?.roomNumber || "",
        room_type: room?.type || "standard",
        check_in: asIso(b.checkIn),
        check_out: asIso(b.checkOut),
        guests: request?.guestsCount ?? 1,
        total_amount: b.totalPkr, // PKR
        status: statusToBookingModelStatus(b.status),
        special_requests: request?.notes ?? null,
        created_at: asIso(b.createdAt),
      };
    }));
  }
});

// ───────────────────────────────────────────────────────────
// GUEST QUERIES + MUTATIONS
// ───────────────────────────────────────────────────────────

export const getAllGuests = query({
  args: {},
  handler: async (ctx) => {
    const users = await ctx.db
      .query("users")
      .withIndex("by_role", q => q.eq("role", "customer"))
      .collect();

    return users.map((u) => ({
      id: idOf(u._id),
      name: u.name,
      email: u.email,
      phone: u.phone || "",
      id_number: null,
      nationality: null,
      address: null,
      total_stays: 0,
      created_at: asIso(u.createdAt),
    }));
  }
});

export const createGuest = mutation({
  args: {
    name: v.string(),
    email: v.string(),
    phone: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const id = await ctx.db.insert("users", {
      role: "customer",
      name: args.name,
      email: args.email,
      phone: args.phone,
      isActive: true,
      createdAt: Date.now(),
    });
    return idOf(id);
  },
});

// ───────────────────────────────────────────────────────────
// INVOICE QUERIES
// ───────────────────────────────────────────────────────────

export const getAllInvoices = query({
  args: {},
  handler: async (ctx) => {
    const invs = await ctx.db.query("invoices").collect();
    return Promise.all(invs.map(async i => {
      const b = await ctx.db.get(i.bookingId);
      const u = b ? await ctx.db.get(b.customerId) : null;
      const room = b ? await ctx.db.get(b.roomId) : null;
      return {
        id: idOf(i._id),
        booking_id: idOf(i.bookingId),
        guest_name: u?.name || "Unknown",
        room_number: room?.roomNumber || "",
        issue_date: asIso(i.issuedAt),
        due_date: i.dueAt ? asIso(i.dueAt) : null,
        subtotal: i.subtotalPkr,
        tax: i.taxPkr,
        total: i.totalPkr,
        status: i.status,
        line_items: [
          {
            description: "Room Charges",
            quantity: 1,
            unit_price: i.subtotalPkr,
            total: i.subtotalPkr,
          },
          {
            description: "Tax",
            quantity: 1,
            unit_price: i.taxPkr,
            total: i.taxPkr,
          },
        ],
      };
    }));
  }
});

// ───────────────────────────────────────────────────────────
// PAYMENT QUERIES
// ───────────────────────────────────────────────────────────

export const getAllPayments = query({
  args: {},
  handler: async (ctx) => {
    const ps = await ctx.db.query("payments").collect();
    return Promise.all(ps.map(async p => {
      const b = await ctx.db.get(p.bookingId);
      const u = b ? await ctx.db.get(b.customerId) : null;
      return {
        id: idOf(p._id),
        invoice_id: p.invoiceId ? idOf(p.invoiceId) : "",
        booking_id: idOf(p.bookingId),
        guest_name: u?.name || "Unknown",
        amount: p.amountPkr,
        method: "online",
        status: p.status,
        paid_at: asIso(p.createdAt),
        transaction_ref: null,
      };
    }));
  }
});

export const getTotalRevenue = query({
  args: {},
  handler: async (ctx) => {
    const ps = await ctx.db.query("payments").collect();
    return ps.reduce((acc, p) => acc + p.amountPkr, 0);
  }
});

// ───────────────────────────────────────────────────────────
// REVIEW QUERIES
// ───────────────────────────────────────────────────────────

export const getAllReviews = query({
  args: {},
  handler: async (ctx) => {
    const reviews = await ctx.db.query("reviews").collect();
    return Promise.all(
      reviews.map(async (r) => {
        const customer = await ctx.db.get(r.customerId);
        return {
          id: idOf(r._id),
          guest_name: customer?.name || "Guest",
          guest_avatar_url: null,
          rating: r.rating,
          comment: r.comment,
          created_at: asIso(r.createdAt),
        };
      }),
    );
  }
});

export const getAverageRating = query({
  args: {},
  handler: async (ctx) => {
    const reviews = await ctx.db.query("reviews").collect();
    if (reviews.length === 0) return 0;
    const total = reviews.reduce((sum, r) => sum + r.rating, 0);
    return total / reviews.length;
  }
});

// ───────────────────────────────────────────────────────────
// STAFF QUERIES + MUTATIONS
// ───────────────────────────────────────────────────────────

export const getStaff = query({
  args: {},
  handler: async (ctx) => {
    const staff = await ctx.db
      .query("users")
      .withIndex("by_role", q => q.eq("role", "staff"))
      .collect();

    return staff.map((u) => ({
      id: idOf(u._id),
      name: u.name,
      email: u.email,
      phone: u.phone || "",
      role: u.role,
      avatar_url: null,
      created_at: asIso(u.createdAt),
      is_active: u.isActive,
    }));
  }
});

export const createStaff = mutation({
  args: {
    name: v.string(),
    email: v.string(),
    phone: v.optional(v.string()),
    password: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const id = await ctx.db.insert("users", {
      role: "staff",
      name: args.name,
      email: args.email,
      phone: args.phone,
      password: args.password,
      isActive: true,
      createdAt: Date.now(),
    });
    return idOf(id);
  },
});

export const deactivateStaff = mutation({
  args: { id: v.id("users") },
  handler: async (ctx, args) => {
    await ctx.db.patch(args.id, { isActive: false });
  },
});

// ───────────────────────────────────────────────────────────
// REPORTS
// ───────────────────────────────────────────────────────────

export const getReports = query({
  args: {},
  handler: async (ctx) => {
    const [rooms, bookings, payments] = await Promise.all([
      ctx.db.query("rooms").collect(),
      ctx.db.query("bookings").collect(),
      ctx.db.query("payments").collect(),
    ]);

    const totalRevenue = payments
      .filter((p) => p.status === "completed")
      .reduce((sum, p) => sum + p.amountPkr, 0);

    const activeBookings = bookings.filter(
      (b) => b.status === "confirmed" || b.status === "checked_in",
    ).length;

    const occupancyRate = rooms.length === 0
      ? "0%"
      : `${((activeBookings / rooms.length) * 100).toFixed(1)}%`;

    return {
      revenue: { total: totalRevenue },
      occupancy: { rate: occupancyRate, totalRooms: rooms.length },
      booking: {
        total: bookings.length,
        confirmed: bookings.filter((b) => b.status === "confirmed").length,
      }
    };
  }
});

// ───────────────────────────────────────────────────────────
// SITE CONTENT QUERIES
// ───────────────────────────────────────────────────────────

export const getGalleryImages = query({
  args: {},
  handler: async (ctx) => {
    const images = await ctx.db
      .query("galleryImages")
      .withIndex("by_sortOrder")
      .collect();

    const roomImageUrls = (await ctx.db.query("rooms").collect())
      .flatMap((room) => normalizeImageUrls(room.imageUrls));

    const merged = [
      ...images.map((img, index) => ({
        url: normalizeMediaUrl(
          img.url,
          localGalleryImages[index % localGalleryImages.length],
        ),
        caption: img.caption,
      })),
      ...roomImageUrls.map((url) => ({ url, caption: "" })),
    ];

    const seen = new Set<string>();
    return merged.filter((item) => {
      if (seen.has(item.url)) return false;
      seen.add(item.url);
      return true;
    });
  },
});

export const getSiteConfig = query({
  args: {},
  handler: async (ctx) => {
    const configs = await ctx.db.query("siteConfig").collect();
    const result: Record<string, string> = {};
    for (const c of configs) {
      result[c.key] = normalizeMediaUrl(c.value, localSiteMediaByKey[c.key] ?? c.value);
    }

    for (const [k, v] of Object.entries(localSiteMediaByKey)) {
      if (!result[k]) result[k] = v;
    }

    return result;
  },
});

// ───────────────────────────────────────────────────────────
// AUTH: getUserByEmail with password check
// ───────────────────────────────────────────────────────────

export const getUserByEmail = query({
  args: { email: v.string(), password: v.optional(v.string()) },
  handler: async (ctx, args) => {
    const user = await ctx.db
      .query("users")
      .withIndex("by_email", (q) => q.eq("email", args.email))
      .first();
    if (!user) return null;

    if (args.password && user.password) {
      if (args.password !== user.password) return null;
    }

    return {
      id: idOf(user._id),
      name: user.name,
      email: user.email,
      phone: user.phone || "",
      role: user.role,
      avatar_url: null,
      created_at: asIso(user.createdAt),
      is_active: user.isActive,
    };
  },
});
