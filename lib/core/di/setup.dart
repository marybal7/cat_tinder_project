import 'package:get_it/get_it.dart';
import '../../data/repositories/cat_repository_impl.dart';
import '../../data/services/cat_api_service.dart';
import '../../domain/repositories/cat_repository.dart';
import '../../domain/usecases/fetch_cat_usecase.dart';
import '../../domain/usecases/manage_liked_cats.dart';
import '../../presentation/providers/liked_cats_provider.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Register services
  getIt.registerSingleton<CatApiService>(CatApiService());

  // Register repositories
  getIt.registerSingleton<CatRepository>(
    CatRepositoryImpl(getIt<CatApiService>()),
  );

  // Register use cases
  getIt.registerSingleton<FetchCatUseCase>(
    FetchCatUseCase(getIt<CatRepository>()),
  );
  getIt.registerSingleton<ManageLikedCatsUseCase>(ManageLikedCatsUseCase());

  // Register providers
  getIt.registerFactory<LikedCatsProvider>(
    () => LikedCatsProvider(getIt<ManageLikedCatsUseCase>()),
  );
}
