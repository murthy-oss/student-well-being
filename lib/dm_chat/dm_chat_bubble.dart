import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:student_welbeing/utils/SizeConfig.dart';

class MyDMChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String time;

  const MyDMChatBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              ChatBubble(
                clipper: ChatBubbleClipper5(type: BubbleType.sendBubble),
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(top: 10),
                backGroundColor:
                    isCurrentUser ? Colors.blue[400]! : Colors.green[300]!,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          message,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          Text(time,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ABC Diatype',
                  fontSize: SizeConfig.screenWidth * 0.025)),
        ],
      ),
    );
  }
}
