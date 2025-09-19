import 'package:chatter_chatapp/Data/models/chat_room_model.dart';
import 'package:flutter/material.dart';

class ChatListTile extends StatelessWidget {
  final ChatRoomModel chat;
  final VoidCallback onTap;
  final String currentUserId;

  const ChatListTile({super.key,
    required this.chat,
    required this.onTap,
    required this.currentUserId,
  });


  /*String _getOtherUsername() {
    try {
      final otherUserId = chat.participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => 'Unknown User',
      );
      return chat.participantsName?[otherUserId] ?? "Unknown User";
    } catch (e) {
      return "Unknown User";
    }
  }*/
  

  String _getOtherUsername() {
    final otherUserId = chat.participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => 'Unknown User',
    );
    return chat.participantsName![otherUserId] ?? "Unknown User";
  }





  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Colors.blueGrey,
        child: Text(_getOtherUsername()[0].toUpperCase()),
      ),



      title: Text(_getOtherUsername()),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(chat.lastMessage ?? '',
                   maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[600]),
                  ),
          ),
        ],
      ),
      
      trailing: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text("*"
          // chat.unreadCount.toString(),
          // style: const TextStyle(color: Colors.white),
        ),
      ),
      
    );
  }
}