import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'languages/locale_service.dart';

class AppInitializer {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize storage first
    await GetStorage.init();

    // Initialize screen util
    await ScreenUtil.ensureScreenSize();

    // Initialize locale service (loads saved language from storage)
    await LocaleService.init();

    debugPrint(
      'App initialized with language: ${LocaleService.to.currentLanguageCode}',
    );

    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
