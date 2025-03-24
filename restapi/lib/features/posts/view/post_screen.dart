import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/post_viewmodel.dart';
import '../model/post_model.dart';
import '../../../core/services/error_service.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostViewModel>().fetchPosts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gönderiler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePostDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSortOptions(),
          Expanded(
            child: _buildPostList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Gönderi ara...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          context.read<PostViewModel>().searchPosts(value);
        },
      ),
    );
  }

  Widget _buildSortOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          const Text('Sırala: '),
          DropdownButton<String>(
            value: context.watch<PostViewModel>().sortBy,
            items: const [
              DropdownMenuItem(value: 'id', child: Text('ID')),
              DropdownMenuItem(value: 'title', child: Text('Başlık')),
            ],
            onChanged: (value) {
              if (value != null) {
                context.read<PostViewModel>().sortPosts(value);
              }
            },
          ),
          IconButton(
            icon: Icon(
              context.watch<PostViewModel>().sortAscending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
            ),
            onPressed: () {
              final viewModel = context.read<PostViewModel>();
              viewModel.sortPosts(
                viewModel.sortBy,
                ascending: !viewModel.sortAscending,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostList() {
    return Consumer<PostViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.posts.isEmpty) {
          return const Center(child: Text('Gönderi bulunamadı'));
        }

        return ListView.builder(
          itemCount: viewModel.posts.length,
          itemBuilder: (context, index) {
            final post = viewModel.posts[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(post.title),
                subtitle: Text(post.body),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditPostDialog(context, post),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteDialog(context, post),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showCreatePostDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Gönderi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Başlık'),
            ),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'İçerik'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final post = Post(
                  userId: 1,
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: titleController.text,
                  body: bodyController.text,
                );
                await context.read<PostViewModel>().createPost(post);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gönderi oluşturuldu')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ErrorService.handleError(e))),
                  );
                }
              }
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditPostDialog(BuildContext context, Post post) async {
    final titleController = TextEditingController(text: post.title);
    final bodyController = TextEditingController(text: post.body);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gönderiyi Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Başlık'),
            ),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'İçerik'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final updatedPost = Post(
                  userId: post.userId,
                  id: post.id,
                  title: titleController.text,
                  body: bodyController.text,
                );
                await context.read<PostViewModel>().updatePost(updatedPost);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gönderi güncellendi')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ErrorService.handleError(e))),
                  );
                }
              }
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Post post) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gönderiyi Sil'),
        content: Text(
            '"${post.title}" gönderisini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await context.read<PostViewModel>().deletePost(post.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gönderi silindi')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ErrorService.handleError(e))),
                  );
                }
              }
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
