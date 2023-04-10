import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:streamate_flutter_app/data/model/irc_message/irc_message.dart';
import 'package:streamate_flutter_app/data/model/obs_event_type.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
import 'package:streamate_flutter_app/shared/widgets/user_info_widget.dart';
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart' as texts;
import 'package:streamate_flutter_app/shared/styles.dart' as styles;

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
      case "CLEARCHAT":
        command = IRCCommand.clearChat;
        break;
      default:
       command = IRCCommand.none;
    }
    return command;
  }

   /// Texto -> mapTextToOBSEvent() -> EventObs
  /// 
  static ObsEvent mapTextToOBSEvent(String text){
    ObsEvent event;
    switch(text) {
      case "CurrentProgramSceneChanged":
        event = ObsEvent.currentProgramSceneChanged;
        break;
      case "InputVolumeChanged":
        event = ObsEvent.inputVolumeChanged;
        break;
      case "SceneNameChanged":
        event = ObsEvent.sceneNameChanged;
        break;
      default:
       event = ObsEvent.none;
    }
    return event;
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

  static void showConfirmDialog(BuildContext context, String title, Widget content, Function() confirmMethod, {String confrimText = "Confirmar",}){
    showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: MyColors.backgroundColorClaro,
          shape:  const RoundedRectangleBorder( borderRadius: BorderRadius.all(Radius.circular(12))),
          title: Text(title, style: styles.textStyleAlertDialogTitle,),
          content: content,
          actions: [
            TextButton(onPressed: (){
              Navigator.of(context).pop(); // dismiss dialog
            }, child: const Text(texts.cancel)),
            ElevatedButton(
              onPressed: confirmMethod, child: Text(confrimText),
              style: ButtonStyle(elevation: MaterialStateProperty.resolveWith<double>(  // As you said you dont need elevation. I'm returning 0 in both case
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled)) {
                    return 0;
                  }
                  return 0; // Defer to the widget's default.
                },
              )),),
          ],
        );
    });
  }


  static bool isAudioSource(String sourceType){
    return ['screen_capture','coreaudio_input_capture','coreaudio_output_capture','coreaudio_output_capture',].contains(sourceType);
  }

}