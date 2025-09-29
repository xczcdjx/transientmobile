import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    // final state=GoRouter.of(context).routerDelegate.currentConfiguration;
    final state = GoRouterState.of(context);
    final id = state.pathParameters['id']; // 获取动态参数
    final query = state.uri.queryParameters; // 获取查询参数
    print("id=$id");
    print("query =$query");
    return Scaffold(
      appBar: AppBar(title: Text('DetailPage ${id}'),),
      body: Column(children: [
        Text("DetailPage"),
        TextButton(onPressed: (){
          context.push('/test');
        }, child: Text('Go test'))
      ],),
    );
  }
}
