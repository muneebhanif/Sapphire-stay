/// StaySite — Sapphire Stay Hotel Management System
///
/// Entry point for the Flutter Web application.
/// Architecture: Feature-based Clean Architecture with Riverpod.
///
/// Module breakdown:
///   • Customer (public)  — Browse rooms, book, gallery, contact
///   • Staff (restricted)  — Reception operations, check-in/out, invoicing
///   • Admin (full access) — Complete hotel management, reports, staff CRUD
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ProviderScope is the root of all Riverpod providers.
  // This makes every provider accessible throughout the widget tree
  // without depending on BuildContext.
  runApp(
    const ProviderScope(
      child: StaySiteApp(),
    ),
  );
}
