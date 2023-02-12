import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/data/model/user.dart';

/// Clase que representa un mensaje IRC del chat de twitch
class IRCMessage{

  late String message;
  late IRCCommand command;


  IRCMessage(this.message,this.command);


  factory IRCMessage.fromIRCData(String data){
    print(data);
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
          return IRCMessage("", IRCCommand.none);
        case IRCCommand.clearMessage:
          return IRCMessage("",IRCCommand.none);
        case IRCCommand.notice:
          return IRCMessage("",IRCCommand.none);
        case IRCCommand.userNotice:
         return IRCMessage("",IRCCommand.none);
        case IRCCommand.roomState:
         return RoomStateMessage.fromIRCData(data);  
        case IRCCommand.userState:
          return IRCMessage("",IRCCommand.none);
        case IRCCommand.globalUserState:
          return IRCMessage("",IRCCommand.none);
        default:
          return IRCMessage("",IRCCommand.none);
      }
    }else{
       return IRCMessage("",IRCCommand.none);
    }
   
    
    
  }
 
}

class RoomStateMessage extends IRCMessage{

  late ChatSettingType chatSettingType;
  // en el caso de emote only 0 o -1,
  // follower only seran los minutos o -1
  // slow sera los segundos y desactivado es 0
  late String value;

  RoomStateMessage(this.chatSettingType,this.value) : super("",IRCCommand.roomState);

  factory RoomStateMessage.fromIRCData(String data){

    List<String> splitData = data.split(';');

    if(data.contains("emote-only")){
      // solo emoticonos
      // emote only -> 0 = true, -1 = false 
      //@emote-only=0;room-id=878422216 :tmi.twitch.tv ROOMSTATE #ruben_pardo_2
      // obtenemos el valor despues del =
      String value = splitData[0].split("=")[1];
      return RoomStateMessage(ChatSettingType.emoteOnly, value);

    }else if(data.contains("followers-only")){
      // solo seguidores
      // followers-only indica minutos, -1 es desactivado
      //@followers-only=-1;room-id=878422216 :tmi.twitch.tv ROOMSTATE #ruben_pardo_2
      String value = splitData[0].split("=")[1];
      return RoomStateMessage(ChatSettingType.followersOnly, value);

    }else if(data.contains("slow")){
      // modo lento
      // slow = segundos
      //@room-id=878422216;slow=0 :tmi.twitch.tv ROOMSTATE #ruben_pardo_2
      String value = splitData[1].split("=")[1];
      return RoomStateMessage(ChatSettingType.slow, value);

    }else{
      // otro tipo que por ahora no nos interesa
      return RoomStateMessage(ChatSettingType.none, "-1");
    }
  }

   @override
  String toString() {
    return "IRCMessage [ chatSetting:$chatSettingType command:$command, value: $value]";
  }

}

enum ChatSettingType {
  followersOnly,
  emoteOnly,
  slow, none
}

class PrivateMessage extends IRCMessage{
  late String id;
  /// guardar el id del set y el id del emblema {setId:"",id:""}
  late List<Map<String,String>> idSetIdbadges;
  late bool isFirstMessage;
  late User user;
  late String? messageReply;
  late String? userReply;

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
    // TODO: implement toString
    return "IRCMessage [id:$id, badges:$idSetIdbadges, msg:$message, isFirst:$isFirstMessage command:$command, parentName: $userReply, msgReply: $messageReply, user: $user]";
  }


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