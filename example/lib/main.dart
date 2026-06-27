import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/image_demo_page.dart';
import 'pages/ui_demo_page.dart';
import 'pages/api_demo_page.dart';

void main() {
  runApp(const RawMagnifierPlusApp());
}

/// ─── App ──────────────────────────────────────────────────────────────────

class RawMagnifierPlusApp extends StatelessWidget {
  const RawMagnifierPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'raw_magnifier_plus',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const DemoShell(),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF7C4DFF),
        onPrimary: Colors.white,
        secondary: const Color(0xFF00E5FF),
        onSecondary: Colors.black,
        tertiary: const Color(0xFFFF6B9D),
        surface: const Color(0xFF1A1A2E),
        onSurface: Colors.white,
        surfaceContainerHighest: const Color(0xFF16213E),
        outline: const Color(0xFF2D2D4E),
      ),
      scaffoldBackgroundColor: const Color(0xFF0D0D1A),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF12121F),
        indicatorColor: const Color(0xFF7C4DFF).withAlpha(51),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
            color: states.contains(WidgetState.selected)
                ? const Color(0xFF7C4DFF)
                : Colors.white54,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? const Color(0xFF7C4DFF)
                : Colors.white38,
          );
        }),
      ),
    );
  }
}

/// ─── Shell ────────────────────────────────────────────────────────────────

class DemoShell extends StatefulWidget {
  const DemoShell({super.key});

  @override
  State<DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<DemoShell> {
  int _selectedIndex = 0;

  static const _pages = [
    ImageDemoPage(),
    UIDemoPage(),
    ApiDemoPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onSelect: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex, required this.onSelect});
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12121F),
        border: Border(
          top: BorderSide(
            color: Colors.white.withAlpha(15),
            width: 0.5,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelect,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.photo_outlined),
            selectedIcon: Icon(Icons.photo),
            label: 'Image',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'UI',
          ),
          NavigationDestination(
            icon: Icon(Icons.code_rounded),
            selectedIcon: Icon(Icons.code_rounded),
            label: 'Raw API',
          ),
        ],
      ),
    );
  }
}
