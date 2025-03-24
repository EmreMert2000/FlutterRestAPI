import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/post_model.dart';
import '../../../core/services/error_service.dart';

abstract class IPostService {
  Future<List<Post>> fetchPosts();
  Future<Post> createPost(Post post);
  Future<Post> updatePost(Post post);
  Future<void> deletePost(int id);
  Future<List<Post>> searchPosts(String query);
  Future<List<Post>> sortPosts(String field, {bool ascending = true});
}

class PostService implements IPostService {
  final http.Client _client = http.Client();
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  @override
  Future<List<Post>> fetchPosts() async {
    try {
      final response = await _client.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Post.fromJson(json)).toList();
      } else {
        throw ErrorService.handleError(
            'Gönderiler yüklenirken bir hata oluştu');
      }
    } catch (e) {
      throw ErrorService.handleError(e);
    }
  }

  @override
  Future<Post> createPost(Post post) async {
    try {
      final response = await _client.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      );
      if (response.statusCode == 201) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw ErrorService.handleError(
            'Gönderi oluşturulurken bir hata oluştu');
      }
    } catch (e) {
      throw ErrorService.handleError(e);
    }
  }

  @override
  Future<Post> updatePost(Post post) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl/${post.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      );
      if (response.statusCode == 200) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw ErrorService.handleError(
            'Gönderi güncellenirken bir hata oluştu');
      }
    } catch (e) {
      throw ErrorService.handleError(e);
    }
  }

  @override
  Future<void> deletePost(int id) async {
    try {
      final response = await _client.delete(Uri.parse('$_baseUrl/$id'));
      if (response.statusCode != 200) {
        throw ErrorService.handleError('Gönderi silinirken bir hata oluştu');
      }
    } catch (e) {
      throw ErrorService.handleError(e);
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
      throw ErrorService.handleError(e);
    }
  }

  @override
  Future<List<Post>> sortPosts(String field, {bool ascending = true}) async {
    try {
      final posts = await fetchPosts();
      posts.sort((a, b) {
        int comparison;
        switch (field) {
          case 'title':
            comparison = a.title.compareTo(b.title);
            break;
          case 'id':
          default:
            comparison = a.id.compareTo(b.id);
        }
        return ascending ? comparison : -comparison;
      });
      return posts;
    } catch (e) {
      throw ErrorService.handleError(e);
    }
  }

  void dispose() {
    _client.close();
  }
}
