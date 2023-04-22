abstract class SettingsEvent{}

class InitSettings extends SettingsEvent{
  final String idBroadCaster;
  final bool fromMemory;
  InitSettings({required this.idBroadCaster, required this.fromMemory});
}

class ChangeStreamTitle extends SettingsEvent{}

class ChangeStreamCategory extends SettingsEvent{}