import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streamate_flutter_app/core/request.dart';
import 'package:streamate_flutter_app/data/services/twitch_api_service.dart';
import 'package:streamate_flutter_app/data/services/twitch_irc_service.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_auth_repository.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_chat_repository.dart';
import 'package:streamate_flutter_app/domain/usecases/check_session_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/delete_message_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/get_badges_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/get_chat_settings_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/get_emotes_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/get_user_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/log_in_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/log_out_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/update_chat_setting_use_case.dart';


final serviceLocator = GetIt.instance;
Future<void> setUpServiceLocator() async {
  // twitch auth ---------------------------------------------------------------------------------
 
  //usecase -----------
  serviceLocator.registerFactory<LogInUseCase>(() => LogInUseCase());
  serviceLocator.registerFactory<GetUserUseCase>(() => GetUserUseCase());
  serviceLocator.registerFactory<CheckSessionUseCase>(() => CheckSessionUseCase());
  serviceLocator.registerFactory<LogOutUseCase>(() => LogOutUseCase());
  serviceLocator.registerFactory<GetEmotesUseCase>(() => GetEmotesUseCase());
  serviceLocator.registerFactory<GetBadgesUseCase>(() => GetBadgesUseCase());
  serviceLocator.registerFactory<GetChatSettingsUseCase>(() => GetChatSettingsUseCase());
  serviceLocator.registerFactory<UpdateChatSettingUseCase>(() => UpdateChatSettingUseCase());
  serviceLocator.registerFactory<DeleteMessageUseCase>(() => DeleteMessageUseCase());

  //datasource
  serviceLocator.registerFactory<TwitchApiService>(
      () => TwitchApiServiceImpl());
  serviceLocator.registerFactory<TwitchIRCService>(
      () => TwitchIRCServiceImpl());

  //repositories
  serviceLocator
      .registerFactory<TwitchAuthRepository>(() => TwitchAuthRepositoryImpl());
  serviceLocator
      .registerFactory<TwitchChatRepository>(() => TwitchChatRepositoryImpl());
      

  //external
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerFactory<SharedPreferences>(() => sharedPreferences);
  // request
  serviceLocator.registerSingleton<Request>(Request());
}