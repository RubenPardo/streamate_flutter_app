import 'dart:developer';

class OBSScene {
  final String name;
  final int index;
  final bool isActual;

  OBSScene({required this.name, required this.index, this.isActual = false});

  factory OBSScene.fromJson(Map<String, dynamic> json) {
    log(json.toString());
    return OBSScene(
      name: json['sceneName'],
      index: json['sceneIndex'],
    );
  }
}