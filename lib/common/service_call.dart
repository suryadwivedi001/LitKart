import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:online_groceries/view_model/splash_view_model.dart';

typedef ResSuccess = Future<void> Function(Map<String, dynamic>);
typedef ResFailure = Future<void> Function(dynamic);

class ServiceCall {
 

  static void post(Map<String, dynamic> parameter, String path,
      {bool isToken = false, ResSuccess? withSuccess, ResFailure? failure}) {
    Future(() {
      try {
        var headers = {'Content-Type': 'application/x-www-form-urlencoded'};

        if(isToken) {
          var token = Get.find<SplashViewModel>().userPayload.value.authToken;
          headers["access_token"] = token ?? "";
          print("🔐 Token: $token");

        }
                // 🟦 PRINT: Log API call details
        print("📤 POST to $path");
        print("📦 Parameters: $parameter");
        print("🔐 Headers: $headers");

        http
            .post(Uri.parse(path), body: parameter, headers: headers)
            .then((value) {
          print("📥 Status Code: ${value.statusCode}");
          print("📥 Response Body: ${value.body}");
          if (kDebugMode) {
            print(value.body);
          }
          try {
            var jsonObj =
                json.decode(value.body) as Map<String, dynamic>? ?? {};
                print("✅ Parsed JSON: $jsonObj");


            if (withSuccess != null) withSuccess(jsonObj);
          } catch (err) {
            if (failure != null) failure(err.toString());
              print("❌ JSON Parsing Error: $err");

          }
        }).catchError((e) {
          if (failure != null) failure(e.toString());
          print("❌ HTTP Error: $e");

        });
      } catch (err) {
        if (failure != null) failure(err.toString());
        print("❌ Outer Try-Catch Error: $err");
      }
    });
  }
}
