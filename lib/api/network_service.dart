import 'dart:convert';
import 'package:hard_diffusion/api/authentication.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  static final NetworkService _singleton = NetworkService._internal();

  factory NetworkService() {
    return _singleton;
  }

  NetworkService._internal();
  final JsonDecoder _decoder = JsonDecoder();
  final JsonEncoder _encoder = JsonEncoder();
  String accessToken = '';
  String refreshToken = '';
  int refreshAttempts = 0;
  Map<String, String> headers = {}; //{"content-type": "text/json"};
  Map<String, String> cookies = {};
  void updateTokenPair(TokenPair tokenPair) {
    accessToken = tokenPair.accessToken;
    headers['Authorization'] = 'Bearer $accessToken';
    refreshToken = tokenPair.refreshToken;
  }

  void updateAccessToken(String token) {
    accessToken = token;
    headers['Authorization'] = 'Bearer $token';
  }

  void updateRefreshToken(String token) {
    refreshToken = token;
  }

  void _updateCookie(http.Response response) {
    String? allSetCookie = response.headers['set-cookie'];

    if (allSetCookie != null) {
      var setCookies = allSetCookie.split(',');

      for (var setCookie in setCookies) {
        var cookies = setCookie.split(';');

        for (var cookie in cookies) {
          _setCookie(cookie);
        }
      }

      headers['cookie'] = _generateCookieHeader();
    }
  }

  void _setCookie(String rawCookie) {
    if (rawCookie.length > 0) {
      var keyValue = rawCookie.split('=');
      if (keyValue.length == 2) {
        var key = keyValue[0].trim();
        var value = keyValue[1];

        // ignore keys that aren't cookies
        if (key == 'path' || key == 'expires') return;

        this.cookies[key] = value;
      }
    }
  }

  String _generateCookieHeader() {
    String cookie = "";

    for (var key in cookies.keys) {
      if (cookie.length > 0) cookie += ";";
      cookie += key + "=" + cookies[key]!;
    }

    return cookie;
  }

  Future<dynamic> get(String url) {
    return http
        .get(Uri.parse(url), headers: headers)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      _updateCookie(response);
      if (statusCode == 403) {
        if (refreshAttempts < 3) {
          refreshAttempts++;
          return refreshAccess().then((value) {
            return get(url);
          });
        } else {
          refreshAttempts == 0;
          throw new TokenRefreshException(
              "Refresh token expired, please login again");
        }
      }
      if (statusCode == 400) {
        throw new BadRequestException("Error while fetching data");
      } else if (statusCode == 401) {
        throw new UnauthorizedException("Bad credentials, please try again.");
      } else if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      try {
        return _decoder.convert(res);
      } catch (e) {
        return res;
      }
    });
  }

  Future<dynamic> post(String url, {body, encoding}) {
    return http
        .post(Uri.parse(url), body: body, headers: headers, encoding: encoding)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      _updateCookie(response);
      print(statusCode);
      if (statusCode == 403) {
        if (refreshAttempts < 3) {
          refreshAttempts++;
          return refreshAccess().then((value) {
            return post(url, body: body, encoding: encoding);
          });
        } else {
          refreshAttempts = 0;
          throw new TokenRefreshException(
              "Refresh token expired, please login again");
        }
      }
      if (statusCode == 400) {
        throw new BadRequestException("Error while fetching data");
      } else if (statusCode == 401) {
        throw new UnauthorizedException("Bad credentials, please try again.");
      } else if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }
}
