import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/channel_info.dart';
import 'package:streamate_flutter_app/data/services/twitch_api_service.dart';

abstract class TwitchChannelRepository{
  Future<ChannelInfo> getChannelInfo(String idBroadCaster );
  Future<bool> updateChannelInfo({String? newTitle, String? newGameId, required String idBroadCaster});
}


class TwitchChannelRepositoryImpl implements TwitchChannelRepository{

  final TwitchApiService _apiService = serviceLocator<TwitchApiService>();

  @override
  Future<ChannelInfo> getChannelInfo(String idBroadCaster) async{
    return ChannelInfo.fromJson(await _apiService.getChannelInfo(idBroadCaster));
  }

  @override
  Future<bool> updateChannelInfo({String? newTitle, String? newGameId, required String idBroadCaster}) async{
    return await _apiService.updateChannelInfo(idBroadCaster: idBroadCaster, newGameId: newGameId, newTitle: newTitle);
  }

}