import 'package:streamate_flutter_app/data/model/channel_info.dart';

abstract class SettingsState{}

class SettingsUninitialized extends SettingsState{}
class SettingsLoading extends SettingsState{}
class SettingsLoaded extends SettingsState{
  final ChannelInfo channelInfo;
  SettingsLoaded({required this.channelInfo});
}
class SettingsError extends SettingsState{}