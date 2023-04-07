import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/data/model/irc_message/clear_all_messages.dart';
import 'package:streamate_flutter_app/data/model/irc_message/clear_message.dart';
import 'package:streamate_flutter_app/data/model/irc_message/notice_message.dart';
import 'package:streamate_flutter_app/data/model/irc_message/private_message.dart';
import 'package:streamate_flutter_app/data/model/irc_message/room_state_message.dart';
import 'package:streamate_flutter_app/data/model/irc_message/user_notice_message.dart';

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
          return PrivateMessage.fromIRCData(data);
        case IRCCommand.clearChat:
          return ClearMessageAll.fromIRCData(data);
        case IRCCommand.clearMessage:
          return ClearMessage.fromIRCData(data);
        case IRCCommand.notice:
          return NoticeMessage.fromIRCData(data);
        case IRCCommand.userNotice:
         return UserNoticeMessage.fromIRCData(data);
        case IRCCommand.roomState:
         return RoomStateMessage.fromIRCData(data);  
        case IRCCommand.userState:
          return IRCMessage("",IRCCommand.userState);
        case IRCCommand.globalUserState:
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