import 'package:streamate_flutter_app/data/model/irc_message/irc_message.dart';
import 'package:streamate_flutter_app/data/model/irc_message/private_message.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart' as texts;
/// Fichero donde se definen los mensajes UserNoticeMessage y todas sus variantes


/// Clase que representa los atributos comunes de un mensaje UserNoticeMessage
class UserNoticeMessage extends IRCMessage{

  //bool isPrime; // para mostrar la corona en el caso de que sea prime o la estrella si es normal
  User user;
  String msgId;
  UserNoticeMessage(this.user,this.msgId,{required String message}):super(message,IRCCommand.userNotice);

  factory UserNoticeMessage.fromIRCData(String data){
    // extraer el msg-id, posibles = sub, resub, subgift, anonsubgift, submysterygift, raid

    //@badge-info=subscriber/10;badges=broadcaster/1,subscriber/0,premium/1;
    //color=#008000;display-name=example_user;emotes=;id=123abc-45e;login=example_user;
    //mod=0;msg-id=resub;msg-param-months=12;msg-param-sub-plan-name=Channel\ Subscriber;
    //msg-param-sub-plan=Prime;room-id=123456;subscriber=1;
    //system-msg=example_user\ subscribed\ for\ 12\ months\ in\ a\ row!;
    //tmi-sent-ts=1558493725000;turbo=0;
    //user-id=123456;user-type=
    // :example_user!example_user@tmi.twitch.tv 

      // mapear los tags en clave valor
    final mappedTags = <String, String>{};
  

    // Loop through each tag and store their key value pairs into the map.
    for (final tag in data.split(';')) {
      // Skip if the tag has no value.
      if (tag.endsWith('=')) continue;

      final tagSplit = tag.split('=');
      mappedTags[tagSplit[0]] = tagSplit[1];
    }

    // obtener el tipo de mensaje
    String msgId = mappedTags["msg-id"] ?? "";
    
    switch(msgId){
      case "sub":
        return SubscriptionNotice.fromIRCData(msgId, mappedTags,data);
      case "resub":
        return SubscriptionNotice.fromIRCData(msgId, mappedTags,data);
      case "announcement":
        return Announcement.fromIRCData(msgId, mappedTags, data);
      case "submysterygift":
        return SubMysterGift.fromIRCData(msgId, mappedTags, data);
      case "subgift":
        return SubGift.fromIRCData(msgId, mappedTags, data);
      case "raid":
        break;
    }
    return SubscriptionNotice(User.fromIRC("id"," login", "displayName", ""),msgId,"",false,false,null,null, message: "PRUEBA");// TODO quitar
  }
  


  factory UserNoticeMessage.dummySubscriptionPrime(){
    return SubscriptionNotice(
      User.dummy(), 
      "resub", 
      "3", 
      true, 
      false, 
      null, 
      PrivateMessage.dummyResub(), 
      message: "se ha suscrito con prime. ¡Su suscripicón es de 3 meses!"
    );
  }
  factory UserNoticeMessage.dummyGift5Sub(){
    return UserNoticeMessage.fromIRCData("@badge-info=subscriber/20;badges=subscriber/12,premium/1;color=#FF0000;display-name=The_eMe20;emotes=;flags=;id=87f83479-66ea-42f7-8a62-36e1a9dfe75b;login=the_eme20;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=5;msg-param-origin-id=3c\\s6e\\s10\\s98\\s90\\s63\\s45\\s4c\\s70\\sb5\\s7a\\s97\\s3f\\s48\\sfc\\sf4\\s4d\\sb4\\s14\\sc9;msg-param-sender-count=262;msg-param-sub-plan=1000;room-id=605221125;subscriber=1;system-msg=The_eMe20\\sis\\sgifting\\s5\\sTier\\s1\\sSubs\\sto\\sgerardromero's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s262\\sin\\sthe\\schannel!;tmi-sent-ts=1677590893254;user-id=276665317;user-type= :tmi.twitch.tv USERNOTICE #gerardromero");
  }
  factory UserNoticeMessage.dummyGiftedSub(){
    return UserNoticeMessage.fromIRCData("@badge-info=subscriber/20;badges=subscriber/12,premium/1;color=#FF0000;display-name=The_eMe20;emotes=;flags=;id=03604d2c-60fa-409a-a616-e3fc0e23b3a7;login=the_eme20;mod=0;msg-id=subgift;msg-param-gift-months=1;msg-param-months=1;msg-param-origin-id=3c\s6e\s10\s98\s90\s63\s45\s4c\s70\sb5\s7a\s97\s3f\s48\sfc\sf4\s4d\sb4\s14\sc9;msg-param-recipient-display-name=odco89;msg-param-recipient-id=50439450;msg-param-recipient-user-name=odco89;msg-param-sender-count=0;msg-param-sub-plan-name=JIJANTE;msg-param-sub-plan=1000;room-id=605221125;subscriber=1;system-msg=The_eMe20\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\sodco89!;tmi-sent-ts=1677590893853;user-id=276665317;user-type= :tmi.twitch.tv USERNOTICE #gerardromero");
  }
  
