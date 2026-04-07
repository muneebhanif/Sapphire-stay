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
      { url: "assets/imgs/turf.jpeg", caption: "Hotel Exterior" },
      { url: "assets/imgs/room.jpeg", caption: "Grand Lobby" },
      { url: "assets/imgs/balcony.jpeg", caption: "Infinity Pool" },
      { url: "assets/imgs/room5.jpeg", caption: "Restaurant" },
      { url: "assets/imgs/bathroom.jpeg", caption: "Spa & Wellness Center" },
      { url: "assets/imgs/room1.jpeg", caption: "Standard Room" },
      { url: "assets/imgs/room2.jpeg", caption: "Deluxe Room" },
      { url: "assets/imgs/room3.jpeg", caption: "Sapphire Suite" },
      { url: "assets/imgs/room6.jpeg", caption: "Presidential Suite" },
      { url: "assets/imgs/banner.jpeg", caption: "Hotel Banner" },
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
      { key: "hotel_name", value: "Sapphire Stay Hotel" },
      { key: "tagline", value: "Where Luxury Meets Comfort" },
      { key: "phone", value: "+1 (555) 123-4567" },
      { key: "email", value: "info@sapphirestay.com" },
      { key: "address", value: "123 Ocean Boulevard, Coastal City, CS 90210" },
      { key: "hero_image", value: "assets/imgs/banner.jpeg" },
      { key: "hotel_exterior", value: "assets/imgs/turf.jpeg" },
      { key: "hotel_lobby", value: "assets/imgs/room.jpeg" },
      { key: "hotel_pool", value: "assets/imgs/balcony.jpeg" },
      { key: "hotel_restaurant", value: "assets/imgs/room5.jpeg" },
      { key: "hotel_spa", value: "assets/imgs/bathroom.jpeg" },
      { key: "stat_years", value: "25+" },
      { key: "stat_guests", value: "50K+" },
      { key: "stat_staff", value: "100+" },
      { key: "stat_awards", value: "15+" },
      { key: "copyright", value: "© 2026 Sapphire Stay Hotel. All rights reserved." },
      { key: "facebook", value: "https://facebook.com/sapphirestay" },
      { key: "instagram", value: "https://instagram.com/sapphirestay" },
      { key: "twitter", value: "https://twitter.com/sapphirestay" },
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
