import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import '../services/globals.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<types.Message> _messages = [];
  final _user = const types.User(id: '1');

  @override
  void initState() {
    super.initState();
    getChats(1);
  }

  Future<void> getChats(int uid) async {
    const url = 'http://localhost:8080/chats/1';
    final response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json; charset=UTF-8",
    });

    if (response.statusCode == 200) {
      final List<dynamic> chatData = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        _messages = chatData.map((data) {
          final bool isUser = data['user'];
          final String text = data['content'];
          final String timestamp = data['createAt'];
          final String messageId = DateTime.now().toString();
          print(chatData);
          return types.TextMessage(
            author: isUser ? _user : types.User(id: 'nabi'),
            createdAt: DateTime.parse(timestamp).millisecondsSinceEpoch,
            id: messageId,
            text: text,
          );
        }).toList();
      });
      _messages.sort((a, b) {
        int compare = b.createdAt!.compareTo(a.createdAt as int);
        if (compare == 0) {
          bool aIsUser = a.author.id == '0';
          bool bIsUser = b.author.id == '1';
          if (aIsUser && !bIsUser) {
            return -1;
          } else if (!aIsUser && bIsUser) {
            return 0;
          }
          return 1;
        }
        return compare;
      });
    } else {
      print('Failed to load chats from server');
    }
  }

  Future<bool> sendChat(int uid, String content) async {
    const url = 'http://localhost:8080/chat';
    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      'uid': uid,
      'content': content,
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        getChats(uid);
        return true;
      } else {
        print('서버 에러: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('네트워크 에러: $e');
      return false;
    }
  }

  void _handleSendPressed(types.PartialText message) async {
    final int uid = 1;
    final content = message.text;

    final success = await sendChat(uid, content);
    if (!success) {
      print('메시지 전송 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Chat(
        theme: const DefaultChatTheme(
          inputBackgroundColor: Color(0xFFF2F2F2),
          inputTextColor: Colors.black,
          primaryColor: Color(0xFFFFFACD),
          sentMessageBodyTextStyle: TextStyle(color: Colors.black87),
          receivedMessageBodyTextStyle: TextStyle(color: Colors.black87),
          secondaryColor: Color(0xFFD3EAFF),
          messageBorderRadius: 20.0,
        ),
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
      ),
    );
  }
}
