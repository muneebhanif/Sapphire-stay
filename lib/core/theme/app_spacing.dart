/// Spacing & sizing constants.
///
/// Uses a 4px base grid for consistency. Every spacing value
/// is a multiple of 4 to maintain visual rhythm.
///
/// Naming convention follows t-shirt sizing for readability.
abstract final class AppSpacing {
  // ─── Base Unit ───────────────────────────────────────────────────
  static const double unit = 4.0;

  // ─── Spacing Scale ───────────────────────────────────────────────
  static const double xxs = 4.0;   //  1 unit
  static const double xs  = 8.0;   //  2 units
  static const double sm  = 12.0;  //  3 units
  static const double md  = 16.0;  //  4 units
  static const double lg  = 24.0;  //  6 units
  static const double xl  = 32.0;  //  8 units
  static const double xxl = 48.0;  // 12 units
  static const double xxxl = 64.0; // 16 units

  // ─── Page Padding ────────────────────────────────────────────────
  static const double pagePaddingMobile  = 16.0;
  static const double pagePaddingTablet  = 32.0;
  static const double pagePaddingDesktop = 64.0;

  // ─── Content Max Width ───────────────────────────────────────────
  static const double maxContentWidth = 1200.0;
  static const double maxFormWidth    = 560.0;
  static const double maxCardWidth    = 380.0;

  // ─── Border Radius ──────────────────────────────────────────────
  static const double radiusSm  = 4.0;
  static const double radiusMd  = 8.0;
  static const double radiusLg  = 12.0;
  static const double radiusXl  = 16.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0;

  // ─── Sidebar / Navigation ───────────────────────────────────────
  static const double sidebarWidth         = 260.0;
  static const double sidebarCollapsedWidth = 72.0;
  static const double navBarHeight         = 72.0;
  static const double footerHeight         = 320.0;

  // ─── Card Sizes ──────────────────────────────────────────────────
  static const double cardElevation = 2.0;
  static const double cardImageHeight = 200.0;

  // ─── Icon Sizes ──────────────────────────────────────────────────
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
}
