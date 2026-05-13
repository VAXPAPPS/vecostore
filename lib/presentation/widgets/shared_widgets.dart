/// Shared UI components for the store pages
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/install_state.dart';
import '../../domain/models/store_item.dart';

// ─── Page route helper ────────────────────────────────────
PageRoute slideRoute(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );

// ─── Loading skeleton grid ────────────────────────────────
class LoadingGrid extends StatelessWidget {
  const LoadingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => const SkeletonCard(),
    );
  }
}

class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween(begin: 0.04, end: 0.1).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _anim.value),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 48, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text('Connection Error',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.35))),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty view ───────────────────────────────────────────
class EmptyView extends StatelessWidget {
  const EmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined,
              size: 48, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 12),
          Text('No content available',
              style: TextStyle(
                  fontSize: 15, color: Colors.white.withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.3,
      ),
    );
  }
}

// ─── Pill chip ────────────────────────────────────────────
class PillChip extends StatelessWidget {
  final String label;
  final Color color;
  const PillChip(this.label, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

// ─── Large icon ───────────────────────────────────────────
class LargeIcon extends StatelessWidget {
  final String? iconUrl;
  final double size;
  const LargeIcon({super.key, this.iconUrl, this.size = 80});

  @override
  Widget build(BuildContext context) {
    if (iconUrl == null || iconUrl!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(size * 0.22),
        ),
        child: Icon(Icons.apps_rounded,
            size: size * 0.5, color: Colors.white.withValues(alpha: 0.3)),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: CachedNetworkImage(
        imageUrl: iconUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: size,
          height: size,
          color: Colors.white.withValues(alpha: 0.08),
          child: const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: Colors.white38)),
        ),
        errorWidget: (_, __, ___) => Container(
          width: size,
          height: size,
          color: Colors.white.withValues(alpha: 0.08),
          child: Icon(Icons.broken_image_outlined,
              color: Colors.white.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}

// ─── Screenshot carousel ──────────────────────────────────
class ScreenshotCarousel extends StatelessWidget {
  final List<String> urls;
  const ScreenshotCarousel({super.key, required this.urls});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: urls[i],
            height: 180,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              width: 280,
              height: 180,
              color: Colors.white.withValues(alpha: 0.06),
              child: const Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: Colors.white38)),
            ),
            errorWidget: (_, __, ___) => Container(
              width: 280,
              height: 180,
              color: Colors.white.withValues(alpha: 0.06),
              child: Icon(Icons.image_not_supported_outlined,
                  color: Colors.white.withValues(alpha: 0.2), size: 36),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Changelog card ───────────────────────────────────────
class ChangelogCard extends StatelessWidget {
  final String changelog;
  const ChangelogCard({super.key, required this.changelog});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Text(
            changelog,
            style: TextStyle(
              fontSize: 12,
              height: 1.8,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Detail titlebar ──────────────────────────────────────
class DetailTitlebar extends StatelessWidget {
  final String title;
  const DetailTitlebar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_new_rounded,
                        size: 11,
                        color: Colors.white.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text('Back',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 72),
        ],
      ),
    );
  }
}

// ─── Large install button ─────────────────────────────────
class DetailInstallButton extends StatelessWidget {
  final StoreItem item;
  final InstallState state;
  final VoidCallback onInstall;
  final VoidCallback onRetry;

  const DetailInstallButton({
    super.key,
    required this.item,
    required this.state,
    required this.onInstall,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (item.updateInfo == null) {
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: Colors.white38)),
        ),
      );
    }

    if (state.status == InstallStatus.downloading) {
      return Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: LinearProgressIndicator(
            value: state.progress,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            color: const Color(0xFF7AB3FF),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Downloading... ${(state.progress * 100).toStringAsFixed(0)}%',
          style: TextStyle(
              fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
        ),
      ]);
    }

    if (state.status == InstallStatus.error) {
      return Column(children: [
        Text(state.errorMessage ?? 'An error occurred',
            style: const TextStyle(fontSize: 12, color: Colors.redAccent),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        BigButton(
          label: 'Retry',
          icon: Icons.refresh,
          color: Colors.redAccent,
          onTap: onRetry,
        ),
      ]);
    }

    final isInstalled = state.status == InstallStatus.installed;
    final hasUpdate = state.status == InstallStatus.updateAvailable;

    if (isInstalled && !hasUpdate) {
      return BigButton(
        label: 'Installed  ✓  v${state.installedVersion}',
        icon: Icons.check_circle_outline,
        color: Colors.greenAccent.shade400,
        onTap: null,
      );
    }

    return BigButton(
      label: hasUpdate
          ? 'Update to v${item.updateInfo!.version}'
          : 'Install',
      icon: hasUpdate
          ? Icons.system_update_outlined
          : Icons.download_outlined,
      color: const Color(0xFF7AB3FF),
      onTap: onInstall,
    );
  }
}

class BigButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const BigButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  State<BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<BigButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return MouseRegion(
      cursor:
          disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            color: disabled
                ? Colors.white.withValues(alpha: 0.06)
                : _hovered
                    ? widget.color.withValues(alpha: 0.25)
                    : widget.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: disabled
                  ? Colors.white.withValues(alpha: 0.1)
                  : widget.color.withValues(alpha: 0.4),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 18, color: widget.color),
                const SizedBox(width: 8),
                Text(widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.color,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
