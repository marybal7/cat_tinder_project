import '../models/cat.dart';
import '../models/liked_cat.dart';

abstract class LikedCatsRepository {
  List<LikedCat> get likedCats;
  void addCat(Cat cat);
  void removeCatAtIndex(int index);
  void clear();
}
