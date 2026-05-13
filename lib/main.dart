import 'package:flutter/material.dart';
import 'package:vecostore/core/colors/vaxp_colors.dart';
import 'package:vecostore/core/theme/vaxp_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:venom_config/venom_config.dart';
import 'presentation/store_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await VenomConfig().init();
  VaxpColors.init();

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1000, 680),
    minimumSize: Size(800, 560),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Vaxp Ecosystem Store',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const VaxpStoreApp());
}

class VaxpStoreApp extends StatelessWidget {
  const VaxpStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vaxp Ecosystem Store',
      theme: VaxpTheme.dark,
      home: const StoreShell(),
    );
  }
}
