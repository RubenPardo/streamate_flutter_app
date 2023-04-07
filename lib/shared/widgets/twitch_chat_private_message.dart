

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/data/model/badge.dart' as BadgeModel;
import 'package:streamate_flutter_app/data/model/emote.dart';
import 'package:streamate_flutter_app/data/model/irc_message/irc_message.dart';
import 'package:streamate_flutter_app/data/model/irc_message/private_message.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_state.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
import 'package:streamate_flutter_app/shared/styles.dart';
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart' as texts;
import 'package:streamate_flutter_app/shared/widgets/user_info_widget.dart';

class TwitchChatPrivateMessage extends StatefulWidget {

  final PrivateMessage privateMessage;
  bool isFromSub = false;
  bool canInteract;


  TwitchChatPrivateMessage({super.key, required this.privateMessage, this.isFromSub = false, this.canInteract = true});

  @override
  State<StatefulWidget> createState() => _TwitchChatPrivateMessageState();

  
  
  
 
}


class _TwitchChatPrivateMessageState extends State<TwitchChatPrivateMessage>{

  bool _isPressed = false;
  late StreamSubscription mSub; // suscribirse al listener para escuchar si se pulsa otro mensaje

  @override
  void initState() {
    super.initState();
    mSub = context.read<ChatBloc>().stream.listen((event) {
      if(event is ChatResumed && _isPressed){
        // si se reanuda quitar el highlited
        setState(() {
          _isPressed = false;
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    mSub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (widget.isFromSub || !widget.canInteract) ? null : _messageClicked,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _isPressed ? MyColors.messageReslted : null,
        ),
        padding: EdgeInsets.only(right: _isPressed ? 8 :0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.privateMessage.isReply ? _buildReplyMessage(context) : Container(),
            
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                _buildMessage(context),
                _buildDeleteMessageIcon()
              ],
            )
          ],
        ),
      ),
    );
  }


  // callback cuando se pulsa un nombre de usuario
  void _userClicked(){
    Utils.showModal(context,widgetBody: UserInfoWidget(user: widget.privateMessage.user));
    context.read<ChatBloc>().add(ClickUserChat(widget.privateMessage.user));
  }

  // callback cuando se pulsa un mensaje
  void _messageClicked(){
    // si se pulsa parar el chat
    setState(() {
      _isPressed = !_isPressed;
    });
    if(_isPressed) context.read<ChatBloc>().add(ClickMessage());
  }

  Widget _buildReplyMessage(BuildContext context){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.95),
      child: Text.rich(
        
        overflow: TextOverflow.ellipsis,
        
        TextSpan(
          children: [
            WidgetSpan(
              baseline: TextBaseline.ideographic, 
              alignment: PlaceholderAlignment.baseline,
              child: Image.asset("assets/images/reply_icon.png",height: 14,width: 14,),
            ),
            const WidgetSpan(child: SizedBox(width: 8,)),
            TextSpan(
              text: "${texts.respuestaA} @${widget.privateMessage.userReply}: ${widget.privateMessage.messageReply}",
              style: textStyleChatNotice,
            ),
          ],
        )
      ),
    );
   }
  /// Funcion que construye el widget del mensaje 
  Widget _buildMessage(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(8),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.95),
      child: Text.rich(
            overflow: TextOverflow.clip,
            TextSpan(
              children: [
                // obtener badges
                ...widget.privateMessage.idSetIdbadges.map((idSetAndId) 
                    => _buildBadgeWidget(idSetAndId)),
                // nombre con el color
                _buildName(),
                // poner el mensaje
                ..._getMessageWidget(widget.privateMessage.message) 
              ]
            
            )
      ),
    );
  }

  // 
  Widget _buildDeleteMessageIcon(){
    return _isPressed 
      ? Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.delete), 
            onPressed: (){
              // BORRAR MENSAJE ---------------------------
              context.read<ChatBloc>().add(DeleteMessage(widget.privateMessage.user, widget.privateMessage));
            },
          ),
        )
      : Container();
  }

  // construimos el widget span con el nombre pero con inkwell para poder pulsar el usuario
  WidgetSpan _buildName(){
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: InkWell(
        onTap: widget.canInteract ? _userClicked : null ,
        child: Text(
          "${widget.privateMessage.user.displayName}: ",
          style: textStyleChatName(widget.privateMessage.user.colorUser),
        ),
      ));
  }

  InlineSpan _buildBadgeWidget(Map<String, String> idSetAndId) {
   String urlBadge = _getBadgeFromIdSetAndId(idSetAndId);
    if(urlBadge != ""){
      return  WidgetSpan( 
        alignment: PlaceholderAlignment.middle, 
        child: Padding(
          padding: const EdgeInsets.only(right: 3),
          child:  Image.network(_getBadgeFromIdSetAndId(idSetAndId)),
          )
      );
    }else{
      return const WidgetSpan(child:Text(""));
    }
    
  }
  
  // Map<Texto,Texto> -> _getBadgeFromIdSetAndId() -> Texto
  // partiendo de un {setId: moderator, id:"1"} obtener el url de todos 
  // los badges que hay (elemento image_url_1x de la version con la id)
  String _getBadgeFromIdSetAndId(Map<String, String> idSetAndId) {
    try{
      // obtenemos el badge con set id
      BadgeModel.Badge badge = ChatBloc.allBadges.firstWhere((badge)=>badge.setId == idSetAndId['setId']);
    // de ese badge la version
      return badge.badgeVersions.firstWhere((version) => version.id == idSetAndId['id']).imageUrls[0];
    }catch(e){
      return "";
    }
    
  }
   

  // Texto -> _getMessageWidget() -> Widget
  // transforma el texto en un TextSpan pero
  // busca en el mensaje si hay emotes y 
  //los transforma en widgetspans con image network
  List<TextSpan> _getMessageWidget(String message){

    List<String> words = message.split(" ");

    return words.map<TextSpan>((word){
      String url = _getEmoteByName(word);
      if(url != ""){
        // emote
        return TextSpan(children: [WidgetSpan(
                child: Image.network(url),
              )]);
      }else{
        // palabra
        return TextSpan(text: "$word ",style: textStyleChat);
        
      }
    }).toList();

  
  }



  // Texto -> _getEmoteByName() -> Texto
  String _getEmoteByName(String name) {
    
    name = name.trim();
    // obtenemos el emote por nombre
    try{
      Emote emote = ChatBloc.allEmotes.firstWhere((emote){
        return emote.name == name;
      });
      return emote.networkUrl;   
    }catch(e){
      return "";
    }
   
    
  }
  
}