  factory UserNoticeMessage.dummyAnnouncement(){
    return UserNoticeMessage.fromIRCData("@badge-info=;badges=moderator/1,partner/1;color=#54BC75;display-name=Moobot;emotes=;flags=;id=89b202c1-30ff-445e-b3ee-8fa0555c6af8;login=moobot;mod=1;msg-id=announcement;msg-param-color=GREEN;room-id=121606712;subscriber=0;system-msg=;tmi-sent-ts=1677425473325;user-id=1564983;user-type=mod :tmi.twitch.tv USERNOTICE #kingsleague :ENTRA EN EL TWITTER DE GREFUSA Y GANA LOTAZOS: https://twitter.com/grefusa");
  }

}

/// Clase que representa una suscripcion en el chat
class SubscriptionNotice extends UserNoticeMessage{
  
  PrivateMessage? privateMessage;
  bool isPrime;
  bool isGift;
  String? cumulativeMonths;
  String? tierSub; // 100 = 1, 2000 = 2, 3000 = 3
  String? gifterName;
  

  get haveMessage => privateMessage !=null;

  SubscriptionNotice(super.user,super.msgId, this.cumulativeMonths,this.isPrime,this.isGift,this.gifterName, this.privateMessage,{required super.message});

  factory SubscriptionNotice.fromIRCData(String msgId, Map<String, String> mappedTags,String rawData){

    // obtener el user
    User user = User.fromIRC(mappedTags['user-id']??"",mappedTags['login']??"", mappedTags['display-name']??"", mappedTags['color']??"");

    // obtener el mensaje
    /// sub con prime
    /// @badge-info=subscriber/1;badges=subscriber/0,premium/1;
    /// color=;display-name=guillermuss01;emotes=;flags=;id=7e50bd3f-47e3-40ed-8694-2c853fbdc4a0;
    /// login=guillermuss01;mod=0;msg-id=sub;msg-param-cumulative-months=1;
    /// msg-param-months=0;msg-param-multimonth-duration=1;
    /// msg-param-multimonth-tenure=0;msg-param-should-share-streak=0;
    /// msg-param-sub-plan-name=Channel\sSubscription\s(KingsLeague);
    /// msg-param-sub-plan=Prime;msg-param-was-gifted=false;room-id=121606712;
    /// subscriber=1;system-msg=guillermuss01\ssubscribed\swith\sPrime.;
    /// tmi-sent-ts=1677425426188;user-id=412109296;
    /// user-type= :tmi.twitch.tv USERNOTICE #kingsleague
    ///
    /// sub sin prime
    /// 
    ///@badge-info=subscriber/1;badges=subscriber/0;color=#0F6A44;display-name=joseph_ramos1;emotes=;
    ///flags=;id=abc97bc5-9cae-4163-a967-e8ed897f6866;login=joseph_ramos1;mod=0;msg-id=sub;
    ///msg-param-cumulative-months=1;msg-param-months=0;msg-param-multimonth-duration=1;
    ///msg-param-multimonth-tenure=0;msg-param-should-share-streak=0;
    ///msg-param-sub-plan-name=Channel\sSubscription\s(KingsLeague);msg-param-sub-plan=1000;
    ///msg-param-was-gifted=false;room-id=121606712;subscriber=1;system-msg=joseph_ramos1\ssubscribed\sat\sTier\s1.;
    ///tmi-sent-ts=1677425419079;user-id=52956158;user-type= :tmi.twitch.tv USERNOTICE #kingsleague
    
    String? cumulativeMonths = mappedTags['msg-param-cumulative-months'];
    bool isPrime = mappedTags['msg-param-sub-plan'] == null ? false : mappedTags['msg-param-sub-plan'] == "Prime"; 

    bool isGifted = mappedTags['msg-param-was-gifted'] == "false";
    String? gitfterName  = mappedTags['msg-param-recipient-user-name'];
    String? tierSub;
    switch(mappedTags['msg-param-sub-plan']){
      case "1000":tierSub = "1";break;
      case "2000":tierSub = "2";break;
      case "3000":tierSub = "3";break;
    }
   
    
    // empezamos el mensaje con el nombre del user
    // TODO cambiar a un texto para poder traducrilo con simbolos para hacer replace
    String noticeMessage = "se ha suscrito con ${isPrime ? "prime" : "el nivel $tierSub"}.";

    if(cumulativeMonths != null && cumulativeMonths != "1"){
      // resub
      noticeMessage += " ¡Su suscripicón es de $cumulativeMonths meses!";
    }
    
    // obtener el posible mensaje de sub
    var splitData = rawData.split(":");
    String message = splitData[splitData.length-1];

    PrivateMessage? privateMessage = message.contains("USERNOTICE") ? null : PrivateMessage.fromIRCData(rawData, message);

    return SubscriptionNotice(user, msgId,cumulativeMonths,isPrime,isGifted,gitfterName,privateMessage, message: noticeMessage);
  }
  
}

