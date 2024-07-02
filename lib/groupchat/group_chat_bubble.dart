import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import '../utils/SizeConfig.dart';

class MyChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String time;
  final String senderName; // New parameter to hold the sender's name

  MyChatBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    required this.time,
    required this.senderName, // Updated constructor to accept sender's name
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 5),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: isCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              isCurrentUser
                  ? ChatBubble(
                      clipper: ChatBubbleClipper5(type: BubbleType.sendBubble),
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(top: 10),
                      backGroundColor: Colors.blue[400]!,
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth: SizeConfig.screenWidth * 0.7,
                            minWidth: SizeConfig.screenWidth * 0.1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              child: Text(
                                message,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      'ABC Diatype', /*fontSize: SizeConfig.screenWidth * 0.04*/
                                ),
                              ),
                            ),
                            /*  Text(time,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'ABC Diatype',
                                    fontSize: SizeConfig.screenWidth * 0.025))*/
                          ],
                        ),
                      ),
                    )
                  : ChatBubble(
                      clipper:
                          ChatBubbleClipper5(type: BubbleType.receiverBubble),
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(top: 10),
                      backGroundColor: Colors.green[400]!,
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth: SizeConfig.screenWidth * 0.7,
                            minWidth: SizeConfig.screenWidth * 0.1),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "~" + senderName,
                                style: TextStyle(
                                    color: Color(0xff00048a),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'ABC Diatype'),
                              ),
                              Container(
                                child: Text(
                                  message,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily:
                                        'ABC Diatype', /*fontSize: SizeConfig.screenWidth * 0.04*/
                                  ),
                                ),
                              ),
                              /* Padding(
                                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  time,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'ABC Diatype',
                                      fontSize: SizeConfig.screenWidth * 0.025,
                                      fontWeight: FontWeight.bold),
                                ),
                              )*/
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
