import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hard_diffusion/main.dart';
import 'package:uuid_type/uuid_type.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TextToImageWebsocketState extends ChangeNotifier {
  TextToImageWebsocketState();

  WebSocketChannel? channel;
  bool webSocketConnected = false;
  bool needsRefresh = false;
  int webSocketReconnectAttempts = 0;
  Map<Uuid, int> taskCurrentStep = {};
  Map<Uuid, int> taskTotalSteps = {};
  Map<Uuid, String> taskPreview = {};

  void onMessage(message) {
    final JsonDecoder _decoder = JsonDecoder();
    var decoded = _decoder.convert(message);
    var decodedMessage = decoded["message"];
    webSocketConnected = true;
    webSocketReconnectAttempts = 0;
    var event = decoded["event"];
    if (event == "image_generated") {
      needsRefresh = true;
    } else if (event == "image_generating") {
      decodedMessage = _decoder.convert(decodedMessage);
      var task_id = Uuid.parse(decodedMessage["task_id"]);
      taskCurrentStep[task_id] = decodedMessage["step"];
      taskTotalSteps[task_id] = decodedMessage["total_steps"];
      if (decodedMessage["image"] != null) {
        taskPreview[task_id] = decodedMessage["image"];
      }
    } else if (event == "image_queued") {
      decodedMessage = Uuid.parse(decodedMessage);
      taskCurrentStep[decodedMessage] = 0;
      taskTotalSteps[decodedMessage] = 0;
      taskPreview[decodedMessage] = "";
      needsRefresh = true;
    } else if (event == "image_errored") {
      needsRefresh = true;
    }
    print(event);
    notifyListeners();
  }

  void onDone() async {
    var delay = 1 + 1 * webSocketReconnectAttempts;
    if (delay > 10) {
      delay = 10;
    }
    print(
        "Done, reconnecting in $delay seconds, attempt $webSocketReconnectAttempts ");
    webSocketConnected = false;
    channel = null;
    await Future.delayed(Duration(seconds: delay));
    connect();
  }

  void onError(error) {
    print(error);
    if (error is WebSocketChannelException) {
      webSocketReconnectAttempts += 1;
    }
  }

  void connect() {
    try {
      channel = WebSocketChannel.connect(
        Uri.parse('$websocketHost/ws/generate/'),
      );
      channel!.stream.listen(onMessage, onDone: onDone, onError: onError);
    } catch (e) {
      print(e);
    }
  }

  void didRefresh() {
    needsRefresh = false;
  }

  void sendMessage(message) {
    if (channel == null) {
      connect();
    }
    if (webSocketConnected && message != null && message.isNotEmpty) {
      channel!.sink.add(message);
    }
  }
}
