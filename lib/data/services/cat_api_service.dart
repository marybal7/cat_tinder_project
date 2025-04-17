import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/models/cat.dart';

class CatApiService {
  static const _baseUrl =
      'https://api.thecatapi.com/v1/images/search?has_breeds=1';
  final String? _apiKey = dotenv.env['CAT_API_KEY'];

  Future<Cat> fetchCat() async {
    if (_apiKey == null) {
      throw Exception('API key is missing');
    }

    final url = Uri.parse("$_baseUrl&api_key=$_apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isEmpty) {
        throw Exception('No cat data received from API');
      }
      try {
        return Cat.fromJson(data[0]);
      } catch (e) {
        throw Exception('Failed to parse cat data: $e');
      }
    } else {
      throw Exception('Failed to load cat (${response.statusCode})');
    }
  }
}
