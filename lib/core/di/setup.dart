import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/cat_repository_impl.dart';
import '../../data/services/cat_api_service.dart';
import '../../domain/repositories/cat_repository.dart';
import '../../domain/usecases/fetch_cat_usecase.dart';
import '../../domain/usecases/manage_liked_cats.dart';
import '../../presentation/providers/liked_cats_provider.dart';
import '../../data/database.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Register services
  getIt.registerSingleton<CatApiService>(CatApiService());
  getIt.registerSingleton<Connectivity>(Connectivity());
  getIt.registerSingleton<AppDatabase>(AppDatabase());
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);

  // Register repositories
  getIt.registerSingleton<CatRepository>(
    CatRepositoryImpl(
      getIt<CatApiService>(),
      getIt<AppDatabase>(),
      getIt<Connectivity>(),
    ),
  );

  // Register use cases
  getIt.registerSingleton<FetchCatUseCase>(
    FetchCatUseCase(getIt<CatRepository>()),
  );
  getIt.registerSingleton<ManageLikedCatsUseCase>(ManageLikedCatsUseCase());

  // Register providers
  getIt.registerFactory<LikedCatsProvider>(
    () => LikedCatsProvider(
      getIt<ManageLikedCatsUseCase>(),
      getIt<SharedPreferences>(),
    ),
  );
}
