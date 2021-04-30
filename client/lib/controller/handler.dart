import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';

class ChatHandler extends GetxController {
  Socket socket;
  Socket displaySocket;
  List messageList = <dynamic>[].obs;

  Future<void> connectToServer() async {
    print("fired");

    print('Connection fired');
    socket = await Socket.connect('192.168.0.110', 5050);
    displaySocket = socket;

    print("Connected to :${socket.remoteAddress.address}");
  }

  void sendMessageToServer() {
    var temp;
    socket.listen((Uint8List data) {
      print(data);
      final serverResponse = String.fromCharCodes(data);
      temp = serverResponse;
      print("Server: $serverResponse");
    },

        //error
        onError: (error) {
      print(error);
      socket.destroy();
    },
        //done
        onDone: () {
      print("leaving server");
      socket.destroy();
    });
  }

  Future<void> sendMessage(String message, {List<dynamic> messageList}) async {
    // socket.write(message);
    // socket.add([10, 10, 68, 90, 101]);
    socket.write('"' + message + '"');
  }
}
