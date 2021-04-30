import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicast/controller/handler.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // final ChatHandler chatHandler = ChatHandler();
  final TextEditingController messageController = TextEditingController();
  bool waitForResponse = false;
  final ScrollController scrollController = ScrollController();
  ChatHandler getxChatController = Get.put(ChatHandler());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // chatHandler.connectToServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 40),
                Text("Unicast Chat App",
                    style: TextStyle(color: Colors.blue, fontSize: 30)),
                FutureBuilder(
                  future: getxChatController.connectToServer(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    print("started");
                    return StreamBuilder(
                      stream: getxChatController.displaySocket,
                      builder: (ctx, event) {
                        if (!event.hasData) {
                          return Container(
                              height: 350,
                              child: Center(child: Text("No data :(")));
                        } else if (event.hasData) {
                          switch (event.connectionState) {
                            case ConnectionState.none:
                              return SizedBox(height: 400);
                              break;
                            case ConnectionState.waiting:
                              return CircularProgressIndicator();
                              break;
                            case ConnectionState.active:
                              {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (scrollController.hasClients) {
                                    scrollController.jumpTo(scrollController
                                        .position.maxScrollExtent);
                                  }
                                });
                                var temp2 = event.data;
                                List<dynamic> test =
                                    json.decode(String.fromCharCodes(temp2));
                                getxChatController.messageList = test;
                                print(getxChatController.messageList);
                                return Container(
                                  height: 500,
                                  child: ListView.builder(
                                      controller: scrollController,
                                      itemBuilder: (context, index) {
                                        return buildCustomMessage(index);
                                      },
                                      itemCount: getxChatController
                                                  .messageList.length ==
                                              0
                                          ? 0
                                          : getxChatController
                                              .messageList.length),
                                );
                              }
                              // TODO: Handle this case.
                              break;
                            case ConnectionState.done:
                              return Text("Chat ended ");
                              break;
                          }
                        }
                        return Container(
                          child: SizedBox(height: 500),
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: messageController,
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          getxChatController.messageList
                              .add(messageController.text);
                          getxChatController.sendMessage(
                            "${messageController.text}",
                          );
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (scrollController.hasClients) {
                              scrollController.jumpTo(
                                  scrollController.position.maxScrollExtent);
                            }
                          });
                        },
                        child: Text('Send')),
                    SizedBox(width: 20),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    getxChatController.connectToServer();
                  },
                  child: Text('connect'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCustomMessage(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 5, top: 5, left: 10, right: 10),
      child: Row(
        children: [
          index % 2 == 0 ? Spacer() : Container(),
          index % 2 == 0
              ? Container(
                  width: 200,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: ClipOval(
                              child: Container(
                                child: Text('RM'),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Text(
                            '${getxChatController.messageList[index]}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  width: 200,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            child: ClipOval(
                              child: Container(
                                child: Text('S'),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Text(
                            '${getxChatController.messageList[index]}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        SizedBox(height: 20)
                      ],
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
