import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:streamate_flutter_app/data/model/irc_message.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
import 'package:streamate_flutter_app/shared/styles.dart';
import 'package:streamate_flutter_app/shared/widgets/twitch_chat_private_message.dart';
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart' as texts; 

class TwitchChatUserNoticeMessage extends StatelessWidget{
  final UserNoticeMessage userNoticeMessage;
  
  const TwitchChatUserNoticeMessage({super.key, required this.userNoticeMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors.userNoticeBackground,
      child: _buildWidget(userNoticeMessage,context)
    );
  }

  /// funcion para poder extraer el switch del metodo build y asi poder poner un padre comun
  /// Se hace un switch del tipo de [userNoticeMessage] y decide que widget pintar
  Widget _buildWidget(UserNoticeMessage userNoticeMessage, BuildContext context){
    switch(userNoticeMessage.runtimeType){
      case SubscriptionNotice:
        return _buildSubWidget (userNoticeMessage as SubscriptionNotice, context);
      case SubMysterGift:
        return _buildSubMysterGiftWidget(userNoticeMessage as SubMysterGift, context);
      case SubGift:
        return _buildSubGiftWidget(userNoticeMessage as SubGift, context);
      case Announcement:
        return _buildAnnouncementWidget(userNoticeMessage as Announcement, context);
      default:
      // TODO quitar
       return Container(
          padding: const EdgeInsets.all(16),
          color: MyColors.userNoticeBackground,
          child: Column(
            children: [
              Text("${userNoticeMessage.msgId} ${userNoticeMessage.message}"),
              
            ],
          )
        );
    }
  }

  /// widget que representa un suscripción
  Widget _buildSubWidget(SubscriptionNotice subscriptionNotice, BuildContext context){
    return Container(
      padding: const EdgeInsets.all( 8),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text.rich(
              overflow: TextOverflow.clip,
              TextSpan(
                children: [
                  // imagen
                  WidgetSpan(
                    baseline: TextBaseline.ideographic, 
                    alignment: PlaceholderAlignment.baseline,
                    child: Image.asset( subscriptionNotice.isPrime ? "assets/images/prime_logo.png" : "assets/images/sub_tier.png",height: 14,width: 14,),
                  ),
                    const WidgetSpan(child: SizedBox(width: 8,),),
                  TextSpan(
                    text: subscriptionNotice.user.displayName,
                    style: textStyleChatUserNoticeTitleSub,
                  ),
                  const WidgetSpan(child: SizedBox(width: 4,),),
                  TextSpan(
                    text: userNoticeMessage.message,
                    style: textStyleChatUserNoticeBody,)
                  // user y mensaje de sub
                  ],
              ),
            ),
            // si el usuario ha escrito un mensaje mostrarlo
            subscriptionNotice.haveMessage 
              ? TwitchChatPrivateMessage(privateMessage: subscriptionNotice.privateMessage!)
              : Container()
          ],
      )
    );
  }

  /// widget que el mensaje de que alguien a regalado x suscripciones
  Widget _buildSubMysterGiftWidget(SubMysterGift subscriptionNotice, BuildContext context){
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 8,),
            Image.asset( "assets/images/sub_gift_icon.png",height: 50,width: 50,),
            const SizedBox(width: 8,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text( 
                    userNoticeMessage.user.displayName,
                    style: textStyleChatUserNoticeTitleGiftMyster,
                  ),
                  const SizedBox(height: 8,),
                  Text( 
                    userNoticeMessage.message,
                    style: textStyleChatUserNoticeBody,
                    overflow: TextOverflow.clip,
                  )
                ],
              ),
            )
          ],
        )
      );
    }

  /// widget que representa un suscripción regalada
  Widget _buildSubGiftWidget(SubGift subscriptionNotice, BuildContext context){
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text.rich(
              overflow: TextOverflow.clip,
              TextSpan(
                children: [
                  // imagen
                  WidgetSpan(
                    baseline: TextBaseline.ideographic, 
                    alignment: PlaceholderAlignment.baseline,
                    child: Image.asset("assets/images/sub_gift_icon.png",height: 14,width: 14,),
                  ),
                    const WidgetSpan(child: SizedBox(width: 4,),),
                  TextSpan(
                    text: subscriptionNotice.user.displayName,
                    style: textStyleChatUserNoticeBody.copyWith(fontWeight: FontWeight.bold),),
                    const WidgetSpan(child: SizedBox(width: 4,),),
                  TextSpan(
                    text: subscriptionNotice.message,
                    style: textStyleChatUserNoticeBody,),
                  
                  const WidgetSpan(child: SizedBox(width: 4,),),
                  TextSpan(
                    text: subscriptionNotice.userRecivingSub,
                    style: textStyleChatUserNoticeBody.copyWith(fontWeight: FontWeight.bold),)
                  ],
              ),
            ),
          ],
      )
    );
  }

  /// widget que representa un anuncio en el chat
  Widget _buildAnnouncementWidget(Announcement announcement, BuildContext context){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      // fondo morado para los bordes laterales
      decoration: const BoxDecoration(
        color: MyColors.primaryColor,
      ),
      child: Container(
        // darle el color de fondo para que el color de arriba como bordes laterales
        decoration: const BoxDecoration(
          color: MyColors.backgroundColorSecondary,
        ),
        child: Column(
          children: [
            // title 
             Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: MyColors.backgroundColorTitleAnounncement,
              ),
               child: Row(
                  children: [
                    const SizedBox(width: 4,),
                    Image.asset("assets/images/anuncio_icono.png",height: 16,width: 16,),
                    const SizedBox(width: 4,),
                    Text(
                      texts.announcement,
                      style: textStyleChatUserNoticeBody.copyWith(fontWeight: FontWeight.bold)
                    )
                ]
                         )
             ),
            // Message
            Container(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: TwitchChatPrivateMessage(privateMessage: announcement.privateMessage)
            )
            
          ],
        )
      ),  
    );
  }


  
}