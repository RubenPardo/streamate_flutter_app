import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/chat_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/obs/obs_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/user_info_bloc/user_info_bloc.dart';
import 'package:streamate_flutter_app/presentation/screens/login/log_in_screen.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
import 'package:streamate_flutter_app/shared/styles.dart';
import 'package:streamate_flutter_app/shared/widgets/user_info_widget.dart';

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
        BlocProvider(
          create: (_) => ChatBloc(),
        ),
        BlocProvider(
          create: (_) => UserInfoBloc(),
        ),
        BlocProvider(
          create: (_) => OBSBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'StreaMate',
        theme: themeData,
        //debugShowCheckedModeBanner: false,
        home: const LogInScreen(title: 'StreaMate'), // TODO cambiar a una splash screen que chequee
      )
    );
  }
}