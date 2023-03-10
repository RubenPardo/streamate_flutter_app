import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streamate_flutter_app/core/request.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/shared/cambiarAEnv.dart';
import 'package:streamate_flutter_app/shared/strings.dart';


abstract class TwitchAuthService{
  Future<Map<String, dynamic>> getTokenDataRemote(String authorizationCode);
  Future<Map<String, dynamic>> getUserRemote(String accessToken);
  Future<Map<String,dynamic>> updateToken(String accessToken);
  String getAutorizationUrl();
}


class TwitchAuthServiceImpl extends TwitchAuthService{

  ///La función obtenerUrlAutorizacion se utiliza para obtener la URL de autorización necesaria para iniciar 
  ///el flujo de OAuth 2.0. Toma como parámetros el clientId y redirectUri de tu aplicación registrada en Twitch. 
  ///La URL de autorización se construye utilizando estos parámetros y los valores necesarios 
  ///para el flujo de OAuth 2.0, como el tipo de respuesta y los permisos solicitados.
  ///abrir esta URL en un navegador y el usuario podrá iniciar sesión con su cuenta de Twitch y 
  ///otorgar los permisos solicitados. Una vez que el usuario ha otorgado los permisos, 
  ///Twitch redirigirá a la URL de redirección especificada en la aplicación con un código de 
  ///autorización que se utilizará para obtener un token de acceso.
  @override
  String getAutorizationUrl() {
    var scopes = ['user:read:email', 'channel:edit:commercial', 'channel:manage:broadcast', 'channel:read:subscriptions','moderator:manage:banned_users','moderator:manage:chat_messages','moderator:read:chat_settings','moderator:manage:chat_settings','moderator:read:chatters'];
    return '${baseUrlOath}oauth2/authorize?force_verify=true&client_id=$CLIENT_ID&redirect_uri=$REDIRECT_URI&response_type=code'
    '&scope=${scopes.join(" ")}';
  }

  /// Texto, Texto -> getTokenDataRemote() -> [texto:texto]
  ///
  /// Para obtener los datos del token hay que pasarle el codigo de autorizacion y la url de
  /// redireccion donde se encuentra el codigo
  /// 
  /// Parametros:
  /// [authorizationCode] = codigo de autorizacion obtenido al dar permisos en el webview lanzado
  /// 
  /// devuelve un mapa con la siguiente estructura:
  /// 
  /// {
  ///   'access_token': data['access_token'],
  ///    'expires_in': data['expires_in'],
  ///    'refresh_token': data['refresh_token'],
  /// }
  /// 
  @override
  Future<Map<String, dynamic>> getTokenDataRemote(String authorizationCode) async {

    print("Get acces token ------------------------------------ ENTRA");
    // Prepara la solicitud
    //Uri url = Uri.parse('https://id.twitch.tv/oauth2/token');
    String url = '${baseUrlOath}oauth2/token?client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&code=$authorizationCode&grant_type=authorization_code&redirect_uri=$REDIRECT_URI';
    /*Map<String, String> body = {
      'client_id': CLIENT_ID,
      'client_secret': CLIENT_SECRET,
      'code': authorizationCode,
      'grant_type': 'authorization_code',
      'redirect_uri': REDIRECT_URI,
    };*/

    // Envía la solicitud y procesa la respuesta
    //http.Response response = await http.post(url, body: body);
    var response = await serviceLocator<Request>().post(url);
    
    if (response.statusCode == 200) {
      // Si la solicitud es exitosa, devuelve los datos del token de acceso
      
      serviceLocator<Request>().updateAuthorization(response.data['access_token']); // actualizar el token en los headers del objeto dio
   
      return {
        'access_token': response.data['access_token'],
        'expires_in': response.data['expires_in'],
        'refresh_token': response.data['refresh_token'],
      };
    } else {
      // Si la solicitud falla, lanza una excepción
      throw Exception('Error al obtener el token de acceso');
    }
  }

  /// Texto -> updateToken() -> Map<String,dynamic>
  /// utilizar esta función en conjunto con la función isTokenExpired para 
  /// actualizar el token siempre que sea necesario antes de realizar una solicitud a la API de Twitch.
  @override
  Future<Map<String,dynamic>> updateToken(String tokenParaActualizar) async {
    // Prepara la solicitud
    //Uri url = Uri.parse('https://id.twitch.tv/oauth2/token');
    String url = '${baseUrlOath}oauth2/token?client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&grant_type=refresh_token&refresh_token=$tokenParaActualizar';
    /*String url = '${baseUrlOath}oauth2/token';
    Map<String, String> body = {
      'client_id': CLIENT_ID,
      'client_secret': CLIENT_SECRET,
      'grant_type': 'refresh_token',
      'refresh_token': tokenParaActualizar,
    };*/

    // Envía la solicitud y procesa la respuesta
    var response = await serviceLocator<Request>().post(url);
    if (response.statusCode == 200) {
      // Si la solicitud es exitosa, actualiza el token de acceso y la fecha de expiración
     
      serviceLocator<Request>().updateAuthorization(response.data['access_token']); // actualizar el token en los headers del objeto dio
      // persist the new token ;
      return response.data;
    } else {
      // Si la solicitud falla, lanza una excepción
      throw Exception('Error al actualizar el token de acceso');
    }
  }

  ///hace una petición HTTP para obtener los datos del usuario de Twitch, 
  ///utilizando el token de acceso que se encuentra guardado en el _tokenSubject. 
  ///El headers incluyen el token de acceso y el client_id para autenticar la petición. Si la petición es exitosa, 
  ///se decodifica el JSON de respuesta y se devuelve los datos del usuario. Si la petición falla, se lanza 
  ///una excepción con un mensaje de error.
  ///Es importante checar si el token ha expirado, si es asi se debe actualizar o 
  ///pedir uno nuevo para realizar la petición, ya que si no es asi, 
  ///la respuesta sera 403 y no se podra obtener la informacion del usuario.
  @override
  Future<Map<String, dynamic>> getUserRemote(String accessToken) async {
    // Obtiene el token de acceso
    print("Get user ------------------------------------ ENTRA");
  
    // Prepara la solicitud
    //Uri url = Uri.parse('https://api.twitch.tv/helix/users');
    String url = '${baseUrlApi}helix/users';
    var headers = {
      'Client-ID': CLIENT_ID,
    };
    // Envía la solicitud y procesa la respuesta
    var response = await serviceLocator<Request>().get(url,headers: headers);
    if (response.statusCode == 200) {
      // Si la solicitud es exitosa, devuelve los datos del usuario
      
      return response.data['data'][0];
    } else {
      print("ERROR DESDE obtenerUSUARIO: ");
      print(response.data);
      // Si la solicitud falla, lanza una excepción
      throw Exception('Error al obtener los datos del usuario');
    }
  }

 
}