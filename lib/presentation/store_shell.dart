import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:venom_config/venom_config.dart';
import '/../presentation/pages/apps_page.dart';
import '/../presentation/pages/themes_page.dart';
import '/../presentation/pages/plugins_page.dart';
import '/../presentation/pages/widgets_page.dart';

// ─── Tab model ────────────────────────────────────────────
class _StoreTab {
  final IconData icon;
  final String label;
  const _StoreTab(this.icon, this.label);
}

const _tabs = [
  _StoreTab(Icons.apps_rounded, 'Apps'),
  _StoreTab(Icons.palette_rounded, 'Themes'),
  _StoreTab(Icons.extension_rounded, 'Plugins'),
  _StoreTab(Icons.widgets_rounded, 'Widgets'),
];

// ─── StoreShell ───────────────────────────────────────────
class StoreShell extends StatefulWidget {
  const StoreShell({super.key});

  @override
  State<StoreShell> createState() => _StoreShellState();
}

class _StoreShellState extends State<StoreShell> {
  int _selectedTab = 0;
  bool _titlebarHovered = false;
  Color _backgroundColor = const Color.fromARGB(100, 0, 0, 0);
  Color _textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadConfig(VenomConfig().getAll());
    VenomConfig().onConfigChanged.listen(_loadConfig);
  }

  void _loadConfig(Map<String, dynamic> config) {
    if (!mounted) return;
    setState(() {
      final bg = config['system.background_color'] as String?;
      final tx = config['system.text_color'] as String?;
      if (bg != null) _backgroundColor = _parseColor(bg);
      if (tx != null) _textColor = _parseColor(tx);
    });
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 3) hex = hex.split('').map((c) => '$c$c').join();
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    return const Color.fromARGB(100, 0, 0, 0);
  }

  Widget _currentPage() => switch (_selectedTab) {
        0 => const AppsPage(),
        1 => const ThemesPage(),
        2 => const PluginsPage(),
        3 => const WidgetsPage(),
        _ => const AppsPage(),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // ── Content with blur when titlebar is hovered ──
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _titlebarHovered ? 8.0 : 0.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (_, blur, child) => ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: child,
            ),
            child: Container(
              margin: const EdgeInsets.only(top: 42),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: KeyedSubtree(
                  key: ValueKey(_selectedTab),
                  child: _currentPage(),
                ),
              ),
            ),
          ),

          // ── Custom Titlebar ──────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _StoreTitlebar(
              selectedTab: _selectedTab,
              textColor: _textColor,
              onTabSelected: (i) => setState(() => _selectedTab = i),
              onHoverEnter: () => setState(() => _titlebarHovered = true),
              onHoverExit: () => setState(() => _titlebarHovered = false),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Titlebar with tabs ────────────────────────────
class _StoreTitlebar extends StatelessWidget {
  final int selectedTab;
  final Color textColor;
  final void Function(int) onTabSelected;
  final VoidCallback onHoverEnter;
  final VoidCallback onHoverExit;

  const _StoreTitlebar({
    required this.selectedTab,
    required this.textColor,
    required this.onTabSelected,
    required this.onHoverEnter,
    required this.onHoverExit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // App title
            Text(
              'Vaxp Ecosystem Store',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: 16),

            // ── Tab pills ──────────────────────────────────
            Expanded(
              child: Center(
                child: _TabStrip(
                  selectedTab: selectedTab,
                  textColor: textColor,
                  onTabSelected: onTabSelected,
                ),
              ),
            ),

            // ── Window buttons ─────────────────────────────
            MouseRegion(
              onEnter: (_) => onHoverEnter(),
              onExit: (_) => onHoverExit(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.info_outline_rounded, size: 16, color: textColor.withValues(alpha: 0.7)),
                    onPressed: () => _showAboutDialog(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 16,
                  ),
                  const SizedBox(width: 24),
                  _WinBtn(
                    color: const Color(0xFFFFBD2E),
                    icon: Icons.remove,
                    onTap: () => windowManager.minimize(),
                  ),
                  const SizedBox(width: 7),
                  _WinBtn(
                    color: const Color(0xFF28C840),
                    icon: Icons.crop_square_rounded,
                    onTap: () async {
                      if (await windowManager.isMaximized()) {
                        windowManager.unmaximize();
                      } else {
                        windowManager.maximize();
                      }
                    },
                  ),
                  const SizedBox(width: 7),
                  _WinBtn(
                    color: const Color(0xFFFF5F57),
                    icon: Icons.close,
                    onTap: () => windowManager.close(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color.fromARGB(210, 15, 15, 20).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Icon(Icons.storefront_rounded, size: 32, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 16),
                  const Text('VAXP Store', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Version 0.1.0', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                  const SizedBox(height: 16),
                  Text('The official ecosystem store for VAXP organization. Download apps, themes, plugins, and widgets.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, height: 1.5, color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(double.infinity, 36),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tab strip (like VaClocks) ────────────────────────────
class _TabStrip extends StatelessWidget {
  final int selectedTab;
  final Color textColor;
  final void Function(int) onTabSelected;

  const _TabStrip({
    required this.selectedTab,
    required this.textColor,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_tabs.length, (i) => _TabPill(
          tab: _tabs[i],
          isSelected: i == selectedTab,
          textColor: textColor,
          onTap: () => onTabSelected(i),
        )),
      ),
    );
  }
}

class _TabPill extends StatefulWidget {
  final _StoreTab tab;
  final bool isSelected;
  final Color textColor;
  final VoidCallback onTap;

  const _TabPill({
    required this.tab,
    required this.isSelected,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_TabPill> createState() => _TabPillState();
}

class _TabPillState extends State<_TabPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isSelected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: active
                ? Colors.white.withValues(alpha: 0.18)
                : _hovered
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.tab.icon,
                size: 13,
                color: active
                    ? widget.textColor
                    : widget.textColor.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 5),
              Text(
                widget.tab.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.w400,
                  color: active
                      ? widget.textColor
                      : widget.textColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Window control button ────────────────────────────────
class _WinBtn extends StatefulWidget {
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _WinBtn({required this.color, required this.icon, required this.onTap});

  @override
  State<_WinBtn> createState() => _WinBtnState();
}

class _WinBtnState extends State<_WinBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.7),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: _hovered ? 1.0 : 0.0,
              child: Icon(widget.icon, size: 9,
                  color: Colors.black.withValues(alpha: 0.7)),
            ),
          ),
        ),
      ),
    );
  }
}
