import 'package:either_dart/either.dart';
import 'package:streamate_flutter_app/core/my_error.dart';
import 'package:streamate_flutter_app/core/request.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_auth_repository.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_chat_repository.dart';

///este use case se encargaría de enviar una solicitud a la API de Twitch para obtener 
///los datos del usuario (nombre de usuario, imagen de perfil, etc.) y devolverlos al BLoC.
class GetUserUseCase{
  

  Future<Either<MyError, User>> call({String? id, String? idBroadCaster}) async {
    TwitchAuthRepository authRepository = serviceLocator<TwitchAuthRepository>();
    TwitchChatRepository chatRepository = serviceLocator<TwitchChatRepository>();
    TokenData token = await authRepository.getTokenDataLocal();
    
    try{
      late User user;
      if(id==null){
        //obtener el usuario logeado
        user = await authRepository.getUserRemote(token.accessToken);
      }else{
        // obtener el usuario que se pasa
        user = await chatRepository.getUserByUserId(token.accessToken, id);
      }
      

      return Right(user);

    }catch(e){
      return Left(MyError("Error al obtener el usuario: $e"));
    }

  
  }


}