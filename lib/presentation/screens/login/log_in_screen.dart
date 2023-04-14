import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_sate.dart';
import 'package:streamate_flutter_app/presentation/screens/home_screen.dart';
import 'package:streamate_flutter_app/shared/styles.dart';
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart';
import 'package:streamate_flutter_app/shared/widgets/large_primary_button.dart';
import 'login_in_webview_screen.dart';
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart' as texts;

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key, required this.title});

  final String title;

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {

  bool _isError = false;
  String _messageError = "";
  @override
  void initState() {
    
    super.initState();
     context.read<AuthBloc>().add(AppStarted()); // ----------------> Iniciar el bloc
  }

 


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) { 
          /// para enviar mensajes como el snack bar o cambiar de ruta
          /// cuando cambia el estado
          if (state is AuthError) {
            if(mounted){
              _isError = true;
              _messageError = state.mensaje;
              
            }
            //Utils.showSnackBar(context,state.mensaje);
          }else if(state is AuthLoading){
              _isError = false;
              _messageError = "";
          }
          else if (state is AuthAuthenticated) {
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) =>  const HomeScreen(),
            ));
           
          }else if(state is AuthAutorizacion){

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginWebViewScreen(url: state.urlAutorizacion),
              ),
            ).then((redirectUri) {
              
              if (redirectUri!=null && redirectUri!="") {
                context.read<AuthBloc>().add(LogIn(redirectUri: redirectUri));

              } else {
                // Autorizacion cancelada o fallida ---> 
                Utils.showSnackBar(context, texts.unexpectedError);
               
              }
            });
          }
        },

        builder: (context, state){
          /// para cambiar la vista
          /// cuando cambia el estado
          if (state is AuthUninitialized || state is AuthUnauthenticated || state is AuthAutorizacion) { // ------------------------> No inicializado
            log('------');
            return _buildBody();
          }
          else if(state is AuthLoading){ // -----------------------------> Cargando
           return const Center(
                  child: CircularProgressIndicator(),
                ); 
          }
          else{
            return  const Center();
          }
        },
     ),
    );
  }

  Widget _buildBody(){
    return Stack(
      children: [
        const Align(
          alignment: Alignment.topLeft,
          child: Image(image: AssetImage("assets/images/item_fondo.png",)),
        ),
        Container(
          padding: const EdgeInsets.only(left: 32,right: 32,top: 64,),
          child: Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Titulo ------------------------------------------------------------------
                Text(appTitle,style: Theme.of(context).textTheme.titleLarge,),
          
                // Texto ----------------------------------------------             
               Container(
                padding: const EdgeInsets.only(left: 8,right: 8,top: 32), 
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(loginDescription, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge,),
                    const SizedBox(height: 16,),
                    Text(loginBodyDescription, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium,),
                      
                  ],
                ),
               ),
               const SizedBox(height: 20,),
                // BOTON -----------------------------------------------------------------
                LargeButton(
                  theresError: _isError,
                  messageError: _messageError,
                  onPressed: () {
                    context.read<AuthBloc>().add(Autorizarse()); // Empezar Login
                  },
                  child: Stack(
                  alignment: Alignment.center,
                    children: const [
                      Align(alignment: Alignment.centerLeft, child: Image(image: AssetImage('assets/images/logo_twitch_bw.png',),height: 48),),
                      Text(iniciarSesion, style: textStyleButton,),
                    ],
                  ),
                )
              ]
            ),
          ),
        ),
         Align(
          alignment: Alignment.bottomRight,
          child: Image(image: const AssetImage("assets/images/item_fondo_inferior.png"),width: MediaQuery.of(context).size.width/1.6,),
        )
      ],
    );
  }

}