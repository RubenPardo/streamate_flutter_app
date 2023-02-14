import 'package:either_dart/either.dart';
import 'package:streamate_flutter_app/core/my_error.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_auth_repository.dart';

///este use case se encargaría de enviar una solicitud a la API de Twitch para obtener 
///los datos del usuario (nombre de usuario, imagen de perfil, etc.) y devolverlos al BLoC.
class GetUserUseCase{
  

  Future<Either<MyError, User>> call() async {
    TwitchAuthRepository authRepository = serviceLocator<TwitchAuthRepository>();
    TokenData token = await authRepository.getTokenDataLocal();
    
    try{
      
      User user = await authRepository.getUserRemote(token.accessToken);

      return Right(user);

    }catch(e){
      return Left(MyError("Error al obtener el usuario: $e"));
    }

  
  }


}