import 'dart:convert';
import 'dart:developer';
import 'package:obs_websocket/obs_websocket.dart';
import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/data/model/obs_event_type.dart';
import 'package:streamate_flutter_app/data/model/obs_scene.dart';
import 'package:web_socket_channel/io.dart';

class OBSService {
  ObsWebSocket? _obsWebSocket;

  late StreamStatusResponse obsStatus;

  
  

  
  Future<bool> connect(String address, int port, String password) async {
   if(_obsWebSocket == null){
      _obsWebSocket = await ObsWebSocket.connect(
        'ws://$address:$port', 
        password: password,
        fallbackEventHandler: eventHandler,
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
  /// getAudioTrackList
  Future<void> getAudioTrackList() async {
    print( _obsWebSocket!.mediaInputs.toString());
    print( (await _obsWebSocket!.send('GetSpecialInputs'))!.responseData);
  }

  Future<void> setVolume(String trackName, double volume) async {
    String request = jsonEncode({"request-type": "SetInputVolume", "inputName": trackName, "inputVolumeMul": volume});
    print( (await _obsWebSocket!.send(request))!.responseData);
  }

  /// Event -> eventHandler
  /// 
  /// funcion para manejer los eventos que llegan del obs
  ///
  void eventHandler(Event event) {

        log('type: ${event.eventType}');
    switch(Utils.mapTextToOBSEvent(event.eventType)){
      
      case ObsEvent.currentProgramSceneChanged:
        log('data: ${event.eventData}');
        break;
      case ObsEvent.inputVolumeChanged:
        log('data: ${event.eventData}');
        break;
      case ObsEvent.sceneNameChanged:
        // TODO: Handle this case.
        break;
      case ObsEvent.inputNameChanged:
        // TODO: Handle this case.
        break;
      case ObsEvent.sceneCreated:
        // TODO: Handle this case.
        break;
      case ObsEvent.sceneRemoved:
        // TODO: Handle this case.
        break;
      case ObsEvent.none:
        print('Ni idea');
        break;
    }
    
  }
}
