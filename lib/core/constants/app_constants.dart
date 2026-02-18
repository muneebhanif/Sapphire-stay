/// Application-wide constants.
///
/// Centralizes magic strings, URLs, and configuration values
/// to ensure single-source-of-truth and easy maintenance.
abstract final class AppConstants {
  // ─── App Info ────────────────────────────────────────────────────
  static const String appName = 'StaySite';
  static const String hotelName = 'Sapphire Stay Hotel';
  static const String tagline = 'Where Luxury Meets Comfort';
  static const String copyright = '© 2026 Sapphire Stay Hotel. All rights reserved.';

  // ─── API (placeholder — backend team will configure) ─────────────
  static const String baseUrl = 'https://api.staysite.com/v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // ─── Assets Paths ────────────────────────────────────────────────
  static const String imagesPath = 'assets/images';
  static const String iconsPath = 'assets/icons';

  // ─── Placeholder Images (from Unsplash — royalty-free) ──────────
  static const String heroImage =
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1920&q=80';
  static const String hotelExterior =
      'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=1200&q=80';
  static const String hotelLobby =
      'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200&q=80';
  static const String hotelPool =
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=1200&q=80';
  static const String hotelRestaurant =
      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=1200&q=80';
  static const String hotelSpa =
      'https://images.unsplash.com/photo-1540555700478-4be289fbec6d?w=1200&q=80';

  // Room type placeholders
  static const String roomStandard =
      'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80';
  static const String roomDeluxe =
      'https://images.unsplash.com/photo-1590490360182-c33d955c3795?w=800&q=80';
  static const String roomSuite =
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80';
  static const String roomPresidential =
      'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80';

  // ─── Contact Info ────────────────────────────────────────────────
  static const String phone = '+1 (555) 123-4567';
  static const String email = 'info@sapphirestay.com';
  static const String address = '123 Ocean Boulevard, Coastal City, CS 90210';

  // ─── Social Links ───────────────────────────────────────────────
  static const String facebook = 'https://facebook.com/sapphirestay';
  static const String instagram = 'https://instagram.com/sapphirestay';
  static const String twitter = 'https://twitter.com/sapphirestay';

  // ─── Animation Durations ────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
}
