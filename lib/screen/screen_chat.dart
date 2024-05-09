import 'dart:convert';
import 'package:doctor_nyang/services/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:iconsax/iconsax.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../assets/theme.dart';
import '../services/urls.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<types.Message> _messages = [];
  final _user = const types.User(id: '1');
  late int page = 0;
  bool _isLoading = false;
  late int day = 0;

  AutoScrollController _scrollController = AutoScrollController();
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    getChats(1);
    getDday();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      page++;
      getChats(1);
      _scrollController.scrollToIndex(0,
          preferPosition: AutoScrollPosition.begin);
    } else if (_scrollController.position.pixels ==
        _scrollController.position.minScrollExtent) {
      if (page > 0) {
        page--;
        getChats(1);
        _scrollController.scrollToIndex(0,
            preferPosition: AutoScrollPosition.end);
      } else {
        print('Reached the top');
      }
    }
  }

  Future<void> getDday() async {
    final url = Uri.parse('$baseUrl/user/d-day');
    final response = await http.get(url, headers: {
      "Content-Type": "application/json; charset=UTF-8",
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> ddayData =
          json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          day = ddayData['days'];
        });
    } else {
      print('Failed to load dday from server');
    }
  }

  Future<void> getChats(int uid) async {
    final url = Uri.parse('$baseUrl/chats/$userId/$page');
    final response = await http.get(url, headers: {
      "Content-Type": "application/json; charset=UTF-8",
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> chatData =
          json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        _messages = chatData.map((data) {
          final bool isUser = data['user'];
          final String text = data['content'];
          final String timestamp = data['createAt'];
          final String messageId = DateTime.now().toString();
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
    final url = Uri.parse('$baseUrl/chat');
    final headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    };
    final body = json.encode({
      'uid': uid,
      'content': content,
    });

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        page = 0;
        setState(() {
          _isLoading = false;
          getChats(1);
        });
        return true;
      } else {
        print('전송 에러: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
        return false;
      }
    } catch (e) {
      print('네트워크 에러: $e');
      return false;
    }
  }

  void _handleSendPressed(types.PartialText message) async {
    final int? uid = userId;
    final content = message.text;

    final success = await sendChat(uid!, content);
    if (!success) {
      print('메시지 전송 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('images/chat_default.png'),
          colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.5), BlendMode.dstATop),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Chat(
                theme: const DefaultChatTheme(
                  inputBackgroundColor: Colors.white,
                  inputTextColor: Colors.black,
                  primaryColor: Color(0xFFFFFACD),
                  sentMessageBodyTextStyle: TextStyle(color: Colors.black87),
                  receivedMessageBodyTextStyle:
                      TextStyle(color: Colors.black87),
                  secondaryColor: Color(0xFFD3EAFF),
                  messageBorderRadius: 20.0,
                  backgroundColor: Colors.transparent,
                  sendButtonIcon: Icon(Iconsax.send_1),
                ),
                messages: _messages,
                onSendPressed: _handleSendPressed,
                user: _user,
                scrollController: _scrollController,
              ),
              Positioned(
                  child: _isLoading
                      ? SpinKitPumpingHeart(color: AppTheme.pastelPink)
                      : Container()),
              Positioned(
                top: 0,
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: Container(
                  color: Colors.white,
                  child: ButtonBar(
                  alignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Iconsax.heart5, size: 30, color: AppTheme.pastelPink),
                      onPressed: () {},
                    ),
                    Text('나비와 함께한지 ${day}일', style: TextStyle(fontSize: 16)),
                    IconButton(
                      icon: Icon(Iconsax.milk5, size: 30, color: AppTheme.pastelBlue),
                      onPressed: () {},
                    ),
                  ],
                ),),
              )
            ],
          ),
        ),
      ),
    );
  }
}
