import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/chat_setting.dart';
import 'package:streamate_flutter_app/data/model/emote.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_auth_repository.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_chat_repository.dart';
import 'package:streamate_flutter_app/domain/usecases/get_chat_settings_use_case.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_bloc.dart';

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
                StreamBuilder(
                  stream: context.read<ChatBloc>().chatSettingsStrem,
                  builder: (context, snapshot) {
                  if (snapshot.hasError){
                      // TODO devolver los botones deshabilitados
                      return const Center(child: Text("ERROR"),);
                  }
                  // TODO cambiar aqui a un widget que tenga todos los botones y 
                  // que reciba el array, si esta vacio estará todo desahibilitado
                  if (!snapshot.hasData){
                      //TODO devolver los botones deshabilitados
                      return const Center();

                  }

                  ListChatSettings listChatSettings = snapshot.data!;
                  return Column(
                    children: listChatSettings.values.map(
                      (e) => Row(
                        children: [
                          Text(e.chatSettingType.name),
                          const SizedBox(width: 8,),
                          Text(e.value)
                        ]
                      )
                    ).toList(),
                  );
                }
              )
            ],
          );
  }

    void _cerrarSesion() {
      context.read<AuthBloc>().add(LogOut()); // ---------------------> cerrar sesion         
  }

 

}