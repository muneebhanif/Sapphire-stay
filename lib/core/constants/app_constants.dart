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

  // ── Local media assets (fallback when DB has none) ──
  static const String heroImage =
      'assets/imgs/banner.jpeg';
  static const String hotelExterior =
      'assets/imgs/turf.jpeg';
  static const String hotelLobby =
      'assets/imgs/room.jpeg';
  static const String hotelPool =
      'assets/imgs/balcony.jpeg';
  static const String hotelRestaurant =
      'assets/imgs/room5.jpeg';
  static const String hotelSpa =
      'assets/imgs/bathroom.jpeg';
  static const String roomStandard =
      'assets/imgs/room1.jpeg';
  static const String roomDeluxe =
      'assets/imgs/room2.jpeg';
  static const String roomSuite =
      'assets/imgs/room3.jpeg';
  static const String roomPresidential =
      'assets/imgs/room6.jpeg';
}