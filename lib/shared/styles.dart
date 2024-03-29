import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colors.dart';
import 'extension_color.dart';

const TextStyle _textStyleTitleApp = TextStyle(
  fontWeight: FontWeight.bold,
  fontFamily: 'Quicksand',
  color: MyColors.textoSobreOscuro,
  fontSize: 48
);

const TextStyle textStyleTitle = TextStyle(
  fontWeight: FontWeight.bold,
  fontFamily: 'Quicksand',
  color: MyColors.textoSobreOscuro,
  fontSize: 24
);
const TextStyle textStyleTitle2 = TextStyle(
  fontWeight: FontWeight.bold,
  fontFamily: 'Quicksand',
  color: MyColors.textoSobreOscuro,
  fontSize: 20
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

const TextStyle textStyleAlertDialogTitle = TextStyle(
  fontWeight: FontWeight.bold,
  fontFamily: 'Quicksand',
  color: MyColors.textoSobreClaro,
  fontSize: 20
);

const TextStyle textStyleAlertDialogBody = TextStyle(
  fontWeight: FontWeight.w500,
  fontFamily: 'Quicksand',
  color: MyColors.textoSobreClaro,
  fontSize: 16
);

const TextStyle textStyleChat = TextStyle(
  fontFamily: 'Roobert',
  color: MyColors.textoSobreOscuro,
  fontSize: 18
);

const TextStyle textStyleChatNotice = TextStyle(
  fontFamily: 'Roobert',
  color: MyColors.textoSobreOscuroNotice,
  fontSize: 16
);

const TextStyle textStyleChatUserNoticeTitleSub = TextStyle(
  fontFamily: 'Roobert',
  color: MyColors.secondaryColor,
  fontWeight: FontWeight.bold,
  fontSize: 16
);

const TextStyle textStyleChatUserNoticeTitleGiftMyster = TextStyle(
  fontFamily: 'Roobert',
  color: MyColors.textoSobreOscuro,
  fontWeight: FontWeight.bold,
  fontSize: 24
);


const TextStyle textStyleChatUserNoticeBody = TextStyle(
  fontFamily: 'Roobert',
  color: MyColors.textoSobreOscuro,
  fontSize: 16
);

TextStyle textStyleChatName(String color){
  return TextStyle(
    color: HexColor.fromHex(color),
    fontFamily: 'Roobert',
    fontWeight: FontWeight.bold,
    fontSize: 18
  ); 
}

const TextStyle textError = TextStyle(
  fontWeight: FontWeight.bold,
  fontFamily: 'Quicksand',
  color: MyColors.textoError,
  fontSize: 16
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