import 'package:flutter/material.dart';
import 'package:streamate_flutter_app/shared/styles.dart';
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart';

class LargePrimaryButton extends StatelessWidget {

  Function()? onPressed;
  bool theresError;
  String messageError;

  LargePrimaryButton({super.key, required this.onPressed, this.theresError = false, this.messageError=""});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 350),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56), // NEW
              ),
              onPressed: onPressed, 
              child:  Stack(
                alignment: Alignment.center,
                  children: const [
                    Align(alignment: Alignment.centerLeft, child: Image(image: AssetImage('assets/images/logo_twitch_bw.png',),height: 48),),
                    Text(iniciarSesion, style: textStyleButton,),
                  ],
                ),
            ),
          ),
          theresError 
            ? Column(children: [const SizedBox(height: 10),Text(messageError, style: textError,)],) 
            : Container()
          
        ],
      )
    );
  }
}
