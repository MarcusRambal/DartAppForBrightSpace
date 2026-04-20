import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';


class MockApiCliente extends Mock implements http.Client {
  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    // Simulamos que el endpoint devuelve datos de estudiantes
    // Este es el objeto que debe retornar tu MockApiCliente.get()
    final mockData = [
      // estudiante 1: Promedio alto (ej. 4.5)
      {"idEvaluado": "gmrey@uninorte.edu.co", "tipo": "puntualidad", "valor_comentario": "4.5"},
      {"idEvaluado": "gmrey@uninorte.edu.co", "tipo": "contribucion", "valor_comentario": "4.5"},
      {"idEvaluado": "gmrey@uninorte.edu.co", "tipo": "actitud", "valor_comentario": "4.5"},
      {"idEvaluado": "gmrey@uninorte.edu.co", "tipo": "compromiso", "valor_comentario": "4.5"},

      // estudiante 2: Promedio bajo (ej. 2.0)
      {"idEvaluado": "mpreston@uninorte.edu.co", "tipo": "puntualidad", "valor_comentario": "2.0"},
      {"idEvaluado": "mpreston@uninorte.edu.co", "tipo": "contribucion", "valor_comentario": "2.0"},
      {"idEvaluado": "mpreston@uninorte.edu.co", "tipo": "actitud", "valor_comentario": "2.0"},
      {"idEvaluado": "mpreston@uninorte.edu.co", "tipo": "compromiso", "valor_comentario": "2.0"},

      // estudiante 3: Promedio neutro (ej. 3.0)
      {"idEvaluado": "acoronellm@uninorte.edu.co", "tipo": "puntualidad", "valor_comentario": "3.0"},
      {"idEvaluado": "acoronellm@uninorte.edu.co", "tipo": "contribucion", "valor_comentario": "3.0"},
      {"idEvaluado": "acoronellm@uninorte.edu.co", "tipo": "actitud", "valor_comentario": "3.0"},
      {"idEvaluado": "acoronellm@uninorte.edu.co", "tipo": "compromiso", "valor_comentario": "3.0"},

      // estudiante 4: No lo incluimos para probar el estado "Pendiente"
    ];
    return http.Response(jsonEncode(mockData), 200);
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
  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    // TODO: implement post
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