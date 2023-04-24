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

class ChangeStreamCategory extends SettingsEvent{}