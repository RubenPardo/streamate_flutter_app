
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_state.dart';

class ChatScreen extends StatefulWidget {

  final TokenData token;
  final User user;

  const ChatScreen({super.key, required this.token, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  BlocConsumer<ChatBloc, ChatState>( 
      listener: (context, state) {
         
      },
      builder: (context, state) {
        if(state is ChatConnected){
          return _buildChat();
        }

        return Center();
      },
      
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

          return SingleChildScrollView(
            reverse: true, // hacer que siempre 
            child: ListView.builder(
              itemCount: chat.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: chat[index]
                );
              },
            )
          );
        },
      );
  }
  
}