import 'package:cat_tinder/data/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cat_tinder/domain/models/cat.dart';
import 'package:cat_tinder/domain/models/liked_cat.dart';
import 'package:cat_tinder/domain/models/breed_info.dart';
import 'package:cat_tinder/presentation/providers/liked_cats_provider.dart';
import '../mocks/mocks.dart';

class FakeCat extends Fake implements Cat {}

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late MockManageLikedCatsUseCase mockUseCase;
  late MockSharedPreferences mockPrefs;
  late LikedCatsProvider provider;
  late Cat testCat;
  late List<LikedCat> likedCatsList;

  setUpAll(() {
    registerFallbackValue(FakeCat());
    GetIt.instance.registerLazySingleton<AppDatabase>(() => MockAppDatabase());
  });

  setUp(() {
    mockUseCase = MockManageLikedCatsUseCase();
    mockPrefs = MockSharedPreferences();
    likedCatsList = [];

    when(() => mockPrefs.getString('liked_cats')).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockUseCase.likedCats).thenReturn(likedCatsList);

    when(() => mockUseCase.addCat(any())).thenAnswer((invocation) {
      final cat = invocation.positionalArguments[0] as Cat;
      likedCatsList.add(LikedCat(cat: cat, likedAt: DateTime.now()));
    });
    when(() => mockUseCase.removeCatAtIndex(any())).thenAnswer((invocation) {
      final index = invocation.positionalArguments[0] as int;
      if (index < likedCatsList.length) {
        likedCatsList.removeAt(index);
      }
    });
    when(() => mockUseCase.clear()).thenAnswer((_) => likedCatsList.clear());

    provider = LikedCatsProvider(mockUseCase, mockPrefs);

    testCat = Cat(
      imageUrl: '',
      breedInfo: BreedInfo(
        name: 'Persian',
        origin: 'Iran',
        temperament: 'Calm',
        description: 'Fluffy cat',
        lifespan: '12-16 years',
      ),
    );
  });

  group('LikedCatsProvider', () {
    test('addCat adds a cat and notifies listeners', () {
      var listenerCalled = false;
      provider.addListener(() => listenerCalled = true);

      provider.addCat(testCat);

      expect(provider.likedCats, hasLength(1));
      expect(provider.likedCats[0].cat, testCat);
      expect(listenerCalled, isTrue);
      verify(() => mockUseCase.addCat(testCat)).called(1);
      verify(() => mockPrefs.setString('liked_cats', any())).called(1);
    });

    test('removeCatAtIndex removes a cat and notifies listeners', () {
      var listenerCalled = false;
      provider.addListener(() => listenerCalled = true);

      provider.addCat(testCat);
      expect(provider.likedCats, hasLength(1));

      provider.removeCatAtIndex(0);
      expect(provider.likedCats, isEmpty);
      expect(listenerCalled, isTrue);

      verify(() => mockUseCase.addCat(testCat)).called(1);
      verify(() => mockUseCase.removeCatAtIndex(0)).called(1);
      verify(() => mockPrefs.setString('liked_cats', any())).called(2);
    });

    test('clear removes all liked cats and notifies listeners', () {
      var listenerCalled = false;
      provider.addListener(() => listenerCalled = true);

      provider.addCat(testCat);
      expect(provider.likedCats, hasLength(1));

      provider.clear();
      expect(provider.likedCats, isEmpty);
      expect(listenerCalled, isTrue);

      verify(() => mockUseCase.addCat(testCat)).called(1);
      verify(() => mockUseCase.clear()).called(1);
      verify(() => mockPrefs.setString('liked_cats', any())).called(2);
    });
  });
}
