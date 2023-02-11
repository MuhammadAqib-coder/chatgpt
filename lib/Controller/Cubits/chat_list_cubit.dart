import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/Models/chat_message.dart';

class ChatListCubit extends Cubit<List<ChatMessage>> {
  ChatListCubit() : super([]);

  addMessage(newMessage) async {
    List<ChatMessage> newList = List.from(state)..add(newMessage);
    emit(newList);
  }
}
