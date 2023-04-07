///
/// Clase que representa una emoticono en el chat
/// Como funciona twitch, de la api se obtienen unos parametros
/// y para poder visualizarlo hay que montar la url template 
/// que nos dan
/// 
///
class Emote {

  static String template = "https://static-cdn.jtvnw.net/emoticons/v2/{{id}}/{{format}}/{{theme_mode}}/{{scale}}";

  late final String id;
  late final String name;
  late final List<String> iamges; // TODO valorar si dejarlo o borrarlo
  late final List<String> format; // puede ser static o animated
  late final List<String> scale; // 1.0 2.0 3.0
  late final List<String> themeMode; // dark light
  late String networkUrl;


  Emote(this.id,this.name,this.iamges,this.format,this.scale,this.themeMode){
    networkUrl = template.replaceAll('{{id}}', id);
    networkUrl = networkUrl.replaceAll('{{format}}', format.contains("animated") ? 'animated' : 'static'); // si se puede animar mejor que estatico
    networkUrl = networkUrl.replaceAll('{{theme_mode}}', themeMode.contains("dark") ? 'dark' : 'light'); // si se puede dark mejor que light
    networkUrl = networkUrl.replaceAll('{{scale}}', scale[0]); // TODO valorar si pillar el 1 o el 2 para el verlo en chat
     
  }


  factory Emote.fromApi(Map<String, dynamic> data){
    //{ ejemplo
    //  "id": "emotesv2_4c3b4ed516de493bbcd2df2f5d450f49",
    //  "name": "twitchdevHyperPitchfork",
    //  "images": {
    //    "url_1x": "https://static-cdn.jtvnw.net/emoticons/v2/emotesv2_4c3b4ed516de493bbcd2df2f5d450f49/static/light/1.0",
    //    "url_2x": "https://static-cdn.jtvnw.net/emoticons/v2/emotesv2_4c3b4ed516de493bbcd2df2f5d450f49/static/light/2.0",
    //    "url_4x": "https://static-cdn.jtvnw.net/emoticons/v2/emotesv2_4c3b4ed516de493bbcd2df2f5d450f49/static/light/3.0"
    //  },
    //  "tier": "1000",
    //  "emote_type": "subscriptions",
    //  "emote_set_id": "318939165",
    //  "format": [
    //    "static",
    //    "animated"
    //  ],
    //  "scale": [
    //    "1.0",
    //    "2.0",
    //    "3.0"
    //  ],
    //  "theme_mode": [
    //    "light",
    //    "dark"
    //  ]
    //}

    return Emote(
      data['id'], 
      data['name'], 
      [data['images']['url_1x'],data['images']['url_2x'],data['images']['url_4x']],
      List<String>.from(data['format']) , 
      List<String>.from(data['scale']), 
      List<String>.from(data['theme_mode'])
    );
  }

}




