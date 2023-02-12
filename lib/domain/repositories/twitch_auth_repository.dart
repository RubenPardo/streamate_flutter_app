
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streamate_flutter_app/core/request.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/data/services/twitch_api_service.dart';




abstract class TwitchAuthRepository{

  Future<TokenData> getTokenDataRemote(String authorizationCode);
  Future<TokenData> getTokenDataLocal();
  void saveTokenDataLocal(TokenData tokenData);
  Future<void> clearTokenDataLocal();
  Future<bool> isTokenExpired();
  Future<bool> isTokenSavedLocal(); 
  Future<TokenData> updateToken(String tokenParaActualizar); 
  Future<User> getUserRemote(String accessToken);
  String getAutorizationUrl();
  
}


/// Clase que sirve de abstraccion para nuestra aplicación de la clase TwitchAuthService
class TwitchAuthRepositoryImpl extends TwitchAuthRepository{

  final TwitchApiService _authService = serviceLocator<TwitchApiService>();


  
  /// getTokenDataLocal() -> TokenData
  /// 
  /// Obtiene los datos del token guardados en sharedPreferences 
  /// y los devuelve en map
  ///  {
  ///    'access_token': accessToken,
  ///    'expires_in': expiresIn,
  ///    'refresh_token': refreshToken,
  ///  }
  /// 
  ///
  @override
  Future<TokenData> getTokenDataLocal() async {
     
    // Obtiene una instancia de SharedPreferences
    SharedPreferences prefs = serviceLocator<SharedPreferences>();

    // Obtiene los valores de acces_token, expires_in y refresh_token de las preferencias
    final accessToken = prefs.getString('access_token');
    final expiresAt = prefs.getInt('expires_at');
    final refreshToken = prefs.getString('refresh_token');

    // Si alguno de los valores es nulo, significa que no hay un token guardado
    if (accessToken == null || expiresAt == null || refreshToken == null) {
      return TokenData.empty();
    }

    // Devuelve los valores en un mapa
    TokenData tokenData = TokenData(accessToken: accessToken,expiresAt: expiresAt,refreshToken: refreshToken);
    serviceLocator<Request>().updateAuthorization(tokenData.accessToken);
    return tokenData;
  }

  /// TokenData -> saveTokenDataLocal() -> 
  /// Función para persistir el token de acceso en el dispositivo
  @override
  Future<void> saveTokenDataLocal(TokenData tokenData) async {
    //  ;
    SharedPreferences prefs = serviceLocator<SharedPreferences>();
    print("SE VA A GUARDAR: ${tokenData.toMap()}");
    prefs.setString('access_token', tokenData.accessToken);
    prefs.setInt('expires_at', tokenData.expiresAt);
    prefs.setString('refresh_token', tokenData.refreshToken);
  }

  /// clearTokenDataLocal()
  /// Función para limpiar el token de acceso del dispositivo
  @override
  Future<void> clearTokenDataLocal() async {
    
    SharedPreferences prefs = serviceLocator<SharedPreferences>();
    prefs.remove('access_token');
    prefs.remove('expires_at');
    prefs.remove('refresh_token');
  }

  /// isTokenExpired -> T/F
  ///
  @override
  Future<bool> isTokenExpired() async{
    TokenData tokenData = await getTokenDataLocal();
    return DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(tokenData.expiresAt));
  }

  /// isTokenSavedLocal() -> T/F
  /// Comprobar si hay un token guardado en el almacenamiento interno del movil
  @override
  Future<bool> isTokenSavedLocal() async{
    TokenData tokenData = await getTokenDataLocal();
    // si uno de estos datos no esta no hay token
    if (tokenData.accessToken == "" || tokenData.expiresAt == 0 || tokenData.refreshToken == "") {
      return false;
    }else{
      return true;
    }
  }


  /// Texto -> getTokenDataRemote() -> TokenData
  @override
  Future<TokenData> getTokenDataRemote(String authorizationCode) async{

    TokenData tokenData;
    // pedimos el token actualizado
    try{
      tokenData = TokenData.fromApiResponse(await _authService.getTokenDataRemote(authorizationCode));

    }catch(error){
      tokenData = TokenData.empty();
    }
    return tokenData;
  }

  @override
  Future<User> getUserRemote(String accessToken) async{
    return User.fromApi((await _authService.getUsers(accessToken))[0]);
  }
  
  /// getAutorizationUrl() -> String
  @override
  String getAutorizationUrl() {
    return _authService.getAutorizationUrl();
  }
  

  /// Texto -> updateToken() -> TokenData
  @override
  Future<TokenData> updateToken(String tokenParaActualizar) async {
    TokenData tokenData;
    // pedimos el token actualizado
    try{
      tokenData = TokenData.fromApiResponse(await _authService.updateToken(tokenParaActualizar));

    }catch(error){
      tokenData = TokenData.empty();
    }
    return tokenData;
  }

}