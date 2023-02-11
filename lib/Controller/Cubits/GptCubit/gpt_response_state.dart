import '../../../Models/chat_message.dart';
import '../chat_list_cubit.dart';
import 'package:bloc/bloc.dart';

abstract class GptResponseState {}

class InitailState extends GptResponseState {}

class LoadingState extends GptResponseState {}

class LoadedState extends GptResponseState {}

class SocketExceptionState extends GptResponseState {}

class TimeOutExceptionState extends GptResponseState {}

class GeneralException extends GptResponseState {}
