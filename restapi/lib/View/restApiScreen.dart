import 'package:flutter/material.dart';
import 'package:restapi/services/restAPI_service.dart';
import '../models/post_model.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Post>> futurePosts;

  @override
  void initState() {
    super.initState();
    futurePosts = apiService.fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Post Listesi")),
      body: FutureBuilder<List<Post>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Gösterilecek veri yok"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final post = snapshot.data![index];
                return ListTile(
                  title: Text(
                    post.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(post.body),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(post: post),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(post.title)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(post.body, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
