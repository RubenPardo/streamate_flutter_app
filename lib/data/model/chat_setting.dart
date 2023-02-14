// clase que representa un ajuste del chat
class ChatSetting {

  late ChatSettingType chatSettingType;
  /// en el caso de emote only 0 o -1,
  /// follower only seran los minutos o -1
  /// slow sera los segundos y desactivado es 0
  late String value;

  ChatSetting(this.chatSettingType, this.value);


  @override
  String toString() {
    // TODO: implement toString
    return "Chat Setting [type: $chatSettingType, value: $value]";
  }
}

enum ChatSettingType {
  followersOnly,
  emoteOnly,
  slow, none
}
