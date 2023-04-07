import 'package:streamate_flutter_app/data/model/obs_connection.dart';
import 'package:streamate_flutter_app/data/model/obs_scene.dart';

abstract class OBSEvent{}

class OBSInit extends OBSEvent{}

class OBSConnect extends OBSEvent{
  final OBSConnection connection;
  OBSConnect({required this.connection});
}

class OBSChangeScene extends OBSEvent{
  final OBSScene scene;
  OBSChangeScene({required this.scene});
}