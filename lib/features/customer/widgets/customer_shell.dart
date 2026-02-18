import 'package:flutter/material.dart';

import 'customer_nav_bar.dart';
import 'footer.dart';

/// Shell layout for all customer-facing pages.
///
/// Wraps every customer route with:
///   • Persistent top navigation bar
///   • Scrollable content area
///   • Consistent footer
///   • Mobile drawer (via [endDrawer])
class CustomerShell extends StatelessWidget {
  final Widget child;

  const CustomerShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const CustomerDrawer(),
      body: Column(
        children: [
          // ── Fixed Nav Bar ──
          const CustomerNavBar(),

          // ── Scrollable Content + Footer ──
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  child,
                  const CustomerFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
