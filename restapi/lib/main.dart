import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/post_viewmodel.dart';
import 'views/post_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PostViewModel(),
      child: MaterialApp(
        title: 'Post Uygulaması',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: PostScreen(),
      ),
    );
  }
}
