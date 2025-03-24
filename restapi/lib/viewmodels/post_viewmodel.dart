import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/restAPI_service.dart';

class PostViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Post> _posts = [];
  bool _isLoading = false;
  String _error = '';

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchPosts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _posts = await _apiService.fetchPosts();
      _error = '';
    } catch (e) {
      _error = 'Postlar yüklenirken hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePost(Post post) async {
    try {
      final updatedPost = await _apiService.updatePost(post);
      if (updatedPost != null) {
        await fetchPosts();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Post güncellenirken hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePost(int id) async {
    try {
      await _apiService.deletePost(id);
      await fetchPosts();
      return true;
    } catch (e) {
      _error = 'Post silinirken hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }
}
