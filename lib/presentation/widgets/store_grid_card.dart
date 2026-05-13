import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/store_item.dart';
import '../../domain/models/install_state.dart';

/// بطاقة عنصر في الـ Grid
class StoreGridCard extends StatefulWidget {
  final StoreItem item;
  final InstallState installState;
  final VoidCallback onInstall;
  final VoidCallback onTap;

  const StoreGridCard({
    super.key,
    required this.item,
    required this.installState,
    required this.onInstall,
    required this.onTap,
  });

  @override
  State<StoreGridCard> createState() => _StoreGridCardState();
}

class _StoreGridCardState extends State<StoreGridCard> {
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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: _hovered
              ? (Matrix4.identity()..translateByDouble(0, -3, 0, 1))
              : Matrix4.identity(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _hovered
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _hovered
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                  boxShadow: _hovered
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Icon ──────────────────────────────
                      _ItemIcon(iconUrl: widget.item.iconUrl),
                      const SizedBox(height: 12),

                      // ── Name ──────────────────────────────
                      Text(
                        widget.item.displayName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // ── Description ───────────────────────
                      Text(
                        widget.item.description.isEmpty
                            ? widget.item.name
                            : widget.item.description,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.55),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Version badge ─────────────────────
                      if (widget.item.updateInfo != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'v${widget.item.updateInfo!.version}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                        ),

                      // ── Install button ────────────────────
                      _CardInstallButton(
                        state: widget.installState,
                        onInstall: widget.onInstall,
                        hasUpdateInfo: widget.item.updateInfo != null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Icon widget ──────────────────────────────────────────
class _ItemIcon extends StatelessWidget {
  final String? iconUrl;
  const _ItemIcon({this.iconUrl});

  @override
  Widget build(BuildContext context) {
    if (iconUrl == null || iconUrl!.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.apps_rounded,
          size: 30,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: CachedNetworkImage(
        imageUrl: iconUrl!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: 60,
          height: 60,
          color: Colors.white.withValues(alpha: 0.08),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: Colors.white54,
              ),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}

// ─── Small install button for card ────────────────────────
class _CardInstallButton extends StatelessWidget {
  final InstallState state;
  final VoidCallback onInstall;
  final bool hasUpdateInfo;

  const _CardInstallButton({
    required this.state,
    required this.onInstall,
    required this.hasUpdateInfo,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == InstallStatus.downloading) {
      return SizedBox(
        height: 4,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: state.progress,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            color: const Color(0xFF7AB3FF),
          ),
        ),
      );
    }

    if (!hasUpdateInfo) {
      return SizedBox(
        height: 28,
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      );
    }

    final (label, color, icon) = switch (state.status) {
      InstallStatus.installed => (
        'Installed ✓',
        Colors.white.withValues(alpha: 0.15),
        Icons.check_circle_outline,
      ),
      InstallStatus.updateAvailable => (
        'Update',
        const Color(0xFF7AB3FF),
        Icons.system_update_outlined,
      ),
      InstallStatus.error => (
        'Error ↺',
        Colors.redAccent.withValues(alpha: 0.7),
        Icons.refresh,
      ),
      _ => ('Install', const Color(0xFF7AB3FF), Icons.download_outlined),
    };

    return GestureDetector(
      onTap: state.status == InstallStatus.installed ? null : onInstall,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 28,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
