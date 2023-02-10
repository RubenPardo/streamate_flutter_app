import 'package:streamate_flutter_app/core/request.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/shared/cambiarAEnv.dart';
import 'package:streamate_flutter_app/shared/strings.dart';

///
/// Clase para acceder a la Api de twitch
///
abstract class TwitchApiService{
  Future<Map<String, dynamic>> getTokenDataRemote(String authorizationCode);
  Future<List<dynamic>> getUsers(String accessToken, {List<String>? loginNames});
  Future<Map<String,dynamic>> updateToken(String accessToken);
  String getAutorizationUrl();
  Future<bool> banUser(String idBroadCaster, String idUser, {int duration});
  Future<bool> unBanUser(String idBroadCaster, String idUser);
  Future<bool> deleteMessage(String idBroadCaster, String idMessage);
  Future<String> getUserColor( String idUser);
  Future<Map<String, dynamic>> getChatSettings(String idBroadCaster);
  Future<bool> updateChatSetting(String idBroadCaster,List<String> setting, List<String> value);
  Future<List<dynamic>> getGlobalBadges();
  Future<List<dynamic>> getChannelBadges(String idBroadcaster);
  Future<List<dynamic>> getGlobalEmotes();
  Future<List<dynamic>> getChannelEmotes(String idBroadcaster);

}


class TwitchApiServiceImpl extends TwitchApiService{

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
    var scopes = ['user:read:email', 'channel:edit:commercial', 'channel:manage:broadcast', 'channel:read:subscriptions','moderator:manage:banned_users','moderator:manage:chat_messages','channel:moderate','moderator:read:chat_settings','moderator:manage:chat_settings','moderator:read:chatters','chat:read','chat:edit'];
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
    // Prepara la solicitud
    //Uri url = Uri.parse('https://id.twitch.tv/oauth2/token');
    String url = '${baseUrlOath}oauth2/token?client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&code=$authorizationCode&grant_type=authorization_code&redirect_uri=$REDIRECT_URI';

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
    String url = '${baseUrlOath}oauth2/token?client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&grant_type=refresh_token&refresh_token=$tokenParaActualizar';

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

  /// Texto, List<Texto> -> getUserRemote() -> List<Map<String,objeto>>
  ///You may look up users using their user ID, login name, 
  ///or both but the sum total of the number of users you may look up is 100. 
  ///For example, you may specify 50 IDs and 50 names or 100 IDs or names, 
  ///but you cannot specify 100 IDs and 100 names.
  ///
  ///If you don’t specify IDs or login names, the request returns information 
  ///about the user in the access token if you specify a user access token.
  @override
  Future<List<dynamic>> getUsers(String accessToken, {List<String>? loginNames}) async {
    // Obtiene el token de acceso
    // 
    // Prepara la solicitud
    String url = '${baseUrlApi}helix/users';
    var headers = {
      'Client-ID': CLIENT_ID,
    };

    // añadir si hay login names
    if(loginNames!=null){
      // añadir a la url '?login=foo&login=bar'
      url+= "?login=";
      url+= loginNames.join('&login=');
    }

    // Envía la solicitud y procesa la respuesta
    var response = await serviceLocator<Request>().get(url,headers: headers);
    if (response.statusCode == 200) {
      // Si la solicitud es exitosa, devuelve los datos del usuario
      
      return response.data['data'];
    } else {
      print("ERROR DESDE obtenerUSUARIO: ");
      print(response.data);
      // Si la solicitud falla, lanza una excepción
      throw Exception('Error al obtener los datos del usuario');
    }
  }
  

  /// Texto, Texto, N -> banUser() -> T/F
  /// vetar a un usuario con id = [idUser] del chat de la retransmisión con id = [idBroadCaster]
  /// si se pasa [duration] se le pondrá un timeout
  @override
  Future<bool> banUser(String idBroadCaster, String idUser, {int? duration}) async{
    // POST moderation/bans

    // moderator id y broadcaster id es el mismo porque en todo momento es el dueño del stream
    String url = '${baseUrlApi}helix/moderation/bans?broadcaster_id=$idBroadCaster&moderator_id=$idBroadCaster';
    Map body = {
      'data':{
        'user_id':idUser,
      }
    };
    if(duration!=null){
      // añadir timeout si se pasa
      body['data']!['duration'] = duration.toString();
    }
    // Envía la solicitud y procesa la respuesta
    var response = await serviceLocator<Request>().post(url,data: body);
    
    return response.statusCode == 200;
        
  }
  
  /// Texto, Texto, N -> banUser() -> T/F
  /// se levantan todas las restricciones del usuario con id = [idUser] 
  /// del chat de la retransmisión con id = [idBroadCaster]
  /// sea un veto o un timeout
   @override
  Future<bool> unBanUser(String idBroadCaster, String idUser) async{
    // moderator id y broadcaster id es el mismo porque en todo momento es el dueño del stream
    String url = '${baseUrlApi}helix/moderation/bans?broadcaster_id=$idBroadCaster&moderator_id=$idBroadCaster&user_id=$idUser';

    var response = await serviceLocator<Request>().delete(url);
    
    return response.statusCode == 204;
  }

  /// Texto, Texto -> deleteMessage -> T/F
  /// borrar un mensaje con id = [idMessage] del canal con id = [idBroadCaster]
  @override
  Future<bool> deleteMessage(String idBroadCaster, String idMessage) async{
    String url = '${baseUrlApi}helix/moderation/chat?broadcaster_id=$idBroadCaster&moderator_id=$idBroadCaster&message_id=$idMessage';

    // Envía la solicitud y procesa la respuesta
    var response = await serviceLocator<Request>().delete(url);
    
    return response.statusCode == 204;
    
  }
  
