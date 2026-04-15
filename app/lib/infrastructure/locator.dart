import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

import '../service/ai_meditation_service.dart';
import '../service/common/api_methods.dart';
import '../service/device_service.dart';
import '../service/locale_service.dart';
import '../service/settings_service.dart';
import '../service/storage_service.dart';
import '../service/system_channel_service.dart';
import '../service/theme_service.dart';
import '../service/tips_service.dart';
import '../service/transport_service.dart';
import '../service/wallet_service.dart';
import 'services/app_ai_meditation_service.dart';
import 'services/app_device_service.dart';
import 'services/app_locale_service.dart';
import 'services/app_settings_service.dart';
import 'services/app_storage_service.dart';
import 'services/app_system_channel_service.dart';
import 'services/app_theme_service.dart';
import 'services/app_tips_service.dart';
import 'services/app_transport_service.dart';
import 'services/app_wallet_service.dart';
import 'services/schedule_storage_service.dart';

Future<GetIt> buildServices() async {
  final locator = GetIt.instance;

  locator
    ..registerLazySingleton<StorageService>(() => AppStorageService())
    ..registerLazySingleton<DeviceService>(() => AppDeviceService())
    ..registerLazySingleton<WalletService>(
      () => AppWalletService(storage: locator.get<StorageService>()),
    )
    ..registerSingletonAsync<ThemeService>(() async {
      final service = AppThemeService(storage: locator.get<StorageService>());
      await service.init();

      return service;
    })
    ..registerSingletonAsync<LocaleService>(() async {
      final service = AppLocaleService(storage: locator.get<StorageService>());
      await service.init();

      return service;
    })
    ..registerSingletonAsync<SettingsService>(
      () async => AppSettingsService(storage: locator.get<StorageService>()),
    )
    ..registerLazySingleton<TipsService>(() => AppTipsService())
    ..registerLazySingleton<SystemChannelService>(
      () => AppSystemChannelService(),
    )
    ..registerSingletonAsync<TransportService>(() async {
      final service = AppTransportService(
        baseApiUrl: dotenv.env['API_URL']!,
        apiKey: dotenv.env['API_KEY']!,
        deviceService: locator.get<DeviceService>(),
        walletService: locator.get<WalletService>(),
      );
      await service.init();

      return service;
    })
    ..registerLazySingleton<AiMeditationService>(
      () => AppAiMeditationService(
        transportService: locator.get<TransportService>(),
      ),
    )
    ..registerLazySingleton<ScheduleStorageService>(
      () => ScheduleStorageService(storage: locator.get<StorageService>()),
    );

  await locator.allReady();

  return locator;
}
