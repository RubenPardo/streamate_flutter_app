/// 
/// Clase que representa los datos del token de Oauth 2.0 de twitch
/// atributos:
/// - el token de acceso
/// - fecha de cuando expira el token
/// - y el token para actualizar el token de acceso
class TokenData{

  late final String accessToken;
  late final int expiresAt; 
  late final String refreshToken;


  /// 
  /// param: tokenData = {
  ///   access_token:Texto usado para realizar peticiones a la api 
  ///   expires_in:Int los segundos que tardará en expirar desde que se recibió
  ///   refresh_token:Texto usado para actualizar el access_token
  /// }
  TokenData({required this.accessToken, required this.expiresAt, required this.refreshToken});

  Map<String, dynamic> toMap() {
    return {
      'access_token': accessToken,
      'expires_at': expiresAt,
      'refresh_token': refreshToken,
    };
  }


  factory TokenData.fromApiResponse(Map<String,dynamic> apiResponseJson) {
    String accesToken = apiResponseJson['access_token'] ?? "";
    String refreshToken = apiResponseJson['refresh_token']  ?? "";

    DateTime expiresAtDT = DateTime.now().add(Duration(seconds: apiResponseJson['expires_in'] ?? 0));
    int expiresAt = expiresAtDT.millisecondsSinceEpoch ~/ 1000;

    return TokenData(accessToken: accesToken, expiresAt: expiresAt, refreshToken:refreshToken); 
  }

  factory TokenData.empty(){
    return TokenData(accessToken: "", expiresAt: 0, refreshToken: "");
  }

  factory TokenData.dummyValido(){
    return TokenData(accessToken: "1234", expiresAt: 3600, refreshToken: "5678");
  }

}