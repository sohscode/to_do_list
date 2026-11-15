# Quickstart: Simple To-Do List Application

## Prerequisites

- Flutter SDK installed, with a Dart SDK satisfying the constraint in `pubspec.yaml`.
- A configured Flutter target (Android, iOS, web, Linux, macOS, or Windows) for manual app interaction.

## Validate

From the project root:

```sh
flutter pub get
flutter test test/widget_test.dart
flutter analyze
```

Expected: dependencies resolve, the focused widget tests pass, and the analyzer reports no issues.

## Manual persistence scenario

1. Run the app with `flutter run` on a configured target.
2. Add a task with a non-whitespace title. Confirm it appears once.
3. Submit an empty title and a whitespace-only title. Confirm neither adds a task.
4. Toggle the task complete, then incomplete. Confirm each state is shown on that task.
5. Add another task and delete the first one. Confirm only the first task disappears.
6. Close and relaunch the app. Confirm the remaining task and its completion state are retained.

See [data-model.md](data-model.md) for task fields and state transitions and [contracts/ui.md](contracts/ui.md) for the single-screen interaction contract.
