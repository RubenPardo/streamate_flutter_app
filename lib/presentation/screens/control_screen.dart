import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/data/services/obs_service.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_event.dart';

class ControlScreen extends StatefulWidget {

  late TokenData tokenData;
  late User user;
  

  ControlScreen({super.key, required this.tokenData, required this.user});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          const Text("LOGEADO"),
          ElevatedButton(
            onPressed: _cerrarSesion, 
            child: const Text("Cerrar sesión")
          ),
          
      ],
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

 

}