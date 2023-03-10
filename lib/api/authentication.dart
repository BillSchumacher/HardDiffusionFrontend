import 'package:flutter/foundation.dart';
import 'package:hard_diffusion/api/network_service.dart';
import 'package:hard_diffusion/main.dart';

class TokenPair {
  final String accessToken;
  final String refreshToken;

  const TokenPair(this.accessToken, this.refreshToken);

  factory TokenPair.fromJson(Map<String, dynamic> json) {
    return TokenPair(json['access'], json['refresh']);
  }
}

class AccessToken {
  final String accessToken;

  const AccessToken(this.accessToken);

  factory AccessToken.fromJson(Map<String, dynamic> json) {
    return AccessToken(json['access']);
  }
}

Future<TokenPair> fetchTokens(String username, String password) async {
  var map = new Map<String, dynamic>();
  map["username"] = username;
  map["password"] = password;
  var ns = NetworkService();
  final response = await ns.post('$apiHost/api/v1/token/', body: map);
  TokenPair tokenPair = await compute(parseTokens, response);
  ns.updateTokenPair(tokenPair);
  return tokenPair;
}

Future<AccessToken> refreshAccess() async {
  var map = new Map<String, dynamic>();
  var ns = NetworkService();
  map["refresh"] = ns.refreshToken;
  final response = await ns.post('$apiHost/api/v1/token/refresh/', body: map);
  AccessToken accessToken = await compute(parseAccessToken, response);
  ns.updateAccessToken(accessToken.accessToken);
  return accessToken;
}

TokenPair parseTokens(dynamic jsonResponse) {
  return TokenPair.fromJson(jsonResponse);
}

AccessToken parseAccessToken(dynamic jsonResponse) {
  return AccessToken.fromJson(jsonResponse);
}

class TokenRefreshException implements Exception {
  String cause;
  TokenRefreshException(this.cause);
}

class BadRequestException implements Exception {
  String cause;
  BadRequestException(this.cause);
}

class UnauthorizedException implements Exception {
  String cause;
  UnauthorizedException(this.cause);
}
/*
Example code, from https://flutter.dev/docs/cookbook/networking/fetch-data
Future<Album> fetchAlbum() async {
  final response = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));
  /*
        // Send authorization headers to the backend.
  headers: {
    HttpHeaders.authorizationHeader: 'Basic your_api_token_here',
  },
      */
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  final int userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}*/
