
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_auth_repository.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_sate.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_event.dart';
import 'package:streamate_flutter_app/presentation/screens/chat_screen.dart';
import 'package:streamate_flutter_app/presentation/screens/login/control_screen.dart';
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
  late User _user;
  late TokenData _tokenData;


  @override
  void initState(){
    
    super.initState();

    mSub = context.read<AuthBloc>().stream.listen((stateAuth) {
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



  void initBotom()async{
      setState(() {
        _isLoading = true;
      });
      
    _tokenData = await serviceLocator<TwitchAuthRepository>().getTokenDataLocal();
    _user = await serviceLocator<TwitchAuthRepository>().getUserRemote(_tokenData.accessToken); 
    
     // inicializar el chat
    context.read<ChatBloc>().add(InitChatBloc(_user.id, _tokenData.accessToken, _user.login));

    _tabsBottomNavigator = [
        [ ControlScreen(tokenData: _tokenData, user: _user),Icon(Icons.abc), "ALGO"],
        [ ChatScreen(token: _tokenData,user: _user,), Icon(Icons.chat), "Chat"],
        
    ];

      setState(() {
        _isLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(appTitle,bottom: Row(mainAxisAlignment: MainAxisAlignment.center,children: [Text("Viewers: 1000"),Text("LIVE ON 00:15:34")],)),
      bottomNavigationBar: _isLoading ? null : BottomNavigationBar(
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        items: _tabsBottomNavigator.map((e) => BottomNavigationBarItem(
            icon: e[1],
            label: e[2],
          ),
        ).toList(),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(),)
          :_tabsBottomNavigator[_selectedIndex][0],
    );
  }

}