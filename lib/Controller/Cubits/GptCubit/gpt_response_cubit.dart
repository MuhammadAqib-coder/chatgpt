import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/Controller/Repo/chat_bot_repo.dart';

import 'gpt_response_state.dart';

// enum GptResponseState {
//   initialState,
//   loadingState,
//   loadedState,
//   tokenExpiry,
//   timeOutState,
//   generalException,
//   socketState
// }

class GptResponseCubit extends Cubit<GptResponseState> {
  GptResponseCubit() : super(InitailState());

  getGptResponse(newMessage) async {
    try {
      emit(LoadingState());

      var response = await ChatBotRepo.getResponse(newMessage);
      if (response == 501) {
        emit(SocketExceptionState());
      } else if (response == 401) {
        emit(TimeOutExceptionState());
      } else if (response == 200) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        emit(LoadedState());
        // return response;
      } else {
        emit(GeneralException());
      }
    } catch (e) {
      emit(GeneralException());
    }
  }
}
