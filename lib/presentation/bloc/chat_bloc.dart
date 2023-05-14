import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/data/model/badge.dart';
import 'package:streamate_flutter_app/data/model/chat_setting.dart';
import 'package:streamate_flutter_app/data/model/emote.dart';
import 'package:streamate_flutter_app/data/model/irc_message/clear_all_messages.dart';
import 'package:streamate_flutter_app/data/model/irc_message/clear_message.dart';
import 'package:streamate_flutter_app/data/model/irc_message/irc_message.dart';
import 'package:streamate_flutter_app/data/model/irc_message/notice_message.dart';
import 'package:streamate_flutter_app/data/model/irc_message/private_message.dart';
import 'package:streamate_flutter_app/data/model/irc_message/room_state_message.dart';
import 'package:streamate_flutter_app/data/model/irc_message/user_notice_message.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_chat_repository.dart';
import 'package:streamate_flutter_app/domain/usecases/ban_user_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/delete_message_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/get_badges_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/get_chat_settings_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/get_emotes_use_case.dart';
import 'package:streamate_flutter_app/domain/usecases/update_chat_setting_use_case.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_state.dart';
import 'package:streamate_flutter_app/shared/widgets/twitch_chat_items/twitch_chat_private_message.dart';
import 'package:rxdart/rxdart.dart';
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart' as texts;

import '../../shared/widgets/twitch_chat_items/twitch_chat_notice_message.dart';
import '../../shared/widgets/twitch_chat_items/twitch_chat_user_notice_message.dart';


class ChatBloc extends Bloc<ChatEvent, ChatState> {

    static List<Emote> allEmotes =[];
    static List<Badge> allBadges =[];

    // atributos para hacer las peticiones
    late String _idBroadcaster;
    late String _accesToken;
    late String _loginUserName;

    late User _broadcasterUser;
    User get getBroadcasterUser => _broadcasterUser;


    // atributos del IRCchat -----------------------------------------
    // stream que se devuelve a la vista y el controlador para añadir objetos
    // tiene que ser un behavior subject para que cuando se cambie de tab al volver vuelva a enviar
    // el ultimo elemento
    final StreamController<List<Widget>> _widgetChatStreamController = BehaviorSubject<List<Widget>>();
    final List<Widget> _chatWidgets = []; 
    // de esta forma podremos filtrar solo los eventos
    final List<Widget> _chatEventsOnlyWidgets = []; 
    bool eventsOnly = false;

    // variable para controlar que mensajes se pintan en pantalla, de esta forma se puede parar el chat y no pintar los nuevos que llegan
    int _messageCountToPaint = 0;
    int get messageCountToPaint => _messageCountToPaint;

    Stream<List<Widget>> get chatStream {
      return _widgetChatStreamController.stream;
    }
  
    bool _isPaused = false;
    bool get isPaused => _isPaused;
    final int _maxChatItems = 250;

    // variables para controlar la conexion con el chat
    StreamSubscription? _channelListener;
    var _backoffTime = 0;

    // atributos de los ajustes del chat -----------------------------------------
    final StreamController<ListChatSettings> _chatSettingsStreamController = BehaviorSubject<ListChatSettings>();
    late ListChatSettings _listChatSettings;
    Stream<ListChatSettings> get chatSettingsStrem {
      return _chatSettingsStreamController.stream;
    }
    
    

