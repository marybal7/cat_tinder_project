import 'dart:convert';
import 'package:cat_tinder/domain/models/breed_info.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/cat.dart';
import '../../domain/models/liked_cat.dart';
import '../../domain/usecases/manage_liked_cats.dart';
import '../../data/database.dart' as db;
import '../../core/di/setup.dart';

class LikedCatsProvider extends ChangeNotifier {
  final ManageLikedCatsUseCase _useCase;
  final SharedPreferences _prefs;
  final db.AppDatabase _database = getIt<db.AppDatabase>();

  LikedCatsProvider(this._useCase, this._prefs) {
    _loadLikedCats();
  }

  List<LikedCat> get likedCats => _useCase.likedCats;

  void addCat(Cat cat) {
    _useCase.addCat(cat);
    _saveLikedCats();
    notifyListeners();
  }

  void removeCatAtIndex(int index) {
    _useCase.removeCatAtIndex(index);
    _saveLikedCats();
    notifyListeners();
  }

  void clear() {
    _useCase.clear();
    _saveLikedCats();
    notifyListeners();
  }

  void _saveLikedCats() {
    final List<Map<String, dynamic>> likedCatsJson =
        likedCats.map((likedCat) {
          return {
            'cat': {
              'url': likedCat.cat.imageUrl,
              'breeds': [
                {
                  'name': likedCat.cat.breedInfo.name,
                  'origin': likedCat.cat.breedInfo.origin,
                  'temperament': likedCat.cat.breedInfo.temperament,
                  'description': likedCat.cat.breedInfo.description,
                  'life_span': likedCat.cat.breedInfo.lifespan,
                },
              ],
            },
            'likedAt': likedCat.likedAt.toIso8601String(),
          };
        }).toList();
    _prefs.setString('liked_cats', json.encode(likedCatsJson));
  }

  void _loadLikedCats() {
    try {
      final String? likedCatsString = _prefs.getString('liked_cats');
      if (likedCatsString != null) {
        final List<dynamic> likedCatsJson = json.decode(likedCatsString);
        final loadedCats =
            likedCatsJson.map((json) {
              final cat = Cat.fromJson(json['cat']);
              final likedAt = DateTime.parse(json['likedAt']);
              return LikedCat(cat: cat, likedAt: likedAt);
            }).toList();
        for (var likedCat in loadedCats) {
          _useCase.addCat(likedCat.cat);
        }
      }
    } catch (e) {
      debugPrint('Error loading liked cats: $e');
      _prefs.remove('liked_cats');
    }
  }

  Future<Cat?> getCatByImageUrl(String imageUrl) async {
    final cats = await _database.getAllCats();
    return cats.firstWhere(
      (cat) => cat.imageUrl == imageUrl,
      orElse:
          () => Cat(
            imageUrl: imageUrl,
            breedInfo: BreedInfo(
              name: 'Unknown',
              origin: 'Unknown',
              lifespan: '',
              temperament: '',
              description: '',
            ),
            imageData: null,
          ),
    );
  }
}
