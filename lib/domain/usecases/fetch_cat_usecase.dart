import '../models/cat.dart';
import '../repositories/cat_repository.dart';

class FetchCatUseCase {
  final CatRepository _repository;

  FetchCatUseCase(this._repository);

  Future<Cat> execute() async {
    return await _repository.fetchCat();
  }
}
