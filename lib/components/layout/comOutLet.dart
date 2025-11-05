import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BackIcon extends StatelessWidget {
  const BackIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: (){
      context.pop();
    }, icon: Icon(Icons.arrow_back));
  }
}
