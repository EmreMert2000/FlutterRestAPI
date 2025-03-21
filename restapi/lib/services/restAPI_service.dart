import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:restapi/models/post_model.dart';

class ApiService {
  final String baseUrl = "https://jsonplaceholder.typicode.com/";

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse('${baseUrl}posts'));
    if (response.statusCode == 200) {
      List<Post> posts =
          (json.decode(response.body) as List)
              .map((data) => Post.fromJson(data))
              .toList();
      return posts;
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<Post> createPost(Post post) async {
    final response = await http.post(
      Uri.parse('${baseUrl}posts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(post.toJson()),
    );
    if (response.statusCode == 201) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create post');
    }
  }
}
