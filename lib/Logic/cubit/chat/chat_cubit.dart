import 'dart:async';

import 'package:chatter_chatapp/Data/reposetory/chat_repository.dart';
import 'package:chatter_chatapp/Logic/cubit/chat/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatState>{
  final ChatRepository _chatRepository;
  final String currentUserId;
  bool isInchat = false;

  StreamSubscription? _messageSubscription;

  ChatCubit({
    required ChatRepository chatRepository,
    required this.currentUserId,
  }) : _chatRepository = chatRepository,
       super(const ChatState());


  void enterChat(String receiverId) async {
    isInchat = true;
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      final chatRoom = await _chatRepository.getOrCreateChatRoom(
        currentUserId,
        receiverId,
      );

      emit(state.copyWith(
        status: ChatStatus.loaded,
        chatRoomId: chatRoom.id,
        receiverId: receiverId
      ));
      _subscribeToMessages(chatRoom.id); // Subscribe to messages in the chat room
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        error: "failed to create chat Room $e",
      ));
    }
  }

  Future<void> sendMessage({required String content , required String receiverId}) async {
    if (state.chatRoomId == null) return;

    try {
      await _chatRepository.sendMessage(
        chatRoomId: state.chatRoomId!,
        senderId: currentUserId,
        receiverId: state.receiverId!,
        content: content,
      );

      
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,               // Set the status to error ,,, if there is an error
        error: "failed to send message $e",
      ));
    }
  }


  void _subscribeToMessages(String chatRoomId) {
    _messageSubscription?.cancel(); // Cancel any existing subscription

    _messageSubscription = _chatRepository.getMessages(chatRoomId)
      .listen((messages) {
        if (isInchat){
          _markMessagesAsRead(chatRoomId);
        }
        emit(
          state.copyWith(
            messages: messages,
            error: null,));
      }, onError: (error) {
        emit(state.copyWith(
          status: ChatStatus.error,
          error: "Failed to load messages: $error",
        ));
      });
  }

  Future<void> _markMessagesAsRead (String chatRoomId) async {
    if (state.chatRoomId == null) return;

    try {
      await _chatRepository.markMessagesAsRead(chatRoomId,currentUserId);
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        error: "Failed to mark messages as read: $e",
      ));
    }
  }

  Future<void> leaveChat() async {
    isInchat = false;
  }
}