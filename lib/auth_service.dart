import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'global.dart' as globals;

class AuthService {

  // Save token to local storage
  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Get token from local storage
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Clear token from local storage
  Future<void> clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Fetch user details using token
  Future<Map<String, dynamic>?> getUserDetails(String token) async {

    final String baseUrl = const String.fromEnvironment("url_base");
    String url = baseUrl+"/v1/auth/user/details";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        "X-User-Timezone": globals.timezone
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  bool isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }

  void decodeToken(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  }

  Duration getTokenRemainingTime(String token) {
    DateTime? expirationDate = JwtDecoder.getExpirationDate(token);
    if (expirationDate == null) {
      throw Exception("Token does not have an expiration date.");
    }
    return expirationDate.difference(DateTime.now());
  }

  bool badToken(String token) {
    bool tokenExpired = isTokenExpired(token);
    if (tokenExpired) {
    } else {
      Duration remainingTime = getTokenRemainingTime(token);
    }

    return tokenExpired;
  }


}
