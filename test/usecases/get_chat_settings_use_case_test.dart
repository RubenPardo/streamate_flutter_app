import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamate_flutter_app/core/my_error.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/chat_setting.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_chat_repository.dart';
import 'package:streamate_flutter_app/domain/usecases/get_chat_settings_use_case.dart';

class MockTwitchChatRepository extends Mock implements TwitchChatRepositoryImpl{}


void main() {
  late GetChatSettingsUseCase getChatSettingUseCase;
  String idBroadCaster = "idBroadcaster";
 
  
    // before all test
    setUpAll(() async{
      //registerFallbackValue(TokenData.empty());
      serviceLocator.registerSingleton<TwitchChatRepository>(MockTwitchChatRepository());
      getChatSettingUseCase = GetChatSettingsUseCase();
    });

    // after all test
    tearDownAll((){
      serviceLocator.reset();
    });


    
    test("GETCHATSETTINGS USECASE - Obtener chat settings valido",() async {
      
      

      // preparacion ----------------------
      // getUserRemote(any()) para luego comprobar que si se ha llamado con el accesToken
      when(() => serviceLocator<TwitchChatRepository>().getChatSettings(any()))
        .thenAnswer((invocation) => Future.value(ListChatSettings([])));

      // ejecucion ---------------------------------
      var result = (await getChatSettingUseCase.call(idBroadCaster)).fold((error) => error,(user)=>user); // result puede ser left de tipo MyError o right de tipo Bool
      

      // comprobacion ---------------------------------
      // si va bien tiene que devolver un valor right y user
      expect(result is ListChatSettings, true); 
      // se llamo al obtener el token
      verify(() => serviceLocator<TwitchChatRepository>().getChatSettings(idBroadCaster)).called(1); 

    });

    test("GETCHATSETTINGS USECASE - Obtener chat settings throw Error",() async {
      String error= "error";
      String errorEsperado = "Error al obtener los emoticonos: $error";
      

      // preparacion -----------------------
      when(() => serviceLocator<TwitchChatRepository>().getChatSettings(idBroadCaster))
        .thenThrow(error);

      var result;
      try{
        // ejecucion ---------------------------------
        result = (await getChatSettingUseCase.call(idBroadCaster)).fold((error) => error,(chatSetting)=>chatSetting);
      }catch(e){}
      finally{
         // comprobacion ---------------------------------
        // si va bien tiene que devolver un valor right y user
        expect(result is MyError, true); 
        expect((result as MyError).message, errorEsperado); 
        // se llamo al obtener el token
        verify(() => serviceLocator<TwitchChatRepository>().getChatSettings(idBroadCaster)).called(1); 
        // se obtuvo el user con el token 
      }
    });


}