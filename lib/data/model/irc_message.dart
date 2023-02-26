import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/data/model/chat_setting.dart';
import 'package:streamate_flutter_app/data/model/user.dart';

/// Clase que representa un mensaje IRC del chat de twitch
class IRCMessage{

  late String message;
  late IRCCommand command;


  IRCMessage(this.message,this.command);


  factory IRCMessage.fromIRCData(String data){
    // averiguar que tipo de mensaje es
    final parts = data.split(" ");
    // comprobamos que no sea un PING
    if(parts[0] != "PING"){
        // el comando siempre esta en la 3 posicion 
      final command = Utils.parseTextToIRCCOmmand(parts[2]);

      switch(command){
        
        case IRCCommand.privateMessage:
          // para obtener el mensaje en sí hay que dividir por : y pillar el ultimo elemento
          final msgSplit = data.split(":");
          return PrivateMessage.fromIRCData(parts[0],msgSplit[msgSplit.length-1]);
        case IRCCommand.clearChat:
        // TODO mapear 
          return IRCMessage("", IRCCommand.clearChat);
        case IRCCommand.clearMessage:
           // TODO mapear 
          return IRCMessage("",IRCCommand.clearMessage);
        case IRCCommand.notice:
          return NoticeMessage.fromIRCData(data);
        case IRCCommand.userNotice:
          //IRC [message: @badge-info=;badges=moderator/1,partner/1;color=#54BC75;display-name=Moobot;emotes=;flags=;id=feabeb1b-7e7f-4fc9-92fe-365f841671df;login=moobot;mod=1;msg-id=announcement;msg-param-color=PRIMARY;room-id=83232866;subscriber=0;system-msg=;tmi-sent-ts=1676308167959;user-id=1564983;user-type=mod :tmi.twitch.tv USERNOTICE #ibai :Si queréis apuntaros como jugadoras de la Queens League: https://www.infojobs.net/barcelona/deportista-profesional-para-queens-league/of-i0177a442274e8384b5890ba28d5856
          //@badge-info=subscriber/15;badges=subscriber/12,premium/1;color=#0000FF;display-name=cultuayaax;emotes=;flags=;id=ef849818-825a-46e5-bed9-b39c89a7d6c8;login=cultuayaax;mod=0;msg-id=resub;msg-param-cumulative-months=15;msg-param-months=0;msg-param-multimonth-duration=0;msg-param-multimonth-tenure=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Channel\sSubscription\s(ibaailvp);msg-param-sub-plan=Prime;msg-param-was-gifted=false;room-id=83232866;subscriber=1;system-msg=cultuayaax\ssubscribed\swith\sPrime.\sThey've\ssubscribed\sfor\s15\smonths!;tmi-sent-ts=1676308226752;user-id=473618573;user-type= :tmi.twitch.tv USERNOTICE #ibai :Vamooos KOI
          // se diferencia en msg-id = anouncment, resub, sub
          // TODO mapear user notice
         return IRCMessage("",IRCCommand.userNotice);
        case IRCCommand.roomState:
         return RoomStateMessage.fromIRCData(data);  
        case IRCCommand.userState:
        // TODO mapear 
          return IRCMessage("",IRCCommand.userState);
        case IRCCommand.globalUserState:
        // TODO mapear 
          return IRCMessage("",IRCCommand.globalUserState);
        default:
          return IRCMessage("",IRCCommand.none);
      }
    }else{
       return IRCMessage("",IRCCommand.none);
    }
   
    
    
  }

  @override
  String toString() {
    return "IRC [message: $message, command: $command]";
  }
 
}

/// estos mensajes se usarán para avisar a la aplicación que ha cambiado 
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

// avisos que salen en el chat al producirse un cambio
class NoticeMessage extends IRCMessage{
  NoticeMessage({required String message}):super(message,IRCCommand.notice);


  factory NoticeMessage.fromIRCData(String data){
    //@msg-id=followers_on :tmi.twitch.tv NOTICE #ruben_pardo_2 :This room is now in 1 hour followers-only mode.
    // TODO averiguar como pasarlo al español
    List<String> dataSplitDots = data.split(":"); // [@msg-id=followers_on , tmi.twitch.tv NOTICE #ruben_pardo_2 , This room is now in 1 hour followers-only mode.]
    
    String message = dataSplitDots[dataSplitDots.length-1];
    
    return NoticeMessage(message: message);
  }
  
  @override
  String toString() {
    return "NOTICE [message: $message, command: $command]";
  }
}
/// mensajes normales que se pintarán en el chat
class PrivateMessage extends IRCMessage{
  late String id;
  /// guardar el id del set y el id del emblema {setId:"",id:""}
  late List<Map<String,String>> idSetIdbadges;
  late bool isFirstMessage;
  late User user;
  late String? messageReply;
  late String? userReply;

  get isReply => messageReply !=null && userReply !=null;

  PrivateMessage(this.id, this.idSetIdbadges, this.isFirstMessage, this.user, this.messageReply,this.userReply,
  {required String message}) 
  : super(message, IRCCommand.privateMessage);

  factory PrivateMessage.fromIRCData(String tags,String msg){
      // mapear los tags en clave valor
    final mappedTags = <String, String>{};
    

    // Loop through each tag and store their key value pairs into the map.
    for (final tag in tags.split(';')) {
      // Skip if the tag has no value.
      if (tag.endsWith('=')) continue;

      final tagSplit = tag.split('=');
      mappedTags[tagSplit[0]] = tagSplit[1];
    }

    // mapear los badges
    // de badges=moderator/1,founder/0,premium/1 a [{setId:"moderator",id:"1"},{..}]
    List<Map<String,String>> badges = (mappedTags['badges']!=null) 
          ? mappedTags['badges']!.split(",").map((e){
            // e == moderator/1
            var splitE = e.split("/");
            return {"setId":splitE[0],"id":splitE[1]};
          }).toList()
          : [];

    // devolver el irc message
    return PrivateMessage(
      mappedTags['id'] ?? "", 
      badges, 
      (mappedTags['first-msg'] ?? 0) == 1, 
      User.fromIRC(mappedTags['user-id']??"", mappedTags['display-name']??"", mappedTags['color']??""),
      mappedTags['reply-parent-msg-body'], 
      mappedTags['reply-parent-display-name'],
      message: msg);
  }

   @override
  String toString() {
    return "PRIVMSG [id:$id, badges:$idSetIdbadges, msg:$message, isFirst:$isFirstMessage command:$command, parentName: $userReply, msgReply: $messageReply, user: $user]";
  }


}

class UserNoticeMessage extends IRCMessage{

  //bool isPrime; // para mostrar la corona en el caso de que sea prime o la estrella si es normal

  UserNoticeMessage({required String message}):super(message,IRCCommand.userNotice);
  
}

enum IRCCommand{
  privateMessage,//when a user posts a chat message in the chat room
  clearChat, //all messages are removed from the chat room, or all messages for a specific user are removed from the chat room
  clearMessage, //when a specific message is removed from the chat room
  notice, // to indicate whether a command succeeded or failed. For example, a moderator tried to ban a user that was already banned
  userNotice,//when events like user subscriptions occur
  roomState,// when a bot joins a channel or a moderator changes the chat room’s chat settings
  userState,//when a user joins a channel or the bot sends a PRIVMSG message
  globalUserState,//when a bot connects to the server
  none
}