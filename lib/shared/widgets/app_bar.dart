import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
import 'package:streamate_flutter_app/shared/styles.dart';

PreferredSizeWidget buildAppBar(String title, {List<Widget>? actions, Widget? bottom}){
  return AppBar(
    elevation: 0,
    backgroundColor: MyColors.primaryColor,
    title: Text(title, style: appBarStyle,),
    actions: actions,
    bottom: bottom!=null ? _buildBottom(bottom) : null
  );
}

PreferredSizeWidget _buildBottom(Widget bottom) {
  return PreferredSize(
      preferredSize: const Size.fromHeight(24),
      child: SizedBox(
        height: 24,
        child:  Container(
            padding: const EdgeInsets.all(8),
            width: double.maxFinite,
            color: MyColors.backgroundColorSecondary,
            child: bottom,
          ),
        
      ),
    );
}