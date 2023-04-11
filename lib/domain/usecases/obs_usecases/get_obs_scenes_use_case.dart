import 'package:either_dart/either.dart';
import 'package:streamate_flutter_app/core/my_error.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/obs_scene.dart';
import 'package:streamate_flutter_app/data/services/obs_service.dart';

class GetOBSScenesUseCase{

  OBSService obsService = serviceLocator<OBSService>();

  /// GetOBSScenesUseCase() -> List<OBSScene>
  /// obtiene la lista de escenas del obs
  Future<Either<List<OBSScene>,MyError>> call() async{
    try{
      List<OBSScene> obsScenes = (await obsService.getSceneList()).reversed.toList(); // llega al reves
      String actualSceneName = await obsService.getCurrentNameScene();
      /// marcar cual es la actual
      for (var scene in obsScenes) {
        if(scene.name == actualSceneName){
          scene.isActual = true;
        }
      }

      return Left(obsScenes);
    }catch(e){
      return Right(MyError('Error al obtener las escenas: $e'));
    }
  }

}