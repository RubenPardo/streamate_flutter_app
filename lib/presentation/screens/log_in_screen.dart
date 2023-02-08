import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_sate.dart';
import 'package:streamate_flutter_app/presentation/screens/home_screen.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
import 'package:streamate_flutter_app/shared/styles.dart';
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart';
import 'package:streamate_flutter_app/shared/widgets/large_primary_button.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_in_webview_screen.dart';

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
            
            _isError = true;
            _messageError = state.mensaje;
          
            //Utils.showSnackBar(context,state.mensaje);
          }else if(state is AuthLoading){
           /* setState(() {
              _isError = false;
              _messageError = "";
            });*/
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
              print("2");
              if (redirectUri!=null && redirectUri!="") {
                print("2.1");
                // Obtenemos autorizacion ----> empezar con el login
                context.read<AuthBloc>().add(LogIn(redirectUri: redirectUri));

              } else {
                print("2.2");
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
        const Image(image: AssetImage("assets/images/item_fondo.png",)),
        Container(
          padding: EdgeInsets.only(left: 32,right: 32,top: 64,bottom: MediaQuery.of(context).size.height/2.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(appTitle,style: Theme.of(context).textTheme.titleLarge,),
              
               Padding(padding: const EdgeInsets.all(32), 
                    child: Text(loginDescription, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge,),),
                    
                    LargePrimaryButton(
                      theresError: _isError,
                      messageError: _messageError,
                      onPressed: () {
                        context.read<AuthBloc>().add(Autorizarse()); // Empezar Login
                      }
                    )
            ]
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