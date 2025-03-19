import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  late WebSocketChannel _channel;

  /// Stream'e erişmek isteyen widget veya katmanlar bu getter'ı kullanabilir.
  Stream get stream => _channel.stream;

  /// Kurucu (constructor). İstenilen WebSocket URL'sini vererek
  /// farklı ortamlarda da tekrar kullanılabilir hale getiriyoruz.
  WebSocketService(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      _channel.sink.add(message);
    }
  }

  /// soket bağlantısını düzgün şekilde kapatıyoruz.
  void dispose() {
    _channel.sink.close();
  }
}
