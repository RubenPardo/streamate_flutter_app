import 'package:streamate_flutter_app/data/model/obs_connection.dart';

abstract class OBSEvent{}

class OBSInit extends OBSEvent{}

class OBSConnect extends OBSEvent{
  final OBSConnection connection;
  OBSConnect({required this.connection});
}