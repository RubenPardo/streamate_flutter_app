import 'package:streamate_flutter_app/data/model/chat_setting.dart';
import 'package:streamate_flutter_app/data/model/irc_message/irc_message.dart';

/// IRCMessage que se usan para avisar a la aplicación que ha cambiado 
/// los ajustes del chat, estos no se pintan en el chat
class RoomStateMessage extends IRCMessage{

  late ChatSetting chatSetting;


  RoomStateMessage(this.chatSetting) : super("",IRCCommand.roomState);

  factory RoomStateMessage.fromIRCData(String data){

    List<String> splitData = data.split(';');

    if(data.contains("emote-only")){
      // solo emoticonos
      // emote only -> 0 = true, -1 = false 
      //@emote-only=0;room-id=878422216 :tmi.twitch.tv ROOMSTATE #ruben_pardo_2
      // obtenemos el valor despues del =
      String value = splitData[0].split("=")[1];
      return RoomStateMessage(ChatSetting(ChatSettingType.emoteOnly, value));

    }else if(data.contains("followers-only")){
      // solo seguidores
      // followers-only indica minutos, -1 es desactivado
      //@followers-only=-1;room-id=878422216 :tmi.twitch.tv ROOMSTATE #ruben_pardo_2
      String value = splitData[0].split("=")[1];
      return RoomStateMessage(ChatSetting(ChatSettingType.followersOnly, value));

    }else if(data.contains("slow")){
      // modo lento
      // slow = segundos
      //@room-id=878422216;slow=0 :tmi.twitch.tv ROOMSTATE #ruben_pardo_2
      String value = splitData[1].split("=")[1];
      return RoomStateMessage(ChatSetting(ChatSettingType.slow, value));

    }else if(data.contains("subscriber_mode")){
      // modo lento
      // slow = segundos
      //@room-id=878422216;slow=0 :tmi.twitch.tv ROOMSTATE #ruben_pardo_2
      String value = splitData[1].split("=")[1];
      return RoomStateMessage(ChatSetting(ChatSettingType.subMode, value));

    }else{
      // otro tipo que por ahora no nos interesa
      return RoomStateMessage(ChatSetting(ChatSettingType.none, "-1"));
    }
  }

   @override
  String toString() {
    return "ROOMSTATE [ chatSetting:$chatSetting command:$command]";
  }

}
