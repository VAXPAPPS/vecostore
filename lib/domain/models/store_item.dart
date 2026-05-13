enum StoreItemType { app, theme, plugin, widget_ }

class UpdateInfo {
  final String version;
  final String url;
  final String changelog;
  final String? installPath;

  const UpdateInfo({
    required this.version,
    required this.url,
    required this.changelog,
    this.installPath,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) => UpdateInfo(
        version: json['version'] as String? ?? '0.0.0',
        url: json['url'] as String? ?? '',
        changelog: json['changelog'] as String? ?? '',
        installPath: json['install_path'] as String?,
      );
}

class BundledItem {
  final String name;
  final String updateJsonUrl;

  BundledItem({required this.name, required this.updateJsonUrl});

  factory BundledItem.fromJson(Map<String, dynamic> json) {
    return BundledItem(
      name: json['name'] as String? ?? '',
      updateJsonUrl: json['update_json'] as String? ?? '',
    );
  }
}

class StoreItem {
  final String name;
  final String package;
  final String displayName;
  final String description;
  final String? iconUrl;
  final List<String> screenshots;
  final String? category;
  final String author;
  final String updateJsonUrl;
  final StoreItemType type;
  final List<BundledItem> bundledPlugins;
  final List<BundledItem> bundledWidgets;

  UpdateInfo? updateInfo;

  StoreItem({
    required this.name,
    required this.package,
    required this.displayName,
    required this.description,
    this.iconUrl,
    this.screenshots = const [],
    this.category,
    this.author = 'VAXP Team',
    required this.updateJsonUrl,
    required this.type,
    this.bundledPlugins = const [],
    this.bundledWidgets = const [],
    this.updateInfo,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json, StoreItemType type) {
    return StoreItem(
      name: json['name'] as String? ?? '',
      package: json['package'] as String? ?? json['name'] as String? ?? '',
      displayName:
          json['display_name'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconUrl: json['icon_url'] as String?,
      screenshots: (json['screenshots'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      category: json['category'] as String?,
      author: json['author'] as String? ?? 'VAXP Team',
      updateJsonUrl: json['update_json'] as String? ?? '',
      type: type,
      bundledPlugins: (json['bundled_plugins'] as List<dynamic>?)
              ?.map((e) => BundledItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bundledWidgets: (json['bundled_widgets'] as List<dynamic>?)
              ?.map((e) => BundledItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
