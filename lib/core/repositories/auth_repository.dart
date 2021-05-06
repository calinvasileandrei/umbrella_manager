import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:umbrella_manager/core/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

class AuthRepository {
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    "Access-Control-Allow-Origin": "*", // Required for CORS support to work
    "Access-Control-Allow-Credentials": 'true', // Required for cookies, authorization headers with HTTPS
    "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
    "Access-Control-Allow-Methods": "*"
  };

  Future<User> authenticate({
    @required String email,
    @required String password,
  }) async {
    var body={
      'email':email,
      'password':password
    };

    /*
    return User.fromMapAPI({
      "email": "vifla01@gmail.com",
      "password": null,
      "role": null,
      "firstName": "flaminio",
      "lastName": "villa",
      "regionId": null,
      "callUser": null
    },'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ2aWZsYTAxQGdtYWlsLmNvbSIsImF1dGgiOiJST0xFX0FETUlOLFJPTEVfQURNSU5fU0VDUkVUQVJZLFJPTEVfU0VDUkVUQVJZLFJPTEVfVVNFUiIsImV4cCI6MTYyMDI5MjU3N30.Oxb-5wA4xLC7naICzHFC7n9csg3kh-Y3AojamJrz0SkCBtWLDMsvDkc1axS4IO2gYeMecZNtwxiXC4wHbh-TvA');
    */

    try {
      final authResponse = await http.post(
          DotEnv.env["BACKEND_URL"] + "api/authenticate",
          headers: headers,
          body: json.encode(body));

      if (authResponse.statusCode == 200) {
        Map<String,dynamic> bodyParsed = json.decode(authResponse.body);
        return User.fromMapAPI(bodyParsed['user'],bodyParsed['id_token']);
      }
    } catch (err) {
      return null;
    }
    return null;
  }

  Future<void> deleteUser() async {
    /// delete from keystore/keychain
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    return;
  }

  Future<void> persistUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user', user.toJson());
    return;
  }

  Future<User> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userRaw =prefs.getString('user');
    if(userRaw != null){
      return User.fromJson(userRaw);
    }

    return null;
  }
}
