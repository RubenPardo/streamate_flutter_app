

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/user_info_bloc/user_info_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/user_info_bloc/user_info_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/user_info_bloc/user_info_state.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
import 'package:streamate_flutter_app/shared/styles.dart';
import 'package:streamate_flutter_app/shared/widgets/twitch_chat_private_message.dart';
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart' as texts;
import 'package:streamate_flutter_app/shared/styles.dart' as styles;

/// Widget que muestra la info de un usuario en concreto y un mini chat con sus mensajes solo
class UserInfoWidget extends StatefulWidget {
  final User user;
  const UserInfoWidget({super.key, required this.user});

  @override
  State<UserInfoWidget> createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {

  late User _broadcasterUser;
  bool _isBanned = false;
  bool _isTimeout = false;

  final List<DropdownMenuItem> _dropdownMenuTimeoutsItems = const [
    DropdownMenuItem(value: 300,child: Text("5 ${texts.minutos}"),),
    DropdownMenuItem(value: 1800,child:  Text("30 ${texts.minutos}"),),
    DropdownMenuItem(value: 3600,child:  Text("1 ${texts.hora}"),),
    DropdownMenuItem(value: 28800,child:  Text("8 ${texts.horas}"),),
    DropdownMenuItem(value: 86400,child:  Text("1 ${texts.dia}"),),
    DropdownMenuItem(value: 604800,child:Text("1 ${texts.semana}"),),
    DropdownMenuItem(value: 1209600,child:  Text("2 ${texts.semanas}"),),
  ];
  int _timeoutDurationSelected = 300;
  @override
  void initState() {
    super.initState();
    _broadcasterUser = context.read<ChatBloc>().getBroadcasterUser;
    context.read<UserInfoBloc>().add(UserInfoEventStart(widget.user.id,_broadcasterUser));
  }


  

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // al estar en un modal es preferible hacerlo aqui no en el dispose
    context.read<UserInfoBloc>().add(UserInfoEventClose());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserInfoBloc, UserInfoState>(
      builder: (context, state) {
        if(state is UserInfoStateLoading){
            return const Center(child: CircularProgressIndicator(),);
        }

        if(state is UserInfoStateError){
          return const Center(child: Text("Ha ocurrido un error"),);
        }

        if(state is UserInfoStateLoaded){
          return _buildWidget(state.user);
        }
        return const Center();
      }, 
      listener: (context, state) {
        
      },
    );
  }

  Widget _buildWidget(User user){

    return Column(
      children: [
        
        _buildHeader(user),
       
        !_isBanned && !_isTimeout ? Expanded(child:   _buildChat() ): Container(), 
        _isBanned ? const Padding(padding: EdgeInsets.only(top: 12), child: Center(child: Text(texts.userBanned),),): Container(),
        _isTimeout ? const Padding(padding: EdgeInsets.only(top: 12), child: Center(child: Text(texts.userTimedOut),),): Container(),
        
         
        
      ],
    );
  }


  // cabecera del widget, se muestra la info del usuario y los botones para vetar o timeout
  Widget _buildHeader(User user){
    return Container(
      padding: const EdgeInsets.all(12),
          //constraints: const BoxConstraints( minHeight: 200),
        // IMAGEN DE FONDO -----------------------------------------------
        decoration: BoxDecoration(
          image: user.offlineImageUrl != "" ? DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
            image: NetworkImage(user.offlineImageUrl,),
            fit: BoxFit.cover,
          ) : const DecorationImage(
            image: AssetImage("assets/images/offline_image_default.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        // --------------------------
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen usuario -----------------------------------------
            CircleAvatar(
              minRadius: 40,
              backgroundImage: NetworkImage(user.profileImageUrl,),
            ),
            const SizedBox(width: 8,),
            // DETALLES -----------------------------------------
            Expanded(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // nombre ------------------------------------
                Text(user.displayName, style: textStyleChatUserNoticeTitleGiftMyster,),
                Text(user.description, overflow: TextOverflow.ellipsis, maxLines: 3,),
                _buildBanButtons()
              ],
            ),
            )
          ],
        ),
      );
  }

  // dos botones vetar y banear el usuario
  Widget _buildBanButtons(){
    return Row(
      children: [
        IconButton(onPressed: (){
          // banear -----------------------------------------------------------------------------------------------------------
          Utils.showConfirmDialog(context, texts.banUserTitle.replaceFirst("{1}", widget.user.displayName), 
          const Text(texts.banUserDescription,style: styles.textStyleAlertDialogBody), 
          confrimText: texts.ban,
          (){
            Navigator.of(context).pop(); // dismiss dialog
            context.read<ChatBloc>().add(BanUserChat(widget.user));
            setState(() {
              _isBanned = true;
            });
          });
        }, icon: const Icon(Icons.remove_circle_outline_outlined)),
        IconButton(onPressed: (){
          // timeout ------------------------------------------------------------------------------------------------------------
          Utils.showConfirmDialog(context, texts.timeoutUserTitle.replaceFirst("{1}", widget.user.displayName), 
          // body: ------ necesitamos un statful builder para que el dialog se pueda actualizar y asi el dropdwon cambie cuando se cambie de opcion
              _buildDropDownTimeoutUser(), 
              // accion ---------
              confrimText: texts.expulsar,
              (){
                Navigator.of(context).pop(); // dismiss dialog
                context.read<ChatBloc>().add(BanUserChat(widget.user, duration: _timeoutDurationSelected));
                setState(() {
                _isTimeout = true;
              });
              }
            );// dialog ---------------
            }, icon: const Icon(Icons.timer_off_outlined)
          ),
      ],
    );
  }

  /// funcion que crea un chat de twtich pero con solo los mensajes de un usuario
  Widget _buildChat() {
    
    return StreamBuilder(
        stream: context.read<ChatBloc>().chatStream,
        builder: (context, snapshot) {
          if (snapshot.hasError){
              //return error message
              return const Center(child: Text("ERROR"),);
          }
          if (!snapshot.hasData){
              //return a loader
              return const Center();

          }
          List<Widget> chat = snapshot.data!;
          // filtramos el chat solo a ese usuario
          chat = _chatFilterById(widget.user.id,chat);
         


          return SingleChildScrollView(
              reverse: false,  
              child: ListView.builder(
                itemCount: chat.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: (chat.reversed.toList()[index] as TwitchChatPrivateMessage)
                                  ..canInteract = false // mostrar al reves el chat
                  );
                },
            ),
          );
        },
      );
  }

  /// funcion que crea un desplegable de los tiempos para expulsar temporalmente a un usuario
  Widget _buildDropDownTimeoutUser(){
    return StatefulBuilder(builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(texts.timeoutUserDescription,style: styles.textStyleAlertDialogBody), 
            const SizedBox(height: 8,),
            Container(
              decoration: BoxDecoration(
                color: MyColors.primaryColor, borderRadius: BorderRadius.circular(10),
                
              ),
              child: Padding(
                padding: const EdgeInsets.only(left:12),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                    value: _timeoutDurationSelected, items: _dropdownMenuTimeoutsItems, 
                    onChanged: (value){
                      setState(() {
                        _timeoutDurationSelected = value;
                      });
                    }
                  ),
                )
              )
            ) 
          ],
        );
      },
    );
  }

  /// Texto, List<Widgets> -> _chatFilterById() -> List<Widgets>
  /// filtrar un array de widgets por el id de un usuario
  List<Widget> _chatFilterById(String id, List<Widget> chatList){
    return chatList.where(
      (e) {
        return (e is TwitchChatPrivateMessage) && e.privateMessage.user.id == id;
      }
    ).toList();

  }

}

