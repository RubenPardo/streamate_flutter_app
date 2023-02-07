import 'package:either_dart/either.dart';
import 'package:streamate_flutter_app/core/my_error.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_auth_repository.dart';

class LogOutUseCase{


  /// -> logOut() -> T/F
  /// 
  /// Iniciar Sesion un usuario dado el url de redireccionamiento de OAuth2.0
  ///
  Future<Either<MyError, bool>> llamar() async {

    TwitchAuthRepository authRepository = serviceLocator<TwitchAuthRepository>();
    authRepository.clearTokenDataLocal(); 
    return const Right(true); // --------------------------------------> logout -> return true 
    
  }
}