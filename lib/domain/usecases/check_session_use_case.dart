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
  

  Future<Either<MyError, User>> llamar() async {
    TwitchAuthRepository authRepository = serviceLocator<TwitchAuthRepository>();
    
    try{
      
      if(await authRepository.isTokenSavedLocal()){
        if(!await authRepository.isTokenExpired()){
          print("Token autorizado");
          // TOKEN AUTORIZADO ----------------------------------------------------------------
          // TODO borrar
          TokenData tokenData = await authRepository.getTokenDataLocal();
          print("Token: ${tokenData.accesToken}");
          User user = await serviceLocator<TwitchAuthRepository>().getUserRemote(tokenData.accesToken);
          print("Usario: $user");
          return Right(user);
        }else{
          print("Token expirado");
          // TOKEN EXPIRADO ----------------------------------------------------------------
          // el token ha expirado hay que actualizarlo
          TokenData tokenData = await authRepository.getTokenDataLocal();
          bool seActualizo = await authRepository.updateToken(tokenData.refresh_token);
          // TODO borrar
          User user = await serviceLocator<TwitchAuthRepository>().getUserRemote(tokenData.accesToken);

          return Right(user);

        }
      }else{
          print("no hay Token ");
        // NO HAY TOKEN  ----------------------------------------------------------------
        return const Left(MyError("Error al comprobar la sesion: BORRAR ESTO"));
       // return const Right(false);
      }  

    }catch(e){
      return Left(MyError("Error al comprobar la sesion: $e"));
    }

  
  }


}