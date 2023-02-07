import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_sate.dart';
import 'package:streamate_flutter_app/presentation/screens/home_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'login_in_webview_screen.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key, required this.title});

  final String title;

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {

  late final WebViewController _webViewController;
  @override
  void initState() {
    
    super.initState();
    _inicializarWebView();
     context.read<AuthBloc>().add(AppStarted()); // ----------------> Iniciar el bloc
  }

  void _inicializarWebView(){
    // inicializamos el controlador del web view
    // con un callback de onPageFinished, de aqui podemos obtener el codigo del usuario
    _webViewController = WebViewController();
    _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    _webViewController.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) {
          if (url.contains("?code=")) {
            context.read<AuthBloc>().add(LogIn(redirectUri: url)); /// obtenemos el url de redireccion para poder obtener el token
            _webViewController.clearCache();
          }

        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login"),), // TODO cambiar a algo mas generico
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) { 
          /// para enviar mensajes como el snack bar o cambiar de ruta
          /// cuando cambia el estado
          
          if (state is AuthError) {
                
                Utils.showSnackBar(context,state.mensaje);
          }
          else if (state is AuthAuthenticated) {
                //AutoRouter.of(context).pushNamed('/home-page');
                // TODO cambiar a por el autorouter
                Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) =>  const HomeScreen(),
                ));
                Utils.showSnackBar(context,"Logeado");
          }else if(state is AuthAutorizacion){

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginWebViewScreen(url: state.urlAutorizacion),
              ),
            ).then((redirectUri) {
              if (redirectUri!=null && redirectUri!="") {
                // Obtenemos autorizacion ----> empezar con el login
                context.read<AuthBloc>().add(LogIn(redirectUri: redirectUri));

              } else {
                // Autorizacion cancelada o fallida ---> 
                Utils.showSnackBar(context,"Login cancelado");
              }
            });
          }
        },

        builder: (context, state){
          /// para cambiar la vista
          /// cuando cambia el estado
          if (state is AuthUninitialized || state is AuthUnauthenticated || state is AuthAutorizacion) { // ------------------------> No inicializado
            return Center(
              child: ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(Autorizarse()); // Empezar Login
              }, child: const Text("Login"),
            ));
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
}