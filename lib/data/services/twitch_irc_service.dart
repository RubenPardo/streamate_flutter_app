import 'package:web_socket_channel/web_socket_channel.dart';

/// service que accede al websocket para conectarse al canal IRC 
/// de un chat de twitch específico
abstract class TwitchIRCService{
  Stream<dynamic> connectChat(String accesToken, String loginName);
  void closeChat();
}

class TwitchIRCServiceImpl implements TwitchIRCService{
 
  WebSocketChannel? channel;
    

  @override
  void closeChat() {
    // TODO: implement closeChat
  }

  /// Texto, Texto -> conncetChat() -> Stream<dynamic>
  /// 
  /// Obtener el stream del chat IRC del canal de twitch con [loginName] 
  /// necesitamos el [accesToken] para realizar la operación
  @override
  Stream<dynamic> connectChat(String accesToken, String loginName) {

    channel?.sink.close(1001); // cuando se reconecta vuelve a llamar al conectar, por tanto si esta abierto lo cerramos
    channel = WebSocketChannel.connect(Uri.parse('wss://irc-ws.chat.twitch.tv:443/irc'));

    channel!.sink.add('PASS oauth:$accesToken');
    channel!.sink.add('NICK $loginName');
    channel!.sink.add('JOIN #$loginName',); // TODO cambiar
    channel!.sink.add('CAP REQ :twitch.tv/commands twitch.tv/tags',); // con esto obtenemos mas informacion en los mensjaes
    
    return channel!.stream;/*listen(
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
    );*/
  }

}