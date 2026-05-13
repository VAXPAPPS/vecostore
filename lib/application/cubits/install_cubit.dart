import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/install_repository.dart';
import '../../domain/models/install_state.dart';
import '../../domain/models/store_item.dart';
import '../../data/repositories/store_repository.dart';

class InstallCubit extends Cubit<InstallState> {
  final InstallRepository _repo;
  final StoreItem item;

  InstallCubit(this._repo, this.item)
      : super(const InstallState.initial());

  String get _prefKey => 'installed_version_${item.package}';

  /// فحص حالة التثبيت عند فتح الصفحة
  Future<void> checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? installedVersion = prefs.getString(_prefKey);

    // للتطبيقات: فحص فعلي عبر dpkg
    if (item.type == StoreItemType.app && installedVersion == null) {
      installedVersion = await _repo.getInstalledVersion(item.package);
      if (installedVersion != null) {
        await prefs.setString(_prefKey, installedVersion);
      }
    }

    // للثيمات/الإضافات/الودجتس: فحص وجود المجلد
    if (item.type != StoreItemType.app && installedVersion == null) {
      if (_repo.isAetherItemInstalled(item.type, item.name)) {
        installedVersion = item.updateInfo?.version ?? '0.1.0';
        await prefs.setString(_prefKey, installedVersion);
      }
    }

    if (installedVersion == null) {
      emit(const InstallState(status: InstallStatus.notInstalled));
      return;
    }

    final latest = item.updateInfo?.version;
    if (latest != null && latest != installedVersion) {
      emit(InstallState(
        status: InstallStatus.updateAvailable,
        installedVersion: installedVersion,
      ));
    } else {
      emit(InstallState(
        status: InstallStatus.installed,
        installedVersion: installedVersion,
      ));
    }
  }

  /// تنفيذ التثبيت أو التحديث
  Future<void> install() async {
    final updateInfo = item.updateInfo;
    if (updateInfo == null || updateInfo.url.isEmpty) return;

    emit(const InstallState(status: InstallStatus.downloading, progress: 0.0));

    try {
      // 1. Install the main item
      await _repo.downloadAndInstall(
        item: item,
        updateInfo: updateInfo,
        onProgress: (p) {
          if (!isClosed) {
            emit(InstallState(status: InstallStatus.downloading, progress: p));
          }
        },
        onSuccess: () {},
        onError: (e) => throw Exception(e),
      );

      // 2. Install bundled plugins and widgets if it's a theme
      if (item.type == StoreItemType.theme) {
        final storeRepo = StoreRepository();
        
        // Helper function for bundles
        Future<void> installBundle(List<BundledItem> bundle, StoreItemType type) async {
          for (final b in bundle) {
            if (b.updateJsonUrl.isEmpty) continue;
            try {
              final info = await storeRepo.fetchUpdateInfo(b.updateJsonUrl);
              // Create a dummy StoreItem just for installation
              final dummyItem = StoreItem(
                name: b.name,
                package: b.name,
                displayName: b.name,
                description: '',
                updateJsonUrl: b.updateJsonUrl,
                type: type,
              );
              await _repo.downloadAndInstall(
                item: dummyItem,
                updateInfo: info,
                onProgress: (_) {}, // Could update UI if desired
                onSuccess: () {},
                onError: (e) => throw Exception(e),
              );
            } catch (_) {
              // Ignore individual bundle failures so main install succeeds
            }
          }
        }

        await installBundle(item.bundledPlugins, StoreItemType.plugin);
        await installBundle(item.bundledWidgets, StoreItemType.widget_);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, updateInfo.version);
      if (!isClosed) {
        emit(InstallState(
          status: InstallStatus.installed,
          installedVersion: updateInfo.version,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(InstallState(status: InstallStatus.error, errorMessage: e.toString()));
      }
    }
  }

  void retry() => install();
}
