
import 'package:either_dart/either.dart';
import 'package:streamate_flutter_app/core/my_error.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/chat_setting.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_chat_repository.dart';

class GetChatSettingsUseCase{
  
  Future<Either<MyError, ListChatSettings>> call(String idBroadcaster) async {
    ListChatSettings chatSettings;

 
    
    try{
     
      chatSettings = await serviceLocator<TwitchChatRepository>().getChatSettings(idBroadcaster);
      return Right(chatSettings);

    }catch(e){
      return Left(MyError("Error al obtener los emoticonos: $e"));
    }

  
  }
}