import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/restAPI_service.dart';
import '../services/error_service.dart';

class PostViewModel extends ChangeNotifier {
  final IApiService _apiService;
  List<Post> _posts = [];
  List<Post> _filteredPosts = [];
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';
  String _sortBy = '';

  PostViewModel({IApiService? apiService})
      : _apiService = apiService ?? ApiService();

  List<Post> get posts => _filteredPosts;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;

  Future<void> fetchPosts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _posts = await _apiService.fetchPosts();
      _applyFilters();
      _error = '';
    } catch (e) {
      _error = ErrorService.handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost(Post post) async {
    try {
      final createdPost = await _apiService.createPost(post);
      if (createdPost != null) {
        await fetchPosts();
        return true;
      }
      return false;
    } catch (e) {
      _error = ErrorService.handleError(e);
      notifyListeners();
      return false;
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
      _error = ErrorService.handleError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePost(int id) async {
    try {
      final success = await _apiService.deletePost(id);
      if (success) {
        await fetchPosts();
        return true;
      }
      return false;
    } catch (e) {
      _error = ErrorService.handleError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> searchPosts(String query) async {
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();

    try {
      if (query.isEmpty) {
        _posts = await _apiService.fetchPosts();
      } else {
        _posts = await _apiService.searchPosts(query);
      }
      _applyFilters();
      _error = '';
    } catch (e) {
      _error = ErrorService.handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sortPosts(String sortBy) async {
    _sortBy = sortBy;
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await _apiService.sortPosts(sortBy);
      _applyFilters();
      _error = '';
    } catch (e) {
      _error = ErrorService.handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilters() {
    _filteredPosts = List.from(_posts);
    if (_searchQuery.isNotEmpty) {
      _filteredPosts = _filteredPosts
          .where((post) =>
              post.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              post.body.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  @override
  void dispose() {
    if (_apiService is ApiService) {
      (_apiService as ApiService).dispose();
    }
    super.dispose();
  }
}
