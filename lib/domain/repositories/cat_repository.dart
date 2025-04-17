import '../models/cat.dart';

abstract class CatRepository {
  Future<Cat> fetchCat();
}
