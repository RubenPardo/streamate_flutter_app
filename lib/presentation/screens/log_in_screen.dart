import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_sate.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) { 
          /// para enviar mensajes como el snack bar o cambiar de ruta
          /// cuando cambia el estado
          
          if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.mensaje,
                    ),
                  ),
                );
                print("ERROR: -----------: ${state.mensaje}");
          }
          else if (state is AuthAuthenticated) {
                //AutoRouter.of(context).pushNamed('/home-page');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Logeado de puta madre',
                    ),
                  ),
                );
          }else if(state is AuthAutorizacion){
            print("${state.urlAutorizacion}");
            _webViewController.loadRequest(Uri.parse(state.urlAutorizacion));
          }
        },

        builder: (context, state){
          /// para cambiar la vista
          /// cuando cambia el estado
          if (state is AuthUninitialized || state is AuthUnauthenticated) { // ------------------------> No inicializado
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
          else if(state is AuthAuthenticated){ // -----------------------> Autenticado
            return 
            // borrar -------------------------------------------------------------
            Center(
              child: Row(
                children: [
                  Image.network(state.user.profileImageUrl),
                  Text(state.user.name)
                ],
              ) ,
            ); // NO hacer nada, hacerlo en el listener = cambiar de pagina
          }
          else if(state is AuthAutorizacion){ // ------------------------> Autorizacion
            return _dialogWebView(state.urlAutorizacion);
          }
          else{
            return  const Center();
          }
        },
     ),
    );
  }



  Widget _dialogWebView(String url){
    return /*AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: const EdgeInsets.all(0),
      content: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child:*/ Container(
          color: Theme.of(context).dialogBackgroundColor,
          width: double.infinity,
          height: MediaQuery.of(context).size.height * .8,
          child: Center(
            child:Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        Navigator.of(context).pop(null);
                      },
                    )
                  ],
                ),
                Expanded(
                  child: WebViewWidget(
                    controller: _webViewController,
                  ),
                ),
              ],
            ),
          )
    );
  }
}