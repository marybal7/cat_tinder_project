import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import '../../domain/models/cat.dart';
import '../../domain/models/breed_info.dart';

part 'database.g.dart';

@DataClassName('CatEntity')
class Cats extends Table {
  TextColumn get id => text()();
  TextColumn get imageUrl => text()();
  BlobColumn get imageData => blob().nullable()();
  TextColumn get breedName => text()();
  TextColumn get origin => text()();
  TextColumn get temperament => text()();
  TextColumn get description => text()();
  TextColumn get lifespan => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Cats])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(cats, cats.imageData);
      }
    },
  );

  Future<List<Cat>> getAllCats() async {
    final catEntities = await select(cats).get();
    return catEntities
        .map(
          (e) => Cat(
            imageUrl: e.imageUrl,
            imageData: e.imageData,
            breedInfo: BreedInfo(
              name: e.breedName,
              origin: e.origin,
              temperament: e.temperament,
              description: e.description,
              lifespan: e.lifespan,
            ),
          ),
        )
        .toList();
  }

  Future<void> insertCat(Cat cat, {Uint8List? imageData}) async {
    await into(cats).insert(
      CatsCompanion(
        id: Value(cat.imageUrl),
        imageUrl: Value(cat.imageUrl),
        imageData: Value(imageData),
        breedName: Value(cat.breedInfo.name),
        origin: Value(cat.breedInfo.origin),
        temperament: Value(cat.breedInfo.temperament),
        description: Value(cat.breedInfo.description),
        lifespan: Value(cat.breedInfo.lifespan),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> clearCats() async {
    await delete(cats).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'cats.sqlite'));
    return NativeDatabase(file);
  });
}
