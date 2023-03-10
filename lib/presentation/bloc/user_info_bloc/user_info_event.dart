import 'package:streamate_flutter_app/data/model/user.dart';

abstract class UserInfoEvent{}
class UserInfoEventStart extends UserInfoEvent{
  String id;
  User broadcasterUser;
  UserInfoEventStart(this.id, this.broadcasterUser);
}
class UserInfoEventClose extends UserInfoEvent{

}