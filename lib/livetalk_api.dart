import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class LiveTalkApi {
  LiveTalkApi._();

  static final instance = LiveTalkApi._();
  Map<String, String>? _sdkInfo;

  Map<String, String>? get sdkInfo => _sdkInfo;

  Future<Map<String, dynamic>?> getConfig(String domainPbx) async {
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('https://social-network-v1-stg.omicrm.com/widget/config/get/$domainPbx'));
    request.body = json.encode({});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      final jsonData = json.decode(data);
      final payload = jsonData["payload"];
      final tentantId = payload["tenant_id"];
      final accessToken = payload["token"]["access_token"];
      final refreshToken = payload["token"]["refresh_token"];
      _sdkInfo = {
        "tenant_id": tentantId,
        "access_token": accessToken,
        "refresh_token": refreshToken,
      };
      return _sdkInfo;
    }
    return null;
  }

  Future<String?> createRoom({required Map<String, dynamic> body}) async {
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('https://social-network-v1-stg.omicrm.com/widget/new_room'));
    request.body = json.encode(body);
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      final jsonData = json.decode(data);
      final payload = jsonData["payload"];
      _sdkInfo!["uuid"] = payload["conversation"]["uuid"];
      _sdkInfo!["room_id"] = payload["conversation"]["_id"];
      _sdkInfo!["access_token"] = payload["login_token"]["access_token"];
      _sdkInfo!["refresh_token"] = payload["login_token"]["refresh_token"];
      return payload["conversation"]["_id"];
    }
    return null;
  }

  Future<bool> sendMessage({required String message}) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${_sdkInfo!["access_token"] as String}",
    };
    var request = http.Request('POST', Uri.parse('https://social-network-v1-stg.omicrm.com/widget/message/guest_send_message'));
    request.body = json.encode({
      "content": message,
      "uuid": _sdkInfo!["uuid"],
      "room_id": _sdkInfo!["room_id"],
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      final jsonData = json.decode(data);
      debugPrint(jsonData.toString());
      return true;
    }
    return false;
  }
}