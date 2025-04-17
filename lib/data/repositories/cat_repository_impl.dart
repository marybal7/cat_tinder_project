import '../../domain/models/cat.dart';
import '../../domain/repositories/cat_repository.dart';
import '../services/cat_api_service.dart';

class CatRepositoryImpl implements CatRepository {
  final CatApiService _apiService;

  CatRepositoryImpl(this._apiService);

  @override
  Future<Cat> fetchCat() async {
    return await _apiService.fetchCat();
  }
}
