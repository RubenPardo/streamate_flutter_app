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

      if(response!=null){
        var a1 = (response.responseData!.entries.toList()[0].value as List)
            .where((input) => Utils.isAudioSource(input['inputKind']));
         
       List<OBSAudioTrack> audioTracks = await Future.wait(a1 // filtrar los audio tracks
            .map((input) async{
              // obtener el audio por pista
              double volumen = await getAudioTrackVolumeDB(input['sourceName']); 
              bool isMuted = await getMuteStatusAudioTrack(input['sourceName']); 
              return OBSAudioTrack(volumenDB:volumen,name: input['sourceName'],isMuted:isMuted,);
            })); // transformarlo en una lista de obsaudiotrack

        return audioTracks;
        
      }
    }
    
    return [];
  }

  Future<List<OBSAudioTrack>> getGlobalAudioTrackList() async {
    if(_obsWebSocket!=null){
      //{desktop1: null, desktop2: null, mic1: Micro global, mic2: null, mic3: null, mic4: null}
      final response = await _obsWebSocket!.send('GetSpecialInputs',);
      if(response!=null){
         List inputName =  response.responseData!.values.where((element) => element!=null).toList();
       List<OBSAudioTrack> audioTracks = await Future.wait( // filtrar los audio tracks
            inputName.map((input) async{
              // obtener el audio por pista
              double volumen = await getAudioTrackVolumeDB(input); 
              bool isMuted = await getMuteStatusAudioTrack(input); 
              return OBSAudioTrack(volumenDB:volumen,name: input,isMuted:isMuted, isGlobal: true);
            })); // transformarlo en una lista de obsaudiotrack
        return audioTracks;
        
      }
    }
    
    return [];
  }

  /// Texto -> getAudioTrackVolumeDB() -> R
  Future<double> getAudioTrackVolumeDB(String trackName) async {
    return (await _obsWebSocket!.send('GetInputVolume',{'inputName':trackName}))!.responseData!['inputVolumeDb'];
  }
  
  /// Texto -> getMuteStatusAudioTrack() -> R
  Future<bool> getMuteStatusAudioTrack(String trackName) async {
    return (await _obsWebSocket!.send('GetInputMute',{'inputName':trackName,}))!.responseData!['inputMuted'];
  }

  /// trackName:Texto, mute:T/F -> setMuteStatusAudioTrack()
  Future<void> setMuteStatusAudioTrack(String trackName, bool mute) async {
     _obsWebSocket!.send('SetInputMute',{'inputName':trackName,'inputMuted':mute});
  }
  

  Future<void> setVolume(String trackName, double volume) async {

    await _obsWebSocket!.send('SetInputVolume',{'inputName':trackName, 'inputVolumeDb':volume});
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
