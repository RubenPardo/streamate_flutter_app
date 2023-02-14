
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:streamate_flutter_app/data/model/badge.dart';
import 'package:streamate_flutter_app/data/model/emote.dart';
import 'package:streamate_flutter_app/data/model/irc_message.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_bloc.dart';
import 'package:streamate_flutter_app/shared/extension_color.dart';
import 'package:streamate_flutter_app/shared/styles.dart';

class TwitchChatPrivateMessage extends StatelessWidget {

  PrivateMessage privateMessage;


  TwitchChatPrivateMessage({super.key, required this.privateMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.95),
                child: Text.rich(
                  overflow: TextOverflow.clip,
                  TextSpan(
                    children: [
                      // obtener badges
                      ...privateMessage.idSetIdbadges.map((idSetAndId) 
                          => _buildBadgeWidget(idSetAndId)),
                      // nombre con el color
                      TextSpan(
                        text: "${privateMessage.user.displayName}: ",
                        style: textStyleChatName(privateMessage.user.colorUser),
                      ),
                      // poner el mensaje
                      
                    ] + _getMessageWidget(privateMessage.message),
                  
                  ),
                ),
               ),
            ],
          ),
        ],
      ),
    );
  }

  InlineSpan _buildBadgeWidget(Map<String, String> idSetAndId) {
   String urlBadge = _getBadgeFromIdSetAndId(idSetAndId);
    if(urlBadge != ""){
      return  WidgetSpan( 
        alignment: PlaceholderAlignment.middle, 
        child:Padding(
          padding: const EdgeInsets.only(right: 3),
          child:  Image.network(_getBadgeFromIdSetAndId(idSetAndId)),
          )
      );
    }else{
      return WidgetSpan(child: Container());
    }
    
  }
  
  // Map<Texto,Texto> -> _getBadgeFromIdSetAndId() -> Texto
  // partiendo de un {setId: moderator, id:"1"} obtener el url de todos 
  // los badges que hay (elemento image_url_1x de la version con la id)
  String _getBadgeFromIdSetAndId(Map<String, String> idSetAndId) {
    try{
      // obtenemos el badge con set id
      Badge badge = ChatBloc.allBadges.firstWhere((badge)=>badge.setId == idSetAndId['setId']);
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
        return TextSpan(text: "$word ");
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