/// clase que representa un emblema de un usuario
class Badge {

  late final String setId;
  late final List<BadgeVersions> badgeVersions;


  Badge(this.setId,this.badgeVersions);


  factory Badge.fromApi(Map<String,dynamic> data){
    //
    // data:
    // {
    //  "set_id": "bits",
    //  "versions": [
    //    {
    //      "id": "1",
    //      "image_url_1x": "https://static-cdn.jtvnw.net/badges/v1/743a0f3b-84b3-450b-96a0-503d7f4a9764/1",
    //      "image_url_2x": "https://static-cdn.jtvnw.net/badges/v1/743a0f3b-84b3-450b-96a0-503d7f4a9764/2",
    //      "image_url_4x": "https://static-cdn.jtvnw.net/badges/v1/743a0f3b-84b3-450b-96a0-503d7f4a9764/3"
    //    }
    //  ]
    //}
    //
    //  

    String setId = data['set_id'] ?? "";
    List<BadgeVersions> versions = [];
    for(dynamic version in data['versions']){
      versions.add(BadgeVersions.fromApi(version));
    }
    return Badge(setId, versions);
  }
  

}

class BadgeVersions{

  late String id;
  late List<String> imageUrls;

  BadgeVersions(this.id,this.imageUrls);


  factory BadgeVersions.fromApi(Map<String,dynamic> data){
    // data = {
    //      "id": "1",
    //      "image_url_1x": "https://static-cdn.jtvnw.net/badges/v1/743a0f3b-84b3-450b-96a0-503d7f4a9764/1",
    //      "image_url_2x": "https://static-cdn.jtvnw.net/badges/v1/743a0f3b-84b3-450b-96a0-503d7f4a9764/2",
    //      "image_url_4x": "https://static-cdn.jtvnw.net/badges/v1/743a0f3b-84b3-450b-96a0-503d7f4a9764/3"
    //    }

    List<String> urls = [];
    urls.add(data['image_url_1x']);
    urls.add(data['image_url_2x']);
    urls.add(data['image_url_4x']);
    return BadgeVersions(data['id'], urls);
  }

}