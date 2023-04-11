import 'package:either_dart/either.dart';
import 'package:streamate_flutter_app/core/my_error.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/obs_audio_track.dart';
import 'package:streamate_flutter_app/data/model/obs_scene.dart';
import 'package:streamate_flutter_app/data/services/obs_service.dart';

class GetOBSAudioTracksUseCase{

  OBSService obsService = serviceLocator<OBSService>();

  /// actualSceneName -> GetOBSAudioTracksUseCase() -> List<OBSAudioTrack>
  /// obtiene todas las pistas de audio del obs, las de la escena y la globales
  Future<Either<List<OBSAudioTrack>,MyError>> call(String actualSceneName) async{
    try{
      List<OBSAudioTrack> obsAudioTracks = (await obsService.getSceneAudioTrackList(actualSceneName));
      obsAudioTracks.addAll((await obsService.getGlobalAudioTrackList()));

      return Left(obsAudioTracks);
    }catch(e){
      return Right(MyError('Error al obtener las escenas: $e'));
    }
  }

}