// announcement
/// Clase que representa un anuncio en el chat
/// ejemplo de irc: @badge-info=;badges=moderator/1,partner/1;color=#54BC75;display-name=Moobot;emotes=;flags=;id=89b202c1-30ff-445e-b3ee-8fa0555c6af8;login=moobot;mod=1;msg-id=announcement;msg-param-color=GREEN;room-id=121606712;subscriber=0;system-msg=;tmi-sent-ts=1677425473325;user-id=1564983;user-type=mod :tmi.twitch.tv USERNOTICE #kingsleague :ENTRA EN EL TWITTER DE GREFUSA Y GANA LOTAZOS: https://twitter.com/grefusa
class Announcement extends UserNoticeMessage{

  PrivateMessage privateMessage;
  
  Announcement(super.user, super.msgId,this.privateMessage,{required super.message});

  

  factory Announcement.fromIRCData(String msgId, Map<String, String> mappedTags,String rawData){
    // obtener el user
    User user = User.fromIRC(mappedTags['user-id']??"",mappedTags['login']??"", mappedTags['display-name']??"", mappedTags['color']??"");
    
    // el mensaje es el final del raw data
    // extraemos el mensaje con expresion regular, entre el usernotice #<cualquier cosa> :<mesnaje a extraer>
    var splitData = rawData.split(RegExp(r'USERNOTICE\s+#\w+\s+:'));
    String message = splitData[splitData.length-1];


    return Announcement(user, msgId,PrivateMessage.fromIRCData(rawData, message),message: message);
  }
}

// submysterygift
/// clase que representa cuando alguien dona subscripciones
/// ejemplo: @badge-info=subscriber/20;badges=subscriber/12,premium/1;color=#FF0000;display-name=The_eMe20;emotes=;flags=;id=87f83479-66ea-42f7-8a62-36e1a9dfe75b;login=the_eme20;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=5;msg-param-origin-id=3c\s6e\s10\s98\s90\s63\s45\s4c\s70\sb5\s7a\s97\s3f\s48\sfc\sf4\s4d\sb4\s14\sc9;msg-param-sender-count=262;msg-param-sub-plan=1000;room-id=605221125;subscriber=1;system-msg=The_eMe20\sis\sgifting\s5\sTier\s1\sSubs\sto\sgerardromero's\scommunity!\sThey've\sgifted\sa\stotal\sof\s262\sin\sthe\schannel!;tmi-sent-ts=1677590893254;user-id=276665317;user-type= :tmi.twitch.tv USERNOTICE #gerardromero
class SubMysterGift extends UserNoticeMessage{
  SubMysterGift(super.user, super.msgId, {required super.message});


