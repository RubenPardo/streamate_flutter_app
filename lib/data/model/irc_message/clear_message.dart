import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/data/model/irc_message/irc_message.dart';
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart' as texts;


/// Clase que representa un mensaje irc que llega cuando un mensaje se borra
class ClearMessage extends IRCMessage{
  String idMessage;
  String loginName;

  ClearMessage(this.idMessage, this.loginName, {required String message}):super(message, IRCCommand.clearMessage);

  factory ClearMessage.fromIRCData(String data){
    //@login=tostyfis360;room-id=;target-msg-id=1e48e381-4ca8-420f-9236-7b391502c2ef;
    //tmi-sent-ts=1678020277488 :tmi.twitch.tv CLEARMSG #ruben_pardo_2 :from barcelon
    
    
    final mappedTags = Utils.mapTagsIrcData(data);

    String id = mappedTags['target-msg-id'] ?? "";
    String loginName = mappedTags['@login'] ?? "";
    String message = texts.eliminarMensaje + loginName;
    return ClearMessage(id,loginName, message: message);


  }
}