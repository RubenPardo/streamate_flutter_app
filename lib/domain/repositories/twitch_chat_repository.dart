
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/badge.dart';
import 'package:streamate_flutter_app/data/model/chat_setting.dart';
import 'package:streamate_flutter_app/data/model/emote.dart';
import 'package:streamate_flutter_app/data/model/irc_message.dart';
import 'package:streamate_flutter_app/data/services/twitch_irc_service.dart';

import '../../data/services/twitch_api_service.dart';

/// Repositorio que tiene las funcionalidades del chat de twitch
/// accede a los servicios de api y irc
abstract class TwitchChatRepository{
  Stream<IRCMessage> connectChat(String accessToken, String loginName);
  Future<ListChatSettings> getChatSettings(String idBroadcaster);
  Future<ListChatSettings> updateChatSetting(String idBroadcaster, List<String>params, List<String> values);
  bool deleteMessage(String idBroadcaster, String idMessage);
  Future<List<Badge>> getGlobalBadges();
  Future<List<Badge>> getChannelBadges(String idBroadcaster);
  Future<List<Emote>> getGlobalEmotes();
  Future<List<Emote>> getChannelEmotes(String idBroadcaster);
}

class TwitchChatRepositoryImpl extends TwitchChatRepository{

  final TwitchApiService _apiService = serviceLocator<TwitchApiService>();
  final TwitchIRCService _ircService = serviceLocator<TwitchIRCService>();


  // Texto, Texto -> conncetChat() -> Stream<IRCMessage>
  @override
  Stream<IRCMessage> connectChat(String accessToken, String loginName) {
    return _ircService.connectChat(accessToken, loginName).map((data) => IRCMessage.fromIRCData(data));
  }


  // Texto -> getChatSettings -> ListChatSettings
  @override
  Future<ListChatSettings> getChatSettings(String idBroadcaster) async{

    // obtenemos el map de la api
    var mapChatSettings = await _apiService.getChatSettings(idBroadcaster);
    // lo mapeamos y lo devolemos
    ListChatSettings listChatSettings = ListChatSettings.fromApi(mapChatSettings);
    
    return listChatSettings;

  }

   @override
  Future<ListChatSettings> updateChatSetting(String idBroadcaster,  List<String>params, List<String> values) async{

    // obtenemos el map de la api
    var mapChatSettings = await _apiService.updateChatSetting(idBroadcaster,params,values);
    // lo mapeamos y lo devolemos
    ListChatSettings listChatSettings = ListChatSettings.fromApi(mapChatSettings);
    
    return listChatSettings;
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