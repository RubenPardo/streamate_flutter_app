import 'package:streamate_flutter_app/data/model/stream_category.dart';

abstract class SettingsEvent{}

class InitSettings extends SettingsEvent{
  final String idBroadCaster;
  final bool fromMemory;
  InitSettings({required this.idBroadCaster, required this.fromMemory});
}


class ChangeStreamSettings extends SettingsEvent{
  final StreamCategory category;
  final String newTitle;
  final String idBroadCaster;
  ChangeStreamSettings({required this.category,required this.newTitle , required this.idBroadCaster});
}

