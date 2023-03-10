import 'package:streamate_flutter_app/data/model/user.dart';

abstract class UserInfoState{}
class UserInfoStateLoaded extends UserInfoState{
  User user;
  UserInfoStateLoaded(this.user);
}
class UserInfoStateLoading extends UserInfoState{}
class UserInfoStateError extends UserInfoState{}