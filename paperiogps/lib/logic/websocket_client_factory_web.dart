import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel makeWsClient(String url) =>
    HtmlWebSocketChannel.connect(url, protocols: ['graphql-ws']);
