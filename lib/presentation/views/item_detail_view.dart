import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/cubits/install_cubit.dart';
import '../../data/repositories/install_repository.dart';
import '../../domain/models/store_item.dart';
import '../../domain/models/install_state.dart';
import '../widgets/shared_widgets.dart';

class ItemDetailView extends StatelessWidget {
  final StoreItem item;
  const ItemDetailView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InstallCubit(InstallRepository(), item)..checkStatus(),
      child: _DetailBody(item: item),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final StoreItem item;
  const _DetailBody({required this.item});

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
                  // ── Header ────────────────────────────────
                  _DetailHeader(item: item),
                  const SizedBox(height: 24),

                  // ── Description ───────────────────────────
                  if (item.description.isNotEmpty) ...[
                    const SectionLabel('Description'),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.7,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Screenshots ───────────────────────────
                  if (item.screenshots.isNotEmpty) ...[
                    const SectionLabel('Screenshots'),
                    const SizedBox(height: 12),
                    ScreenshotCarousel(urls: item.screenshots),
                    const SizedBox(height: 24),
                  ],

                  // ── Changelog ─────────────────────────────
                  if (item.updateInfo?.changelog.isNotEmpty == true) ...[
                    const SectionLabel('Changelog'),
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

// ─── Header ───────────────────────────────────────────────
class _DetailHeader extends StatelessWidget {
  final StoreItem item;
  const _DetailHeader({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              LargeIcon(iconUrl: item.iconUrl),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayName,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(item.author,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5))),
                    if (item.updateInfo != null) ...[
                      const SizedBox(height: 6),
                      PillChip(
                          'v${item.updateInfo!.version}',
                          const Color(0xFF7AB3FF)),
                    ],
                    if (item.category != null) ...[
                      const SizedBox(height: 4),
                      PillChip(
                          item.category!,
                          Colors.white.withValues(alpha: 0.3)),
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
