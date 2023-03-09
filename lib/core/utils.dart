import 'package:flutter/material.dart';
import 'package:streamate_flutter_app/data/model/irc_message/irc_message.dart';
import 'package:streamate_flutter_app/shared/widgets/user_info_widget.dart';

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

  static void showModal(BuildContext context,{required UserInfoWidget widgetBody}) {
    showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return widgetBody;
            },
          );
  }

  static List<Widget> removeListFromList(List<Widget> lst1, List<Widget> lst2){
    var set1 = Set.from(lst1);
    var set2 = Set.from(lst2);
    print(set1);
    print(set2);
    List<Widget> list = List.from(set1.difference(set2));
    print(list);
    return list;
  }
}