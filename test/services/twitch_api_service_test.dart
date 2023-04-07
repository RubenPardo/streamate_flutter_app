// To stub any method; gives error when used for futures or stream
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streamate_flutter_app/core/request.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/services/twitch_api_service.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_auth_repository.dart';
import 'package:streamate_flutter_app/shared/cambiarAEnv.dart';
import 'package:streamate_flutter_app/shared/strings.dart';


// creamos los mocks que se van a usar en los tests
class MockRequest extends Mock implements Request{}

void main() {
 
  
  group("Token data", (){

      Future<void> registrarDependencias() async{
      // registrar las dependencias
      // hay que registrar de nuevo todas las dependencias que vayamos a usar y las que queramos mockear hay que pasarles la clase
      // creada con el build_runner, no podemos llamar al setup para qye añada todas porque sino dará error de duplicados
      serviceLocator.registerSingleton<Request>(MockRequest());
      final sharedPreferences = await SharedPreferences.getInstance();
      serviceLocator.registerFactory<SharedPreferences>(() => sharedPreferences);
    }
  
    
    late TwitchApiService twitchApiService;
  
    // before all test
    setUpAll(() async{
      await registrarDependencias();
      twitchApiService = TwitchApiServiceImpl();
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
      var tokenDataRecibido = await twitchApiService.getTokenDataRemote(authorizationCode);
      
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
    expect(()=>twitchApiService.getTokenDataRemote(authorizationCode), throwsA(isA<Exception>()));
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
      var tokenDataRecibido = await twitchApiService.updateToken(tokenParaActualizar);
      
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
    expect(()=>twitchApiService.updateToken(tokenParaActualizar), throwsA(isA<Exception>()));
    // no se ha llamado nunca
    verifyNever(() => serviceLocator<Request>().updateAuthorization(any()));
    
  });

  });

  group("User", (){

      Future<void> registrarDependencias() async{
      // registrar las dependencias
      // hay que registrar de nuevo todas las dependencias que vayamos a usar y las que queramos mockear hay que pasarles la clase
      // creada con el build_runner, no podemos llamar al setup para qye añada todas porque sino dará error de duplicados
      serviceLocator.registerSingleton<Request>(MockRequest());
      final sharedPreferences = await SharedPreferences.getInstance();
      serviceLocator.registerFactory<SharedPreferences>(() => sharedPreferences);
    }
  
    
    late TwitchApiService twitchApiService;
  
    // before all test
    setUpAll(() async{
      await registrarDependencias();
      twitchApiService = TwitchApiServiceImpl();
    });

    // after all test
    tearDownAll((){
      serviceLocator.reset();
    });


     test('Successfully get user data sin login names', () async {
    // dato esperado
      String accesToken = "123";
      Map<String,dynamic> mapRecibidoPost = {"data":[{"id":"878422216","login":"ruben_pardo_2","display_name":"ruben_pardo_2","type":"","broadcaster_type":"","description":"","profile_image_url":"https://static-cdn.jtvnw.net/user-default-pictures-uv/de130ab0-def7-11e9-b668-784f43822e80-profile_image-300x300.png","offline_image_url":"","view_count":0,"email":"sr.corn1999@gmail.com","created_at":"2023-02-05T17:16:08Z"}]};
      String urlEsperada = '${baseUrlApi}helix/users';
      var headersEsperados = {
      'Client-ID': CLIENT_ID,
      };
      
      // inicializar ------------------
      // mockeamos la respuest post
      when(() => serviceLocator<Request>().get(
        any(), headers: headersEsperados,
      )).thenAnswer(
        (inv) => Future.value(Response(
          statusCode: 200,
          data: mapRecibidoPost,
          requestOptions: RequestOptions(path: '<https://reqres.in/api/login>'),
        )),
      );


      await twitchApiService.getUsers(accesToken);

      // ejecucion ----------------------
      verify(() => serviceLocator<Request>().get(urlEsperada,headers: headersEsperados)).called(1); // comprobamos que se ha montado bien la url
    });


    test('Successfully get user data con login names', () async {
    // dato esperado
      String accesToken = "123";
      Map<String,dynamic> mapRecibidoPost = {"data":[{"id":"id1"},{"id":"id2"},{"id":"id3"}]};
      String urlEsperada = '${baseUrlApi}helix/users?id=id1&id=id2&id=id3';
      List<String> ids = ['id1','id2','id3'];
      var headersEsperados = {
      'Client-ID': CLIENT_ID,
      };
      
      // inicializar ------------------
      // mockeamos la respuest post
      when(() => serviceLocator<Request>().get(
        any(), headers: headersEsperados,
      )).thenAnswer(
        (inv) => Future.value(Response(
          statusCode: 200,
          data: mapRecibidoPost,
          requestOptions: RequestOptions(path: '<https://reqres.in/api/login>'),
        )),
      );


      // ejecucion
      var response = await twitchApiService.getUsers(accesToken,ids: ids);

      expect(response.length == ids.length, true);
      // verificacion ----------------------
      verify(() => serviceLocator<Request>().get(urlEsperada,headers: headersEsperados)).called(1); // comprobamos que se ha montado bien la url
    });


    test('Ban user', () async {
      // TODO acabar el test de ban user, entender porque no funciona bien en este caso el verify
    // dato esperado
      String idUser = "123";
      String idUserToBan = "234";
      //Map<String,dynamic> mapRecibidoPost = {"data":[{"login":"user1"},{"login":"user2"},{"login":"user3"}]};
      String urlEsperada = '${baseUrlApi}helix/moderation/bans?broadcaster_id=$idUser&moderator_id=$idUser';
      Map bodyEsperado = {'data':{'data':{'user':idUserToBan}}}; // el primer data es por como funciona mockito que le pone un nombre delante igual al nombre del atributo
      
      // inicializar ------------------
      // mockeamos la respuest post
      when(() => serviceLocator<Request>().post(
        any(),data: any(named: "data"),
      )).thenAnswer(
        (inv) => Future.value(Response(
          statusCode: 200,
          data: {},
          requestOptions: RequestOptions(path: '<https://reqres.in/api/login>'),
        )),
      );


      // ejecucion
      var response = await twitchApiService.banUser(idUser,idUserToBan);

      expect(response, true);
      // verificacion ----------------------
      verify(() => serviceLocator<Request>().post(urlEsperada,data: bodyEsperado)).called(1); // comprobamos que se ha montado bien la url
    });

    test('UnBan user', () async {
    // dato esperado
      String idUser = "123";
      String idUserToUnBan = "234";
      //Map<String,dynamic> mapRecibidoPost = {"data":[{"login":"user1"},{"login":"user2"},{"login":"user3"}]};
      String urlEsperada = '${baseUrlApi}helix/moderation/bans?broadcaster_id=$idUser&moderator_id=$idUser&user_id=$idUserToUnBan';
      
      // inicializar ------------------
      // mockeamos la respuest post
      when(() => serviceLocator<Request>().delete(
        any(),
      )).thenAnswer(
        (inv) => Future.value(Response(
          statusCode: 204,
          data: {},
          requestOptions: RequestOptions(path: '<https://reqres.in/api/login>'),
        )),
      );


      // ejecucion
      var response = await twitchApiService.unBanUser(idUser,idUserToUnBan);

      expect(response, true);
      // verificacion ----------------------
      verify(() => serviceLocator<Request>().delete(urlEsperada)).called(1); // comprobamos que se ha montado bien la url
    });


  });



}