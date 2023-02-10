class IRCMessage {
  final String raw;
  Command command;
  final Map<String, String> tags;
  final String? user;
  //final Map<String, Emote>? localEmotes;
  String? message;
  List<String>? split;
  bool? action;
  bool? mention;

  IRCMessage({
    required this.raw,
    required this.command,
    required this.tags,
    this.user,
    //  this.localEmotes,
    this.message,
    this.split,
    this.action,
    this.mention,
  });

  factory IRCMessage.createNotice({required String message}) => IRCMessage(
        raw: '',
        tags: {},
        command: Command.notice,
        message: message,
      );

}

enum Command {
  privateMessage,
  clearChat,
  clearMessage,
  notice,
  userNotice,
  roomState,
  userState,
  globalUserState,
  none,
}