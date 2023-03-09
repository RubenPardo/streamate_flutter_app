import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/data/model/irc_message/irc_message.dart';

/// este mensaje llega cuando se borra todo el chat o se banea un usuario
/// que en ese ultimo caso se borran todos los mensajes de ese usuario
class ClearMessageAll extends IRCMessage{
  
  String? user;// si no es null se borran solo los de este

  ClearMessageAll(this.user,String message,) : super (message, IRCCommand.clearChat);

  factory ClearMessageAll.fromIRCData(String data){
    //@room-id=878422216;tmi-sent-ts=1678361456312 :tmi.twitch.tv CLEARCHAT #ruben_pardo_2
 
    var splitData = data.split(":");
    String? user = splitData.last;

    String message;
    if(user.contains("CLEARCHAT")) {
      user = null;
      message = "Se borrarón todos los mensajes de la sala";
    }else{
      user = user.replaceAll("\n", "");
      user = user.trim();
       message = "Se borrarón todos los mensajes de $user";
    }


    return ClearMessageAll(user, message);


  }
  
}