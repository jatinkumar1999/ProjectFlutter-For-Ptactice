import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:project_flutter/modals/users_modal.dart';

class HttpServices {
  UserData? userData;
  Future<UserData?> getDogsImagswithApi({int? pages}) async {
    String url = "https://reqres.in/api/users?page=$pages";
    final response = await http.get(Uri.parse(url));
    print("===>>${response.body}");
    if (response.statusCode == 200) {
      return userData = UserData.fromJson(json.decode(response.body));
    }
  }
}
