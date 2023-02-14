
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/irc_message.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/data/services/twitch_api_service.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_chat_repository.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_state.dart';
import 'package:streamate_flutter_app/shared/styles.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


class ChatScreen extends StatefulWidget {

  TokenData token;
  User user;

  ChatScreen({super.key, required this.token, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {


  StreamSubscription? _channelListener;
  var _backoffTime = 0;
  var _retries = 0;

  /// The list of chat messages to add once autoscroll is resumed.
  /// This is used as an optimization to prevent the list from being updated/shifted while the user is scrolling.
  final _messageBuffer = <IRCMessage>[];
  
  List<String> _listChat = [];
/*
  Future<void> connectToChat( ) async {

    print("Connect chat");
    Stream<dynamic> ircChatStream = serviceLocator<TwitchChatRepository>().connectChat(widget.token.accessToken, widget.user.login);
    

     // Listen for new messages and forward them to the handler.
    _channelListener = ircChatStream.listen(
      (data) => _handleIRCData(data.toString()),
      onError: (error) => debugPrint('Chat error: ${error.toString()}'),
      onDone: () async {
      
        if (_backoffTime > 0) {
          // Add notice that chat was disconnected and then wait the backoff time before reconnecting.
          final notice =
              'Disconnected from chat, waiting $_backoffTime ${_backoffTime == 1 ? 'second' : 'seconds'} before reconnecting...';
          //_messageBuffer.add(IRCMessage.createNotice(message: notice));
        }

        await Future.delayed(Duration(seconds: _backoffTime));

        // Increase the backoff time for the next retry.
        _backoffTime == 0 ? _backoffTime++ : _backoffTime *= 2;

        // Increment the retry count and attempt the reconnect.
        _retries++;
        //_messageBuffer.add(IRCMessage.createNotice(message: 'Reconnecting to chat (attempt $_retries)...'));
        _channelListener?.cancel();
        connectToChat();
      },
    );
  }

*/
  Future<void> pruebas() async{
    
    
    //print(await serviceLocator<TwitchApiService>().updateChatSetting(widget.user.id,["follower_mode","follower_mode_duration"],["true","300"]));
    //print(await serviceLocator<TwitchApiService>().getUserColor(elTostadas.id));
    //print(await serviceLocator<TwitchApiService>().banUser(widget.user.id,elTostadas.id,duration: 300)); // okay
    //print(await serviceLocator<TwitchApiService>().unBanUser(widget.user.id,elTostadas.id)); // okay
    //okay
    //print(await serviceLocator<TwitchApiService>().getGlobalBadges()); // okay
    //print(await serviceLocator<TwitchApiService>().getGlobalEmotes()); // okay
    //print(await serviceLocator<TwitchApiService>().getChannelEmotes(elTostadas.id)); // okay
   /* String templateEmote = 'https://static-cdn.jtvnw.net/emoticons/v2/{{id}}/{{format}}/{{theme_mode}}/{{scale}}';
    //https://static-cdn.jtvnw.net/emoticons/v2/emotesv2_11271365da594d03880b1bcaa400cea0/animated/light/3.0
    var rawEmote = (await serviceLocator<TwitchApiService>().getGlobalEmotes())[0];
    networkEmote = templateEmote.replaceAll('{{id}}', rawEmote['id']); // okay
    networkEmote = networkEmote.replaceAll('{{format}}', rawEmote['format'][1]); // okay
    networkEmote = networkEmote.replaceAll('{{theme_mode}}', rawEmote['theme_mode'][1]); // okay
    networkEmote = networkEmote.replaceAll('{{scale}}', rawEmote['scale'][2]); // okay*/
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pruebas();

    //connectToChat();
  }

  @override
  Widget build(BuildContext context) {
    return  BlocConsumer<ChatBloc, ChatState>( 
      listener: (context, state) {
        
      },
      builder: (context, state) {
        if(state is ChatConnected){
          return _buildChat(state);
        }

        return Center();
      },
      
    );
     
  }
  
  Widget _buildChat(ChatConnected state) {
    return StreamBuilder(
        stream: state.chatStream,
        builder: (context, snapshot) {
          if (snapshot.hasError){
              //return error message
              return Center(child: Text("ERROR"),);
          }

          if (!snapshot.hasData){
              //return a loader
              return Center(child: Text("CARGANDO"),);

          }

          //else you have data
          List<Widget> _chat = snapshot.data!;
          // do your thing with ListView.builder
          return SingleChildScrollView(
            reverse: true, // hacer que siempre 
            child: ListView.builder(
              itemCount: _chat.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _chat[index];
              },
            )
          );
        },
      );
  }
  
}