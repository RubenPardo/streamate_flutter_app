/// Clase que representa los mensajes que srive como 
/// avisos que salen en el chat al producirse un cambio
/// como que cambiaron el modo de chat
import 'package:streamate_flutter_app/data/model/irc_message/irc_message.dart';

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
