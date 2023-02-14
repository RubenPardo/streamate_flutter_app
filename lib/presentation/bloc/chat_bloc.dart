import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/badge.dart';
import 'package:streamate_flutter_app/data/model/emote.dart';
import 'package:streamate_flutter_app/data/model/irc_message.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_chat_repository.dart';
import 'package:streamate_flutter_app/domain/usecases/get_badges_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/get_emotes_use_case.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_state.dart';
import 'package:streamate_flutter_app/shared/widgets/twitch_chat_private_message.dart';



class ChatBloc extends Bloc<ChatEvent, ChatState> {

    static List<Emote> allEmotes =[];
    static List<Badge> allBadges =[];

    // atributos para hacer las peticiones
    late String _idBroadcaster;
    late String _accesToken;
    late String _loginUserName;

    // stream que se devuelve a la vista y el controlador para añadir objetos
    StreamController<List<Widget>> controllerWidgetIrcMessageStream = StreamController.broadcast();
    List<Widget> _chatWidgets = [];
    
    // variables para controlar la conexion con el chat
    StreamSubscription? _channelListener;
    var _backoffTime = 0;

    ChatBloc(): super(ChatUninitialized()){

      on<InitChatBloc>(// -------------------------------------------
        (event, emit) async{

          _idBroadcaster = event.idBroadcaster;
          _accesToken = event.accesToken;
          _loginUserName = event.loginName;

          
          // obtener los emotes, los emblemas, los ajustes del canal y 
          (await serviceLocator<GetEmotesUseCase>().call(_idBroadcaster))
              .fold((error) => null, (emotes) => allEmotes = emotes);
          (await serviceLocator<GetBadgesUseCase>().call(_idBroadcaster))
              .fold((error) => null, (badges) => allBadges = badges);

          // TODO obtener los ajustes del chat
          
          // conectarse al chat
          _connectToChat();

          // return Stream<Widget>
          emit(ChatConnected(controllerWidgetIrcMessageStream.stream));
        },
      );

    }


    void _connectToChat(){
      // obtenemos el stream
       _channelListener = serviceLocator<TwitchChatRepository>().connectChat(_accesToken, _loginUserName)
          .listen(
            (data) => _handleIRCData(data),
            onError: (error) => debugPrint('Chat error: ${error.toString()}'),
            onDone: () async {
              print("DONE");

              if (_backoffTime > 0) {
                // Add notice that chat was disconnected and then wait the backoff time before reconnecting.
                final notice =
                    'Disconnected from chat, waiting $_backoffTime ${_backoffTime == 1 ? 'second' : 'seconds'} before reconnecting...';
                //_messageBuffer.add(IRCMessage.createNotice(message: notice));
              }

              await Future.delayed(Duration(seconds: _backoffTime));

              // Increase the backoff time for the next retry.
              _backoffTime == 0 ? _backoffTime++ : _backoffTime *= 2;

              //_messageBuffer.add(IRCMessage.createNotice(message: 'Reconnecting to chat (attempt $_retries)...'));
              _channelListener?.cancel();
              _connectToChat();
            });

    }

    // IRCMessage ->_handleIRCData ->
    // mapear el mensaje irc a un widget y añadirlo al stream para que se pinte en la vista
    void _handleIRCData(IRCMessage mensaje)async {
      print("MENSAJE: $mensaje");
      if(mensaje is PrivateMessage){
        _chatWidgets.add(TwitchChatPrivateMessage(privateMessage: mensaje));
        
      }

      controllerWidgetIrcMessageStream.add(_chatWidgets);
    }
    
}