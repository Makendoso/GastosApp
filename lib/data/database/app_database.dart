import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart' show Color, IconData;
import 'package:flutter/material.dart' show Icons;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/category.dart' as category_model;
import '../models/movement.dart' as finance;
import '../models/monthly_budget.dart';

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

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get icon => integer()();
  IntColumn get color => integer()();
  TextColumn get type => text().nullable()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Movements, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
        await _createMonthlyBudgetsTable();
        await seedDefaultCategories();
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(categories);
          await seedDefaultCategories();
        }
        if (from < 3) {
          await _createMonthlyBudgetsTable();
        }
      },
    );
  }

  Future<void> _createMonthlyBudgetsTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS monthly_budgets (
        month_key TEXT NOT NULL PRIMARY KEY,
        budget_limit REAL NOT NULL
      )
    ''');
  }

  Future<MonthlyBudget> getMonthlyBudget(String monthKey) async {
    await _createMonthlyBudgetsTable();

    final rows = await customSelect(
      'SELECT month_key, budget_limit FROM monthly_budgets WHERE month_key = ?',
      variables: [Variable.withString(monthKey)],
    ).get();

    if (rows.isEmpty) {
      return MonthlyBudget(monthKey: monthKey, limit: 0);
    }

    final row = rows.first;
    return MonthlyBudget(
      monthKey: row.read<String>('month_key'),
      limit: row.read<double>('budget_limit'),
    );
  }

  Future<void> saveMonthlyBudget(MonthlyBudget budget) async {
    await _createMonthlyBudgetsTable();

    await customStatement(
      '''
        INSERT INTO monthly_budgets (month_key, budget_limit)
        VALUES (?, ?)
        ON CONFLICT(month_key) DO UPDATE SET budget_limit = excluded.budget_limit
      ''',
      [budget.monthKey, budget.limit],
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

  Future<List<category_model.Category>> getCategories() async {
    final query = select(categories)
      ..orderBy([
        (table) => OrderingTerm(expression: table.sortOrder),
        (table) => OrderingTerm(expression: table.name),
      ]);
    final rows = await query.get();

    if (rows.isEmpty) {
      await seedDefaultCategories();
      return category_model.Category.defaults;
    }

    return rows.map(_categoryFromRow).toList(growable: false);
  }

  Future<void> saveCategory(category_model.Category category) {
    final sortOrder = category_model.Category.defaults.indexWhere(
      (defaultCategory) => defaultCategory.id == category.id,
    );

    return into(categories).insertOnConflictUpdate(
      CategoriesCompanion.insert(
        id: category.id,
        name: category.name,
        icon: category.icon.codePoint,
        color: category.color.value,
        type: Value(category.type?.name),
        sortOrder: sortOrder == -1
            ? category_model.Category.defaults.length
            : sortOrder,
      ),
    );
  }

  Future<void> deleteCategory(String id) {
    return (delete(categories)..where((table) => table.id.equals(id))).go();
  }

  Future<void> seedDefaultCategories() async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        categories,
        [
          for (var index = 0;
              index < category_model.Category.defaults.length;
              index++)
            CategoriesCompanion.insert(
              id: category_model.Category.defaults[index].id,
              name: category_model.Category.defaults[index].name,
              icon: category_model.Category.defaults[index].icon.codePoint,
              color: category_model.Category.defaults[index].color.value,
              type: Value(category_model.Category.defaults[index].type?.name),
              sortOrder: index,
            ),
        ],
      );
    });
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

  category_model.Category _categoryFromRow(CategoryRow row) {
    return category_model.Category(
      id: row.id,
      name: row.name,
      icon: _iconFromCodePoint(row.icon),
      color: Color(row.color),
      type: row.type == null
          ? null
          : finance.MovementType.values.firstWhere(
              (type) => type.name == row.type,
              orElse: () => finance.MovementType.expense,
            ),
    );
  }

  IconData _iconFromCodePoint(int codePoint) {
    return switch (codePoint) {
      0xe25a => Icons.fastfood,
      0xe1d5 => Icons.directions_bus,
      0xe318 => Icons.home,
      0xe305 => Icons.health_and_safety,
      0xe5e8 => Icons.sports_esports,
      0xe559 => Icons.school,
      0xe50d => Icons.receipt_long,
      _ => Icons.receipt_long,
    };
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final file = File(p.join(documentsDirectory.path, 'finance.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
