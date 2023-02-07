import 'package:flutter/material.dart';

class Utils{

  static void showSnackBar(var context, String message){
    ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      message,
                    ),
                  ),
                );
  }

}