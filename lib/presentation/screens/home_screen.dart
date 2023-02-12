
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/emote.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/data/services/twitch_api_service.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_auth_repository.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_chat_repository.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_sate.dart';
import 'package:streamate_flutter_app/presentation/screens/chat_screen.dart';
import 'package:streamate_flutter_app/presentation/screens/login/log_in_screen.dart';
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart';
import 'package:streamate_flutter_app/shared/widgets/app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

   // obtenemos la referencia a la subscripcion del bloc, 
   // para cuando se cierre esta ventana, cerrarla y asi tambien evitar duplicidad
  late StreamSubscription mSub;
  late AuthBloc myBloc;


  // bottom navigator ----------------------------------------------
  int _selectedIndex = 0;
  bool _isLoading = true;

  static late List<List<dynamic>> _tabsBottomNavigator;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  // -----------------------------------------------------------------

  @override
  void initState(){
    


    super.initState();
    myBloc = context.read<AuthBloc>();
    mSub = myBloc.stream.listen((stateAuth) {
      if(stateAuth is AuthUnauthenticated){
          // ha cerrado sesion salir
          // TODO cambiar a por el autorouter
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) =>  const LogInScreen(title: 'Login',),
          ));
          
          mSub.cancel();
      }
    });

    initBotom();
    
  }

  late User user;

  void initBotom()async{
    TokenData tokenData = await serviceLocator<TwitchAuthRepository>().getTokenDataLocal();
    user = await serviceLocator<TwitchAuthRepository>().getUserRemote(tokenData.accessToken);   
    _tabsBottomNavigator = [
      [Column(
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
            ),
          Icon(Icons.abc), "ALGO"],
        [ ChatScreen(token: tokenData,user: user,), Icon(Icons.chat), "Chat"],
        
      ];

      setState(() {
        _isLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(appTitle,bottom: Row(mainAxisAlignment: MainAxisAlignment.center,children: [Text("Viewers: 1000"),Text("LIVE ON 00:15:34")],)),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        items: _tabsBottomNavigator.map((e) => BottomNavigationBarItem(
            icon: e[1],
            label: e[2],
          ),
        ).toList(),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _pruebas,
      ),*/
      body: _tabsBottomNavigator[_selectedIndex][0],
    );
  }

  void _cerrarSesion() {
      context.read<AuthBloc>().add(LogOut()); // ---------------------> cerrar sesion         
  }

  List<Emote> emotes = [];

  void _pruebas() async{
    TokenData tokenData = await serviceLocator<TwitchAuthRepository>().getTokenDataLocal();
    user = await serviceLocator<TwitchAuthRepository>().getUserRemote(tokenData.accessToken);   
    var emotes1 = await serviceLocator<TwitchChatRepository>().getGlobalEmotes();
    var emotes2 = await serviceLocator<TwitchChatRepository>().getChannelEmotes(user.id);
    setState(() {
      emotes.addAll(emotes1);
      emotes.addAll(emotes2);
    
    });

    for(Emote e in emotes){
      print(e.networkUrl);
    }
  }
}