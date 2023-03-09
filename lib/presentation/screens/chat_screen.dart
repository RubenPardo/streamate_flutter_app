
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/data/model/chat_setting.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_state.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
import 'package:streamate_flutter_app/shared/widgets/chat_settings_widget.dart';

class ChatScreen extends StatefulWidget {

  final TokenData token;
  final User user;

  const ChatScreen({super.key, required this.token, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  
  bool _isPaused = false;
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();

    
    
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  // indica al bloc que el chat se ha reanudado, el bloc devolvera todos los mensajes que estaban en cache
  // el from scroll evita que el jumpTo devuelve errores por ya estar bajo del todo
  // el [addToBloc] sirve para cuando se llama desde el listener y asi evitar loop infinito
  void _resumeChat({required bool fromScroll, bool addToBloc = true}){
    if(addToBloc) context.read<ChatBloc>().add(ResumeChat());
    setState(() {
      _isPaused = false;
    });
    if(mounted && !fromScroll){
      // nos movemos al principio del scroll para reanudar el chat
      //_scrollController.jumpTo(_scrollController.position.minScrollExtent);
      
    }
  }
  // para el chat, a partir de ahora el bloc guardara los mensajes nuevos en cache asi no se movera el scroll
  void _stopChat({bool addToBloc = true}){
     if(addToBloc) context.read<ChatBloc>().add(StopChat());
     setState(() {
      _isPaused = true;
    });
  }
  @override
  Widget build(BuildContext context) {

    return  BlocConsumer<ChatBloc, ChatState>( 
      listener: (context, state) {
        if(state is ChatPaused){
          _stopChat(addToBloc: false);
        }
        if(state is ChatResumed){
          _resumeChat(fromScroll: false,addToBloc: false);

        }
      },
      builder: (context, state) {
        

        if(state is ChatConnected){
          return Column(
            children: [
              
              // BOTONERA
              _buildChatSettingButtons(),
              // CHAT
              Expanded(
                child: Stack(
                alignment: Alignment.center,
                children: [
                  

                  // chat ------------------------------------------------------------------------------
                  Align(alignment: Alignment.bottomCenter,child: _buildChat(),),

                  // boton de pausa ----------------------------------------------------------------------------
                  _isPaused 
                  ? Align(alignment: Alignment.bottomCenter, child: _buildIsChatPaused(),)
                  : Container(), 
                  
                ],
              ),
              )
            ],
          );
        }
        return const Center();
      },
      
    );
     
  }
  
  Widget _buildChatSettingButtons(){
    return StreamBuilder(
        stream: context.read<ChatBloc>().chatSettingsStrem,
        builder: (context, snapshot) {
        if (snapshot.hasError){
            // TODO devolver los botones deshabilitados
            return const Center(child: Text("ERROR"),);
        }
      
        return ChattSettingsWidget(
          isPartner: widget.user.broadcasterType == "partner",
          listChatSettings: snapshot.data ?? ListChatSettings([]));
      }
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
          


          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if(notification.metrics.pixels == notification.metrics.minScrollExtent){
                // esta bajo del todo
                if(_isPaused) _resumeChat(fromScroll:true);
              }else{
                // si lo movio y no esta parado, parar el chat
                if(!_isPaused) _stopChat();
              }
              return true;
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              reverse: true, // hacer que siempre 
              child: ListView.builder(
                itemCount: context.read<ChatBloc>().messageCountToPaint,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: chat[index]
                  );
                },
              )
            ),
          );
        },
      );
  }
  

  /// widget que se muestra cuando el chat esta pausado tambien sirve como boton para reanudar
  Widget _buildIsChatPaused(){
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: (){
          print("SE PULSA XSS");
        if(_isPaused){
          _resumeChat(fromScroll: false);
        }else{
          _stopChat();
        }
        }, 
        child: Container(
          constraints: BoxConstraints(maxHeight: 50, maxWidth: MediaQuery.of(context).size.width),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: MyColors.backgroundColorChatPaused,
          ),
          padding: const EdgeInsets.all(8),
          child: const Center(child: Text("El chat esta pausado. Reanudar")),
        )
      ),
    );
  }
}