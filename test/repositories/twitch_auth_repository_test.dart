// To stub any method; gives error when used for futures or stream
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streamate_flutter_app/core/request.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/services/twitch_auth_service.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_auth_repository.dart';


// creamos los mocks que se van a usar en los tests
class MockRequest extends Mock implements Request{}
class MockTwitchAuthService extends Mock implements TwitchAuthServiceImpl{}
class MockTwitchAuthRepository extends Mock implements TwitchAuthRepositoryImpl{}

void main() {
 
  
    Future<void> registrarDependencias() async{
      // registrar las dependencias
      // hay que registrar de nuevo todas las dependencias que vayamos a usar y las que queramos mockear hay que pasarles la clase
      // creada con el build_runner, no podemos llamar al setup para qye añada todas porque sino dará error de duplicados
      serviceLocator.registerSingleton<Request>(MockRequest());
      serviceLocator.registerSingleton<TwitchAuthService>(MockTwitchAuthService());
      final sharedPreferences = await SharedPreferences.getInstance();
      serviceLocator.registerFactory<SharedPreferences>(() => sharedPreferences);
    }
  
    
    late TwitchAuthRepository twitchAuthRepository;
  
    // before all test
    setUpAll(() async{
      await registrarDependencias();
      registerFallbackValue(TokenData.empty());
      twitchAuthRepository = TwitchAuthRepositoryImpl();
    });

    // after all test
    tearDownAll((){
      serviceLocator.reset();
    });


    test('Successfully get token data', () async {
    
      // dato esperado
        String authorizationCode = "1234";
        int expiresAtEsperado = DateTime.now().add(const Duration(seconds: 3600)).millisecondsSinceEpoch ~/ 1000;// una hora mas tarde
        TokenData tokenDataEsperado = TokenData(accessToken: "access_token",refreshToken: "refresh_token",expiresAt: expiresAtEsperado);
        
        // mockeamos la respuesta del servicio
        when(() => serviceLocator<TwitchAuthService>().getTokenDataRemote(
            any(),
          )).thenAnswer((invocation) => Future.value({
          'access_token': 'access_token',
          'expires_in': 3600, // expira en una hora
          'refresh_token': 'refresh_token',
        }));

        //when(() => twitchAuthRepository.saveTokenDataLocal(any()),);

        // ejecucion ----------------------
        TokenData tokenDataRecibido = await twitchAuthRepository.getTokenDataRemote(authorizationCode);
        // comprobacion -----------
        expect(tokenDataRecibido.toMap().toString() == tokenDataEsperado.toMap().toString(),true,);
      

        }
    );

    test('Successfully not get token data', () async {
    
      // dato esperado
        String authorizationCode = "1234";
        TokenData tokenDataEsperado = TokenData.empty();
        
        // mockeamos la respuesta del servicio
        when(() => serviceLocator<TwitchAuthService>().getTokenDataRemote(
            any(),
          )).thenThrow((invocation) => Exception());

        //when(() => twitchAuthRepository.saveTokenDataLocal(any()),);

        // ejecucion ----------------------
        TokenData tokenDataRecibido = await twitchAuthRepository.getTokenDataRemote(authorizationCode);
        // comprobacion -----------
        expect(tokenDataRecibido.toMap().toString() == tokenDataEsperado.toMap().toString(),true,);
      

        }
    );
  
  
     test('Successfully update token data', () async {
    
      // dato esperado
        String refresToken = "1234";
        int expiresAtEsperado = DateTime.now().add(const Duration(seconds: 3600)).millisecondsSinceEpoch ~/ 1000;// una hora mas tarde
        TokenData tokenDataEsperado = TokenData(accessToken: "access_token",refreshToken: "refresh_token",expiresAt: expiresAtEsperado);
        
        // mockeamos la respuesta del servicio
        when(() => serviceLocator<TwitchAuthService>().updateToken(
            any(),
          )).thenAnswer((invocation) => Future.value({
          'access_token': 'access_token',
          'expires_in': 3600, // expira en una hora
          'refresh_token': 'refresh_token',
        }));

        //when(() => twitchAuthRepository.saveTokenDataLocal(any()),);

        // ejecucion ----------------------
        TokenData tokenDataRecibido = await twitchAuthRepository.updateToken(refresToken);
        // comprobacion -----------
        expect(tokenDataRecibido.toMap().toString() == tokenDataEsperado.toMap().toString(),true,);
      

        }
    );

    test('Successfully not update token data', () async {
    
      // dato esperado
        String authorizationCode = "1234";
        TokenData tokenDataEsperado = TokenData.empty();
        
        // mockeamos la respuesta del servicio
        when(() => serviceLocator<TwitchAuthService>().updateToken(
            any(),
          )).thenThrow((invocation) => Exception());

        //when(() => twitchAuthRepository.saveTokenDataLocal(any()),);

        // ejecucion ----------------------
        TokenData tokenDataRecibido = await twitchAuthRepository.getTokenDataRemote(authorizationCode);
        // comprobacion -----------
        expect(tokenDataRecibido.toMap().toString() == tokenDataEsperado.toMap().toString(),true,);
      

        }
    );
}