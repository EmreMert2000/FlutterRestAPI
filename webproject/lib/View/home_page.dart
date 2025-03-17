import 'package:flutter/material.dart';


import '../Services/web_socket_service.dart';
class HomePage extends StatefulWidget {
  final String title;
  final WebSocketService webSocketService;

  const HomePage({
    Key? key,
    required this.title,
    required this.webSocketService,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();

  // Mesaj gönderme işlevi, direkt olarak servisi çağırıyor.
  void _sendMessage() {
    widget.webSocketService.sendMessage(_controller.text);
  }

  @override
  void dispose() {
    // WebSocket kapatma ve controller’ı temizleme
    widget.webSocketService.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              child: TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Send a message',
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Gelen veriyi ekranda göstermek için StreamBuilder kullanıyoruz.
            StreamBuilder(
              stream: widget.webSocketService.stream,
              builder: (context, snapshot) {
                return Text(snapshot.hasData ? '${snapshot.data}' : '');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: const Icon(Icons.send),
      ),
    );
  }
}
