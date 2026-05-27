import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/movement.dart' as finance;

part 'app_database.g.dart';

@DataClassName('MovementRow')
class Movements extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()();
  TextColumn get category => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Movements])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
    );
  }

  Future<List<finance.Movement>> getMovements() async {
    final query = select(movements)
      ..orderBy([
        (table) => OrderingTerm(
              expression: table.date,
              mode: OrderingMode.desc,
            ),
      ]);
    final rows = await query.get();

    return rows.map(_movementFromRow).toList(growable: false);
  }

  Future<void> saveMovement(finance.Movement movement) {
    return into(movements).insertOnConflictUpdate(
      MovementsCompanion.insert(
        id: movement.id,
        title: movement.title,
        amount: movement.amount.abs(),
        type: movement.type.name,
        category: movement.category,
        date: movement.date,
        note: Value(movement.note),
      ),
    );
  }

  Future<void> deleteMovement(String id) {
    return (delete(movements)..where((table) => table.id.equals(id))).go();
  }

  finance.Movement _movementFromRow(MovementRow row) {
    return finance.Movement(
      id: row.id,
      title: row.title,
      amount: row.amount,
      type: finance.MovementType.values.firstWhere(
        (type) => type.name == row.type,
        orElse: () => finance.MovementType.expense,
      ),
      category: row.category,
      date: row.date,
      note: row.note,
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final file = File(p.join(documentsDirectory.path, 'finance.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
