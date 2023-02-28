class User{

  
  
  late final String id;
  late final String displayName;
  late final String broadcasterType;
  late final String colorUser;
  late final String offlineImageUrl;
  late final int viewCount;
  late final String login;
  late final String description;
  late final String profileImageUrl;
  late final String email;
  late final String createdAt;

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
  User(this.id,this.displayName,this.login,this.email,this.profileImageUrl,
  this.offlineImageUrl,this.broadcasterType,this.description,this.colorUser,
  this.createdAt,this.viewCount);

  factory User.fromApi(Map<String,dynamic> data){
    return User(
      data['id'] ?? "",
      data['display_name'] ?? "",
      data['login'] ?? "",
      data['email'] ?? "",
      data['profile_image_url'] ?? "",
      data['offline_image_url'] ?? "",
      data['broadcaster_type'] ?? "",
      data['description'] ?? "",
      data['color'] ?? "",
      data['created_at'] ?? "",
      data['view_count'] ?? 0,
    );
  }

  factory User.fromIRC(String id, String login, String displayName,String color){
    return User(
      id,
      displayName,
      login,
      "",
      "",
      "",
      "",
      "",
      color,
      "",
      0,
    );
  }


  factory User.dummy(){
    return User("id","user_dummy","user_dummy", "email", "", "", "", "Descripcion dummy", "ff5533", "", 0);
  }
  @override
  String toString() {
    // TODO: implement toString
    return "User[id:$id, name:$displayName, login:$login, email:$email, profilaImage: $profileImageUrl, "
    "offilneImage: $offlineImageUrl, broadcasterType: $broadcasterType, description: $description, color: $colorUser, "
    "createdAt: $createdAt], viewCount: $viewCount";
  }

}