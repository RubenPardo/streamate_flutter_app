
import 'package:streamate_flutter_app/data/model/obs_connection.dart';

abstract class OBSState{}


class OBSUninitialized extends OBSState{}

class OBSLoading extends OBSState{}
class OBSError extends OBSState{
  final String message;
  OBSError({required this.message});
}
class OBSConnected extends OBSState{}
class OBSInitialized extends OBSState{
  final OBSConnection? lastConnection;
  OBSInitialized({required this.lastConnection});
}