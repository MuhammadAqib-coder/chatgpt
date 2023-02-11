import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatbot/Controller/Cubits/GptCubit/gpt_response_cubit.dart';
import 'package:flutter_chatbot/Controller/Cubits/GptCubit/gpt_response_state.dart';
import 'package:flutter_chatbot/Controller/Repo/chat_bot_repo.dart';
import 'package:http/http.dart' as http;

import '../Controller/Cubits/chat_list_cubit.dart';
import '../Models/chat_message.dart';

const backgroundColor = Color(0xff343541);
const botBackgroundColor = Color(0xff444654);

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final _textControler = TextEditingController();
  final _scrollControler = ScrollController();
  final List<ChatMessage> _messages = [];

  // late bool isLoading;
  var isLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: botBackgroundColor,
        title: const Text(
          'Flutter Chat Gpt',
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildList()),
            BlocConsumer<GptResponseCubit, GptResponseState>(
                listener: ((_, state) {
              if (state is LoadedState) {
                context.read<ChatListCubit>().addMessage(ChatMessage(
                    text: chatBotMessage,
                    chatMessageType: ChatMessageType.bot));
              }
            }), builder: (_, state) {
              if (state is LoadingState) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    color: botBackgroundColor,
                  ),
                );
              }
              if (state is LoadedState) {
                return Container();
              }
              if (state is TimeOutExceptionState) {
                return const Text("Time out exception");
              }
              if (state is SocketExceptionState) {
                return const Text('socket exception');
              }
              return Container();
            }),
            // ValueListenableBuilder(
            //     valueListenable: isLoading,
            //     builder: (context, value, _) {
            //       if (value) {
            //         return const Padding(
            //           padding: EdgeInsets.all(8.0),
            //           child: CircularProgressIndicator(),
            //         );
            //       } else {
            //         return Container();
            //       }
            //     }),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [_buildInput(), _buildSubmit()],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSubmit() {
    return ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (context, value, _) {
          if (!value) {
            return Container(
              color: botBackgroundColor,
              child: IconButton(
                  onPressed: () async {
                    // _messages.add(ChatMessage(
                    //     text: _textControler.text,
                    //     chatMessageType: ChatMessageType.user));
                    context.read<ChatListCubit>().addMessage(ChatMessage(
                        text: _textControler.text,
                        chatMessageType: ChatMessageType.user));
                    isLoading.value = !isLoading.value;
                    setState(() {});
                    var input = _textControler.text;
                    _textControler.clear();
                    Future.delayed(const Duration(milliseconds: 50))
                        .then((value) => _scrollDown());
                    await context
                        .read<GptResponseCubit>()
                        .getGptResponse(input);
                    setState(() {
                      isLoading.value = !isLoading.value;
                    });

                    // await generateResponse(input).then(
                    //   (value) {
                    //     isLoading.value = !isLoading.value;
                    //     _messages.add(ChatMessage(
                    //         text: value, chatMessageType: ChatMessageType.bot));
                    //     // setState(() {
                    //     // });
                    //   },
                    // );

                    // _textControler.clear();
                    Future.delayed(const Duration(milliseconds: 50))
                        .then((value) => _scrollDown());
                  },
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Color.fromRGBO(142, 142, 160, 1),
                  )),
            );
          } else {
            return Container();
          }
        });

    // return Visibility(
    //     visible: !isLoading,
    //     child: Container(
    //       color: botBackgroundColor,
    //       child: IconButton(
    //           onPressed: () async {
    //             setState(() {
    //               _messages.add(ChatMessage(
    //                   text: _textControler.text,
    //                   chatMessageType: ChatMessageType.user));
    //               isLoading = true;
    //             });
    //             var input = _textControler.text;
    //             _textControler.clear();
    //             Future.delayed(const Duration(milliseconds: 50))
    //                 .then((value) => _scrollDown());
    //             // var newMessage = await _api.sendMessage(input,
    //             //     conversationId: _conversationId,
    //             //     parentMessageId: _parentMessageId);
    //             await generateResponse(input).then(
    //               (value) {
    //                 setState(() {
    //                   isLoading = false;
    //                   _messages.add(ChatMessage(
    //                       text: value, chatMessageType: ChatMessageType.bot));
    //                 });
    //               },
    //             );

    //             // _textControler.clear();
    //             Future.delayed(const Duration(milliseconds: 50))
    //                 .then((value) => _scrollDown());
    //           },
    //           icon: const Icon(
    //             Icons.send_rounded,
    //             color: Color.fromRGBO(142, 142, 160, 1),
    //           )),
    //     ));
  }

  Widget _buildInput() {
    return Expanded(
        child: TextField(
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(color: Colors.white),
      controller: _textControler,
      decoration: const InputDecoration(
          fillColor: botBackgroundColor,
          filled: true,
          focusedBorder: InputBorder.none,
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          enabledBorder: InputBorder.none),
    ));
  }

  BlocBuilder<ChatListCubit, List<ChatMessage>> _buildList() {
    return BlocBuilder<ChatListCubit, List<ChatMessage>>(
        builder: (context, state) {
      return ListView.builder(
          controller: _scrollControler,
          itemCount: state.length,
          itemBuilder: (context, index) {
            var message = state[index];
            return ChatMessageWidget(
              text: message.text,
              chatMessageType: message.chatMessageType,
            );
          });
    });
  }

  void _scrollDown() {
    _scrollControler.animateTo(_scrollControler.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget(
      {super.key, required this.text, required this.chatMessageType});

  final String text;
  final ChatMessageType chatMessageType;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(8),
      color: chatMessageType == ChatMessageType.user
          ? backgroundColor
          : botBackgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          chatMessageType == ChatMessageType.bot
              ? Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/chatgpt3.jpg'),
                    // backgroundColor: const Color.fromRGBO(16, 163, 127, 1),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: const CircleAvatar(child: Icon(Icons.person)),
                ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

Future<String> generateResponse(String prompt) async {
  const apiKey = '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';

  var url = Uri.https("api.openai.com", "/v1/completions");
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $apiKey"
    },
    body: json.encode({
      "model": "text-davinci-003",
      "prompt": prompt,
      'temperature': 0,
      'max_tokens': 2000,
      'top_p': 1,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    }),
  );

  // Do something with the response
  Map<String, dynamic> newresponse = jsonDecode(response.body);

  return newresponse['choices'][0]['text'];
}
