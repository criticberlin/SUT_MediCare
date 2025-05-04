import 'package:flutter/material.dart';
import '../utils/theme/light_mode_theme.dart';

/// A scaffold wrapper that forces light mode regardless of system theme
/// Use this for screens that should always be in light mode
class LightModeScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Widget? drawer;
  final Widget? endDrawer;

  const LightModeScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawer,
    this.endDrawer,
  });

  @override
  Widget build(BuildContext context) {
    // Force light theme using Theme widget
    return Theme(
      data: LightModeTheme.theme,
      child: Scaffold(
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        backgroundColor: backgroundColor ?? LightModeTheme.backgroundColor,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        drawer: drawer,
        endDrawer: endDrawer,
      ),
    );
  }
} 