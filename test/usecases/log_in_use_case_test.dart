// creamos los mocks que se van a usar en los tests
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamate_flutter_app/core/my_error.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_auth_repository.dart';
import 'package:streamate_flutter_app/domain/usecases/log_in_use_case.dart';

class MockTwitchAuthRepository extends Mock implements TwitchAuthRepositoryImpl{}

void main() {


  late LogInUseCase loginUseCase;
  
  // before all test
  setUpAll(() async{
      registerFallbackValue(TokenData.empty());
      serviceLocator.registerSingleton<TwitchAuthRepository>(MockTwitchAuthRepository());
      loginUseCase = LogInUseCase();
    });

  // after all test
  tearDownAll((){
    serviceLocator.reset();
  });

  test("Login - nos devuelven un token valido",() async {

    String authCode = "1234";
    String url = "https://dumyurl?code=$authCode";

      when(() => serviceLocator<TwitchAuthRepository>().getTokenDataRemote(
            any(),
          )).thenAnswer((invocation) => Future.value(TokenData.dummyValido()));
      when(() => serviceLocator<TwitchAuthRepository>().saveTokenDataLocal(any()),).thenAnswer((invocation) => Future.value());

      var result = (await loginUseCase.call(url)).fold((error) => error,(loged)=>loged); // result puede ser left de tipo MyError o right de tipo Bool
      
      // si va bien tiene que devolver un valor right y true
      expect(result, true); 
      // se llamo al metodo del repositorio de obtener el token del server
      verify(() => serviceLocator<TwitchAuthRepository>().getTokenDataRemote(authCode)).called(1); 
      // guarda el token en local
      verify(() => serviceLocator<TwitchAuthRepository>().saveTokenDataLocal(any())).called(1); 


  });

  test("Login - no nos devuelven un token valido",() async {

    String authCode = "1234";
    String url = "https://dumyurl?code=$authCode";

      when(() => serviceLocator<TwitchAuthRepository>().getTokenDataRemote(
            any(),
          )).thenAnswer((invocation) => Future.value(TokenData.empty()));
      when(() => serviceLocator<TwitchAuthRepository>().saveTokenDataLocal(any()),).thenAnswer((invocation) => Future.value());

      var result = (await loginUseCase.call(url)).fold((error) => error,(loged)=>loged); // result puede ser left de tipo MyError o right de tipo Bool
      
      // si va bien tiene que devolver un valor left y un error
      expect(result is MyError, true); 


  });

  test("Login - le pasan una url mal formada",() async { 
 
    String url = "https://dumyurl?co"; 
 
      when(() => serviceLocator<TwitchAuthRepository>().getTokenDataRemote( 
            any(), 
          )).thenAnswer((invocation) => Future.value(TokenData.empty())); 
      when(() => serviceLocator<TwitchAuthRepository>().saveTokenDataLocal(any()),).thenAnswer((invocation) => Future.value()); 
 
      var result = (await loginUseCase.call(url)).fold((error) => error,(loged)=>loged); // result puede ser left de tipo MyError o right de tipo Bool 
       
      // si va bien tiene que devolver un valor left y un error 
      expect(result is MyError, true);  
 
 
  }); 
 
 




}