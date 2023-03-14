import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamate_flutter_app/core/my_error.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_auth_repository.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_chat_repository.dart';
import 'package:streamate_flutter_app/domain/usecases/get_user_use_case.dart';

class MockTwitchChatRepository extends Mock implements TwitchChatRepositoryImpl{}
class MockTwitchAuthRepository extends Mock implements TwitchAuthRepositoryImpl{}
/// cuando se llame al caso de uso getUserUseCase sin parametros  
/// se obtendra la informacion del broadcaster, por otra parte el de los ids pasados 
void main() {
  late GetUserUseCase getUserUseCase;
  
    // before all test
    setUpAll(() async{
      //registerFallbackValue(TokenData.empty());
      serviceLocator.registerSingleton<TwitchChatRepository>(MockTwitchChatRepository());
      serviceLocator.registerSingleton<TwitchAuthRepository>(MockTwitchAuthRepository());
      getUserUseCase = GetUserUseCase();
    });

    // after all test
    tearDownAll((){
      serviceLocator.reset();
    });


    
    test("GETUSER USECASE - Obtener Usuario logeado valido",() async {
      
      
      String accessToken = "accesToken";
      TokenData tokenData = TokenData(accessToken: accessToken, expiresAt: 200, refreshToken: "refreshToken");

      // preparacion -----------------------
       when(() => serviceLocator<TwitchAuthRepository>().getTokenDataLocal())
        .thenAnswer((invocation) => Future.value(tokenData));

      // getUserRemote(any()) para luego comprobar que si se ha llamado con el accesToken
      when(() => serviceLocator<TwitchAuthRepository>().getUserRemote(any()))
        .thenAnswer((invocation) => Future.value(User.dummy()));

      // ejecucion ---------------------------------
      var result = (await getUserUseCase.call()).fold((error) => error,(user)=>user); // result puede ser left de tipo MyError o right de tipo Bool
      

      // comprobacion ---------------------------------
      // si va bien tiene que devolver un valor right y user
      expect(result is User, true); 
      // se llamo al obtener el token
      verify(() => serviceLocator<TwitchAuthRepository>().getTokenDataLocal()).called(1); 
      // se obtuvo el user con el token 
      verify(() => serviceLocator<TwitchAuthRepository>().getUserRemote(accessToken)).called(1); 

    });

    test("GETUSER USECASE - Obtener Usuario throw Error",() async {
      String accessToken = "accesToken";
      String error = "error";
      String errorEsperado = "Error al obtener el usuario: $error";
      TokenData tokenData = TokenData(accessToken: accessToken, expiresAt: 200, refreshToken: "refreshToken");

      // preparacion -----------------------
       when(() => serviceLocator<TwitchAuthRepository>().getTokenDataLocal())
        .thenAnswer((invocation) => Future.value(tokenData));

      // getUserRemote(any()) para luego comprobar que si se ha llamado con el accesToken
      when(() => serviceLocator<TwitchAuthRepository>().getUserRemote(any()))
        .thenThrow(error);

      var result;
      try{
        // ejecucion ---------------------------------
        result = (await getUserUseCase.call()).fold((error) => error,(user)=>user);
      }catch(e){}
      finally{
         // comprobacion ---------------------------------
        // si va bien tiene que devolver un valor right y user
        expect(result is MyError, true); 
        expect((result as MyError).message, errorEsperado); 
        // se llamo al obtener el token
        verify(() => serviceLocator<TwitchAuthRepository>().getTokenDataLocal()).called(1); 
        // se obtuvo el user con el token 
        verify(() => serviceLocator<TwitchAuthRepository>().getUserRemote(accessToken)).called(1); 
      }
    });

    test("GETUSER USECASE - Obtener Usuario byId valido",() async {

      String accessToken = "accesToken";
      String id = "id1";
      TokenData tokenData = TokenData(accessToken: accessToken, expiresAt: 200, refreshToken: "refreshToken");

      // preparacion -----------------------
       when(() => serviceLocator<TwitchAuthRepository>().getTokenDataLocal())
        .thenAnswer((invocation) => Future.value(tokenData));

      // getUserRemote(any()) para luego comprobar que si se ha llamado con el accesToken
      when(() => serviceLocator<TwitchChatRepository>().getUserByUserId(any(),any()))
        .thenAnswer((invocation) => Future.value(User.dummy()));

      // ejecucion ---------------------------------
      var result = (await getUserUseCase.call(id: id)).fold((error) => error,(user)=>user); // result puede ser left de tipo MyError o right de tipo Bool
      

      // comprobacion ---------------------------------
      // si va bien tiene que devolver un valor right y user
      expect(result is User, true); 
      // se llamo al obtener el token
      verify(() => serviceLocator<TwitchAuthRepository>().getTokenDataLocal()).called(1); 
      // se obtuvo el user con el token 
      verify(() => serviceLocator<TwitchChatRepository>().getUserByUserId(accessToken,id)).called(1); 

    });


}