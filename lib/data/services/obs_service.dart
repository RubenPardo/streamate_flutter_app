import 'dart:convert';
import 'dart:developer';
import 'package:obs_websocket/obs_websocket.dart';
import 'package:obs_websocket/request.dart';
import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/data/model/obs_audio_track.dart';
import 'package:streamate_flutter_app/data/model/obs_event_type.dart';
import 'package:streamate_flutter_app/data/model/obs_scene.dart';
import 'package:web_socket_channel/io.dart';

class OBSService {
  ObsWebSocket? _obsWebSocket;

  late StreamStatusResponse obsStatus;

  
  

  
  Future<bool> connect(String address, int port, String? password) async {
   if(_obsWebSocket == null){
      _obsWebSocket = await ObsWebSocket.connect(
        'ws://$address:$port', 
        password: password,
      );
      // tell obsWebSocket to listen to events, since the default is to ignore them
      await _obsWebSocket!.listen(EventSubscription.all.index);
      obsStatus = await _obsWebSocket!.stream.status;
   }

    return true;
      
  }

  void close() async {
   _obsWebSocket!.close();   
  }
  
  
  /// obtener la lista de escenas de la conexion obs
  /// 
  /// getSceneList() -> List<[OBSScene]>
  ///
  Future<List<OBSScene>> getSceneList() async {
    final sceneList = await _obsWebSocket!.scenes.getSceneList();
    return sceneList.scenes.map((scene) => OBSScene.fromJson(scene.toJson())).toList();
  }

  /// obtiene el nombre de la escena actual
  ///
  ///getCurrentNameScene() -> Text
  ///
  Future<String> getCurrentNameScene() async {
    String scene = await _obsWebSocket!.scenes.getCurrentProgramScene();
    return scene;
  }


  /// cambia la escena actual del obs
  /// text -> setCurrentScene
  Future<void> setCurrentScene(String sceneName) async {
    await _obsWebSocket!.scenes.setCurrentProgramScene(sceneName);
  }

  /// obtiene las pistas de audio del obs 
  /// Texto -> getAudioTrackList -> List[OBSAudioTrack]
  Future<List<OBSAudioTrack>> getSceneAudioTrackList(String sceneName) async {
    if(_obsWebSocket!=null){
      final response = await _obsWebSocket!.send('GetSceneItemList',{'sceneName':sceneName});
      // global
      final response3 = await _obsWebSocket!.send('GetSpecialInputs',);
      final response4 = await _obsWebSocket!.send('GetInputKindList',);

      log(response4!.responseData!.toString());

      if(response!=null){
        var a1 = (response.responseData!.entries.toList()[0].value as List)
            .where((input) => Utils.isAudioSource(input['inputKind']));
         
       List<OBSAudioTrack> audioTracks = await Future.wait(a1 // filtrar los audio tracks
            .map((input) async{
              // obtener el audio por pista
              double volumen = await getAudioTrackVolumeDB(input['sourceName']); 
              return OBSAudioTrack(volumenDB:volumen,name: input['sourceName']);
            })); // transformarlo en una lista de obsaudiotrack

        log("-------- aqui");
        return audioTracks;
        
      }
    }
    
    return [];
  }

  /// Texto -> getAudioTrackVolumeDB() -> R
  Future<double> getAudioTrackVolumeDB(String trackName) async {
    return (await _obsWebSocket!.send('GetInputVolume',{'inputName':trackName}))!.responseData!['inputVolumeDb'];
  }
  

  Future<void> setVolume(String trackName, double volume) async {
    String request = jsonEncode({"request-type": "SetInputVolume", "inputName": trackName, "inputVolumeDb": volume});
    print( (await _obsWebSocket!.send(request))!.responseData);
  }

  /// Function(Event e) -> setEventHandler
  /// añadir un manejador de eventos para poder escuchar los 
  /// cambios que se realizan desde el obs
  void setEventHandler(Function(Event) handler){
    if(  _obsWebSocket!=null && _obsWebSocket!.fallbackHandlers.isNotEmpty){
       _obsWebSocket?.fallbackHandlers.removeLast();
    }
    _obsWebSocket?.fallbackHandlers.add(handler);
  }
}
