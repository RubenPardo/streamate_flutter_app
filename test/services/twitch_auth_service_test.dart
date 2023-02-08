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
import 'package:streamate_flutter_app/shared/cambiarAEnv.dart';
import 'package:streamate_flutter_app/shared/strings.dart';


// creamos los mocks que se van a usar en los tests
class MockRequest extends Mock implements Request{}

void main() {
 
  
  group("Remote rquests", (){

      Future<void> registrarDependencias() async{
      // registrar las dependencias
      // hay que registrar de nuevo todas las dependencias que vayamos a usar y las que queramos mockear hay que pasarles la clase
      // creada con el build_runner, no podemos llamar al setup para qye añada todas porque sino dará error de duplicados
      serviceLocator.registerSingleton<Request>(MockRequest());
      final sharedPreferences = await SharedPreferences.getInstance();
      serviceLocator.registerFactory<SharedPreferences>(() => sharedPreferences);
    }
  
    
    late TwitchAuthService twitchAuthService;
  
    // before all test
    setUpAll(() async{
      await registrarDependencias();
      twitchAuthService = TwitchAuthServiceImpl();
    });

    // after all test
    tearDownAll((){
      serviceLocator.reset();
    });


     test('Successfully get token data', () async {
    // dato esperado
      String accesTokenQueDevuelveLaPeticion = "123";
      Map<String,dynamic> mapRecibidoPost = {"access_token":accesTokenQueDevuelveLaPeticion,"expires_in":1234,"refresh_token":"345"};
      String authorizationCode = "1234";
      String urlEsperada = '${baseUrlOath}oauth2/token?client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&code=$authorizationCode&grant_type=authorization_code&redirect_uri=$REDIRECT_URI';
      
      // inicializar ------------------
      // mockeamos la respuest post
      when(() => serviceLocator<Request>().post(
        any(),
      )).thenAnswer(
        (inv) => Future.value(Response(
          statusCode: 200,
          data: mapRecibidoPost,
          requestOptions: RequestOptions(path: '<https://reqres.in/api/login>'),
        )),
      );




      // ejecucion ----------------------
      var tokenDataRecibido = await twitchAuthService.getTokenDataRemote(authorizationCode);
      
      expect(tokenDataRecibido.toString() == mapRecibidoPost.toString(),true,);
      verify(() => serviceLocator<Request>().updateAuthorization(accesTokenQueDevuelveLaPeticion)).called(1); // que se llamo a update auth
      verify(() => serviceLocator<Request>().post(urlEsperada)).called(1); // comprobamos que se ha montado bien la url
    });


    test('Error get token data', () async {
    
    
    // inicializar ------------------
    String authorizationCode = "codigo erroneo";
    // mockeamos la respuest post
    when(() => serviceLocator<Request>().post(
      '${baseUrlOath}oauth2/token?client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&code=$authorizationCode&grant_type=authorization_code&redirect_uri=$REDIRECT_URI',
    )).thenAnswer(
      (inv) => Future.value(Response(
        statusCode: 400,
        requestOptions: RequestOptions(path: '<https://reqres.in/api/login>'),
      )),
    );
   


    // ejecucion ----------------------
    //
    expect(()=>twitchAuthService.getTokenDataRemote(authorizationCode), throwsA(isA<Exception>()));
    // no se ha llamado nunca
    verifyNever(() => serviceLocator<Request>().updateAuthorization(any()));
  });

    test('Successfully and well formed update token data petition', () async {
      
      // dato esperado
      String accesTokenQueDevuelveLaPeticion = "123";
      Map<String,dynamic> mapRecibidoPost = {"access_token":accesTokenQueDevuelveLaPeticion,"expires_in":1234,"refresh_token":"345"};
      String tokenParaActualizar = "1234";
      String urlEsperada = '${baseUrlOath}oauth2/token?client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&grant_type=refresh_token&refresh_token=$tokenParaActualizar';
      
      // inicializar ------------------
      // mockeamos la respuest post
      when(() => serviceLocator<Request>().post(
        any(),
      )).thenAnswer(
        (inv) => Future.value(Response(
          statusCode: 200,
          data: mapRecibidoPost,
          requestOptions: RequestOptions(path: '<https://reqres.in/api/login>'),
        )),
      );




      // ejecucion ----------------------
      var tokenDataRecibido = await twitchAuthService.updateToken(tokenParaActualizar);
      
      // comprobacion -------------------------
      expect(tokenDataRecibido.toString() == mapRecibidoPost.toString(),true,);
      verify(() => serviceLocator<Request>().updateAuthorization(accesTokenQueDevuelveLaPeticion)).called(1); // que se llamo a update auth
      verify(() => serviceLocator<Request>().post(urlEsperada)).called(1); // comprobamos que se ha montado bien la url
      
    });

    test('Bad update token data petition', () async {
    
    // dato esperado
    String tokenParaActualizar = "1234"; 
    // inicializar ------------------
    // mockeamos la respuest post
    when(() => serviceLocator<Request>().post(
      any(),
    )).thenAnswer(
      (inv) => Future.value(Response(
        statusCode: 400,
        requestOptions: RequestOptions(path: '<https://reqres.in/api/login>'),
      )),
    );




    // ejecucion ----------------------
    expect(()=>twitchAuthService.updateToken(tokenParaActualizar), throwsA(isA<Exception>()));
    // no se ha llamado nunca
    verifyNever(() => serviceLocator<Request>().updateAuthorization(any()));
    
  });

  });
}