import 'package:either_dart/either.dart';
import 'package:streamate_flutter_app/core/my_error.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/chat_setting.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_chat_repository.dart';

class UpdateChatSettingUseCase{


  /// -> logOut() -> T/F
  /// 
  /// Iniciar Sesion un usuario dado el url de redireccionamiento de OAuth2.0
  ///
  Future<Either<MyError, ListChatSettings>> call(String idBroadcaster, ChatSetting chatSetting) async {
    print("CHAT -- 3 USE CASE");
    TwitchChatRepository chatRepository = serviceLocator<TwitchChatRepository>();
    
    try{
      
      List<List<String>> listParamsValues = chatSetting.toApi();
      List<String> listParams = listParamsValues[0];
      List<String> listValues = listParamsValues[1];
      
      ListChatSettings listChatSettings = await chatRepository.updateChatSetting(idBroadcaster, listParams,listValues); 

      print("CHAT -- caso de uso update setting: $listChatSettings");

      return Right(listChatSettings);
    }catch (e){
      return const Left(MyError("Error al actualizar el ajuste del canal")); // --------------------------------------> error
    }
    
    
  }
}