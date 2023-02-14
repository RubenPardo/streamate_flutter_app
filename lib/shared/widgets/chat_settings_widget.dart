import 'package:flutter/material.dart';
import 'package:streamate_flutter_app/data/model/chat_setting.dart';
import 'package:streamate_flutter_app/shared/colors.dart';

class ChattSettingsWidget extends StatefulWidget {

  final ListChatSettings listChatSettings;
  final bool isPartner; // si es partner se activa el modo subs

  const ChattSettingsWidget({super.key, required this.listChatSettings, required this.isPartner});

  @override
  State<ChattSettingsWidget> createState() => _ChattSettingsWidgetState();
}

class _ChattSettingsWidgetState extends State<ChattSettingsWidget> {
  @override
  Widget build(BuildContext context) {

    print("SETTIGS ${widget.listChatSettings}");

    ChatSetting chatEmoteOnly =widget.listChatSettings.values.firstWhere((element) => element.chatSettingType == ChatSettingType.emoteOnly,orElse: () => ChatSetting(ChatSettingType.none,""));
    ChatSetting chatSubMode =widget.listChatSettings.values.firstWhere((element) => element.chatSettingType == ChatSettingType.subMode,orElse: () => ChatSetting(ChatSettingType.none,""));
    ChatSetting chatFollow =widget.listChatSettings.values.firstWhere((element) => element.chatSettingType == ChatSettingType.followersOnly,orElse: () => ChatSetting(ChatSettingType.none,""));
    ChatSetting chatSlow =widget.listChatSettings.values.firstWhere((element) => element.chatSettingType == ChatSettingType.slow,orElse: () => ChatSetting(ChatSettingType.none,""));

    return Center(
      child: Wrap(
        spacing: 16, //vertical spacing
        runSpacing: 16, //horizontal spacing
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          //modo emotes
          _buildChatSetting(
            disable: chatEmoteOnly.chatSettingType == ChatSettingType.none,
            color: chatEmoteOnly.value != "0" ? MyColors.primaryColor : Colors.white,
            textColor: chatEmoteOnly.value == "0" ? MyColors.primaryColor : Colors.white,
            onTap: () {},
            text: "MODO SEGUIDORES",
          ),
          //modo sub
           _buildChatSetting(
            disable: (chatSubMode.chatSettingType == ChatSettingType.none || !widget.isPartner),
            color: chatSubMode.value != "0" ? MyColors.primaryColor : Colors.white,
            textColor: chatSubMode.value == "0" ? MyColors.primaryColor : Colors.white,
            onTap: () {},
            text: "MODO SUB",
          ),
          //modo seguidor
         _buildChatSetting(
            disable: chatFollow.chatSettingType == ChatSettingType.none,
            color: chatFollow.value != "-1" ? MyColors.primaryColor : Colors.white,
            textColor: chatFollow.value == "-1" ? MyColors.primaryColor : Colors.white,
            onTap: () {},
            text: "MODO SEGUIDORES",
          ),
          // modo slow
          _buildChatSetting(
            disable: chatSlow.chatSettingType == ChatSettingType.none,
            color: chatSlow.value != "-1" ? MyColors.primaryColor : Colors.white,
            textColor: chatSlow.value == "-1" ? MyColors.primaryColor : Colors.white,
            onTap: () {},
            text: "MODO LENTO",
          ),

          //adds
          _buildChatSetting(
            disable: !widget.isPartner,
            color: chatSubMode.value != "0" ? MyColors.primaryColor : Colors.white,
            textColor: chatSubMode.value == "0" ? MyColors.primaryColor : Colors.white,
            onTap: () {},
            text: "Anuncios",
          ),
          

        ],
      
      ),
    );
  }
  


  

  
  Widget _buildChatSetting(
  {required Color color, required Null Function() onTap, required String text, required Color textColor, required bool disable}) {
    return Container(
      color: disable ? MyColors.backgroundColorSecondary : color,
      constraints: const BoxConstraints(maxHeight: 100, maxWidth: 100),
      child: InkWell(
        onTap: onTap, 
        child: Center(child:  Text(text, style: TextStyle(color: disable ? Colors.white : textColor),),)
      ),
    );
    
  }



}