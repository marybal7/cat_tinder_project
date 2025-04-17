import 'package:flutter/material.dart';
import '../../domain/models/cat.dart';
import '../../domain/models/liked_cat.dart';
import '../../domain/usecases/manage_liked_cats.dart';

class LikedCatsProvider extends ChangeNotifier {
  final ManageLikedCatsUseCase _useCase;

  LikedCatsProvider(this._useCase);

  List<LikedCat> get likedCats => _useCase.likedCats;

  void addCat(Cat cat) {
    _useCase.addCat(cat);
    notifyListeners();
  }

  void removeCatAtIndex(int index) {
    _useCase.removeCatAtIndex(index);
    notifyListeners();
  }

  void clear() {
    _useCase.clear();
    notifyListeners();
  }
}
