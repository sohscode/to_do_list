# Research: Simple To-Do List Application

## Local persistence

**Decision**: Use Flutter's `shared_preferences` plugin to store the small task collection locally as serialized records. Await reads before showing the loaded list and await writes after each add, completion change, or delete.

**Rationale**: The app stores a small amount of data on one device, requires no querying or synchronization, and targets the Flutter platforms already scaffolded in the repository. Flutter's persistence guidance recommends key-value storage for small amounts of simple local data and identifies `shared_preferences` as the supported plugin. The plugin's supported platforms include Android, iOS, Linux, macOS, web, and Windows.

**Alternatives considered**:

- On-device SQLite is appropriate for larger or query-heavy structured data, but adds database setup and schema handling unnecessary for this MVP.
- A custom file-based store would require platform-aware file paths and additional failure/atomic-write handling, with no MVP benefit over the cross-platform plugin.
- A cloud database conflicts with the explicit no-backend, no-account, and one-device requirements.

**Reliability consideration**: `shared_preferences` is intended for simple, non-critical data and its documentation does not guarantee that data has been flushed to disk when a write completes. This is a known limitation of the simplest cross-platform choice; writes must still be awaited and normal close/reopen persistence must be tested. A future requirement for stronger durability would justify reconsidering SQLite.

## Task input and state

**Decision**: Trim a submitted title for validation and storage; reject it if the trimmed result is empty. Each task has a stable local identifier, title, and completion flag. Toggle and delete by identifier so an operation changes only the selected task.

**Rationale**: This directly implements the specification's whitespace rule and makes state changes unambiguous without categories, deadlines, or other fields.

## Testing approach

**Decision**: Use Flutter widget tests to exercise the screen's add, blank-input rejection, completion toggle, and delete behavior, with the preferences test support to verify values survive reconstruction/reload. Run the existing test target and analyzer.

**Rationale**: The repository is a Flutter app with `flutter_test` already configured. These checks align with the constitution's requirement to validate the primary flows and avoid adding test frameworks.

## References

- Flutter, [Store key-value data on disk](https://docs.flutter.dev/cookbook/persistence/key-value): recommends `shared_preferences` for a relatively small collection of key-values; documents supported types, read/write APIs, mock test support, and the durability limitation.
- Flutter, [Choose a database for your Flutter app](https://docs.flutter.dev/data-and-backend/persistence/choose-a-database): compares local SQLite and key-value storage and their intended data shapes.
- [`shared_preferences` on pub.dev](https://pub.dev/packages/shared_preferences): supported Flutter platforms, data types, and current API guidance.
