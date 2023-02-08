import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

const TextStyle _textStyleTitleApp = TextStyle(
  fontWeight: FontWeight.bold,
  fontFamily: 'Quicksand',
  color: MyColors.textoSobreOscuro,
  fontSize: 48
);

const TextStyle appBarStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontFamily: 'Quicksand',
  color: MyColors.textoSobreOscuro,
  fontSize: 20
);

const TextStyle _textStyleBodyLarge= TextStyle(
  fontWeight: FontWeight.w600,
  fontFamily: 'Quicksand',
  color: MyColors.textoSobreOscuro,
  fontSize: 24,
);

const TextStyle _textStyleBodyMedium = TextStyle(
  fontFamily: 'Quicksand',
  color: MyColors.textoSobreOscuro,
  fontSize: 20,
);

const TextStyle textStyleButton = TextStyle(
  fontWeight: FontWeight.w500,
  fontFamily: 'Quicksand',
  color: MyColors.textoSobreOscuro,
  fontSize: 20
);


const TextStyle textError = TextStyle(
  fontWeight: FontWeight.bold,
  fontFamily: 'Quicksand',
  color: MyColors.textoError,
  fontSize: 18
);



ColorScheme _colorScheme = const ColorScheme(
  brightness: Brightness.dark, 
  primary: MyColors.primaryColor, 
  onPrimary: MyColors.textoSobreOscuro, 
  secondary: MyColors.secondaryColor, 
  onSecondary: MyColors.textoSobreClaro, 
  error: MyColors.textoError, 
  onError: MyColors.textoError, 
  background: MyColors.backgroundColor, 
  onBackground: MyColors.textoSobreOscuro, 
  surface: MyColors.textoSobreOscuro, 
  onSurface: MyColors.backgroundColor
);

ThemeData themeData = ThemeData(
  //brightness: Brightness.dark,
  colorScheme: _colorScheme,
  fontFamily: 'Quicksand',
  appBarTheme: const AppBarTheme(
    backgroundColor: MyColors.primaryColor,
    iconTheme: IconThemeData(color: MyColors.textoSobreOscuro)
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 72.0),
    titleLarge: _textStyleTitleApp,
    bodyMedium: _textStyleBodyMedium,
    bodyLarge: _textStyleBodyLarge,
  ),
);