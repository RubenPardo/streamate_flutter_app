
import 'package:streamate_flutter_app/data/model/badge.dart';
import 'package:streamate_flutter_app/data/model/chat_settings.dart';
import 'package:streamate_flutter_app/data/model/emote.dart';

abstract class TwitchChatRepository{
  void connectChat();
  void closeChat();
  ChatSettings getChatSettings(String idBroadcaster);
  bool deleteMessage(String idBroadcaster, String idMessage);
  List<Badge> getGlobalBadges();
  List<Badge> getChannelBadges(String idBroadcaster);
  List<Emote> getGlobalEmotes();
  List<Emote> getChannelEmotes(String idBroadcaster);
}

class TwitchChatRepositoryImpl extends TwitchChatRepository{


  @override
  void connectChat() {
  // implementación para conectar al chat
  }

  @override
  void closeChat() {
  // implementación para cerrar la conexión del chat
  }

  @override
  ChatSettings getChatSettings(String idBroadcaster) {
  // implementación para obtener la configuración del chat
    throw UnimplementedError();
  }

  @override
  bool deleteMessage(String idBroadcaster, String idMessage) {
  // implementación para eliminar un mensaje del chat
    throw UnimplementedError();
  }

  @override
  List<Badge> getGlobalBadges() {
  // implementación para obtener los emblemas globales
  throw UnimplementedError();
  }

  @override
  List<Badge> getChannelBadges(String idBroadcaster) {
  // implementación para obtener los emblemas del canal
  throw UnimplementedError();
  }

  @override
  List<Emote> getGlobalEmotes() {
  // implementación para obtener los emoticonos globales
  throw UnimplementedError();
  }

  @override
  List<Emote> getChannelEmotes(String idBroadcaster) {
  // implementación para obtener los emoticonos del canal
  throw UnimplementedError();
  }
}