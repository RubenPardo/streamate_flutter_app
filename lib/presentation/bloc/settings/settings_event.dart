import 'package:streamate_flutter_app/data/model/stream_category.dart';

abstract class SettingsEvent{}

class InitSettings extends SettingsEvent{
  final String idBroadCaster;
  final bool fromMemory;
  InitSettings({required this.idBroadCaster, required this.fromMemory});
}

class ChangeStreamTitle extends SettingsEvent{
  final String newTitle;
  final String idBroadCaster;
  ChangeStreamTitle({required this.newTitle, required this.idBroadCaster});
}

class ChangeStreamCategory extends SettingsEvent{
  final StreamCategory category;
  final String idBroadCaster;
  ChangeStreamCategory({required this.category, required this.idBroadCaster});
}

class SearchStreamCategory extends SettingsEvent{
  final String category;
  SearchStreamCategory({required this.category});
}