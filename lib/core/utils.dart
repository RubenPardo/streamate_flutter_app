import 'package:flutter/material.dart';
import 'package:streamate_flutter_app/data/model/irc_message/irc_message.dart';

class Utils{

  static void showSnackBar(var context, String message){
    ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      message,
                    ),
                  ),
                );
  }


  /// Texto -> parseTextToIRCCOmmand() -> IRCCommand
  /// 
  static IRCCommand parseTextToIRCCOmmand(String commandStr){
    IRCCommand command;
    switch(commandStr) {
      case "PRIVMSG":
        command = IRCCommand.privateMessage;
        break;
      case "NOTICE":
        command = IRCCommand.notice;
        break;
      case "ROOMSTATE":
        command = IRCCommand.roomState;
        break;
      case "USERNOTICE":
        command = IRCCommand.userNotice;
        break;
      case "CLEARMSG":
        command = IRCCommand.clearMessage;
        break;
      case "USERSTATE":
        command = IRCCommand.userState;
        break;
      default:
       command = IRCCommand.none;
    }
    return command;
  }

  // Texto -> mapTagsIrcData() -> {Texto:Texto}
  static Map<String,String> mapTagsIrcData(String data){
    final mappedTags = <String, String>{};
    for (final tag in data.split(';')) {
      // Skip if the tag has no value.
      if (tag.endsWith('=')) continue;

      final tagSplit = tag.split('=');
      mappedTags[tagSplit[0]] = tagSplit[1];
    }

    return mappedTags;

  }
}