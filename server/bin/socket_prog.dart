import 'dart:io';
import 'dart:typed_data';

void main() async {
  // bind the socket server to an address and port
  // this is my laptop's private IP address
  var addr = '192.168.0.110';
  final server = await ServerSocket.bind(
      InternetAddress(addr, type: InternetAddressType.IPv4), 5050);
  print('Server started on ${server.address}');
  // listen for clent connections to the server
  server.listen((client) {
    handleConnection(client);
  });
}

var messageList = [];
String welcomMessage = "Welcome";

void handleConnection(Socket client) {
  print('Connection from'
      ' ${client.remoteAddress.address}:${client.remotePort}');

  // listen for events from the client
  client.listen(
    // handle data from the client
    (Uint8List data) async {
      final message = String.fromCharCodes(data);
      messageList.add(message);
      print('Message from ${client.remoteAddress.address}> $message');
      stdout.write('Reply to ${client.remoteAddress.address} ---->  ');
      var reply = '"' + stdin.readLineSync() + '"';
      messageList.add(reply);
      client.write(messageList);
    },

    // handle errors
    onError: (error) {
      print(error);
      client.close();
    },

    // handle the client closing the connection
    onDone: () {
      print('Client left');
      client.close();
    },
  );
}
