import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../application/cubits/install_cubit.dart';
import '../../data/repositories/install_repository.dart';
import '../../domain/models/store_item.dart';
import '../../domain/models/install_state.dart';
import '../widgets/shared_widgets.dart';
import 'package:vecostore/core/colors/vaxp_colors.dart';

class ThemeDetailView extends StatelessWidget {
  final StoreItem item;
  const ThemeDetailView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InstallCubit(InstallRepository(), item)..checkStatus(),
      child: _ThemeDetailBody(item: item),
    );
  }
}

class _ThemeDetailBody extends StatelessWidget {
  final StoreItem item;
  const _ThemeDetailBody({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(210, 10, 10, 15),
      body: Column(
        children: [
          DetailTitlebar(title: item.displayName),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Theme header with preview ──────────────
                  _ThemeHeader(item: item),
                  const SizedBox(height: 24),

                  // ── Description ───────────────────────────
                  if (item.description.isNotEmpty) ...[
                    SectionLabel('Description'),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.7,
                        color: VaxpColors.defaultText.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Screenshots ───────────────────────────
                  if (item.screenshots.isNotEmpty) ...[
                    SectionLabel('Theme Preview'),
                    const SizedBox(height: 12),
                    ScreenshotCarousel(urls: item.screenshots),
                    const SizedBox(height: 24),
                  ],

                  // ── Bundle section (unique to themes) ─────
                  if (item.bundledPlugins.isNotEmpty ||
                      item.bundledWidgets.isNotEmpty) ...[
                    _BundleSection(item: item),
                    const SizedBox(height: 24),
                  ],

                  // ── Changelog ─────────────────────────────
                  if (item.updateInfo?.changelog.isNotEmpty == true) ...[
                    SectionLabel('Changelog'),
                    const SizedBox(height: 8),
                    ChangelogCard(changelog: item.updateInfo!.changelog),
                    const SizedBox(height: 24),
                  ],

                  // ── Install button ────────────────────────
                  BlocBuilder<InstallCubit, InstallState>(
                    builder: (context, state) => DetailInstallButton(
                      item: item,
                      state: state,
                      onInstall: () =>
                          context.read<InstallCubit>().install(),
                      onRetry: () => context.read<InstallCubit>().retry(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Theme header with large preview image ────────────────
class _ThemeHeader extends StatelessWidget {
  final StoreItem item;
  const _ThemeHeader({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: VaxpColors.defaultText.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: VaxpColors.defaultText.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview image at top
              if (item.iconUrl != null && item.iconUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: CachedNetworkImage(
                    imageUrl: item.iconUrl!,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 160,
                      color: VaxpColors.defaultText.withValues(alpha: 0.05),
                      child: Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 1.5, color: VaxpColors.defaultText.withValues(alpha: 0.24)),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 160,
                      color: VaxpColors.defaultText.withValues(alpha: 0.04),
                      child: Center(
                        child: Icon(Icons.palette_outlined,
                            size: 48,
                            color: VaxpColors.defaultText.withValues(alpha: 0.15)),
                      ),
                    ),
                  ),
                ),

              // Name + meta below image
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: VaxpColors.defaultText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(item.author,
                        style: TextStyle(
                            fontSize: 12,
                            color: VaxpColors.defaultText.withValues(alpha: 0.4))),
                    if (item.updateInfo != null) ...[
                      const SizedBox(height: 8),
                      PillChip(
                          'v${item.updateInfo!.version}',
                          const Color(0xFF7AB3FF)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bundle section ───────────────────────────────────────
class _BundleSection extends StatelessWidget {
  final StoreItem item;
  const _BundleSection({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: VaxpColors.defaultText.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: VaxpColors.defaultText.withValues(alpha: 0.09)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 14, color: VaxpColors.defaultText.withValues(alpha: 0.5)),
                  const SizedBox(width: 6),
                  Text('Bundle Contents',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: VaxpColors.defaultText)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Automatically installed with the theme',
                  style: TextStyle(
                      fontSize: 11,
                      color: VaxpColors.defaultText.withValues(alpha: 0.35))),

              if (item.bundledPlugins.isNotEmpty) ...[
                const SizedBox(height: 14),
                _BundleGroup(
                  label: 'Plugins',
                  icon: Icons.extension_rounded,
                  color: const Color(0xFFB39DFF),
                  items: item.bundledPlugins,
                  type: StoreItemType.plugin,
                ),
              ],

              if (item.bundledWidgets.isNotEmpty) ...[
                const SizedBox(height: 12),
                _BundleGroup(
                  label: 'Widgets',
                  icon: Icons.widgets_rounded,
                  color: const Color(0xFF80CBC4),
                  items: item.bundledWidgets,
                  type: StoreItemType.widget_,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BundleGroup extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final List<BundledItem> items;
  final StoreItemType type;

  const _BundleGroup({
    required this.label,
    required this.icon,
    required this.color,
    required this.items,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color.withValues(alpha: 0.7)),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((n) => _BundleChip(name: n.name, color: color, type: type))
              .toList(),
        ),
      ],
    );
  }
}

class _BundleChip extends StatefulWidget {
  final String name;
  final Color color;
  final StoreItemType type;

  const _BundleChip(
      {required this.name, required this.color, required this.type});

  @override
  State<_BundleChip> createState() => _BundleChipState();
}

class _BundleChipState extends State<_BundleChip> {
  bool _installed = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  void _check() {
    final installed =
        InstallRepository().isAetherItemInstalled(widget.type, widget.name);
    if (mounted) setState(() => _installed = installed);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _installed ? Icons.check_rounded : Icons.download_outlined,
            size: 11,
            color: _installed
                ? Colors.greenAccent.shade400
                : widget.color.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 5),
          Text(widget.name,
              style: TextStyle(
                  fontSize: 11,
                  color: widget.color.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