    ChatBloc(): super(ChatUninitialized()){

      on<InitChatBloc>(// -------------------------------------------
        (event, emit) async{
          _broadcasterUser = event.user;
          _idBroadcaster = event.user.id;
          _accesToken = event.accesToken;
          _loginUserName = event.user.login;

          
          // obtener los emotes, los emblemas, los ajustes del canal y 
          (await serviceLocator<GetEmotesUseCase>().call(_idBroadcaster))
              .fold((error) => null, (emotes) => allEmotes = emotes);
          (await serviceLocator<GetBadgesUseCase>().call(_idBroadcaster))
              .fold((error) => null, (badges) => allBadges = badges);

          (await serviceLocator<GetChatSettingsUseCase>().call(_idBroadcaster))
              .fold((error) {
                // TODO bloquear los chat settings (pull requests para actualzar???)
              }, 
              (chatSettings){
                // guardar los chat settings
                _listChatSettings = chatSettings;
                _chatSettingsStreamController.add(chatSettings);

              });
          // conectarse al chat
          _connectToChat();
          //_addDummyMessages();
          _addWelcomeMessage();
          // return Stream<Widget>
          emit(ChatConnected());
          
        },
      );

      on<ClickUserChat>((event, emit) { // -------------------------------------------------------
        
        // si alguien ha pulsado un usuario reanudamos el chat porque sino
        // en la ventana nueva no saldran los mensajes
        add(ResumeChat());
        print("BLOC click user");


      },);

      on<ClickMessage>((event, emit) {
        
        // si alguien ha pulsado un mensaje paramos el chat
        print("BLOC click message");
        add(StopChat());


      },);

      on<StopChat>(//----------------------------------------------------
        (event, emit) {
          _isPaused = true;
          emit(ChatPaused());
          emit(ChatConnected());

      },);
      
      on<ResumeChat>(//----------------------------------------------------
        (event, emit) {
          // añadir todos los mensajes a la espera a la lista que se muestra
          _isPaused = false;
          if(_chatWidgets.length > _maxChatItems){
            _chatWidgets.removeRange(0, _chatWidgets.length - _maxChatItems);
          }
          _messageCountToPaint = _chatWidgets.length > _maxChatItems ? _maxChatItems : _chatWidgets.length;
          print("Resumed: $_messageCountToPaint");
          emit(ChatResumed());
          emit(ChatConnected());

      },);
      
      on<ChangeChatSettings>(
        (event, emit) async{
          print("CHAT -- 2 BLOC");
          print("CHAT SETTING AL ENTRAR EL EVENTO----------------------------");
          print(_listChatSettings);
          (await serviceLocator<UpdateChatSettingUseCase>().call(_idBroadcaster,event.chatSetting))
              .fold((error) {
                // poner el que estaba antes
                print("CHAT -- ERROR");
                print("CHAT SETTING AL DAR ERROR ----------------------------");
                print(_listChatSettings);
                _chatSettingsStreamController.add(_listChatSettings);

              }, 
              (chatSettings){
                // guardar los chat settings
                _listChatSettings = chatSettings;
                _chatSettingsStreamController.add(chatSettings);

              });
        },
      );
    
      on<DeleteMessage>(
        (event, emit) {
          String idUser = event.user.id;
          String idMessage = event.message.id;
          serviceLocator<DeleteMessageUseCase>().call(idUser, idMessage);
        },
      );

      on<BanUserChat>((event, emit) { // --------------------------------------------------
        User userToBan = event.userToBan;
        serviceLocator<BanUserUseCase>().call(_broadcasterUser.id, userToBan.id,duration: event.duration);
      },);

      on<FilterChat>((event, emit) { // --------------------------------------------------
        print("FILTER");
        eventsOnly = event.eventsOnly;
        // cambiar de array cuando venga un filtro por eventos, 
        // hay que actualizar el el message count to paint para que no se borren los mensajes mientras vienen nuevos
        if(eventsOnly){
          _widgetChatStreamController.add(_chatEventsOnlyWidgets);
           _messageCountToPaint = _chatEventsOnlyWidgets.length > _maxChatItems ? _maxChatItems : _chatEventsOnlyWidgets.length;
        }else{
          _widgetChatStreamController.add(_chatWidgets);
           _messageCountToPaint = _chatWidgets.length > _maxChatItems ? _maxChatItems : _chatWidgets.length;

        }
      },);

    }

  


  void _connectToChat(){
    if(_channelListener != null){
      _channelListener!.cancel();
    }
    // obtenemos el stream
    _channelListener = serviceLocator<TwitchChatRepository>().connectChat(_accesToken, _loginUserName)
      .listen(
        (data) => _handleIRCData(data),
        onError: (error) => debugPrint('Chat error: ${error.toString()}'),
        onDone: () async {
          print("DONE");

          if (_backoffTime > 0) {
            // Add notice that chat was disconnected and then wait the backoff time before reconnecting.
            final notice =
                'Disconnected from chat, waiting $_backoffTime ${_backoffTime == 1 ? 'second' : 'seconds'} before reconnecting...';
            //_messageBuffer.add(IRCMessage.createNotice(message: notice));
          }

          await Future.delayed(Duration(seconds: _backoffTime));

          // Increase the backoff time for the next retry.
          _backoffTime == 0 ? _backoffTime++ : _backoffTime *= 2;

          //_messageBuffer.add(IRCMessage.createNotice(message: 'Reconnecting to chat (attempt $_retries)...'));
          _channelListener?.cancel();
          _connectToChat();
        });


    //_addDummyMessages();
  }
  
