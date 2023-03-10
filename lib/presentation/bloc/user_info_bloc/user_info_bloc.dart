import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/domain/usecases/get_user_use_case.dart';
import 'package:streamate_flutter_app/presentation/bloc/user_info_bloc/user_info_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/user_info_bloc/user_info_state.dart';

class UserInfoBloc extends Bloc<UserInfoEvent,UserInfoState> {
  

  final GetUserUseCase _getUserUseCase = serviceLocator<GetUserUseCase>();

  UserInfoBloc(): super(UserInfoStateLoading()){
        
        
        on<UserInfoEventStart>( // ------------------------------------------------------------------
          (event,emit) async{
            // obtener usuario
            
            var res = await _getUserUseCase.call(id: event.id, idBroadCaster: event.broadcasterUser.id);
            res.fold(
              (error) {
                // ------------------------------------------ return error
                emit(UserInfoStateError());
              }, 
              (user) {
                // ------------------------------------------ return usuario
                emit(UserInfoStateLoaded(user));
              }
            );
          }

        );
        on<UserInfoEventClose>( // ------------------------------------------------------------------
          (event,emit) async{
            emit(UserInfoStateLoading());
          }

        );
    }
}