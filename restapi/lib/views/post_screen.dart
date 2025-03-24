import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../viewmodels/post_viewmodel.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
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
        title: Text("Post Listesi"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
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
      padding: EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Post ara...',
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
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Text('Sırala: '),
          DropdownButton<String>(
            value: context.watch<PostViewModel>().sortBy,
            items: [
              DropdownMenuItem(value: '', child: Text('Varsayılan')),
              DropdownMenuItem(value: 'title', child: Text('Başlığa Göre')),
              DropdownMenuItem(value: 'id', child: Text('ID\'ye Göre')),
            ],
            onChanged: (value) {
              if (value != null) {
                context.read<PostViewModel>().sortPosts(value);
              }
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
          return Center(child: CircularProgressIndicator());
        }

        if (viewModel.error.isNotEmpty) {
          return Center(child: Text(viewModel.error));
        }

        if (viewModel.posts.isEmpty) {
          return Center(child: Text("Gösterilecek veri yok"));
        }

        return ListView.builder(
          itemCount: viewModel.posts.length,
          itemBuilder: (context, index) {
            final post = viewModel.posts[index];
            return _buildPostTile(post);
          },
        );
      },
    );
  }

  Widget _buildPostTile(Post post) {
    return ListTile(
      title: Text(
        post.title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(post.body),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _showEditPostDialog(context, post),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(context, post),
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
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
        title: Text('Yeni Post Oluştur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Başlık'),
            ),
            TextField(
              controller: bodyController,
              decoration: InputDecoration(labelText: 'İçerik'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              final newPost = Post(
                userId: 1,
                id: 0,
                title: titleController.text,
                body: bodyController.text,
              );

              final success =
                  await context.read<PostViewModel>().createPost(newPost);
              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Post başarıyla oluşturuldu')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Post oluşturulurken hata oluştu')),
                );
              }
            },
            child: Text('Oluştur'),
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
        title: Text('Postu Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Başlık'),
            ),
            TextField(
              controller: bodyController,
              decoration: InputDecoration(labelText: 'İçerik'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              final updatedPost = Post(
                userId: post.userId,
                id: post.id,
                title: titleController.text,
                body: bodyController.text,
              );

              final success =
                  await context.read<PostViewModel>().updatePost(updatedPost);
              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Post başarıyla güncellendi')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Post güncellenirken hata oluştu')),
                );
              }
            },
            child: Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Postu Sil"),
        content: Text("Bu postu silmek istediğinizden emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("İptal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Sil", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<PostViewModel>().deletePost(post.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Post başarıyla silindi")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Post silinirken hata oluştu")),
        );
      }
    }
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
