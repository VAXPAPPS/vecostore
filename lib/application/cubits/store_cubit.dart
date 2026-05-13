import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/store_repository.dart';
import '../../domain/models/store_item.dart';

// ─── States ───────────────────────────────────────────────
abstract class StoreState {}

class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

class StoreLoaded extends StoreState {
  final List<StoreItem> items;
  StoreLoaded(this.items);
}

class StoreError extends StoreState {
  final String message;
  StoreError(this.message);
}

// ─── Cubit ────────────────────────────────────────────────
class StoreCubit extends Cubit<StoreState> {
  final StoreRepository _repository;
  final StoreItemType type;

  StoreCubit(this._repository, this.type) : super(StoreInitial());

  Future<void> load() async {
    emit(StoreLoading());
    try {
      final items = await _repository.fetchItems(type);
      emit(StoreLoaded(List.from(items)));
      _fetchUpdateInfosInBackground(items);
    } catch (e) {
      emit(StoreError(e.toString()));
    }
  }

  Future<void> refresh() => load();

  /// يجلب update.json لكل عنصر في الخلفية ويحدّث القائمة تدريجياً
  Future<void> _fetchUpdateInfosInBackground(List<StoreItem> items) async {
    for (final item in items) {
      if (item.updateJsonUrl.isEmpty) continue;
      try {
        final info = await _repository.fetchUpdateInfo(item.updateJsonUrl);
        item.updateInfo = info;
        if (state is StoreLoaded && !isClosed) {
          emit(StoreLoaded(List.from((state as StoreLoaded).items)));
        }
      } catch (_) {
        // تجاهل فشل أي عنصر منفرد
      }
    }
  }
}
