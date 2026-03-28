/// Application-wide constants.
///
/// These serve as FALLBACK defaults only. All dynamic content
/// should come from the database via siteConfigProvider.
/// These constants are used when the DB value is not yet loaded
/// or when a DB entry doesn't exist.
abstract final class AppConstants {
  // ── Branding ──
  static const String appName = 'StaySite';
  static const String hotelName = 'Sapphire Stay Hotel';
  static const String tagline = 'Experience Luxury & Comfort at its Finest';
  static const String copyright =
      '© 2026 Sapphire Stay Hotel. All rights reserved.';

  // ── Contact (fallback) ──
  static const String phone = '+92 300 1234567';
  static const String email = 'info@sapphirestay.com';
  static const String address = 'Main Boulevard, Islamabad, Pakistan';

  // ── Currency ──
  static const double usdToPkrRate = 280.0;

  // ── Stock Image URLs (fallback when DB has none) ──
  static const String heroImage =
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1600&q=80';
  static const String hotelExterior =
      'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=1200&q=80';
  static const String hotelLobby =
      'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=1200&q=80';
  static const String hotelPool =
      'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200&q=80';
  static const String hotelRestaurant =
      'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=1200&q=80';
  static const String hotelSpa =
      'https://images.unsplash.com/photo-1540555700478-4be289fbec6d?w=1200&q=80';
  static const String roomStandard =
      'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=1200&q=80';
  static const String roomDeluxe =
      'https://images.unsplash.com/photo-1631049552057-403cdb8f0658?w=1200&q=80';
  static const String roomSuite =
      'https://images.unsplash.com/photo-1590490360182-c33d82de0e5c?w=1200&q=80';
  static const String roomPresidential =
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=1200&q=80';
}