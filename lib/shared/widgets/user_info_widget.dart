

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/domain/usecases/get_user_use_case.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_event.dart';
import 'package:streamate_flutter_app/shared/styles.dart';
import 'package:streamate_flutter_app/shared/widgets/twitch_chat_private_message.dart';
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart' as texts;

/// Widget que muestra la info de un usuario en concreto y un mini chat con sus mensajes solo
class UserInfoWidget extends StatefulWidget {
  final User user;
  const UserInfoWidget({super.key, required this.user});

  @override
  State<UserInfoWidget> createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {

  late User _broadcasterUser;

  @override
  void initState() {
    super.initState();
    _broadcasterUser = context.read<ChatBloc>().getBroadcasterUser;
    context.read<UserInfoBloc>().add(UserInfoEventStart(widget.user.id,_broadcasterUser));
  }


  

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
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
          print("USER -- llego: ${state.user}");
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
        Expanded(child: _buildChat())
        
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          // banear ------------------------------
          Utils.showConfirmDialog(context, texts.banUserTitle.replaceFirst("{1}", widget.user.displayName), texts.banUserDescription, 
          confrimText: texts.ban,
          (){
            Navigator.of(context).pop(); // dismiss dialog
            context.read<ChatBloc>().add(BanUserChat(widget.user));
          });
        }, icon: Icon(Icons.lock_clock)),
        IconButton(onPressed: (){
          // timeout ------------------------------
        }, icon: Icon(Icons.abc)),
      ],
    );
  }

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

  List<Widget> _chatFilterById(String id, List<Widget> chatList){
    return chatList.where(
      (e) {
        return (e is TwitchChatPrivateMessage) && e.privateMessage.user.id == id;
      }
    ).toList();

  }

}





// TODO pasar a un archivo a parte
class UserInfoBloc extends Bloc<UserInfoEvent,UserInfoState> {
  

  final GetUserUseCase _getUserUseCase = serviceLocator<GetUserUseCase>();

  UserInfoBloc(): super(UserInfoStateLoading()){
        
        
        on<UserInfoEventStart>( // ------------------------------------------------------------------
          (event,emit) async{
            // obtener usuario
            
            var res = await _getUserUseCase.call(id: event.id, idBroadCaster: event.broadcasterUser.id);
            res.fold(
              (error) {
                // ------------------------------------------ return error
                emit(UserInfoStateError());
              }, 
              (user) {
                // ------------------------------------------ return usuario
                emit(UserInfoStateLoaded(user));
              }
            );
          }

        );
        on<UserInfoEventClose>( // ------------------------------------------------------------------
          (event,emit) async{
            emit(UserInfoStateLoading());
          }

        );
    }
}

abstract class UserInfoEvent{}
class UserInfoEventStart extends UserInfoEvent{
  String id;
  User broadcasterUser;
  UserInfoEventStart(this.id, this.broadcasterUser);
}
class UserInfoEventClose extends UserInfoEvent{

}

abstract class UserInfoState{}
class UserInfoStateLoaded extends UserInfoState{
  User user;
  UserInfoStateLoaded(this.user);
}
class UserInfoStateLoading extends UserInfoState{}
class UserInfoStateError extends UserInfoState{}