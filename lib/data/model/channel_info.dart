import 'package:streamate_flutter_app/data/model/stream_category.dart';

class ChannelInfo {
  String broadcasterId;
  String broadcasterLogin;
  String broadcasterName;
  String broadcasterLanguage;
  StreamCategory streamCategory;
  String title;
  int delay;
  List<String> tags;

  ChannelInfo(
      {
      required this.broadcasterId,
      required this.broadcasterLogin,
      required this.broadcasterName,
      required this.broadcasterLanguage,
      required this.streamCategory,
      required this.title,
      required this.delay,
      required this.tags});

  factory ChannelInfo.fromJson(Map<String, dynamic> json) {
    return ChannelInfo(
      broadcasterId: json['broadcaster_id'],
      broadcasterLogin: json['broadcaster_login'],
      broadcasterName: json['broadcaster_name'],
      broadcasterLanguage: json['broadcaster_language'],
      streamCategory: StreamCategory(gameId: json['game_id'], gameName: json['game_name']),
      title: json['title'],
      delay: json['delay'],
      tags: json['tags'].cast<String>()
    );
  }

  @override
  String toString() {
    return 'ChannelInfo: [broadcasterId: $broadcasterId, broadcasterLogin: $broadcasterLogin, broadcasterName: $broadcasterName, broadcasterLanguage: $broadcasterLanguage, streamCategory: $streamCategory, title: $title, delay: $delay, tags: $tags]';
    
  }
}