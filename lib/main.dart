import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posts App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 22, 168, 37)RGB(255, 17, 193, 29)),
      ),
      home: const PostsPage(),
    );
  }
}

// Модель данных для поста
class Post {
  final int id;
  final String title;
  final String body;

  Post({
    required this.id,
    required this.title,
    required this.body,
  });

  // Конструктор для создания объекта из JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

// StatefulWidget для отображения списка постов
class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late Future<List<Post>> futurePosts;
  List<Post>? posts;
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    futurePosts = fetchPosts();
  }

  // Асинхронная функция для получения постов с API
  Future<List<Post>> fetchPosts() async {
    try {
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final List<Post> loadedPosts =
            jsonData.map((json) => Post.fromJson(json)).toList();
        setState(() {
          posts = loadedPosts;
          isLoading = false;
          errorMessage = null;
        });
        return loadedPosts;
      } else {
        throw Exception('Ошибка загрузки: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Ошибка загрузки постов: $e';
      });
      throw Exception(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Посты'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : posts != null && posts!.isNotEmpty
                  ? ListView.builder(
                      itemCount: posts!.length,
                      itemBuilder: (context, index) {
                        final post = posts![index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('${post.id}'),
                          ),
                          title: Text(post.title),
                          subtitle: Text(
                            post.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text('Постов не найдено'),
                    ),
    );
  }
}
