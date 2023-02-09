// creamos los mocks que se van a usar en los tests
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamate_flutter_app/core/my_error.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_auth_repository.dart';
import 'package:streamate_flutter_app/domain/usecases/check_session_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/log_in_use_case.dart';

class MockTwitchAuthRepository extends Mock implements TwitchAuthRepositoryImpl{}

void main() {


  late CheckSessionUseCase checkSessionUseCase;
  
    // before all test
    setUpAll(() async{
      registerFallbackValue(TokenData.empty());
      serviceLocator.registerSingleton<TwitchAuthRepository>(MockTwitchAuthRepository());
      checkSessionUseCase = CheckSessionUseCase();
    });


  test("No hay un token guardado en local",() async {

      when(() => serviceLocator<TwitchAuthRepository>().isTokenSavedLocal()).thenAnswer((invocation) => Future.value(false));
      

      var result = (await checkSessionUseCase.call()).fold((error) => error,(loged)=>loged); // result puede ser left de tipo MyError o right de tipo Bool 
      
      // si no hay token guardado devuelve un false
      expect(result, false);


  });

  test("Hay un token guardado que esta expirado y al pedirlo lo devuelve bien",() async {    

    when(() => serviceLocator<TwitchAuthRepository>().isTokenSavedLocal()).thenAnswer((invocation) => Future.value(true));
    when(() => serviceLocator<TwitchAuthRepository>().isTokenExpired()).thenAnswer((invocation) => Future.value(true));
    when(() => serviceLocator<TwitchAuthRepository>().updateToken(any()),)
        .thenAnswer((invocation) => Future.value(TokenData.dummyValido()));// devolvemos un token valido
    when(() => serviceLocator<TwitchAuthRepository>().getTokenDataLocal(),).thenAnswer((invocation) => Future.value(TokenData.dummyValido()));
    when(() => serviceLocator<TwitchAuthRepository>().saveTokenDataLocal(any()),).thenAnswer((invocation) => Future.value());

    // si esta expirado, se obtendrá el token de local, lo actualizará y lo guardará en local
    var result = (await checkSessionUseCase.call()).fold((error) => error,(loged)=>loged); // result puede ser left de tipo MyError o right de tipo Bool 
    
    // si hay token guardado expirado y al pedirlo da un token valido devuelve un true
    expect(result, true);

  });

  test("Hay un token guardado que esta expirado y al pedirlo no lo devuelve bien",() async {    
     when(() => serviceLocator<TwitchAuthRepository>().isTokenSavedLocal()).thenAnswer((invocation) => Future.value(true));
    when(() => serviceLocator<TwitchAuthRepository>().isTokenExpired()).thenAnswer((invocation) => Future.value(true));
    when(() => serviceLocator<TwitchAuthRepository>().updateToken(any()),)
          .thenAnswer((invocation) => Future.value(TokenData.empty())); // devolvemos un token no valido
    when(() => serviceLocator<TwitchAuthRepository>().getTokenDataLocal(),).thenAnswer((invocation) => Future.value(TokenData.dummyValido()));
    when(() => serviceLocator<TwitchAuthRepository>().saveTokenDataLocal(any()),).thenAnswer((invocation) => Future.value());

    // si esta expirado, se obtendrá el token de local, lo actualizará y lo guardará en local
    var result = (await checkSessionUseCase.call()).fold((error) => error,(loged)=>loged); // result puede ser left de tipo MyError o right de tipo Bool 
    
    // si hay token guardado expirado y al pedirlo da un token no valido devuelve un false
    expect(result, false);
   });

  test("Hay un token guardado y no esta expirado",() async {
    when(() => serviceLocator<TwitchAuthRepository>().isTokenSavedLocal()).thenAnswer((invocation) => Future.value(true));
    when(() => serviceLocator<TwitchAuthRepository>().isTokenExpired()).thenAnswer((invocation) => Future.value(false));
      

    var result = (await checkSessionUseCase.call()).fold((error) => error,(loged)=>loged); // result puede ser left de tipo MyError o right de tipo Bool 
      
    // si no hay token guardado devuelve un false
    expect(result, true);
  });




}