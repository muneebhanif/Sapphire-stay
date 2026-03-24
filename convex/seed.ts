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
      imageUrls: ["https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80"],
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
      imageUrls: ["https://images.unsplash.com/photo-1590490360182-c33d955c3795?w=800&q=80"],
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
      imageUrls: ["https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80"],
      createdAt: Date.now(),
    });

    return { customerId, staffId, adminId, roomId };
  },
});

export const seedGallery = mutation({
  args: {},
  handler: async (ctx) => {
    const images = [
      { url: "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=1200&q=80", caption: "Hotel Exterior" },
      { url: "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200&q=80", caption: "Grand Lobby" },
      { url: "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=1200&q=80", caption: "Infinity Pool" },
      { url: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=1200&q=80", caption: "Fine Dining Restaurant" },
      { url: "https://images.unsplash.com/photo-1540555700478-4be289fbec6d?w=1200&q=80", caption: "Spa & Wellness Center" },
      { url: "https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80", caption: "Standard Room" },
      { url: "https://images.unsplash.com/photo-1590490360182-c33d955c3795?w=800&q=80", caption: "Deluxe Room" },
      { url: "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80", caption: "Sapphire Suite" },
      { url: "https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80", caption: "Presidential Suite" },
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

export const seedServices = mutation({
  args: {},
  handler: async (ctx) => {
    const services = [
      { icon: "restaurant", title: "Fine Dining", description: "Award-winning restaurant featuring international cuisine prepared by renowned chefs. Open for breakfast, lunch, and dinner." },
      { icon: "spa", title: "Spa & Wellness", description: "Full-service spa offering massages, facials, body treatments, and a state-of-the-art fitness center." },
      { icon: "pool", title: "Swimming Pool", description: "Heated infinity pool with panoramic ocean views, poolside bar, and dedicated cabanas." },
      { icon: "business", title: "Business Center", description: "Fully equipped business center with meeting rooms, conference facilities, and high-speed internet." },
      { icon: "car", title: "Valet Parking", description: "Complimentary valet parking for all guests. Airport shuttle service available upon request." },
      { icon: "room_service", title: "24/7 Room Service", description: "Round-the-clock in-room dining with an extensive menu. Special dietary requirements accommodated." },
      { icon: "laundry", title: "Laundry Service", description: "Same-day laundry and dry cleaning service. Express service available for urgent needs." },
      { icon: "concierge", title: "Concierge", description: "Expert concierge team to assist with tour bookings, restaurant reservations, and local recommendations." },
    ];
    const now = Date.now();
    for (let i = 0; i < services.length; i++) {
      await ctx.db.insert("hotelServices", {
        icon: services[i].icon,
        title: services[i].title,
        description: services[i].description,
        sortOrder: i,
        createdAt: now,
      });
    }
    return { inserted: services.length };
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
      { key: "hero_image", value: "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1920&q=80" },
      { key: "hotel_exterior", value: "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=1200&q=80" },
      { key: "hotel_lobby", value: "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200&q=80" },
      { key: "hotel_pool", value: "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=1200&q=80" },
      { key: "hotel_restaurant", value: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=1200&q=80" },
      { key: "hotel_spa", value: "https://images.unsplash.com/photo-1540555700478-4be289fbec6d?w=1200&q=80" },
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
