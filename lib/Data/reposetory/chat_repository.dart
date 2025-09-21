
import 'package:chatter_chatapp/Data/models/chat_messege.dart';
import 'package:chatter_chatapp/Data/models/chat_room_model.dart';
import 'package:chatter_chatapp/Data/sevicies/base_reposatry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository extends BaseReposatry{

  CollectionReference get _chatRooms => firestore.collection("chatRoom");

  CollectionReference getChatRoomMessages(String chatRoomId) {
    return _chatRooms.doc(chatRoomId).collection("messages");
  }

  Future<ChatRoomModel> getOrCreateChatRoom(
    String currentUserID, String otherUserID)  async{

      // prevent creating a chat room with yourself
      if (currentUserID == otherUserID) {
        throw Exception("Cannot create a chat room with yourself");
      }


      final users = [currentUserID , otherUserID]..sort();
      final roomId = users.join("_");

      final roomDoc = await _chatRooms.doc(roomId).get();

      if (roomDoc.exists){
        return ChatRoomModel.fromFirestore(roomDoc);
      }

      final currentUserData = (await firestore.collection("users").doc(currentUserID).get()).data()
       as Map<String,dynamic>;
      
      final otherUserData = (await firestore.collection("users").doc(otherUserID).get()).data()
       as Map<String , dynamic>;

      final participantsName = {
        currentUserID : currentUserData["fullName"]?.toString() ?? "",    //--- here i have chnaged fullname to fullName
        otherUserID : otherUserData["fullName"]?.toString() ?? "",        //--- here i have chnaged fullname to fullName
      };

      final newRoom = ChatRoomModel(
        id: roomId,
         participants: users,
         participantsName: participantsName,
         lastReadTime: {
          currentUserID: Timestamp.now(),
          otherUserID : Timestamp.now()
         });

      await _chatRooms.doc(roomId).set(newRoom.toMap());
      return newRoom;

    }





    



    Future<void> sendMessage({
      required String chatRoomId,
      required String senderId,
      required String receiverId,
      required String content,
      MessageType type = MessageType.text,
    }) async{
      // batch -- write multiple documents atomically

      final batch = firestore.batch();

      // get message sub collection

      final messageRef = getChatRoomMessages(chatRoomId);          // get the messages sub collection of the chat room
      final messageDoc = messageRef.doc();

      // ChatMessage

      final message = ChatMessage(               // create a new message object
        id: messageDoc.id,
        chatRoomId: chatRoomId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        type: type,
        timestamp: Timestamp.now(),
        readBy: [senderId],
      );
      
      
      // add message to the sub collection

      batch.set(messageDoc, message.toMap());              // add message to the sub collection

      //update chat room

      batch.update(
        _chatRooms.doc(chatRoomId),
        {
          "lastMessage": content,
          "lastMessageTime": message.timestamp,
          "lastMessageSenderId": senderId,
          
        },
      );
      await batch.commit();                // commit the batch
    }


    Stream <List<ChatMessage>> getMessages(String chatRoomId,{
      DocumentSnapshot? lastDocument}){
        var query = getChatRoomMessages(chatRoomId)
        .orderBy('timestamp' ,
         descending: true)
         .limit(25);

        if (lastDocument != null){
          query = query.startAfterDocument(lastDocument);
        }

        return query.snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList());
      }


      Future <List<ChatMessage>> getMoreMessages(String chatRoomId,{
      required DocumentSnapshot lastDocument}) async{
        final query = getChatRoomMessages(chatRoomId)
        .orderBy('timestamp' ,descending: true).startAfterDocument(lastDocument)
         .limit(25);

        
        final snapshot = await query.get();
        

        return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
      }

      Stream<List<ChatRoomModel>> getChatRooms(String userId) {
        return _chatRooms
        .where("participants", arrayContains: userId)
        .orderBy("lastMessageTime", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatRoomModel.fromFirestore(doc)).toList());
      }

      Stream <int> getUnreadMessageCount(String chatRoomId, String userId){
        return getChatRoomMessages(chatRoomId)
        .where("receiverId", isEqualTo: userId)
        .where("status", isEqualTo: MessageStatus.sent.toString())
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
      }


      Future<void> markMessagesAsRead(String chatRoomId, String userId) async{
        try{
          final batch = firestore.batch();
          final unreadMessages = await getChatRoomMessages(chatRoomId)
          .where("receiverId", isEqualTo: userId)
          .where("status", isEqualTo: MessageStatus.sent.toString())
          .get();

        print("found ${unreadMessages.docs.length} unread messages");

          for (var doc in unreadMessages.docs){
            batch.update(doc.reference, {
              "status": MessageStatus.read.toString(),
              "readBy": FieldValue.arrayUnion([userId]),
            });
          }

          // update last read time in chat room
          batch.update(_chatRooms.doc(chatRoomId), {
            "lastReadTime.$userId": Timestamp.now(),
          });

          await batch.commit();
        } catch (e){
          print("Error marking messages as read: $e");
        }

        
      }


}