    // IRCMessage ->_handleIRCData ->
    // mapear el mensaje irc a un widget y añadirlo al stream para que se pinte en la vista
  void _handleIRCData(IRCMessage mensaje)async {
    
    Widget? chatWidget; // nuevo widget
    int? position;//posicion en el caso de sustituir un mensaje por otro
    if(mensaje is PrivateMessage){
      // Añadir widget de mensaje privado ( alguien ha hablado )
      chatWidget = TwitchChatPrivateMessage(privateMessage: mensaje);   
    }else if(mensaje is RoomStateMessage){
      // borramos el chat setting igual que el que llega y añadimos el nuevo
       _listChatSettings.values.removeWhere((element) => element.chatSettingType == mensaje.chatSetting.chatSettingType);
       _listChatSettings.values.add(mensaje.chatSetting);
       // lo pasamos al stream
       _chatSettingsStreamController.add(_listChatSettings);
    }else if(mensaje is NoticeMessage){
      // añadir widget de mensaje de noticia del chat ( texto recibido cuando se cambia el chat de modo )
      chatWidget = TwitchChatNoticeMessage(noticeMessage: mensaje.message);
    }else if(mensaje is UserNoticeMessage){
      // añadir widget de mensaje de usuario, cuando se suscribe, se hace un anuncio, regalos, etc..
      chatWidget = (TwitchChatUserNoticeMessage(userNoticeMessage: mensaje));
    }else if(mensaje is ClearMessage){
      // cuando se borra un mensaje hay que añadir este widget en el sitio donde el mensjae que se ha borrado
      // creamos el mensaje que indica que se ha borrado el mensaje
      chatWidget = TwitchChatNoticeMessage(noticeMessage: mensaje.message);
      // buscamos el widget que corresponde al mensaje que se ha borrado
      int indexDeletedMessage = _chatWidgets.indexWhere((element){
          if(element is TwitchChatPrivateMessage && element.privateMessage.id == mensaje.idMessage){
            return true;
          }else{
            return false;
          }
      } );
      if(indexDeletedMessage!=-1){
        position = indexDeletedMessage;
        // si esta en la lista quitarlo y remplazarlo    
      }
    }else if(mensaje is ClearMessageAll){
      // se borran mas de un mensaje, si el user es null todos los del chat
      // en otra caso los de ese usuario
      String? user = mensaje.user;
      
      if(user == null || user == ""){
        // todos
        _clearMessages();
      }else{
        // borrar los de ese justo
        _clearMessages(user: user);
      }
      chatWidget = TwitchChatNoticeMessage(noticeMessage: mensaje.message);
    }
    if(chatWidget != null){
      _addNewMessage(chatWidget, atPosition: position);
     
    }
  }

  /// Añadir un nuevo mensaje al chat, se puede pasar una posicion en el caso de 
  /// que se borre un mensaje y se tenga que sustituir
  void _addNewMessage(Widget newChatWidget,{int? atPosition}){
    if(atPosition!=null){
      // TODO TESTEAR MUCHO MAS
      // sustituir un mensaje
      _chatWidgets.removeAt(atPosition);
      _chatWidgets.insert(atPosition, newChatWidget);
    }else{
      // nuevo mensaje
      // sumar contador para pintar en el chat ---------------
      if(!_isPaused){
        if(!eventsOnly){
          // si no esta en events only sumar si os si
          _messageCountToPaint++;// de esta forma el listview no pintara los nuevos
          

        }else if(newChatWidget is TwitchChatUserNoticeMessage){
          // si es events only y es un evento sumar
          _messageCountToPaint++;// de esta forma el listview no pintara los nuevos
        }
        
      }

      // añadir al array  ---------------
      if(newChatWidget is TwitchChatUserNoticeMessage){
        _chatEventsOnlyWidgets.add(newChatWidget);
      }
      _chatWidgets.add(newChatWidget);
      
    }

    // comprobar el limite de mensajes
    if(eventsOnly){
      if(( _chatEventsOnlyWidgets.length) > _maxChatItems){
        // borrar de los que se ven el primero y añadirlo a los pausados
        if(!_isPaused){
          _chatEventsOnlyWidgets.removeAt(0);
          _messageCountToPaint = _maxChatItems;
        }
        
      }
    }else{
      if(( _chatWidgets.length) > _maxChatItems){
        // borrar de los que se ven el primero y añadirlo a los pausados
        if(!_isPaused){
          _chatWidgets.removeAt(0);
          _messageCountToPaint = _maxChatItems;
        }
        
      }
    }
   
    _widgetChatStreamController.add(eventsOnly ?_chatEventsOnlyWidgets : _chatWidgets);
  }
  
