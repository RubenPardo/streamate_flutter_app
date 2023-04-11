import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:obs_websocket/obs_websocket.dart';
import 'package:rxdart/rxdart.dart';
import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/data/model/obs_audio_track.dart';
import 'package:streamate_flutter_app/data/model/obs_connection.dart';
import 'package:streamate_flutter_app/data/model/obs_event_type.dart';
import 'package:streamate_flutter_app/data/model/obs_scene.dart';
import 'package:streamate_flutter_app/data/services/obs_service.dart';
import 'package:streamate_flutter_app/presentation/bloc/obs/obs_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/obs/obs_state.dart';
import 'package:collection/collection.dart';


class OBSBloc extends Bloc<OBSEvent,OBSState>{
  
  // atributos para controlar las escenas del obs ---------------------------------
  final StreamController<List<OBSScene>> _scenesStreamController = BehaviorSubject<List<OBSScene>>();
  List<OBSScene> _obsScenes = []; 
  Stream<List<OBSScene>> get sceneStream {
    return _scenesStreamController.stream;
  } 

  // atributos para controlar las pistas de audio del obs ----------------------------
  final StreamController<List<OBSAudioTrack>> _audioTrackStreamController = BehaviorSubject<List<OBSAudioTrack>>();
  List<OBSAudioTrack> _obsAudioTrack = []; 
  Stream<List<OBSAudioTrack>> get audioTrackStream {
    return _audioTrackStreamController.stream;
  } 
  
