import 'package:streamate_flutter_app/data/model/irc_message.dart';
import 'package:streamate_flutter_app/data/model/user.dart';

abstract class ChatEvent{}

class InitChatBloc extends ChatEvent{
  String idBroadcaster;
  String accesToken;
  String loginName;
  InitChatBloc(this.idBroadcaster, this.accesToken,this.loginName);
}

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
  RoomStateMessage message;
  ChangeChatSettings(this.message);
}


