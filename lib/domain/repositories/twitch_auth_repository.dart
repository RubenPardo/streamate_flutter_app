
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/data/services/twitch_auth_service.dart';




abstract class TwitchAuthRepository{

  Future<TokenData> getTokenDataRemote(String authorizationCode);
  Future<TokenData> getTokenDataLocal();
  void saveTokenDataLocal(TokenData tokenData);
  Future<void> clearTokenDataLocal();
  Future<bool> isTokenExpired();
  Future<bool> isTokenSavedLocal(); 
  Future<bool> updateToken(String tokenParaActualizar); 
  Future<User> getUserRemote(String accessToken);
  String getAutorizationUrl();
  
}


/// Clase que sirve de abstraccion para nuestra aplicación de la clase TwitchAuthService
class TwitchAuthRepositoryImpl extends TwitchAuthRepository{

  final TwitchAuthService _authService = serviceLocator<TwitchAuthService>();

  @override
  Future<bool> isTokenExpired() {
    return _authService.isTokenExpired();
  }

  @override
  void saveTokenDataLocal(TokenData tokenData) {
    print("GUARDAR token");
    print(tokenData.toMap());
    _authService.saveTokenDataLocal(tokenData.toMap());
  }

  @override
  Future<bool> isTokenSavedLocal() {
    return _authService.isTokenSavedLocal();
  }

  @override
  Future<void> clearTokenDataLocal() {
    return _authService.clearTokenDataLocal();
  }

  @override
  Future<TokenData> getTokenDataLocal() async{
    return TokenData(await _authService.getTokenDataLocal());
  }

  @override
  Future<TokenData> getTokenDataRemote(String authorizationCode) async{
    return TokenData(await _authService.getTokenDataRemote(authorizationCode));
  }

  @override
  Future<User> getUserRemote(String accessToken) async{
    return User(await _authService.getUserRemote(accessToken));
  }
  
  @override
  String getAutorizationUrl() {
    return _authService.getAutorizationUrl();
  }
  
  @override
  Future<bool> updateToken(String tokenParaActualizar) async {
    return await _authService.updateToken(tokenParaActualizar);
  }

}