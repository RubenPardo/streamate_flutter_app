import 'package:either_dart/either.dart';
import 'package:streamate_flutter_app/core/my_error.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_auth_repository.dart';
///
/// El login consta de dos partes:
/// 1. obtener una url para que el usuario autorize la aplicacion, debe ser si o si por web view
/// 2. obtener el token del acceso y guardarlo en el dispositivo
///
class LogInUseCase{


  /// Texto -> logIn() -> T/F
  /// 
  /// Iniciar Sesion un usuario dado el url de redireccionamiento de OAuth2.0
  ///
  Future<Either<MyError, User>> logIn(String redirectUrl) async {

    TwitchAuthRepository authRepository = serviceLocator<TwitchAuthRepository>();

    final Uri uri = Uri.parse(redirectUrl);
    final String? authorizationCode = uri.queryParameters['code'];

 

    // Si se obtuvo un código de autorización, se solicita un token de acceso
    if (authorizationCode != null) {
      try{
        TokenData tokenData = await authRepository.getTokenDataRemote(authorizationCode);
        print("TENEMOS TOKEN DATA");
          // Si se obtuvo un token de acceso, se persiste y se devuelve
        authRepository.saveTokenDataLocal(tokenData);
        User user = await serviceLocator<TwitchAuthRepository>().getUserRemote(tokenData.accesToken);
        
        return Right(user);
      }catch(e){

        return Left(MyError("Error al iniciar sesion $e"));
      }


    } else {
      return const Left(MyError("Error al iniciar sesion"));
    }

    
  }

  ///  -> getAutorizationUrl() -> Texto
  /// 
  /// Obtener el enlace para que el usuario puede dar sus credenciales y autorizar la aplicacion
  ///
  String getAutorizationUrl(){
   
    // Obtener la URL de autorización desde el servicio de autenticación
    return  serviceLocator<TwitchAuthRepository>().getAutorizationUrl();
  }
}
