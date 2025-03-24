import 'package:flutter/foundation.dart';
import '../model/post_model.dart';
import '../repository/post_repository.dart';
import '../../../core/services/error_service.dart';

class PostViewModel extends ChangeNotifier {
  final IPostRepository _repository;
  List<Post> _posts = [];
  List<Post> _filteredPosts = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _sortBy = 'id';
  bool _sortAscending = true;

  PostViewModel(this._repository);

  List<Post> get posts => _filteredPosts;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  Future<void> fetchPosts() async {
    try {
      _isLoading = true;
      notifyListeners();

      _posts = await _repository.getPosts();
      _applyFilters();
    } catch (e) {
      throw ErrorService.handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost(Post post) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newPost = await _repository.createPost(post);
      _posts.add(newPost);
      _applyFilters();
    } catch (e) {
      throw ErrorService.handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePost(Post post) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updatedPost = await _repository.updatePost(post);
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = updatedPost;
        _applyFilters();
      }
    } catch (e) {
      throw ErrorService.handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePost(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.deletePost(id);
      _posts.removeWhere((post) => post.id == id);
      _applyFilters();
    } catch (e) {
      throw ErrorService.handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchPosts(String query) async {
    try {
      _isLoading = true;
      notifyListeners();

      _searchQuery = query;
      _filteredPosts = await _repository.searchPosts(query);
      _applySorting();
    } catch (e) {
      throw ErrorService.handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sortPosts(String field, {bool ascending = true}) async {
    try {
      _isLoading = true;
      notifyListeners();

      _sortBy = field;
      _sortAscending = ascending;
      _filteredPosts = await _repository.sortPosts(field, ascending: ascending);
    } catch (e) {
      throw ErrorService.handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredPosts = List.from(_posts);
    } else {
      _filteredPosts = _posts
          .where((post) =>
              post.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              post.body.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    _applySorting();
  }

  void _applySorting() {
    _filteredPosts.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'id':
        default:
          comparison = a.id.compareTo(b.id);
      }
      return _sortAscending ? comparison : -comparison;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
