import 'package:either_dart/either.dart';
import 'package:streamate_flutter_app/core/my_error.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_auth_repository.dart';

///Este use case se encargaría de comprobar si el token de acceso 
///almacenado en el dispositivo ha expirado o no, y si es así, actualizarlo mediante el uso del 
///refresh token o notificar al BLoC para pedir al User que vuelva a iniciar sesión
class CheckSessionUseCase{
  

  Future<Either<MyError, bool>> call() async {
    TwitchAuthRepository authRepository = serviceLocator<TwitchAuthRepository>();
    
    try{
      
      if(await authRepository.isTokenSavedLocal()){
        if(!await authRepository.isTokenExpired()){
          print("Token autorizado");
          // TOKEN AUTORIZADO ----------------------------------------------------------------
          //print("Token: ${tokenData.accessToken}");
          //User user = await serviceLocator<TwitchAuthRepository>().getUserRemote(tokenData.accessToken);
          return const Right(true);
        }else{
          print("Token expirado");
          // TOKEN EXPIRADO ----------------------------------------------------------------
          // el token ha expirado hay que actualizarlo
          TokenData tokenData = await authRepository.getTokenDataLocal(); // obtenemos el token guardado
          TokenData newTokenData = await authRepository.updateToken(tokenData.refreshToken); // lo actualizamos
          authRepository.saveTokenDataLocal(newTokenData); // y lo guardamos

          return Right(newTokenData.accessToken != ""); /// si el token esta vacío ha habido un error

        }
      }else{
        // NO HAY TOKEN  ----------------------------------------------------------------
        return const Right(false);
      }  

    }catch(e){
      return Left(MyError("Error al comprobar la sesion: $e"));
    }

  
  }


}