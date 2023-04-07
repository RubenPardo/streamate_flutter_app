
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/domain/usecases/check_session_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/log_in_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/log_out_use_case.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_sate.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  

  final LogInUseCase _loginCasoUso = serviceLocator<LogInUseCase>();
  final CheckSessionUseCase _comprobarSesionCasoUso = serviceLocator<CheckSessionUseCase>();
  final LogOutUseCase _logoutUseCase = serviceLocator<LogOutUseCase>();

  AuthBloc(): super(AuthUninitialized()){
        
        
        on<AppStarted>( // ------------------------------------------------------------------
          (event,emit) async{
            emit(AuthLoading());
            var result = await _comprobarSesionCasoUso.call();
            result.fold(
              (error){
                emit(AuthError(mensaje: error.message));// ----------> Error al comprobar sesion
                emit(AuthUnauthenticated());// ----------> Error al comprobar sesion
              },
              (autorizado){
                
                if(autorizado){
                  emit(AuthAuthenticated()); // -------------------------> Autenticado
                }else{
                  emit(AuthUnauthenticated()); // -----------------------> No autenticado
                }
              }
            );
          }

        );
  
        on<Autorizarse>(
          (event,emit){
            emit(AuthLoading());
            emit(AuthAutorizacion(urlAutorizacion: _loginCasoUso.getAutorizationUrl())); // -----> mostrar webview para logear/autorizar
          }
        );


        on<LogIn>( // ------------------------------------------------------------------
          (event,emit) async{
            // event.objeto para obtener cosas
            emit(AuthLoading()); // ---------------------------> Loading

            var result = await _loginCasoUso.call(event.redirectUri);
            result.fold(
              (error){
                emit(AuthError(mensaje: error.message));// ----------> Error
                emit(AuthUnauthenticated());// ----------> No autenticado
              }, 
              (autenticado){
                
                if(autenticado){
                  emit(AuthAuthenticated());// ------------> Autenticado
                }else{
                  emit(AuthUnauthenticated());// ------------> NO Autenticado
                }
                
              }
            );
          }

        );


        on<LogOut>( // ------------------------------------------------------------------
          (event,emit) async{
            print("----------------------------------------------EVENT Logut");
            // event.objeto para obtener cosas
            await _logoutUseCase.call();
            emit(AuthUnauthenticated());// -----------> No autenticado
          }

        );


        
      }

}
