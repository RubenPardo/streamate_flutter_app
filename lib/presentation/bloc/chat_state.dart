import 'package:flutter/cupertino.dart';
import 'package:streamate_flutter_app/data/model/chat_setting.dart';
import 'package:streamate_flutter_app/data/model/irc_message.dart';

abstract class ChatState{}

class ChatUninitialized extends ChatState{}
class ChatConnected extends ChatState{}
class ChatError extends ChatState{
  String error;
  ChatError(this.error);
}