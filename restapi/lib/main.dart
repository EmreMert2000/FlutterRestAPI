import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/posts/view/post_screen.dart';
import 'features/posts/viewmodel/post_viewmodel.dart';
import 'features/posts/repository/post_repository.dart';
import 'features/posts/service/post_service.dart';

void main() {
  Provider.debugCheckInvalidValueType = null;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<IPostService>(
          create: (_) => PostService(),
        ),
        ProxyProvider<IPostService, IPostRepository>(
          update: (_, service, __) => PostRepository(service),
        ),
        ChangeNotifierProxyProvider<IPostRepository, PostViewModel>(
          create: (_) => PostViewModel(PostRepository(PostService())),
          update: (_, repository, viewModel) =>
              viewModel ?? PostViewModel(repository),
        ),
      ],
      child: MaterialApp(
        title: 'Gönderi Uygulaması',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const PostScreen(),
      ),
    );
  }
}
