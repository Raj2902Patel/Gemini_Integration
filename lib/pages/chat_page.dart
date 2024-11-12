import 'package:flutter/material.dart';
import 'package:google_gemini/google_gemini.dart';

const apiKey = "";

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  List chatList = [];

  //create gemini instance
  final geminiAI = GoogleGemini(
    apiKey: apiKey,
  );

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  //function for getting result from AI
  void chatFunc({required String query}) async {
    setState(() {
      isLoading = true;
      chatList.add({
        "role": "User",
        "text": query,
      });
      _textController.clear();
    });
    _scrollToBottom();

    geminiAI.generateFromText(query).then((value) {
      setState(() {
        isLoading = false;
        chatList.add({
          "role": "Gemini",
          "text": value.text,
        });
      });
      _scrollToBottom();
    }).onError((error, stackTrace) {
      setState(() {
        isLoading = false;
        chatList.add({
          "role": "Gemini",
          "text": error.toString(),
        });
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gemini AI",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontSize: 24.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent.withOpacity(0.6),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatList.length,
              padding: EdgeInsets.only(bottom: 2.0), // Add padding at bottom
              itemBuilder: (context, index) {
                return ListTile(
                  isThreeLine: true,
                  leading: CircleAvatar(
                    child: Text(
                      chatList[index]["role"].substring(0, 1),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 22.0,
                      ),
                    ),
                  ),
                  title: Text(
                    chatList[index]['role'],
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0,
                    ),
                  ),
                  subtitle: Text(
                    chatList[index]['text'],
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Ask me anything..",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none),
                      fillColor: Colors.transparent,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_textController.text.trim().isNotEmpty) {
                      chatFunc(query: _textController.text);
                    }
                  },
                  icon: isLoading
                      ? CircularProgressIndicator(
                          color: Colors.blueGrey,
                        )
                      : Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
