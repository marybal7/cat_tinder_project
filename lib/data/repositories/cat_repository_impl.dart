import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/models/cat.dart';
import '../../domain/repositories/cat_repository.dart';
import '../services/cat_api_service.dart';
import '../database.dart' as db;

class CatRepositoryImpl implements CatRepository {
  final CatApiService _apiService;
  final db.AppDatabase _database;
  final Connectivity _connectivity;

  CatRepositoryImpl(this._apiService, this._database, this._connectivity);

  @override
  Future<Cat> fetchCat() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      try {
        final cat = await _apiService.fetchCat();
        Uint8List? imageData;
        try {
          final response = await http
              .get(Uri.parse(cat.imageUrl))
              .timeout(const Duration(seconds: 5));
          if (response.statusCode == 200) {
            imageData = response.bodyBytes;
            debugPrint('Successfully loaded image for ${cat.imageUrl}');
          } else {
            debugPrint(
              'Failed to load image for ${cat.imageUrl}: Status code ${response.statusCode}',
            );
            throw Exception('Failed to load image');
          }
        } catch (e) {
          debugPrint('Failed to load image for ${cat.imageUrl}: $e');
          throw Exception('Failed to load image');
        }
        await _database.insertCat(cat, imageData: imageData);
        debugPrint('Inserted cat: ${cat.imageUrl}');
        return cat;
      } catch (e) {
        debugPrint('API error: $e');
        final cats = await _database.getAllCats();
        debugPrint('Fetched ${cats.length} cats from database');
        if (cats.isNotEmpty) {
          final validCats = cats.where((cat) => cat.imageData != null).toList();
          if (validCats.isNotEmpty) {
            final random = Random();
            return validCats[random.nextInt(validCats.length)];
          }
        }
        throw Exception('No internet and no cached cats available');
      }
    } else {
      final cats = await _database.getAllCats();
      debugPrint('Offline mode: Fetched ${cats.length} cats from database');
      if (cats.isNotEmpty) {
        final validCats = cats.where((cat) => cat.imageData != null).toList();
        debugPrint('Offline mode: Found ${validCats.length} cats with images');
        if (validCats.isNotEmpty) {
          final random = Random();
          return validCats[random.nextInt(validCats.length)];
        }
      }
      throw Exception('No internet and no cached cats available');
    }
  }
}
