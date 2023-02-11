import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/Controller/Cubits/GptCubit/gpt_response_cubit.dart';
import 'package:flutter_chatbot/Controller/Cubits/chat_list_cubit.dart';
import 'package:flutter_chatbot/Views/chat_bot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ChatListCubit()),
          BlocProvider(create: (_) => GptResponseCubit())
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const ChatBot(),
        ));
  }
}
