import 'package:chatter_chatapp/Data/models/chat_messege.dart';
import 'package:chatter_chatapp/Data/sevicies/service_locator.dart';
import 'package:chatter_chatapp/Logic/cubit/chat/chat_cubit.dart';
import 'package:chatter_chatapp/Logic/cubit/chat/chat_state.dart';
import 'package:chatter_chatapp/Presentation/home/home_screen.dart';
import 'package:chatter_chatapp/router/app_router.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatMessageScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  const ChatMessageScreen({super.key , required this.receiverId, required this.receiverName});



  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  final TextEditingController messageController = TextEditingController();

  late final ChatCubit _chatCubit;
  @override
  void initState() {
    _chatCubit = getIt<ChatCubit>();
    _chatCubit.enterChat(widget.receiverId);              // Enter the chat room with the receiver's ID
    super.initState();
  }

  Future<void> handelSendMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return; // Do not send empty messages

    try {
      await _chatCubit.sendMessage(
        content: messageText,
        receiverId: widget.receiverId,
      );
      messageController.clear(); // Clear the input field after sending
    } catch (e) {
      // Handle error if needed
      debugPrint("Error sending message: $e");
    }
  }

  @override
  void dispose() {
    messageController.dispose(); // Dispose the controller to free resources 
    _chatCubit.leaveChat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF004F4F),
        leading:IconButton(
          onPressed: (){
            getIt<AppRouter>().pushAndRemoveUntil  (HomeScreen());
          }, 
          icon: Icon(Icons.arrow_back_ios_new_rounded), color: Colors.cyanAccent,
          ),

          title: Row(
            children: [ CircleAvatar(child: Text(widget.receiverName[0],style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,color: Colors.white),),),

            SizedBox(height: 12, width: 5,),
              
            
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((widget.receiverName),style: TextStyle(color: Colors.white)),
                  Text(("Online.."),style :TextStyle(color: CupertinoColors.activeGreen, fontSize: 15),),
                ],
              ),
            ],
          ),

          actions: [IconButton(onPressed: (){}, icon: Icon(Icons.more_vert), color: Colors.cyanAccent,)],


      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/homeBg04.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 13),
          child: BlocBuilder<ChatCubit, ChatState>(
            bloc: _chatCubit,
            builder: (context, state) {
              if (state.status == ChatStatus.loading) {
                return Center(child: CircularProgressIndicator(color: Colors.cyanAccent,));
              } else if (state.status == ChatStatus.error) {
                return Center(child: Text("Error: ${state.error}", style: TextStyle(color: Colors.red),));
              } /*else if (state.messages.isEmpty) {
                return Center(child: Text("No messages yet", style: TextStyle(color: Colors.blueGrey),));
              }*/
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder( 
                      reverse: true,
                      itemCount: state.messages.length,
                      itemBuilder: (context, index){
                        final message = state.messages[index];
                        final isMe = message.senderId == _chatCubit.currentUserId;
        
                    return MessageBubble(
                      message: message,
                      isMe: isMe
                      );
                    }),
                    
                  ),
              
              
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            decoration: InputDecoration(
                              hintText: "Type a message",
                              hintStyle: TextStyle(color: Colors.blueGrey, fontSize: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30), 
                              ),
                              fillColor: Colors.black54,
              
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: IconButton(
                                  onPressed: (){},
                                   icon: Icon(Icons.emoji_emotions_outlined),
                                    color: Colors.cyanAccent,
                                    iconSize: 30,
                                ),
                              ),
              
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: IconButton(
                                  onPressed: handelSendMessage,
                                  icon: Icon(Icons.send, color: Colors.cyanAccent, size: 29,),
                                ),
                              ),
                              
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                  
                  
                  
                  ],
              );
            }
          ),
        ),
      ),
    );

      
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  // final bool showTime;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    // this.showTime = true,
    });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,

      child: Container(

        margin: EdgeInsets.only(
          left: isMe ? 124 : 8,
          right: isMe ? 8 : 124,
          top: 3,
          bottom: 4,
          
        ),
        padding: isMe ? EdgeInsets.only(top: 15, bottom: 0, left: 13 , right: 10) : EdgeInsets.only(top: 15, bottom: 0, left: 10 , right: 8),
        
        decoration: BoxDecoration(
          color: isMe ? (const Color.fromARGB(255, 26, 86, 88).withOpacity(0.7)) : (const Color.fromARGB(255, 212, 212, 212).withOpacity(0.5)),
          borderRadius: BorderRadius.circular(21),
        ),
      
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, // Align text based on sender
          children: [
            Text(message.content, 
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),

          
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                DateFormat("h:mm:a").format(message.timestamp.toDate()),
                style: TextStyle(color: isMe ? Colors.white70 : Colors.black54, fontSize: 12),  
              ),
              if (isMe) ...[
                SizedBox(width: 5),
                Icon(
                  message.readBy.length > 1 ? Icons.done_all : Icons.done,
                  size: 16,
                  color: message.readBy.length > 1 ? Colors.blueAccent : (isMe ? Colors.white70 : Colors.black54),
                ),
              ],
              
              
            ],
          ),

          
          ],
        ),
      ),
    );
  }
}