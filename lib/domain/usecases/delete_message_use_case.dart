import 'package:either_dart/either.dart';
import 'package:streamate_flutter_app/core/my_error.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_auth_repository.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_chat_repository.dart';

///Este use case se encargaría de comprobar si el token de acceso 
///almacenado en el dispositivo ha expirado o no, y si es así, actualizarlo mediante el uso del 
///refresh token o notificar al BLoC para pedir al User que vuelva a iniciar sesión
class DeleteMessageUseCase{
  

  Future<Either<MyError, bool>> call(String idUser, String idMessage) async {
    TwitchChatRepository authRepository = serviceLocator<TwitchChatRepository>();
    
    try{
      bool valid = await authRepository.deleteMessage(idUser, idMessage);
      
      return Right(valid);

    }catch(e){
      return Left(MyError("Error al comprobar la sesion: $e"));
    }

  
  }


}