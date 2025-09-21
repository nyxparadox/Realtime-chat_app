import 'package:chatter_chatapp/Data/models/chat_room_model.dart';
import 'package:chatter_chatapp/Data/reposetory/chat_repository.dart';
import 'package:chatter_chatapp/Data/sevicies/service_locator.dart';
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
      
      trailing: StreamBuilder<int>(
        stream: getIt<ChatRepository>().getUnreadMessageCount(
          chat.id, currentUserId),
           builder: (context, snapshot){
            if (!snapshot.hasData || snapshot.data == 0){
              return const SizedBox();

            }
            return Container(
              padding: const EdgeInsets.all(8),
              decoration:  BoxDecoration(
                color: Colors.blue.shade400,
                shape: BoxShape.circle,
              ),
              child: Text(
                snapshot.data.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
           }),
           
      
    );
  }
}