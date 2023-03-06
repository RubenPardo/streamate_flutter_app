import 'package:flutter/cupertino.dart';
import 'package:streamate_flutter_app/data/model/chat_setting.dart';
import 'package:streamate_flutter_app/data/model/irc_message/irc_message.dart';
import 'package:streamate_flutter_app/data/model/irc_message/private_message.dart';
import 'package:streamate_flutter_app/data/model/user.dart';

abstract class ChatEvent{}

class InitChatBloc extends ChatEvent{
  String idBroadcaster;
  String accesToken;
  String loginName;
  InitChatBloc(this.idBroadcaster, this.accesToken,this.loginName);
}

class StopChat extends ChatEvent{}
class ResumeChat extends ChatEvent{}

class ClickUserChat extends ChatEvent{
  User user;
  ClickUserChat(this.user);
}

class BanUserChat extends ChatEvent{
  User user;
  User userToBan;
  int? duration;
  BanUserChat(this.user,this.userToBan,{this.duration});
}

class DeleteMessage extends ChatEvent{
  User user;
  PrivateMessage message;
  DeleteMessage(this.user,this.message);
}

class ChangeChatSettings extends ChatEvent{
  ChatSetting chatSetting;
  ChangeChatSettings(this.chatSetting);
}


