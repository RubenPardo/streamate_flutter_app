
import 'package:flutter/widgets.dart';
import 'package:streamate_flutter_app/data/model/badge.dart';
import 'package:streamate_flutter_app/data/model/emote.dart';
import 'package:streamate_flutter_app/data/model/irc_message/irc_message.dart';
import 'package:streamate_flutter_app/data/model/irc_message/notice_message.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_bloc.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
import 'package:streamate_flutter_app/shared/styles.dart';

class TwitchChatNoticeMessage extends StatelessWidget {

  final NoticeMessage noticeMessage;


  const TwitchChatNoticeMessage({super.key, required this.noticeMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
               Container(
                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 0),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.95),
                child: Text(noticeMessage.message, style: textStyleChatNotice,),
                ),
            ],
          ),
        ],
      ),
    );
  }


}