import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/data/model/chat_setting.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_event.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart' as texts;
import 'package:streamate_flutter_app/shared/styles.dart' as styles;

class ChattSettingsWidget extends StatefulWidget {

  final ListChatSettings listChatSettings;
  final bool isPartner; // si es partner se activa el modo subs

  const ChattSettingsWidget({super.key, required this.listChatSettings, required this.isPartner});

  @override
  State<ChattSettingsWidget> createState() => _ChattSettingsWidgetState();
}

class _ChattSettingsWidgetState extends State<ChattSettingsWidget> {


  final List<String> opcionesModoSeguidoresEnMinutos = ["-1","0","10","30","60","1440","10080","43200","131400"];
  final List<String> opcionesModoSeguidoresEnTexto= [texts.desactivar,"0 ${texts.minutos}","10 ${texts.minutos}","30 ${texts.minutos}","1 ${texts.hora}","1 ${texts.dia}","1 ${texts.semana}","1 ${texts.mes}","3 ${texts.meses}"];
  final List<String> opcionesModoLentoEnSegundos = ["-1","3","5","10","20","30","60","120"];
  final List<String> opcionesModoLentoEnTexto = [texts.desactivar,"3 ${texts.segundos}","5 ${texts.segundos}","10 ${texts.segundos}","20 ${texts.segundos}","30 ${texts.segundos}","60 ${texts.segundos}","120 ${texts.segundos}"];
  final List<String> duracionAnunciosEnSegundos = ["-1","30","60","90","120","150","180"];

  @override
  Widget build(BuildContext context) {

    ChatSetting chatEmoteOnly =widget.listChatSettings.values.firstWhere((element) => element.chatSettingType == ChatSettingType.emoteOnly,orElse: () => ChatSetting(ChatSettingType.none,""));
    ChatSetting chatSubMode =widget.listChatSettings.values.firstWhere((element) => element.chatSettingType == ChatSettingType.subMode,orElse: () => ChatSetting(ChatSettingType.none,""));
    ChatSetting chatFollow =widget.listChatSettings.values.firstWhere((element) => element.chatSettingType == ChatSettingType.followersOnly,orElse: () => ChatSetting(ChatSettingType.none,""));
    ChatSetting chatSlow =widget.listChatSettings.values.firstWhere((element) => element.chatSettingType == ChatSettingType.slow,orElse: () => ChatSetting(ChatSettingType.none,""));

    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //modo emotes
          _buildChatSetting(
            assetPrefix: "modo_emote",
            disable: chatEmoteOnly.chatSettingType == ChatSettingType.none,
            activado: chatEmoteOnly.value != "0",
            onTap: () {
              // poner el valor contrario
              context.read<ChatBloc>().add(ChangeChatSettings(ChatSetting(chatEmoteOnly.chatSettingType, chatEmoteOnly.value == "0" ? "1" : "0")));
            },
          ),
          //modo sub
           _buildChatSetting(
            assetPrefix: "modo_sub",
            disable: (chatSubMode.chatSettingType == ChatSettingType.none),
            activado: chatSubMode.value != "0",
            onTap: () {
              // poner el valor contrario
              context.read<ChatBloc>().add(ChangeChatSettings(ChatSetting(chatSubMode.chatSettingType, chatSubMode.value == "0" ? "1" : "0")));
            },
          ),
          //modo seguidor
         _buildChatSetting(
            assetPrefix: "modo_seguidores",
            disable: chatFollow.chatSettingType == ChatSettingType.none,
            activado: chatFollow.value != "-1",
            onTap: () {
              if(chatFollow.chatSettingType != ChatSettingType.none ) {
                _buildChatSettingDialog(texts.followersOnlyTitle, texts.followersOnlyBody, chatFollow, opcionesModoSeguidoresEnMinutos,opcionesModoSeguidoresEnTexto);
              }
            },
          ),
          // modo slow
          _buildChatSetting(
            assetPrefix: "modo_lento",
            disable: chatSlow.chatSettingType == ChatSettingType.none,
            activado: chatSlow.value != "-1",
            onTap: () {
              if(chatFollow.chatSettingType != ChatSettingType.none ) {
                _buildChatSettingDialog(texts.slowModeTitle, texts.slowModeBody, chatSlow, opcionesModoLentoEnSegundos, opcionesModoLentoEnTexto);
              }
            },
          )

        ],
      
      ),
    );
  }
  

  /// params:
  /// [title] Titulo del dialog
  /// [description] descripcion del dialog,
  /// [chatSetting] objeto chat setting al cual se modificará
  /// [options] los valores que admite
  /// [optionLabels] eitquetas que se mostraran, debe coincidir en tamaño con el array anterior
  ///
  void _buildChatSettingDialog(String title,String description, ChatSetting chatSetting, List<String> options,List<String> optionLabels){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          titleTextStyle:Theme.of(context).textTheme.headlineMedium?.copyWith(color: MyColors.textoSobreClaro,fontSize: 24,fontWeight: FontWeight.bold),
          contentTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: MyColors.textoSobreClaro),
          
          title:  Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(description,style: styles.textStyleAlertDialogBody), 
              const SizedBox(height: 32,),
              Container(

                decoration: BoxDecoration(
                  color: MyColors.primaryColor, borderRadius: BorderRadius.circular(10),
                  
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left:12),
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: chatSetting.value,
                      onChanged: (value){
                            context.read<ChatBloc>().add(ChangeChatSettings(ChatSetting(chatSetting.chatSettingType, value!)));
                            Navigator.pop(context);
                          },
                        items: options.map((e) {
                          log(optionLabels[options.indexOf(e)]);
                          return DropdownMenuItem<String>(
                            value: e,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Center(child: Text(optionLabels[options.indexOf(e)],textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white,fontWeight: FontWeight.bold),))),
                      
                        );
                      }).toList(),
                    ),
                  )
                )
              ) 
            ]
          ),
          
        );
      },
    );
  }

  /// Construye un boton para los chat settings
  /// params:
  /// 
  /// [color]
  /// [text]
  /// [textColor]
  /// [disable]
  /// [assetPrefix] una de estas opciones: [modo_sub, modo_lento, modo_seguidores,modo_emote], con este prefijo hara la referencia al asset
  ///
  Widget _buildChatSetting(
  { required Null Function() onTap, required bool disable, required bool activado, required assetPrefix}) {
    return Container(
      margin: const EdgeInsets.all(8),

      decoration:  BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // if(disable) { gris } else{ if(activado){ morado } else{ blanco }}
        color: disable ? MyColors.backgroundColorSecondary : activado ? MyColors.primaryColor : Colors.white,
      ),
      constraints: const BoxConstraints(maxHeight: 36, maxWidth: 36),
      child: InkWell(
        onTap: onTap, 
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(child:  Image.asset('assets/images/${assetPrefix}_${activado ? "activado": "desactivado"}.png'),),
        )
        
      ),
    );
    
  }



}