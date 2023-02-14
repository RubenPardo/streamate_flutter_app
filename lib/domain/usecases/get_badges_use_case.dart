import 'package:either_dart/either.dart';
import 'package:streamate_flutter_app/core/my_error.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/badge.dart';
import 'package:streamate_flutter_app/data/model/emote.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_chat_repository.dart';

///este use case se encargaría de enviar una solicitud a la API de Twitch para obtener 
///los datos del usuario (nombre de usuario, imagen de perfil, etc.) y devolverlos al BLoC.
class GetBadgesUseCase{
  

  Future<Either<MyError, List<Badge>>> call(String idBroadcaster) async {
    List<Badge> badges = [];

 
    
    try{
      
      badges.addAll(await serviceLocator<TwitchChatRepository>().getChannelBadges(idBroadcaster));
      badges.addAll(await serviceLocator<TwitchChatRepository>().getGlobalBadges());

      return Right(badges);

    }catch(e){
      return Left(MyError("Error al obtener los emoticonos: $e"));
    }

  
  }


}