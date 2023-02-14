import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/emote.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_auth_repository.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_chat_repository.dart';
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
                ElevatedButton(
                  onPressed: _pruebas, 
                  child: const Text("Probar")
                ),
                 ListView.builder(
                    shrinkWrap: true,
                    itemCount: emotes.length,
                    itemBuilder: (context, index) {
                      return Image.network(emotes[index].networkUrl);
                    },
                  )
              ],
            );
  }

    void _cerrarSesion() {
      context.read<AuthBloc>().add(LogOut()); // ---------------------> cerrar sesion         
  }

  List<Emote> emotes = [];

  void _pruebas() async{
   
    var emotes1 = await serviceLocator<TwitchChatRepository>().getGlobalEmotes();
    var emotes2 = await serviceLocator<TwitchChatRepository>().getChannelEmotes(widget.user.id);
    setState(() {
      emotes.addAll(emotes1);
      emotes.addAll(emotes2);
    
    });

    for(Emote e in emotes){
      print(e.networkUrl);
    }
  }

}