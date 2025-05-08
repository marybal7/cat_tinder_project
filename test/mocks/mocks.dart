import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cat_tinder/domain/usecases/manage_liked_cats.dart';

class MockManageLikedCatsUseCase extends Mock
    implements ManageLikedCatsUseCase {}

class MockSharedPreferences extends Mock implements SharedPreferences {}
