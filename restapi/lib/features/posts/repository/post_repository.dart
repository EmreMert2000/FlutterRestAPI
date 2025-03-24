import '../model/post_model.dart';
import '../service/post_service.dart';

abstract class IPostRepository {
  Future<List<Post>> getPosts();
  Future<Post> createPost(Post post);
  Future<Post> updatePost(Post post);
  Future<void> deletePost(int id);
  Future<List<Post>> searchPosts(String query);
  Future<List<Post>> sortPosts(String field, {bool ascending = true});
}

class PostRepository implements IPostRepository {
  final IPostService _service;

  PostRepository(this._service);

  @override
  Future<List<Post>> getPosts() async {
    return await _service.fetchPosts();
  }

  @override
  Future<Post> createPost(Post post) async {
    return await _service.createPost(post);
  }

  @override
  Future<Post> updatePost(Post post) async {
    return await _service.updatePost(post);
  }

  @override
  Future<void> deletePost(int id) async {
    await _service.deletePost(id);
  }

  @override
  Future<List<Post>> searchPosts(String query) async {
    return await _service.searchPosts(query);
  }

  @override
  Future<List<Post>> sortPosts(String field, {bool ascending = true}) async {
    return await _service.sortPosts(field, ascending: ascending);
  }
}
