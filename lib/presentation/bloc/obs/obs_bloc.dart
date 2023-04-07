import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:obs_websocket/obs_websocket.dart';
import 'package:rxdart/rxdart.dart';
import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/data/model/obs_connection.dart';
import 'package:streamate_flutter_app/data/model/obs_event_type.dart';
import 'package:streamate_flutter_app/data/model/obs_scene.dart';
import 'package:streamate_flutter_app/data/services/obs_service.dart';
import 'package:streamate_flutter_app/presentation/bloc/obs/obs_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/obs/obs_state.dart';

class OBSBloc extends Bloc<OBSEvent,OBSState>{
  
  final StreamController<List<OBSScene>> _scenesStreamController = BehaviorSubject<List<OBSScene>>();
  List<OBSScene> _obsScenes = []; 

  Stream<List<OBSScene>> get sceneStream {
    return _scenesStreamController.stream;
  } 
  
  OBSBloc():super(OBSUninitialized()){

    final OBSService obsService = OBSService();// TODO cambiar al serivce locator


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
            // escuchar los cambios del obs
            obsService.setEventHandler(eventHandler);

            _scenesStreamController.add(_obsScenes);
            emit(OBSConnected()); // ------------------------------------------> return connected
            
          }else{

            emit(OBSError(message: 'Error al conectarse al obs'));
          }
        }catch(e){

          emit(OBSError(message: 'Error al conectarse al obs $e'));
        }
      },
    );

  }

  /// Event -> eventHandler
  /// 
  /// funcion para manejer los eventos que llegan del obs
  ///
  void eventHandler(Event event) {

        log('type: ${event.eventType}');
    switch(Utils.mapTextToOBSEvent(event.eventType)){
      
      case ObsEvent.currentProgramSceneChanged:
        // eventData = {sceneName: Escena 3}
        _obsScenes = _obsScenes.map<OBSScene>((scene) {
          return scene..isActual  = (scene.name == event.eventData!['sceneName']);
        }).toList();
        _scenesStreamController.add(_obsScenes);
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