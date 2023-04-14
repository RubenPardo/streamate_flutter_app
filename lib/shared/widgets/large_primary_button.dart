import 'package:flutter/material.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
import 'package:streamate_flutter_app/shared/styles.dart';
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart';

class LargeButton extends StatelessWidget {

  final Function()? onPressed;
  final bool theresError;
  final String messageError;
  final Widget child;
  final Color backgroundColor;

  const LargeButton({
    super.key, 
    required this.onPressed, 
    this.theresError = false, 
    this.backgroundColor = MyColors.primaryColor,
    this.messageError="",
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 350),
            child: ElevatedButton(
              
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                minimumSize: const Size.fromHeight(56), // NEW
              ),
              onPressed: onPressed, 
              child: child
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
