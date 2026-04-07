// @ts-nocheck
import { mutation } from "./_generated/server";

export const seedUsers = mutation({
  args: {},
  handler: async (ctx) => {
    const customerId = await ctx.db.insert("users", {
      role: "customer",
      name: "John Doe",
      email: "john@example.com",
      phone: "+923000000000",
      password: "customer123",
      isActive: true,
      createdAt: Date.now(),
    });

    const staffId = await ctx.db.insert("users", {
      role: "staff",
      name: "Staff James",
      email: "staff@sapphirestay.com",
      phone: "+923001111111",
      password: "staff123",
      isActive: true,
      createdAt: Date.now(),
    });

    const adminId = await ctx.db.insert("users", {
      role: "admin",
      name: "Admin Sarah",
      email: "admin@sapphirestay.com",
      phone: "+923002222222",
      password: "admin123",
      isActive: true,
      createdAt: Date.now(),
    });

    const roomId = await ctx.db.insert("rooms", {
      roomNumber: "101",
      type: "standard",
      floor: 1,
      capacity: 2,
      pricePkr: 5000,
      status: "available",
      amenities: ["WiFi", "TV", "AC"],
      imageUrls: ["assets/imgs/room1.jpeg"],
      createdAt: Date.now(),
    });

    await ctx.db.insert("rooms", {
      roomNumber: "201",
      type: "deluxe",
      floor: 2,
      capacity: 3,
      pricePkr: 12000,
      status: "available",
      amenities: ["WiFi", "TV", "AC", "Mini Bar", "City View", "King Bed"],
      imageUrls: ["assets/imgs/room2.jpeg"],
      createdAt: Date.now(),
    });

    await ctx.db.insert("rooms", {
      roomNumber: "301",
      type: "suite",
      floor: 3,
      capacity: 4,
      pricePkr: 25000,
      status: "available",
      amenities: ["WiFi", "Smart TV", "AC", "Mini Bar", "Living Room", "Butler Service", "Panoramic View"],
      imageUrls: ["assets/imgs/room3.jpeg"],
      createdAt: Date.now(),
    });

    return { customerId, staffId, adminId, roomId };
  },
});

export const seedGallery = mutation({
  args: {},
  handler: async (ctx) => {
    const images = [
      { url: "assets/imgs/1000199454.jpg", caption: "" },
      { url: "assets/imgs/turf.jpeg", caption: "" },
      { url: "assets/imgs/room.jpeg", caption: "" },
      { url: "assets/imgs/balcony.jpeg", caption: "" },
      { url: "assets/imgs/room5.jpeg", caption: "" },
      { url: "assets/imgs/bathroom.jpeg", caption: "" },
      { url: "assets/imgs/room1.jpeg", caption: "" },
      { url: "assets/imgs/room2.jpeg", caption: "" },
      { url: "assets/imgs/room3.jpeg", caption: "" },
      { url: "assets/imgs/room6.jpeg", caption: "" },
      { url: "assets/imgs/banner.jpeg", caption: "" },
    ];
    const now = Date.now();
    for (let i = 0; i < images.length; i++) {
      await ctx.db.insert("galleryImages", {
        url: images[i].url,
        caption: images[i].caption,
        sortOrder: i,
        createdAt: now,
      });
    }
    return { inserted: images.length };
  },
});

export const seedSiteConfig = mutation({
  args: {},
  handler: async (ctx) => {
    const configs = [
      { key: "hotel_name", value: "Sapphire Stay | Muzaffarabad" },
      { key: "tagline", value: "Comfortable Rooms in Muzaffarabad" },
      { key: "phone", value: "+92 317 9219995" },
      { key: "email", value: "sapphire.stay" },
      { key: "address", value: "Gojra Bypass Road, Muzaffarabad, Pakistan, 13100." },
      { key: "hero_image", value: "assets/imgs/banner.jpeg" },
      { key: "hotel_exterior", value: "assets/imgs/turf.jpeg" },
      { key: "hotel_lobby", value: "assets/imgs/room.jpeg" },
      { key: "stat_years", value: "25+" },
      { key: "stat_guests", value: "50K+" },
      { key: "stat_staff", value: "100+" },
      { key: "stat_awards", value: "15+" },
      { key: "copyright", value: "© 2026 Sapphire Stay | Muzaffarabad. All rights reserved." },
      { key: "facebook", value: "" },
      { key: "instagram", value: "https://instagram.com/sapphire.stay" },
      { key: "twitter", value: "" },
    ];
    const now = Date.now();
    for (const c of configs) {
      await ctx.db.insert("siteConfig", {
        key: c.key,
        value: c.value,
        createdAt: now,
      });
    }
    return { inserted: configs.length };
  },
});

export const updatePasswords = mutation({
  args: {},
  handler: async (ctx) => {
    const passwords: Record<string, string> = {
      "admin@sapphirestay.com": "admin123",
      "staff@sapphirestay.com": "staff123",
      "john@example.com": "customer123",
    };

    let updated = 0;
    const users = await ctx.db.query("users").collect();
    for (const user of users) {
      const pw = passwords[user.email];
      if (pw) {
        await ctx.db.patch(user._id, { password: pw });
        updated++;
      }
    }
    return { updated };
  },
});

export const syncPublicContent = mutation({
  args: {},
  handler: async (ctx) => {
    const now = Date.now();

    const galleryUrls = [
      "assets/imgs/1000199454.jpg",
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

    const existingGallery = await ctx.db.query("galleryImages").collect();
    for (const item of existingGallery) {
      await ctx.db.delete(item._id);
    }
    for (let i = 0; i < galleryUrls.length; i++) {
      await ctx.db.insert("galleryImages", {
        url: galleryUrls[i],
        caption: "",
        sortOrder: i,
        createdAt: now,
      });
    }

    const configs: Record<string, string> = {
      hotel_name: "Sapphire Stay | Muzaffarabad",
      tagline: "Comfortable Rooms in Muzaffarabad",
      phone: "+92 317 9219995",
      email: "sapphire.stay",
      address: "Gojra Bypass Road, Muzaffarabad, Pakistan, 13100.",
      hero_image: "assets/imgs/banner.jpeg",
      hotel_exterior: "assets/imgs/turf.jpeg",
      hotel_lobby: "assets/imgs/room.jpeg",
      stat_years: "25+",
      stat_guests: "50K+",
      stat_staff: "100+",
      stat_awards: "15+",
      copyright: "© 2026 Sapphire Stay | Muzaffarabad. All rights reserved.",
      facebook: "",
      instagram: "https://instagram.com/sapphire.stay",
      twitter: "",
    };

    for (const [key, value] of Object.entries(configs)) {
      const existing = await ctx.db
        .query("siteConfig")
        .withIndex("by_key", (q) => q.eq("key", key))
        .first();

      if (existing) {
        await ctx.db.patch(existing._id, { value, createdAt: now });
      } else {
        await ctx.db.insert("siteConfig", { key, value, createdAt: now });
      }
    }

    return {
      galleryImages: galleryUrls.length,
      siteConfig: Object.keys(configs).length,
    };
  },
});
