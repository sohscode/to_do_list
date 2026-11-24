import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:to_do_list/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'adds a trimmed task and rejects blank input while persisting after restart',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '   Buy milk   ');
      await tester.tap(find.text('Add'));
      await tester.pump();

      expect(find.text('Buy milk'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);

      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.text('Add'));
      await tester.pump();

      expect(find.text('Please enter a task title.'), findsOneWidget);
      expect(find.text('Buy milk'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text('Add'));
      await tester.pump();

      expect(find.text('Please enter a task title.'), findsOneWidget);
      expect(find.text('Buy milk'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Buy milk'), findsOneWidget);
      expect(find.text('Please enter a task title.'), findsNothing);
    },
  );

  testWidgets('toggles and deletes tasks while keeping results after restart', (
    WidgetTester tester,
  ) async {
    final initialTasks = [
      {'id': 'task-1', 'title': 'Write report', 'isCompleted': false},
      {'id': 'task-2', 'title': 'Call mom', 'isCompleted': false},
    ];
    SharedPreferences.setMockInitialValues({
      'todo_list_tasks': jsonEncode(initialTasks),
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final toggleFinder = find.byKey(const ValueKey('task-toggle-task-1'));
    await tester.tap(toggleFinder);
    await tester.pump();

    final checkbox = tester.widget<Checkbox>(toggleFinder);
    expect(checkbox.value, isTrue);

    final otherCheckboxFinder = find.byKey(
      const ValueKey('task-toggle-task-2'),
    );
    expect(tester.widget<Checkbox>(otherCheckboxFinder).value, isFalse);

    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(toggleFinder).value, isFalse);

    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();

    final deleteFinder = find.byKey(const ValueKey('task-delete-task-2'));
    await tester.tap(deleteFinder);
    await tester.pump();

    expect(find.text('Write report'), findsOneWidget);
    expect(find.text('Call mom'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Write report'), findsOneWidget);
    expect(find.text('Call mom'), findsNothing);

    final renewedCheckbox = tester.widget<Checkbox>(
      find.byKey(const ValueKey('task-toggle-task-1')),
    );
    expect(renewedCheckbox.value, isTrue);
  });

  testWidgets(
    'shows a load error instead of an empty list and leaves stored data alone',
    (WidgetTester tester) async {
      const storedTasks =
          '[{"id":"saved","title":"Keep me","isCompleted":false}]';
      SharedPreferences.setMockInitialValues({'todo_list_tasks': storedTasks});
      final failingStorage = FailingLoadStorage();

      await tester.pumpWidget(MyApp(storage: failingStorage));
      await tester.pumpAndSettle();

      expect(find.text('Failed to load tasks.'), findsOneWidget);
      expect(find.text('No tasks yet.'), findsNothing);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('todo_list_tasks'), storedTasks);
    },
  );

  testWidgets(
    'keeps current list available when a save fails and shows an error',
    (WidgetTester tester) async {
      final failingStorage = FailingSaveStorage();

      await tester.pumpWidget(MyApp(storage: failingStorage));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '  Read book  ');
      await tester.tap(find.text('Add'));
      await tester.pump();

      expect(find.text('Read book'), findsOneWidget);
      expect(find.text('Failed to save tasks.'), findsOneWidget);
    },
  );

  testWidgets('an older successful save does not hide a newer failed save', (
    WidgetTester tester,
  ) async {
    final storage = ControlledSaveStorage();

    await tester.pumpWidget(MyApp(storage: storage));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'First');
    await tester.tap(find.text('Add'));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Second');
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(storage.pendingSaves, hasLength(2));
    final olderSave = storage.pendingSaves[0];
    final newerSave = storage.pendingSaves[1];

    // The newer save fails first.
    newerSave.completer.completeError(const FormatException('save failed'));
    await tester.pump();

    expect(find.text('Failed to save tasks.'), findsOneWidget);

    // The older save succeeds later and must not clear the error.
    olderSave.completer.complete();
    await tester.pump();

    expect(find.text('Failed to save tasks.'), findsOneWidget);
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);

    // A later successful save clears the error and keeps every task.
    await tester.enterText(find.byType(TextField), 'Third');
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(storage.pendingSaves, hasLength(3));
    final latestSave = storage.pendingSaves[2];
    latestSave.completer.complete();
    await tester.pump();

    expect(find.text('Failed to save tasks.'), findsNothing);
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    expect(find.text('Third'), findsOneWidget);
    expect(latestSave.tasks.map((task) => task.title), [
      'First',
      'Second',
      'Third',
    ]);
  });
}

class FailingLoadStorage extends TaskStorage {
  @override
  Future<List<Task>> loadTasks() async {
    throw const FormatException('load failed');
  }
}

class FailingSaveStorage extends TaskStorage {
  @override
  Future<void> saveTasks(List<Task> tasks) async {
    throw const FormatException('save failed');
  }
}

class ControlledSaveStorage extends TaskStorage {
  final pendingSaves = <PendingSave>[];

  @override
  Future<List<Task>> loadTasks() async => [];

  @override
  Future<void> saveTasks(List<Task> tasks) {
    final completer = Completer<void>();
    pendingSaves.add(PendingSave(tasks, completer));
    return completer.future;
  }
}

class PendingSave {
  PendingSave(this.tasks, this.completer);

  final List<Task> tasks;
  final Completer<void> completer;
}
