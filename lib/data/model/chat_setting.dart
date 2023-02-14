
class ListChatSettings{
  late List<ChatSetting> values;

  ListChatSettings(this.values);

  factory ListChatSettings.fromApi(Map<String,dynamic> data){
    // data =
    // {"broadcaster_id":"878422216",
    // "slow_mode":false,
    // "slow_mode_wait_time":null,
    // "follower_mode":false,
    // "follower_mode_duration":null,
    // "subscriber_mode":false,
    // "emote_mode":true,
    // "unique_chat_mode":false}
    //
    
       List<ChatSetting> result = [];

    // mapeamos el map a una lista de [ChatSetting]
     for(MapEntry entry in data.entries){
 
      if(entry.key == "slow_mode_wait_time"){
        result.add(ChatSetting(ChatSettingType.slow, entry.value != null ? entry.value.toString() : "-1"));
        continue;
      }else if(entry.key =="follower_mode_duration"){
        result.add(ChatSetting(ChatSettingType.followersOnly, entry.value != null ? entry.value.toString() : "-1"));
        continue;
      }else if(entry.key =="emote_mode"){
        result.add(ChatSetting(ChatSettingType.emoteOnly, entry.value  == false ? "0": "1"));
        continue;
      }else if(entry.key =="subscriber_mode"){
        result.add(ChatSetting(ChatSettingType.subMode, entry.value  == false ? "0": "1"));
        continue;
      }
         
    }
   
    return ListChatSettings(result);
  }

  @override
  String toString() {
    String res = "ListChatSetting ";

    for (var element in values) {res+=" $element";}
    return res;
  }
}
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
  slow,
  none, 
  subMode
}
