import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_sate.dart';
import 'package:streamate_flutter_app/presentation/screens/log_in_screen.dart';
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart';
import 'package:streamate_flutter_app/shared/widgets/app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

   // obtenemos la referencia a la subscripcion del bloc, 
   // para cuando se cierre esta ventana, cerrarla y asi tambien evitar duplicidad
  late StreamSubscription mSub;
  late AuthBloc myBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myBloc = context.read<AuthBloc>();
    mSub = myBloc.stream.listen((stateAuth) {
      if(stateAuth is AuthUnauthenticated){
          // ha cerrado sesion salir
          // TODO cambiar a por el autorouter
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) =>  const LogInScreen(title: 'Login',),
          ));
          
          mSub.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(appTitle,bottom: Row(mainAxisAlignment: MainAxisAlignment.center,children: [Text("Viewers: 1000"),Text("LIVE ON 00:15:34")],)),
      body: Center(
      child: Column(
        children: [
          const Text("LOGEADO"),
          ElevatedButton(
            onPressed: (){
              context.read<AuthBloc>().add(LogOut()); // ---------------------> cerrar sesion
            }, 
            child: const Text("Cerrar sesión")
          )
        ],
      ),
    ),
    );
  }
}