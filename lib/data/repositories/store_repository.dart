import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/store_item.dart';

class StoreRepository {
  static const _urls = {
    StoreItemType.app:
        'https://raw.githubusercontent.com/VAXPAPPS/apps_index/main/apps.json',
    StoreItemType.theme:
        'https://raw.githubusercontent.com/vaxpos/vaxp-themes/main/apps.json',
    StoreItemType.plugin:
        'https://raw.githubusercontent.com/VAXPAPPS/vaxp-plugins/main/apps.json',
    StoreItemType.widget_:
        'https://raw.githubusercontent.com/VAXPAPPS/vaxp-widget/main/apps.json',
  };

  Future<List<StoreItem>> fetchItems(StoreItemType type) async {
    final url = _urls[type]!;
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch data (${response.statusCode})');
    }

    final body = response.body.trim();
    final List<dynamic> list = jsonDecode(body);
    return list
        .map((json) => StoreItem.fromJson(json as Map<String, dynamic>, type))
        .toList();
  }

  Future<UpdateInfo> fetchUpdateInfo(String url) async {
    if (url.isEmpty) throw Exception('Update URL is empty');
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch update info');
    }

    return UpdateInfo.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }
}
