class User{

  
  
  late final String name;
  late final String login;
  late final String description;
  late final String profileImageUrl;
 /* late final String urlOfflineImagen;
  late final String email;
  late final String cuentaCreadaEn;
*/
  ///
  ///
  /// Ejemplo de datos:
  /// {id: 230213335, login: ruben_pardo, display_name: ruben_pardo, type: , 
  /// broadcaster_type: , description: why are we still here, just to suffer, 
  /// profile_image_url: https://static-cdn.jtvnw.net/jtv_user_pictures/46225d55-41c6-4b25-8e8d-9c7d11897a14-profile_image-300x300.png, 
  /// offline_image_url: , 
  /// view_count: 4, 
  /// email: rubenpardocasanova@gmail.com, 
  /// created_at: 2018-06-10T08:08:36Z
  /// }
  ///
  User(Map<String,dynamic> data){
    name = data['display_name'] ?? "";
    login = data['login'] ?? "";
    profileImageUrl = data['profile_image_url'] ?? "";
    description = data['description'] ?? "";
  }

}