  OBSBloc():super(OBSUninitialized()){

    final OBSService obsService = OBSService();// TODO cambiar al serivce locator


  /// {oldSceneName: Escena b, sceneName: Escena a} -> sceneNameChanged
  /// callback cuando el event handler detecta que una escena ha cambiado el nombre 
  void sceneNameChanged(Map<String, dynamic> data) async{
    // event.eventData: {oldSceneName: Escena b, sceneName: Escena a}
    String oldSceneName = data['oldSceneName'];
        String sceneName =data['sceneName'];
        OBSScene oldScene = _obsScenes.firstWhere((element) => element.name == oldSceneName);
        int oldIndex = _obsScenes.indexOf(oldScene);
        OBSScene newScene = OBSScene(name: sceneName, index: oldScene.index, isActual: oldScene.isActual);
        _obsScenes.insert(oldIndex,newScene);
        _obsScenes.remove(oldScene);
        _scenesStreamController.add(_obsScenes);
        _obsAudioTrack = (await obsService.getSceneAudioTrackList(sceneName));
        _obsAudioTrack.addAll((await obsService.getGlobalAudioTrackList()));
        _audioTrackStreamController.add(_obsAudioTrack);
  }

  /// {sceneName: Escena 3} -> sceneChanged
  /// callback cuando el event handler detecta que se ha cambiado la escena
  void sceneChanged(Map<String, dynamic> data) async{
    // data = {sceneName: Escena 3}
    String sceneName = data['sceneName'];
    _obsScenes = _obsScenes.map<OBSScene>((scene) {
      return scene..isActual  = (scene.name == sceneName);
    }).toList();
    _scenesStreamController.add(_obsScenes);
    _obsAudioTrack = (await obsService.getSceneAudioTrackList(sceneName));
    _obsAudioTrack.addAll((await obsService.getGlobalAudioTrackList()));
    _audioTrackStreamController.add(_obsAudioTrack);
    
  }

  /// {isGroup: false, sceneName: Escena 1} -> sceneChanged
  /// callback cuando el event handler detecta que se ha creado una escena
  void sceneCreated(Map<String, dynamic> data) async{
    // {isGroup: false, sceneName: Escena 1}
    _obsScenes.add(OBSScene(name: data['sceneName'], index: _obsScenes.length));
    _scenesStreamController.add(_obsScenes);
    
  }

  /// data:{defaultInputSettings: {device_id: default}, inputKind: coreaudio_input_capture, inputName: Captura de entrada audio, inputSettings: {}, unversionedInputKind: coreaudio_input_capture}
  ///    -> sceneChanged
  /// callback cuando el event handler detecta que se ha creado una input
  void inputCreated(Map<String, dynamic> data) async{
    // {isGroup: false, sceneName: Escena 1}
    log(data.toString());
    if(Utils.isAudioSource(data['inputKind'])){
      // TODO pasar a caso de uso
      double volumen = await obsService.getAudioTrackVolumeDB(data['inputName']); 
      bool isMuted = await obsService.getMuteStatusAudioTrack(data['inputName']); 
      _obsAudioTrack.add(OBSAudioTrack(volumenDB:volumen,name: data['inputName'],isMuted: isMuted,));
      _audioTrackStreamController.add(_obsAudioTrack);
    }
    
  }

  /// {inputName: Captura de entrada audio} -> inputRemoved
  /// callback cuando el event handler detecta que se ha creado una input
  void inputRemoved(Map<String, dynamic> data) async{
    // {inputName: Captura de entrada audio}
    _obsAudioTrack.removeWhere((element) => element.name == data['inputName']);
    _audioTrackStreamController.add(_obsAudioTrack);
    
  }


  /// {isGroup: false, sceneName: Escena 1} -> sceneChanged
  /// callback cuando el event handler detecta que se ha borrado una escena
  void sceneRemoved(Map<String, dynamic> data) async{
    // {isGroup: false, sceneName: Escena 23}
    _obsScenes.removeWhere((element) => element.name == data['sceneName']);
    _scenesStreamController.add(_obsScenes);
  }

  /// data:{inputName: audio E1, inputVolumeDb: -1.383665680885315, inputVolumeMul: 0.8527401685714722}
  ///  -> inputVolumeChanged()
  /// callback cuando el event hanlder detecta que un input de auido ha cambiado su volumen
  void inputVolumeChanged(Map<String, dynamic> data){

        // {inputName: audio E1, inputVolumeDb: -1.383665680885315, inputVolumeMul: 0.8527401685714722}
    _obsAudioTrack = _obsAudioTrack.map(
      (element){
        if(element.name == data['inputName']){
          return OBSAudioTrack(name: element.name, volumenDB: data['inputVolumeDb'], isMuted: element.isMuted, isGlobal: element.isGlobal);
        }else{
          return element;
        }
      }).toList();
      _audioTrackStreamController.add(_obsAudioTrack);
  }


  /// data:{inputName: a, oldInputName: audio E1} -> inputNameChanged
  /// callback cuando el event handler detecta que un input ha cambiado el nombre 
  void inputNameChanged(Map<String, dynamic> data) async{
    String oldInputeName = data['oldInputName'];
    String newInputName =data['inputName'];
    // obtener el input antiguo
    OBSAudioTrack? oldInput = _obsAudioTrack.firstWhereOrNull((element) => element.name == oldInputeName);
    // puede que lo que haya cambiado no sea un audio source, por lo que puede no encontrarlo, en ese caso devuelve null
    if(oldInput!=null){
      // crear la nueva pista de audio
      OBSAudioTrack newInput = OBSAudioTrack(name: newInputName,volumenDB: oldInput.volumenDB, isMuted: oldInput.isMuted, isGlobal: oldInput.isGlobal);
      // insertarla en la misma posicion que la antigua
      int oldIndex = _obsAudioTrack.indexOf(oldInput);
      _obsAudioTrack.insert(oldIndex,newInput);
      _obsAudioTrack.remove(oldInput);
      _audioTrackStreamController.add(_obsAudioTrack);
    }
        
  }

  /// data:{inputMuted: true, inputName: captura E1} -> inputMuteStateChanged
  /// callback cuando el event handler detecta que un input ha cambiado el estado del mute
  void inputMuteStateChanged(Map<String, dynamic> data) async{
    
    String inputName =data['inputName'];
    bool isMuted =data['inputMuted'];
    // obtener el input antiguo
    OBSAudioTrack? oldInput = _obsAudioTrack.firstWhereOrNull((element) => element.name == inputName);
    // puede que lo que haya cambiado no sea un audio source, por lo que puede no encontrarlo, en ese caso devuelve null
    if(oldInput!=null){
      // crear la nueva pista de audio
      OBSAudioTrack newInput = OBSAudioTrack(name: inputName,volumenDB: oldInput.volumenDB, isMuted: isMuted, isGlobal: oldInput.isGlobal);
      // insertarla en la misma posicion que la antigua
      int oldIndex = _obsAudioTrack.indexOf(oldInput);
      _obsAudioTrack.insert(oldIndex,newInput);
      _obsAudioTrack.remove(oldInput);
      _audioTrackStreamController.add(_obsAudioTrack);
    }
        
  }

  /// Event -> eventHandler
  /// 
  /// funcion para manejer los eventos que llegan del obs
  ///
  void eventHandler(Event event) async{

        log('type: ${event.eventType}');
    switch(Utils.mapTextToOBSEvent(event.eventType)){
      
      case ObsEvent.currentProgramSceneChanged:
        sceneChanged(event.eventData!);  
        break;
      case ObsEvent.inputVolumeChanged:
        log(event.eventData!.toString());
        Map<String, dynamic> data = event.eventData!;
        inputVolumeChanged(data);
        break;
      case ObsEvent.sceneNameChanged:
        sceneNameChanged(event.eventData!);
        break;
      case ObsEvent.inputNameChanged:
        inputNameChanged(event.eventData!);
        break;
      case ObsEvent.sceneCreated:
        sceneCreated(event.eventData!);
        break;
      case ObsEvent.sceneRemoved:
        sceneRemoved(event.eventData!);
        break;
      case ObsEvent.inputCreated:
        inputCreated(event.eventData!);
        break;
      case ObsEvent.inputRemoved:
        inputRemoved(event.eventData!);
        break;
      case ObsEvent.inputMuteStateChanged:
        inputMuteStateChanged(event.eventData!);
        break;
      case ObsEvent.none:
        break;
    }
    
  }

    /// comprueba si hay una conexión guardada o no
    on<OBSInit>(
      (event, emit) {
        emit(OBSInitialized(lastConnection: null));//------------> nno hay ninguna guardad, return null
      },
    );

    /// conectarse al obs, si se pudo conectar obtener las escenas, las pistas de audio y emitirlas por los streams
    /// ademas de registrar el handler al servicio para escuchar cambios en el obs
    /// OBSConnection -> OBSConnect() -> OBSConnected
    on<OBSConnect>(
      (event, emit) async{
        try{
          // TODO pasar a caso de uso con el either
          OBSConnection connection = event.connection;

          bool connected = await obsService.connect(connection.address, connection.port, connection.password);
          if(connected){

            _obsScenes = (await obsService.getSceneList()).reversed.toList(); // llega al reves
            String actualSceneName = await obsService.getCurrentNameScene();
            /// marcar cual es la actual
            for (var scene in _obsScenes) {
              if(scene.name == actualSceneName){
                scene.isActual = true;
              }
            }

            _obsAudioTrack = (await obsService.getSceneAudioTrackList(actualSceneName));
            _obsAudioTrack.addAll((await obsService.getGlobalAudioTrackList()));
            // escuchar los cambios del obs
            obsService.setEventHandler(eventHandler);

            _scenesStreamController.add(_obsScenes);
            _audioTrackStreamController.add(_obsAudioTrack);
            emit(OBSConnected()); // ------------------------------------------> return connected
            
          }else{

            emit(OBSError(message: 'Error al conectarse al obs'));
          }
        }catch(e){

          emit(OBSError(message: 'Error al conectarse al obs $e'));
        }
      },
    );

    /// OBSScene -> OBSChangeScene
    /// cambiar la escena en el obs
    on<OBSChangeScene>(
      (event, emit) async{
        try{
          OBSScene scene = event.scene;
          
          obsService.setCurrentScene(scene.name);
          
        }catch(e){

          emit(OBSError(message: 'Error al cambiar la escena en el obs $e'));
        }
      },
    );

    /// audioTrackName:Texto,newVolumen:double -> OBSChangeTrackVolumen
    /// cambiar el volumen de una pista de audio
    on<OBSChangeTrackVolumen>(
      (event, emit) async{
        try{
          String audioTrackName = event.audioTrackName;
          double newVolumen = event.newVolumen;
          
          obsService.setVolume(audioTrackName,newVolumen);
          
        }catch(e){

          emit(OBSError(message: 'Error al cambiar la escena en el obs $e'));
        }
      },
    );

    /// audioTrackName:Texto,isMuted:bool -> OBSChangeTrackMute
    /// cambiar el estado de mute de una pista de audio
    on<OBSChangeTrackMute>(
      (event, emit) async{
        try{
          String audioTrackName = event.audioTrackName;
          bool isMuted = event.isMuted;
          
          obsService.setMuteStatusAudioTrack(audioTrackName,isMuted);
          
        }catch(e){

          emit(OBSError(message: 'Error al cambiar la escena en el obs $e'));
        }
      },
    );


  

  }


}