  factory SubMysterGift.fromIRCData(String msgId, Map<String, String> mappedTags,String rawData){
    // obtener el user
    User user = User.fromIRC(mappedTags['user-id']??"",mappedTags['login']??"", mappedTags['display-name']??"", mappedTags['color']??"");
    
    //"msg-param-mass-gift-count": indica el número de suscripciones que se han regalado en este mensaje.
    String giftCount = mappedTags["msg-param-mass-gift-count"] ?? "";
    
    /*String message = mappedTags["system-msg"] != null ? mappedTags["system-msg"]!.replaceAll("\\s", " ") : "";
    message = message.replaceFirst(user.displayName,"");*/

    //"msg-param-sub-plan": indica el plan de suscripción (Prime, Tier 1, Tier 2, Tier 3) que se ha regalado.
    String? tierSub;
    switch(mappedTags['msg-param-sub-plan']){
      case "1000":tierSub = "1";break;
      case "2000":tierSub = "2";break;
      case "3000":tierSub = "3";break;
    }

    // obtener el nombre del canal
    var splitData = rawData.split(" ");
    String comunityName = splitData[splitData.length-1].replaceAll("#",""); 
    String message = texts.subMysterGift.replaceAll("{1?}",giftCount);
    message = message.replaceAll("{2?}",tierSub ?? "");
    message = message.replaceAll("{3?}",comunityName);

    return SubMysterGift(user, msgId, message: message);
  }
}

// subgift
/// clase que representa el mensaje cuando alguien recibe un suscripción
/// ejemplo: @badge-info=subscriber/20;badges=subscriber/12,premium/1;color=#FF0000;display-name=The_eMe20;emotes=;flags=;id=03604d2c-60fa-409a-a616-e3fc0e23b3a7;login=the_eme20;mod=0;msg-id=subgift;msg-param-gift-months=1;msg-param-months=1;msg-param-origin-id=3c\s6e\s10\s98\s90\s63\s45\s4c\s70\sb5\s7a\s97\s3f\s48\sfc\sf4\s4d\sb4\s14\sc9;msg-param-recipient-display-name=odco89;msg-param-recipient-id=50439450;msg-param-recipient-user-name=odco89;msg-param-sender-count=0;msg-param-sub-plan-name=JIJANTE;msg-param-sub-plan=1000;room-id=605221125;subscriber=1;system-msg=The_eMe20\sgifted\sa\sTier\s1\ssub\sto\sodco89!;tmi-sent-ts=1677590893853;user-id=276665317;user-type= :tmi.twitch.tv USERNOTICE #gerardromero
class SubGift extends UserNoticeMessage{

  String userRecivingSub;
  SubGift(super.user, super.msgId, this.userRecivingSub,{required super.message});


  factory SubGift.fromIRCData(String msgId, Map<String, String> mappedTags,String rawData){
    // obtener el user
    User user = User.fromIRC(mappedTags['user-id']??"",mappedTags['login']??"", mappedTags['display-name']??"", mappedTags['color']??"");
    
    //"msg-param-recipient-user-name": indica el nombre de usuario que ha recibido la sub
    
    String userRecivingSub = mappedTags["msg-param-recipient-user-name"] ?? "";
    //"msg-param-sub-plan": indica el plan de suscripción (Prime, Tier 1, Tier 2, Tier 3) que se ha regalado.
    String? tierSub;
    switch(mappedTags['msg-param-sub-plan']){
      case "1000":tierSub = "1";break;
      case "2000":tierSub = "2";break;
      case "3000":tierSub = "3";break;
    }

    String message = texts.subGifted.replaceAll("{1?}",tierSub ?? "");

    return SubGift(user, msgId, userRecivingSub, message: message);
  }
}
