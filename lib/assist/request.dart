import 'dart:convert';
import 'package:http/http.dart' as http;

class Request{
  // Making http request and converting result into json
  static Future<dynamic> makeRequest(String url) async {
    http.Response response = await http.get(Uri.parse(url));

    try {
      if (response.statusCode == 200){
        String jsonData = response.body;
        var decode = jsonDecode(jsonData);
        return decode;
      }
      else {
        return "Failed";
      }
    }
    catch (exp){
      return "Failed";
    }
  }
}