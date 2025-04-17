import '../models/cat.dart';
import '../models/liked_cat.dart';
import '../repositories/liked_cat_repository.dart';

class ManageLikedCatsUseCase implements LikedCatsRepository {
  final List<LikedCat> _likedCats = [];

  @override
  List<LikedCat> get likedCats => _likedCats;

  @override
  void addCat(Cat cat) {
    _likedCats.add(LikedCat(cat: cat, likedAt: DateTime.now()));
  }

  @override
  void removeCatAtIndex(int index) {
    _likedCats.removeAt(index);
  }

  @override
  void clear() {
    _likedCats.clear();
  }
}
