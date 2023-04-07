
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
import 'package:streamate_flutter_app/presentation/bloc/chat_state.dart';
import 'package:streamate_flutter_app/presentation/screens/chat_screen.dart';
import 'package:streamate_flutter_app/presentation/screens/control_screen.dart';
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
  late StreamSubscription mSubAuthBloc;
  // para recibir los mensajes de si el chat se ha parado o no 
  late StreamSubscription mSubChatBloc;


  // bottom navigator ----------------------------------------------
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isError = false;

  static List<List<dynamic>> _tabsBottomNavigator = [[Center(),Center()],[Center(),Center()]];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  // -----------------------------------------------------------------
  late User _user;
  late TokenData _tokenData;

  bool _isChatPaused = false;
  bool _isEventsOnly = false;
  final int _chatIndex = 1;


  @override
  void initState(){
    
    super.initState();

    mSubAuthBloc = context.read<AuthBloc>().stream.listen((stateAuth) {
      if(stateAuth is AuthUnauthenticated){
          // ha cerrado sesion salir
          // TODO cambiar a por el autorouter
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) =>  const LogInScreen(title: 'Login',),
          ));
          
          mSubAuthBloc.cancel();
      }
    });

    mSubChatBloc = context.read<ChatBloc>().stream.listen((state) {
      if(state is ChatPaused){
          setState(() {
            _isChatPaused = true;
          });
        }
        if(state is ChatResumed){
          setState(() {
            _isChatPaused = false;
          });
        }
    });

    initBotom();
    
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    mSubChatBloc.cancel();
  }

  void initBotom()async{
      setState(() {
        _isLoading = true;
        _isError = false;
      });
      
    try{
      _tokenData = await serviceLocator<TwitchAuthRepository>().getTokenDataLocal();
      _user = await serviceLocator<TwitchAuthRepository>().getUserRemote(_tokenData.accessToken); 
       // inicializar el chat
      context.read<ChatBloc>().add(InitChatBloc(_user, _tokenData.accessToken));

      _tabsBottomNavigator = [
          [ ControlScreen(tokenData: _tokenData, user: _user),Icon(Icons.abc), "ALGO"],
          [ ChatScreen(token: _tokenData,user: _user,), Icon(Icons.chat), "Chat"],
          
      ];

       setState(() {
          _isLoading = false;
      });

        
    
    }catch(e){
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(appTitle, bottom: Center(child: Text("PRUEBA"),),
        actions: [
          _selectedIndex == _chatIndex 
            ? _buildPauseChatButton() : Container(),
          _selectedIndex == _chatIndex 
            ? _buildFilterChatButton() : Container()
        ] 
      ),
      bottomNavigationBar: (_isLoading || _isError) ? null : BottomNavigationBar(
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
          : _isError ? _buildError() : _tabsBottomNavigator[_selectedIndex][0],
    );
  }
  
  _buildError() {
    return RefreshIndicator(
      onRefresh: () async{
        initBotom();
      },
      child: ListView(
        children: const[
          Center(child: Text("Ha ocurrido un error, desliza para actualizar"),)
        ],
      ), 
    );
  }

  Widget _buildPauseChatButton(){
    return IconButton(onPressed: (){
      if(!_isChatPaused){
        context.read<ChatBloc>().add(StopChat());
      }else{
        context.read<ChatBloc>().add(ResumeChat());
      }
      
    }, icon: Icon(_isChatPaused ? Icons.play_arrow  : Icons.pause));
  }

  Widget _buildFilterChatButton(){
    return IconButton(onPressed: (){
      setState(() {
        _isEventsOnly = !_isEventsOnly;
      });
      context.read<ChatBloc>().add(FilterChat(_isEventsOnly));
      
    }, icon: Icon(_isEventsOnly ? Icons.filter_alt_off  : Icons.filter_alt));
  }


}