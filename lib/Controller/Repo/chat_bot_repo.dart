import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_chatbot/Controller/Cubits/chat_list_cubit.dart';
import 'package:http/http.dart' as http;

String chatBotMessage = '';

class ChatBotRepo {
  static var newText =
      "The chatbot name will be Muhammad Aqib. The user name will be Flutter developer. The chatbot will help user in dart programming if the user have any problem";
  static const apiKey = 'Your ChatGPt Api key';

  static const baseurl = 'https://api.openai.com/v1/completions';
  static const headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey'
  };
  static Future<dynamic> getResponse(message) async {
    // newText = '$newText User: $message';
    var body = json.encode({
      "model": "text-davinci-003",
      "prompt": message,
      'temperature': 0,
      'max_tokens': 2000,
      'top_p': 1,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
      "stop": [" User:", " Chatbot:"]
    });
    try {
      var response =
          await http.post(Uri.parse(baseurl), headers: headers, body: body);
      if (response.statusCode == 200) {
        var result = await json.decode(response.body);
        var messageResponse = result["choices"][0]['text'];
        newText = "$newText chatbot: $messageResponse";
        chatBotMessage = messageResponse;
        // return messageResponse;
        // chatBotMessage = messageResponse.toString().split(':').last;
      }
      return response.statusCode;
    } on SocketException catch (e) {
      return 401;
    } on TimeoutException catch (e) {
      return 501;
    } catch (e) {
      return e.toString();
    }
  }
}
