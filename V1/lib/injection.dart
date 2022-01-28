import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'infrastructure/api/api_service.dart';
import 'infrastructure/core/pref_manager.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@injectableInit
void configureInjection(String env) {
  $initGetIt(getIt, environment: env);
  getIt.registerSingletonAsync<SharedPreferences>(
      () async => await Prefs.load());
  // getIt.registerLazySingletonAsync<dynamic>(
  //     () async => await PushNotificationService().initialise());
  getIt.registerFactory<HeyPApiService>(() => HeyPApiService.create());
}
