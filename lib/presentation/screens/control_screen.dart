import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:obs_websocket/obs_websocket.dart';
import 'package:streamate_flutter_app/data/model/obs_connection.dart';
import 'package:streamate_flutter_app/data/model/obs_scene.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/data/services/obs_service.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
import 'package:streamate_flutter_app/shared/styles.dart' as styles;
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart' as texts;
import 'package:streamate_flutter_app/presentation/bloc/obs/obs_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/obs/obs_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/obs/obs_state.dart';
import 'package:streamate_flutter_app/shared/widgets/large_primary_button.dart';

class OBSScreen extends StatefulWidget {

  final TokenData tokenData;
  final User user;
  

  const OBSScreen({super.key, required this.tokenData, required this.user});

  @override
  State<OBSScreen> createState() => _OBSScreenState();
}

class _OBSScreenState extends State<OBSScreen> {


  @override
  void initState() {
    super.initState();
    if(context.read<OBSBloc>().state is OBSUninitialized){
      context.read<OBSBloc>().add(OBSInit());
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OBSBloc,OBSState>(
        builder: (context, state) {
          if(state is OBSInitialized){
            return _buildInitialized(state.lastConnection);
          }

          if(state is OBSConnected){
            return _buildConnected();
          }

          return const SizedBox();
        },
        listener: (context, state) {
          if(state is OBSError){
            log('XDDDD ${state.message}');
          }
        },
    );
  }

    void _cerrarSesion() async{
      var obs = OBSService();
     await obs.connect('192.168.1.107', 4455, 'holaxd');
      await obs.getSceneList();
      await obs.getAudioTrackList();
      await obs.setVolume('Audio del escritorioxD',0);
      await obs.setVolume('Mic/Aux',0);

      ///context.read<AuthBloc>().add(LogOut()); // ---------------------> cerrar sesion         
  }


  /// funcion que devuelve el widget para conectarse al obs
  /// si [lastConnection] no es null se mostrara un boton para 
  /// connectarse directamente usando esos parametros
  Widget _buildInitialized(OBSConnection? lastConnection) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(texts.linkObsTitle,
              textAlign: TextAlign.center,style:Theme.of(context).textTheme.bodyLarge,),
            const SizedBox(height: 40,),
            LargePrimaryButton(
                child: Text(texts.linkObs,style:Theme.of(context).textTheme.bodyLarge,),
                onPressed: () {
                   context.read<OBSBloc>().add(OBSConnect(connection: OBSConnection(address: '192.168.1.107',password: 'holaxd')));
                }
              )
          ],
        ),
      ),
    );
  }
  

  /// devuelve el listado de las escenas y pistas de audio del obs
  Widget _buildConnected() {
    return StreamBuilder(
      stream: context.read<OBSBloc>().sceneStream,
      builder: (context, scenesSnapshot) {
        if(scenesSnapshot.hasData){
          List<OBSScene> scenes = scenesSnapshot.data!;
          log('DATOS');
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: scenes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8
            ), 
            itemBuilder: (context, index) {
              return _buildSceneItem(scenes[index]);
            },
          );
        }
          log('NADA');

        return const SizedBox();
      },
    );
  }

  Widget _buildSceneItem(OBSScene scene){
    return GestureDetector(
      onTap: () {
        
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        color: scene.isActual ? MyColors.primaryColor: Colors.white,
        child: Center(
          child: Text(
            scene.name,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(color: !scene.isActual ? MyColors.primaryColor: Colors.white,),
          ),
        ),
      ),
    );
  }

}