
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/badge.dart';
import 'package:streamate_flutter_app/data/model/chat_settings.dart';
import 'package:streamate_flutter_app/data/model/emote.dart';

import '../../data/services/twitch_api_service.dart';

abstract class TwitchChatRepository{
  void connectChat();
  void closeChat();
  ChatSettings getChatSettings(String idBroadcaster);
  bool deleteMessage(String idBroadcaster, String idMessage);
  Future<List<Badge>> getGlobalBadges();
  Future<List<Badge>> getChannelBadges(String idBroadcaster);
  Future<List<Emote>> getGlobalEmotes();
  Future<List<Emote>> getChannelEmotes(String idBroadcaster);
}

class TwitchChatRepositoryImpl extends TwitchChatRepository{

  final TwitchApiService _apiService = serviceLocator<TwitchApiService>();

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
  Future<List<Badge>> getGlobalBadges() async{
    List<Badge> badges = [];
    var listBadgesData = await _apiService.getGlobalBadges();
    for(dynamic badgeData in listBadgesData){
      badges.add(Badge.fromApi(badgeData));
    }
    return badges;
  }

  @override
  Future<List<Badge>> getChannelBadges(String idBroadcaster) async{
    List<Badge> badges = [];
    var listBadgesData = await _apiService.getChannelBadges(idBroadcaster);
    for(dynamic badgeData in listBadgesData){
      badges.add(Badge.fromApi(badgeData));
    }
    return badges;
  }

  @override
  Future<List<Emote>> getGlobalEmotes() async{
    List<Emote> emotes = [];
    var listEmoteData = await _apiService.getGlobalEmotes();
    for(dynamic emoteData in listEmoteData){
      emotes.add(Emote.fromApi(emoteData));
    }
    return emotes;
  }

  @override
  Future<List<Emote>> getChannelEmotes(String idBroadcaster) async{
    List<Emote> emotes = [];
    var listEmoteData = await _apiService.getChannelEmotes(idBroadcaster);
    for(dynamic emoteData in listEmoteData){
      emotes.add(Emote.fromApi(emoteData));
    }
    return emotes;
  }
}