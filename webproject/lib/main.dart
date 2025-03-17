import 'package:flutter/material.dart';

import 'Services/web_socket_service.dart';
import 'View/home_page.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // WebSocketService, "S"ingle Responsibility prensibine uygun olarak
  // sadece WebSocket ile ilgili işlemleri barındırır.
  // Uygulama genelinde kullanmak istediğimiz için burada oluşturuyoruz.
  final WebSocketService _webSocketService = 
      WebSocketService('wss://echo.websocket.events');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Demo',
      home: HomePage(
        title: 'WebSocket Demo',
        webSocketService: _webSocketService,
      ),
    );
  }
}
