
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/data/services/twitch_api_service.dart';
import 'package:streamate_flutter_app/shared/styles.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'irce.dart';

class ChatScreen extends StatefulWidget {

  TokenData token;
  User user;

  ChatScreen({super.key, required this.token, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {


  WebSocketChannel? _channel;
  StreamSubscription? _channelListener;
  var _backoffTime = 0;
  var _retries = 0;
   /// The periodic timer used for batching chat message re-renders.
  late final Timer _messageBufferTimer;

  /// The list of chat messages to add once autoscroll is resumed.
  /// This is used as an optimization to prevent the list from being updated/shifted while the user is scrolling.
  final _messageBuffer = <IRCMessage>[];
  
  List<String> _listChat = [];

  Future<void> connectToChat( ) async {

    print("CONNECT TO CHAT");
    _channel?.sink.close(1001);
    _channel = WebSocketChannel.connect(Uri.parse('wss://irc-ws.chat.twitch.tv:443/irc'));
    //_channel?.sink.add('CAP REQ :twitch.tv/tags twitch.tv/commands');
    _channel?.sink.add('PASS oauth:${widget.token.accessToken}');
    //_channel?.sink.add('NICK ${user.login}');
    _channel?.sink.add('NICK justinfan888${widget.user.login}');
    _channel?.sink.add('JOIN #${widget.user.login}',);
    _channel?.sink.add('CAP REQ :twitch.tv/commands twitch.tv/tags',); // con esto obtenemos mas informacion en los mensjaes
    

     // Listen for new messages and forward them to the handler.
    _channelListener = _channel?.stream.listen(
      (data) => _handleIRCData(data.toString()),
      onError: (error) => debugPrint('Chat error: ${error.toString()}'),
      onDone: () async {
        print("DONE");
        if (_channel == null) return;

        if (_backoffTime > 0) {
          // Add notice that chat was disconnected and then wait the backoff time before reconnecting.
          final notice =
              'Disconnected from chat, waiting $_backoffTime ${_backoffTime == 1 ? 'second' : 'seconds'} before reconnecting...';
          _messageBuffer.add(IRCMessage.createNotice(message: notice));
        }

        await Future.delayed(Duration(seconds: _backoffTime));

        // Increase the backoff time for the next retry.
        _backoffTime == 0 ? _backoffTime++ : _backoffTime *= 2;

        // Increment the retry count and attempt the reconnect.
        _retries++;
        _messageBuffer.add(IRCMessage.createNotice(message: 'Reconnecting to chat (attempt $_retries)...'));
        _channelListener?.cancel();
        connectToChat();
      },
    );
  }


  late WebSocket _socket;



    Future<void> connectToModChat() async {
      print("connect");

      _socket = await WebSocket.connect('wss://irc-ws.chat.twitch.tv:443/irc');
      _socket.add('PASS oauth:${widget.token.accessToken}');
      _socket.add('NICK ${widget.user.login}');
      _socket.add('JOIN #${widget.user.login}');
      _socket.listen(_onMessage);
    }
    void _onMessage(dynamic message) {
      print("ON MESSAGE");
      if (message is String) {
        final parts = message.split(':');
        if (parts.length > 2) {
          final user = parts[1].split('!')[0];
          final messageC = parts.sublist(2).join(':');
          // Ahora puedes procesar el mensaje y el usuario
          // y mostrarlo en la pantalla junto con los iconos de roles.
          //var userRoleIcon = await getUserRolesIcon(user);
          if(mounted){
            setState(() {
            _listChat.add(message);
          });
          }else{
            _listChat.add(message);
          }
        }
      }
    }

  Future<void> pruebas() async{
    
    //User elTostadas = User((await serviceLocator<TwitchApiService>().getUsers(loginNames: ["ibai"],widget.token.accessToken))[0]);
    print(await serviceLocator<TwitchApiService>().updateChatSetting(widget.user.id,["follower_mode","follower_mode_duration"],["true","300"]));
    //print(await serviceLocator<TwitchApiService>().getUserColor(elTostadas.id));
    //print(await serviceLocator<TwitchApiService>().banUser(widget.user.id,elTostadas.id,duration: 300)); // okay
    //print(await serviceLocator<TwitchApiService>().unBanUser(widget.user.id,elTostadas.id)); // okay
    //print(await serviceLocator<TwitchApiService>().getChannelBadges(elTostadas.id)); //okay
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
    //connectToModChat();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _listChat.length,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Text(_listChat[index],style: textStyleChat,),
        );
      },
    );
  }
  
  _handleIRCData(String mensaje)async {
    if(mounted){
      setState(() {
      _listChat.add(mensaje);
    });
    }else{
      _listChat.add(mensaje);
    }
  }
}