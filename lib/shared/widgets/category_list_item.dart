

import 'package:flutter/material.dart';
import 'package:streamate_flutter_app/data/model/stream_category.dart';

class CategoryListItem extends StatelessWidget {
  const CategoryListItem ({super.key, required this.category});

  final StreamCategory category;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Image.network(category.boxArtUrl!),
        const SizedBox(width: 8,),
        Flexible(child: Text(category.gameName, overflow: TextOverflow.clip,maxLines: 2,)),
        const SizedBox(width: 16,),
      ],
    );
  }
}