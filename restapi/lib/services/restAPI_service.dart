import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';
import 'error_service.dart';

abstract class IApiService {
  Future<List<Post>> fetchPosts();
  Future<Post?> createPost(Post post);
  Future<Post?> updatePost(Post post);
  Future<bool> deletePost(int id);
  Future<List<Post>> searchPosts(String query);
  Future<List<Post>> sortPosts(String sortBy);
}

class ApiService implements IApiService {
  final String baseUrl = "https://jsonplaceholder.typicode.com/";
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<Post>> fetchPosts() async {
    try {
      final response = await _client.get(Uri.parse('${baseUrl}posts'));
      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((data) => Post.fromJson(data))
            .toList();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception(ErrorService.handleError(e));
    }
  }

  @override
  Future<Post?> createPost(Post post) async {
    try {
      final response = await _client.post(
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
    } catch (e) {
      throw Exception(ErrorService.handleError(e));
    }
  }

  @override
  Future<Post?> updatePost(Post post) async {
    try {
      final response = await _client.put(
        Uri.parse('${baseUrl}posts/${post.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(post.toJson()),
      );
      if (response.statusCode == 200) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update post');
      }
    } catch (e) {
      throw Exception(ErrorService.handleError(e));
    }
  }

  @override
  Future<bool> deletePost(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('${baseUrl}posts/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception(ErrorService.handleError(e));
    }
  }

  @override
  Future<List<Post>> searchPosts(String query) async {
    try {
      final posts = await fetchPosts();
      return posts
          .where((post) =>
              post.title.toLowerCase().contains(query.toLowerCase()) ||
              post.body.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception(ErrorService.handleError(e));
    }
  }

  @override
  Future<List<Post>> sortPosts(String sortBy) async {
    try {
      final posts = await fetchPosts();
      switch (sortBy) {
        case 'title':
          posts.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'id':
          posts.sort((a, b) => a.id.compareTo(b.id));
          break;
        default:
          break;
      }
      return posts;
    } catch (e) {
      throw Exception(ErrorService.handleError(e));
    }
  }

  void dispose() {
    _client.close();
  }
}
