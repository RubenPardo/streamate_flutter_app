import 'package:flutter/material.dart';
import 'package:streamate_flutter_app/app/app.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';


void main() async{
  // Inicializar la inyeccion de dependencias --------------------------------------------------
  WidgetsFlutterBinding.ensureInitialized();
  await setUpServiceLocator();
  //--------------------------------------------------------------------------------------------
  runApp(const App());
}