import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:streamate_flutter_app/presentation/screens/log_in_screen.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
import 'package:streamate_flutter_app/shared/styles.dart';

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'StreaMate',
        theme: themeData,
        debugShowCheckedModeBanner: false,
        home: const LogInScreen(title: 'StreaMate'), // TODO cambiar a una splash screen que chequee
      )
    );
  }
}