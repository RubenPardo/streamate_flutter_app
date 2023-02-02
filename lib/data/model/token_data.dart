/// 
/// Clase que representa los datos del token de Oauth 2.0 de twitch
/// atributos:
/// - el token de acceso
/// - la fecha en que expira
/// - y el token para actualizar el token de acceso
class TokenData{

  late final String accesToken;
  late final int expiresIn;
  late final String refresh_token;


  TokenData(Map<String,dynamic> tokenData){
    accesToken = tokenData['access_token'];
    expiresIn = tokenData['expires_in'];
    refresh_token = tokenData['refresh_token'];
  }

  Map<String, dynamic> toMap() {
    return {
      'access_token': accesToken,
      'expires_in': expiresIn,
      'refresh_token': refresh_token,
    };
  }

}