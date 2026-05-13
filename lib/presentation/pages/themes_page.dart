import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/cubits/store_cubit.dart';
import '../../application/cubits/install_cubit.dart';
import '../../data/repositories/store_repository.dart';
import '../../data/repositories/install_repository.dart';
import '../../domain/models/store_item.dart';
import '../../domain/models/install_state.dart';
import '../widgets/store_grid_card.dart';
import '../widgets/shared_widgets.dart';
import '../views/theme_detail_view.dart';

class ThemesPage extends StatelessWidget {
  const ThemesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          StoreCubit(StoreRepository(), StoreItemType.theme)..load(),
      child: const _ThemesView(),
    );
  }
}

class _ThemesView extends StatelessWidget {
  const _ThemesView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        if (state is StoreLoading) return const LoadingGrid();
        if (state is StoreError) {
          return ErrorView(
            message: state.message,
            onRetry: () => context.read<StoreCubit>().load(),
          );
        }
        if (state is StoreLoaded) {
          if (state.items.isEmpty) return const EmptyView();
          return _ThemeGrid(items: state.items);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ThemeGrid extends StatelessWidget {
  final List<StoreItem> items;
  const _ThemeGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => BlocProvider(
        key: ValueKey(items[i].name),
        create: (_) =>
            InstallCubit(InstallRepository(), items[i])..checkStatus(),
        child: _ThemeCardWrapper(item: items[i]),
      ),
    );
  }
}

class _ThemeCardWrapper extends StatelessWidget {
  final StoreItem item;
  const _ThemeCardWrapper({required this.item});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstallCubit, InstallState>(
      builder: (context, installState) => StoreGridCard(
        item: item,
        installState: installState,
        onInstall: () => context.read<InstallCubit>().install(),
        onTap: () => Navigator.of(context)
            .push(slideRoute(ThemeDetailView(item: item))),
      ),
    );
  }
}
