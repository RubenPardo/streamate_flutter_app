import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:streamate_flutter_app/data/model/irc_message.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
import 'package:streamate_flutter_app/shared/styles.dart';
import 'package:streamate_flutter_app/shared/widgets/twitch_chat_private_message.dart';

class TwitchChatUserNoticeMessage extends StatelessWidget{
  final UserNoticeMessage userNoticeMessage;
  
  const TwitchChatUserNoticeMessage({super.key, required this.userNoticeMessage});

  @override
  Widget build(BuildContext context) {
    switch(userNoticeMessage.runtimeType){
      case SubscriptionNotice:
        return Container(
            color: MyColors.userNoticeBackground,
            padding: const EdgeInsets.all( 8),
            child: _buildSubWidget (userNoticeMessage as SubscriptionNotice, context));
      case SubMysterGift:
        return Container(
          color: MyColors.userNoticeBackground,
          padding: const EdgeInsets.all( 8),
          child:_buildSubMysterGiftWidget(userNoticeMessage as SubMysterGift, context));
      case SubGift:
        return Container(
          color: MyColors.userNoticeBackground,
          padding: const EdgeInsets.all( 8),
          child:_buildSubGiftWidget(userNoticeMessage as SubGift, context));
      default:
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


  Widget _buildSubWidget(SubscriptionNotice subscriptionNotice, BuildContext context){
    return Column(
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
    );
  }

  Widget _buildSubMysterGiftWidget(SubMysterGift subscriptionNotice, BuildContext context){
    return Row(
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
      );
  }

  Widget _buildSubGiftWidget(SubGift subscriptionNotice, BuildContext context){
    return Column(
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
    );
  }

}