import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamate_flutter_app/core/my_error.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/domain/usecases/check_session_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/log_in_use_case.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_sate.dart';

class MockLoginUseCase extends Mock implements LogInUseCase{}
class MockCheckSesionUseCase extends Mock implements CheckSessionUseCase{}

/// 
/// Para facilitar la prueba, definimos typematchers, 
/// que básicamente crea una instancia de comparación de tipo [T].
/// 
const unInitialized = TypeMatcher<AuthUninitialized>();
const authenticated = TypeMatcher<AuthAuthenticated>();
const loading = TypeMatcher<AuthLoading>();
const error = TypeMatcher<AuthError>();
const unAuthenticated = TypeMatcher<AuthUnauthenticated>();


void main() {

  
  late AuthBloc authBloc;


  setUpAll((){
    serviceLocator.registerSingleton<LogInUseCase>(MockLoginUseCase());
    serviceLocator.registerSingleton<CheckSessionUseCase>(MockCheckSesionUseCase());

    
    authBloc = AuthBloc();
  });

  
  test('el estado inicial debe ser unInitialized', () async {
     expect(authBloc.state,unInitialized);
  });

  group("Se emite [AppStarted] -", (){

    ///
    /// emitsInOrder: devuelve un StreamMatcher 
    /// que coincide con el stream si cada matcher 
    /// coincide uno tras otro en orden.
    ///
    test('[checkSessionUseCase] devuelve true', () async {
      
      
      Either<MyError,bool> valorRetornoUseCase = const Right(true);

      // stub
      when(() => serviceLocator<CheckSessionUseCase>().call(),).thenAnswer((invocation) => Future.value(valorRetornoUseCase));
      
      // ejecucion
      authBloc.add(AppStarted());

      // comprobar los estado del stream del bloc en orden, en este caso el orden es loading, autenticado
      await expectLater(authBloc.stream,emitsInOrder([loading, authenticated]));

      
    });


    test('[checkSessionUseCase] devuelve false', () async {
      
      
      Either<MyError,bool> valorRetornoUseCase = const Right(true);

      // stub
      when(() => serviceLocator<CheckSessionUseCase>().call(),).thenAnswer((invocation) => Future.value(valorRetornoUseCase));
      
      // ejecucion
      authBloc.add(AppStarted());

      // comprobar los estado del stream del bloc en orden, en este caso el orden es loading, autenticado
      await expectLater(authBloc.stream,emitsInOrder([loading, authenticated]));

      
    });

    test('[checkSessionUseCase] lanza una excepcion', () async {
      
      Either<MyError,bool> valorRetornoUseCase = const Left(MyError("error"));

      // stub
      when(() => serviceLocator<CheckSessionUseCase>().call(),).thenAnswer((inv)=>Future.value(valorRetornoUseCase));
      
      // ejecucion
      authBloc.add(AppStarted());

      // comprobar los estado del stream del bloc en orden, en este caso el orden es loading, autenticado
      await expectLater(authBloc.stream,emitsInOrder([loading, error, unAuthenticated]));

      
    });

  });

  group("Se emite [LogIn] -", (){

    test('[LogInUseCase] devuelve true', () async {
      
      String uri = "1234";
      Either<MyError,bool> valorRetornoUseCase = const Right(true);

      // stub
      when(() => serviceLocator<LogInUseCase>().call(any()),).thenAnswer((inv)=>Future.value(valorRetornoUseCase));
      
      // ejecucion
      authBloc.add(LogIn(redirectUri: uri));

      // comprobar los estado del stream del bloc en orden, en este caso el orden es loading, autenticado
      await expectLater(authBloc.stream,emitsInOrder([loading, authenticated]));
      
      // se llama al caso de uso con la uri
     verify(() => serviceLocator<LogInUseCase>().call(uri),).called(1);

      
    });

    test('[LogInUseCase] devuelve false', () async {
      
      Either<MyError,bool> valorRetornoUseCase = const Right(false);
      String uri = "1234";

      // stub
      when(() => serviceLocator<LogInUseCase>().call(any()),).thenAnswer((inv)=>Future.value(valorRetornoUseCase));
      
      // ejecucion
      authBloc.add(LogIn(redirectUri: uri));

      // comprobar los estado del stream del bloc en orden, en este caso el orden es loading, no autenticado
      await expectLater(authBloc.stream,emitsInOrder([loading, unAuthenticated]));

      // se llama al caso de uso con la uri
     verify(() => serviceLocator<LogInUseCase>().call(uri),).called(1);

      
    });

    test('[LogInUseCase] lanza una excepcion', () async {
      
      Either<MyError,bool> valorRetornoUseCase = const Left(MyError("error"));
      String uri = "1234";

      // stub
      when(() => serviceLocator<LogInUseCase>().call(any()),).thenAnswer((inv)=>Future.value(valorRetornoUseCase));
      
      // ejecucion
      authBloc.add(LogIn(redirectUri: uri));

      // comprobar los estado del stream del bloc en orden, en este caso el orden es loading, autenticado
      await expectLater(authBloc.stream,emitsInOrder([loading, error, unAuthenticated]));

      // se llama al caso de uso con la uri
     verify(() => serviceLocator<LogInUseCase>().call(uri),).called(1);

      
    });

  });

}