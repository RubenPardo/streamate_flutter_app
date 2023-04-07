import 'package:either_dart/either.dart';
import 'package:streamate_flutter_app/core/my_error.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_chat_repository.dart';

/// Este use case se encarga de banear a un usuario del chat de otro usuario
/// para vetarlo para siempre no hay que pasar la duracion
class BanUserUseCase{
  

  Future<Either<MyError, bool>> call(String idUser, String idUserToBan, {int? duration}) async {
    TwitchChatRepository apiRepository = serviceLocator<TwitchChatRepository>();
    
    try{
      bool valid = await apiRepository.banUser(idUser, idUserToBan, duration: duration);
      
       
      
      return Right(valid);

    }catch(e){
      return Left(MyError("Error al banear el usuario: $e"));
    }

  
  }


}