  /// borra todos los mensajes si user es null
  /// borra los mensajes de ese user en especifico
   void _clearMessages({String? user}) {
    if(user !=null){
      
      List<Widget> chatWidgetUser = _chatWidgets.where((element){
        return element is TwitchChatPrivateMessage && element.privateMessage.user.displayName.toLowerCase().compareTo(user)==0;
      }).toList();
      _messageCountToPaint -= chatWidgetUser.length;// restar los que se van a borrar
      // eliminar mensajes
      _chatWidgets.removeWhere((element){
        print("BAN USER ----------------------------");
        print((element is TwitchChatPrivateMessage) ? "BAN USER -- Disp ${element.privateMessage.user.displayName.toLowerCase()}" : "BAN USER -- ------");
        print((element is TwitchChatPrivateMessage) ? "BAN USER -- USER ${user}" : "BAN USER -- ------");
        print((element is TwitchChatPrivateMessage) ? "BAN USER -- USER ${element.privateMessage.user.displayName.toLowerCase().compareTo(user)}" : "BAN USER -- ------");
        print("BAN USER ----------------------------");

        if(element is TwitchChatPrivateMessage && element.privateMessage.user.displayName.toLowerCase().compareTo(user)==0){
          return true;
        }else{
          return false;
        }
      });
    }else{
      _messageCountToPaint = 0;
      _chatWidgets.clear();
    }
      
   }

  void _addDummyMessages(){
    _chatWidgets.add(TwitchChatPrivateMessage(privateMessage: PrivateMessage.dummyConEmoji()));
    _chatWidgets.add(TwitchChatPrivateMessage(privateMessage: PrivateMessage.dummy()));
    _chatWidgets.add(TwitchChatPrivateMessage(privateMessage: PrivateMessage.dummy()));
    _chatWidgets.add(TwitchChatPrivateMessage(privateMessage: PrivateMessage.dummyConEmoji()));
    _chatWidgets.add(TwitchChatPrivateMessage(privateMessage: PrivateMessage.dummyReply()));
    _chatWidgets.add(TwitchChatUserNoticeMessage(userNoticeMessage: UserNoticeMessage.dummySubscriptionPrime()));
    _chatWidgets.add(TwitchChatUserNoticeMessage(userNoticeMessage: UserNoticeMessage.dummyGift5Sub()));
    _chatWidgets.add(TwitchChatUserNoticeMessage(userNoticeMessage: UserNoticeMessage.dummyGiftedSub()));
    _chatWidgets.add(TwitchChatUserNoticeMessage(userNoticeMessage: UserNoticeMessage.dummyGiftedSub()));
    _chatWidgets.add(TwitchChatUserNoticeMessage(userNoticeMessage: UserNoticeMessage.dummyGiftedSub()));
    _chatWidgets.add(TwitchChatUserNoticeMessage(userNoticeMessage: UserNoticeMessage.dummyGiftedSub()));
    _chatWidgets.add(TwitchChatUserNoticeMessage(userNoticeMessage: UserNoticeMessage.dummyAnnouncement()));
    _chatWidgets.add(TwitchChatUserNoticeMessage(userNoticeMessage: UserNoticeMessage.dummyGiftedSub()));
    _chatWidgets.add(TwitchChatPrivateMessage(privateMessage: PrivateMessage.dummy()));
    _chatWidgets.add(TwitchChatPrivateMessage(privateMessage: PrivateMessage.dummy()));
    _chatWidgets.add(TwitchChatPrivateMessage(privateMessage: PrivateMessage.dummy()));
    _chatWidgets.add(TwitchChatPrivateMessage(privateMessage: PrivateMessage.dummy()));
    _chatWidgets.add(TwitchChatPrivateMessage(privateMessage: PrivateMessage.dummyLarge()));
    _messageCountToPaint = 18;
    _widgetChatStreamController.add(_chatWidgets);
  }
  
  void _addWelcomeMessage(){
    _addNewMessage(const TwitchChatNoticeMessage(noticeMessage: texts.welcomeChat));
  }
 
}