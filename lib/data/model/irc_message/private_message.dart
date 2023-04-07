import 'package:streamate_flutter_app/data/model/irc_message/irc_message.dart';
import 'package:streamate_flutter_app/data/model/user.dart';

/// Clase que representa un mensaje normal en el chat de twitch - IRCMessage
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

  factory PrivateMessage.fromIRCData(String data,{String? message}){

    var splitData = data.split(RegExp(r'PRIVMSG\s+#\w+\s+:'));
     // si el message que llega no es null es que ya se lo han pasado, por otra parte es el ultimo elemento del split anterior
    message ??= splitData[splitData.length-1];

      // mapear los tags en clave valor
    final mappedTags = <String, String>{};
  
    // Loop through each tag and store their key value pairs into the map.
    for (final tag in data.split(';')) {
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

    // los mensajes de respuesta vienen con \s en vez de espacios
    String? replyMessageBoddy =  mappedTags['reply-parent-msg-body']?.replaceAll("\\s"," ");
    String? userReply = mappedTags['reply-parent-display-name'];
    //si es una respuesta tendra los parametros de a quien responde y en el mensaje también, quitar el del mensaje
    if(userReply!=null){
      message = message.replaceFirst("@$userReply","");
    }
    
    // devolver el irc message
    return PrivateMessage(
      mappedTags['id'] ?? "", 
      badges, 
      (mappedTags['first-msg'] ?? 0) == 1, 
      User.fromIRC(mappedTags['user-id']??"",mappedTags['login']??"", mappedTags['display-name']??"", mappedTags['color']??""),
      replyMessageBoddy, 
      userReply,
      message: message.replaceAll("\n", ""));
  }


  factory PrivateMessage.dummyResub(){
    return PrivateMessage(message: "3 mesecitos ya LUL",
        "1",
        [{"set_id":"1979-revolution_1","id":"1"}],
        false,
        User("id","user-1", "user-1", "email", "profileImageUrl", "offlineImageUrl", "", "description", "ff1144", "createdAt", 12),
        null,
        null);
  }

  factory PrivateMessage.dummyConEmoji(){
    return PrivateMessage(message: "Hola LUL",
        "1",
        [{"set_id":"1979-revolution_1","id":"1"}],
        false,
        User("id","user-1", "user-1", "email", "profileImageUrl", "offlineImageUrl", "", "description", "ff1144", "createdAt", 12),
        null,
        null);
  }
  
  factory PrivateMessage.dummy(){
    return PrivateMessage.fromIRCData("@badge-info=;badges=broadcaster/1;client-nonce=839f40774a390d3610c265d414638a98;color=#DAA520;display-name=ruben_pardo_2;emotes=;first-msg=0;flags=;id=2bbc2cc4-f942-45b2-920f-999a7f107bf0;mod=0;returning-chatter=0;room-id=878422216;subscriber=0;tmi-sent-ts=1678359594270;turbo=0;user-id=878422216;user-type= :ruben_pardo_2!ruben_pardo_2@ruben_pardo_2.tmi.twitch.tv PRIVMSG #ruben_pardo_2 : Hola mi gente LUL",);
  }

  factory PrivateMessage.dummyLarge(){
    return PrivateMessage.fromIRCData("@badge-info=;badges=broadcaster/1;client-nonce=839f40774a390d3610c265d414638a98;color=#DAA520;display-name=ruben_pardo_2;emotes=;first-msg=0;flags=;id=2bbc2cc4-f942-45b2-920f-999a7f107bf0;mod=0;returning-chatter=0;room-id=878422216;subscriber=0;tmi-sent-ts=1678359594270;turbo=0;user-id=878422216;user-type= :ruben_pardo_2!ruben_pardo_2@ruben_pardo_2.tmi.twitch.tv PRIVMSG #ruben_pardo_2 : Hola xD");
  }

  factory PrivateMessage.dummyReply(){
    return PrivateMessage(message: "Hola",
        "2",
        [{"set_id":"vip","id":"1"}],
        false,
        User("id","user-2", "user-2", "email", "profileImageUrl", "offlineImageUrl", "", "description", "4411ff", "createdAt", 12),
        "Hola LUL",
        "user-1");
  }

   @override
  String toString() {
    return "PRIVMSG [id:$id, badges:$idSetIdbadges, msg:$message, isFirst:$isFirstMessage command:$command, parentName: $userReply, msgReply: $messageReply, user: $user]";
  }


}
