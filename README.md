# To-Do List

A single-screen Flutter to-do app. You can add tasks, mark them complete or
incomplete, delete them, and keep them after closing and reopening the app.
Data is stored only on the device with `shared_preferences`. There is no
account, backend, or network use.

## Requirements

- Flutter SDK with Dart `^3.13.3` (the constraint in `pubspec.yaml`).
- Check with `flutter --version` and `flutter doctor`.

## Setup

From a fresh clone:

```bash
git clone <repo-url>
cd to_do_list
flutter pub get
```

## Run

```bash
flutter run
```

Pick a device or emulator when Flutter asks. Persistence can be checked by
adding tasks, closing the app completely, and opening it again.

## Test and verify

```bash
flutter analyze
flutter test test/widget_test.dart
dart format --output=none --set-exit-if-changed .
```

The widget tests cover:

- adding a trimmed title and rejecting empty or whitespace-only titles;
- keeping tasks after the app is rebuilt;
- toggling and deleting only the selected task;
- showing an error instead of an empty list when loading fails;
- keeping the in-memory list and showing an error when saving fails;
- overlapping saves, where an older successful save must not hide a newer
  failed save, and a later successful save clears the error.

### Last recorded results

Fill this in from your own run before submitting:

| Command | Result |
| --- | --- |
| `flutter pub get` | _(paste result)_ |
| `flutter analyze` | _(paste result)_ |
| `flutter test test/widget_test.dart` | _(paste result)_ |
| Persistence after closing and reopening (device/emulator) | _(paste result)_ |

## Save behavior

Each change (add, complete or reopen, delete) updates the in-memory list
first and then saves the whole list. Every save gets a request number. Only the
most recent save can show or clear the "Failed to save tasks." message, so an
older save that finishes late cannot hide a newer failure. The in-memory list
always keeps the latest changes.

## Spec Kit

This project uses Spec Kit for planning. The feature docs are in
`specs/001-todo-list-app/`:

- `spec.md`: requirements and acceptance criteria
- `plan.md`: technical plan and constitution checks
- `tasks.md`: implementation tasks
- `research.md`, `data-model.md`, `contracts/ui.md`, `quickstart.md`: supporting
  design notes
- `checklists/requirements.md`: spec quality checklist

The active feature is selected in `.specify/feature.json`:

```json
{
  "feature_directory": "specs/001-todo-list-app"
}
```

Project principles are in `.specify/memory/constitution.md`. The constitution
keeps the app simple. It does not allow Clean Architecture layers, a repository
pattern, Cubit or Bloc, or Hive.
