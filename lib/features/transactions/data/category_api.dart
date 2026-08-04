import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../models/category.dart';

class CategoryApi {
  final http.Client _client;

  CategoryApi({
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<List<Category>> getCategories() async {

    final response = await _client.get(
      Uri.parse(
        '${AppConfig.apiBaseUrl}/categories',
      ),
    );


    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar categorias',
      );
    }

    final List data = jsonDecode(response.body);

    return data.map((item) => Category.fromJson(item),).toList();
  }
  
}