  /// Texto -> getChannelBadges -> Map<String, dynamic>
  /// obtener los emblemas de un canal con id = [idBroadcaster]
  @override
  Future<List<dynamic>> getChannelBadges(String idBroadcaster) async{
    String url = '${baseUrlApi}helix/chat/badges?broadcaster_id=$idBroadcaster';

    // Envía la solicitud y procesa la respuesta
    var response = await serviceLocator<Request>().get(url);
    if (response.statusCode == 200) {
      // Si la solicitud es exitosa, devuelve los datos del usuario
      
      return response.data['data'];
    } else {
      print("ERROR DESDE getChannelBadges: ");
      print(response.data);
      // Si la solicitud falla, lanza una excepción
      throw Exception('Error al obtener los emblemas del canal');
    }
  }

  /// -> getGlobalBadges -> Map<String, dynamic>
  /// obtener los emblemas generales de Twitch
  @override
  Future<List<dynamic>> getGlobalBadges() async{
    String url = '${baseUrlApi}helix/chat/badges/global';

    // Envía la solicitud y procesa la respuesta
    var response = await serviceLocator<Request>().get(url);
    if (response.statusCode == 200) {
      // Si la solicitud es exitosa, devuelve los datos del usuario
      
      return response.data['data'];
    } else {
      print("ERROR DESDE getGlobalBadges: ");
      print(response.data);
      // Si la solicitud falla, lanza una excepción
      throw Exception('Error al obtener los emblemas globales');
    }
  }
  
  /// Texto -> getChannelEmotes -> Map<String, dynamic>
  /// obtener los emoticonos de un canal con id = [idBroadcaster]
  @override
  Future<List<dynamic>> getChannelEmotes(String idBroadcaster) async{
    String url = '${baseUrlApi}helix/chat/emotes?broadcaster_id=$idBroadcaster';

    // Envía la solicitud y procesa la respuesta
    var response = await serviceLocator<Request>().get(url);
    if (response.statusCode == 200) {
      // Si la solicitud es exitosa, devuelve los datos del usuario
      
      return response.data['data'];
    } else {
      print("ERROR DESDE getChannelEmotes: ");
      print(response.data);
      // Si la solicitud falla, lanza una excepción
      throw Exception('Error al obtener los emotes del canal');
    }
  }

   /// -> getGlobalEmotes -> Map<String, dynamic>
  /// obtener los emoticonos generales de Twitch
  @override
  Future<List<dynamic>> getGlobalEmotes() async{
    String url = '${baseUrlApi}helix/chat/emotes/global';

    // Envía la solicitud y procesa la respuesta
    var response = await serviceLocator<Request>().get(url);
    if (response.statusCode == 200) {
      // Si la solicitud es exitosa, devuelve los datos del usuario
      
      return response.data['data'];
    } else {
      print("ERROR DESDE getGlobalEmotes: ");
      print(response.data);
      // Si la solicitud falla, lanza una excepción
      throw Exception('Error al obtener los emotes globales');
    }
  }
  
  /// Texto -> getChatSettings -> Map<String, dynamic>
  /// obtener los ajustes de un canal con id = [idBroadCaster]
  /// Usamos esta funcion para saber si el chat esta en modo subs, modo emotesm etc..
  @override
  Future<Map<String, dynamic>> getChatSettings(String idBroadCaster) async{
    String url = '${baseUrlApi}helix/chat/settings?broadcaster_id=$idBroadCaster';

    // Envía la solicitud y procesa la respuesta
    var response = await serviceLocator<Request>().get(url);
    if (response.statusCode == 200) {
      // Si la solicitud es exitosa, devuelve los datos del usuario
      
      return response.data['data'][0];
    } else {
      print("ERROR DESDE getChatSettings: ");
      print(response.data);
      // Si la solicitud falla, lanza una excepción
      throw Exception('Error al obtener los ajustes del chat');
    }
  }
  
  /// Texto, Texto, Texto -> updateChatSetting() -> T/F
  ///
  /// Actualiza uno de los ajustes [setting] del chat de twitch [value] 
  /// 
  ///
  @override
  Future<bool> updateChatSetting(String idBroadCaster,List<String> setting, List<String> value) async{
    
      if(setting.length == value.length){
        String url = '${baseUrlApi}helix/chat/settings?broadcaster_id=$idBroadCaster&moderator_id=$idBroadCaster';
        
        var body = {};
        
        for(int i = 0; i< setting.length; i++){
          body[setting[i]] = value[i] == "null" ? null :value[i];
        }
        
        // Envía la solicitud y procesa la respuesta
        var response = await serviceLocator<Request>().patch(url,data:body);
        if (response.statusCode == 200) {
          return true;
        } else {
          throw Exception('Failed to update chat setting');
        }
    }else{
      throw Exception('Error al actualizar ajustes de chat: tamaño de settings y values es distinto');
    }

    
  }
  
  /// Texto -> getUserColor() -> Texto
  /// Obtener el color asociado del usario con id = [idUser] en el chat
  ///
  @override
  Future<String> getUserColor(String idUser) async{
    String url = '${baseUrlApi}helix/chat/color?user_id=$idUser';

    // Envía la solicitud y procesa la respuesta
    var response = await serviceLocator<Request>().get(url);
    if (response.statusCode == 200) {
      // Si la solicitud es exitosa, devuelve los datos del usuario
      
      return response.data['data'][0]['color'];
    } else {
      print("ERROR DESDE getUserColor: ");
      print(response.data);
      // Si la solicitud falla, lanza una excepción
      throw Exception('Error al obtener el color del usuario con id: $idUser');
    }
  }
  
 


 
}