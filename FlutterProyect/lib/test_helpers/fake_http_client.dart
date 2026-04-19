import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;


class FakeHttpClient implements http.Client {
  @override
  Future<http.Response> post(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
        Object? encoding,
      }) async {
    if (url.path.contains('/login')) {
      return http.Response(jsonEncode({
        'accessToken': 'token_abc',
        'refreshToken': 'token_def',
        'user': {'id': "999", 'email': 'mpreston@uninorte.edu.co'}
      }), 201);
    }

    if (body != null && body.toString().contains('error@test.com')) {
      return http.Response(jsonEncode({'message': 'Unauthorized'}), 401);
    }

    if (url.path.contains('/insert')) {
      return http.Response(jsonEncode({'status': 'ok'}), 201);
    }

    return http.Response(jsonEncode({}), 200);
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return http.Response(jsonEncode([
      {
        "userId": "999",
        "email": "mpreston@uninorte.edu.co",
        "rol": "estudiante"
      }
    ]), 200, headers: {'content-type': 'application/json; charset=UTF-8'});
  }

  @override
  void close() {
    // TODO: implement close
  }

  @override
  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) {
    // TODO: implement head
    throw UnimplementedError();
  }

  @override
  Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    // TODO: implement patch
    throw UnimplementedError();
  }

  @override
  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    // TODO: implement put
    throw UnimplementedError();
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    // TODO: implement readBytes
    throw UnimplementedError();
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // TODO: implement send
    throw UnimplementedError();
  }
}