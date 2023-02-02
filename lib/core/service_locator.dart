import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streamate_flutter_app/core/request.dart';
import 'package:streamate_flutter_app/data/services/twitch_auth_service.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_auth_repository.dart';
import 'package:streamate_flutter_app/domain/usecases/check_session_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/get_user_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/log_in_use_case.dart';


final serviceLocator = GetIt.instance;
Future<void> setUpServiceLocator() async {
  // twitch auth ---------------------------------------------------------------------------------
 
  //usecase -----------
  serviceLocator.registerFactory<LogInUseCase>(() => LogInUseCase());
  serviceLocator.registerFactory<GetUserUseCase>(() => GetUserUseCase());
  serviceLocator.registerFactory<CheckSessionUseCase>(() => CheckSessionUseCase());

  //datasource
  serviceLocator.registerFactory<TwitchAuthService>(
      () => TwitchAuthServiceImpl());

  //repositories
  serviceLocator
      .registerFactory<TwitchAuthRepository>(() => TwitchAuthRepositoryImpl());

  //external
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerFactory<SharedPreferences>(() => sharedPreferences);
  // request
  serviceLocator.registerSingleton<Request>(Request());
}