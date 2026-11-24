---
description: "Implementation tasks for the Simple To-Do List Application"
---

# Tasks: Simple To-Do List Application

**Input**: Design documents from `/specs/001-todo-list-app/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/ui.md`

**Organization**: Tasks are grouped by user story to enable incremental implementation and validation. Widget tests are included because the project constitution requires validation of core task behavior.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story label for story-phase tasks
- Each task names the exact project file(s) to change or validate.

## Phase 1: Setup

**Purpose**: Add the planned local storage dependency to the existing Flutter app.

- [X] T001 Add `shared_preferences` to `dependencies` in `pubspec.yaml` and resolve the dependency into `pubspec.lock`.

---

## Phase 2: Foundational

**Purpose**: Provide the shared task representation and local persistence used by both user stories.

- [X] T002 Implement task record serialization and local preference load/save logic in `lib/main.dart`, including startup loading, awaited mutation writes, and explicit handling of persistence failures.

**Checkpoint**: Shared task data and persistence are ready for both user stories.

---

## Phase 3: User Story 1 - Add Tasks (Priority: P1) 🎯 MVP

**Goal**: Show the single-screen task list and let the user add valid titles while rejecting blank input.

**Independent Test**: Add a non-empty task and confirm it appears exactly once and persists after app reconstruction; submit empty and whitespace-only titles and confirm neither creates a task.

### Tests for User Story 1

- [X] T003 [US1] Replace the generated counter test with widget tests for adding a trimmed non-empty title, rejecting empty and whitespace-only titles, retaining an added task after app reconstruction, and handling load failure by showing an error instead of an empty list without clearing or overwriting stored task data in `test/widget_test.dart`.

### Implementation for User Story 1

- [X] T004 [US1] Implement the single-screen task entry, add action, task list, empty-list state, and blank-title validation in `lib/main.dart`; clear the entry after a valid add and persist the new task.

**Checkpoint**: User Story 1 supports adding and displaying tasks, rejects invalid titles, and retains additions locally.

---

## Phase 4: User Story 2 - Manage Tasks (Priority: P1)

**Goal**: Allow the user to mark individual tasks complete or incomplete and delete tasks, retaining each change after restart.

**Independent Test**: With a task available in the list, toggle it complete and incomplete, then delete it; confirm only the selected task changes and that completion/deletion results persist after app reconstruction.

### Tests for User Story 2

- [X] T005 [US2] Add widget tests for toggling only the selected task, deleting only the selected task, retaining the completion/deletion results after app reconstruction, and confirming that a failed save keeps the current in-memory task list available and shows an error in `test/widget_test.dart`.

### Implementation for User Story 2

- [X] T006 [US2] Add per-task completion and delete controls in `lib/main.dart`; update only the task identified by its stable ID and persist each state change.

**Checkpoint**: User Story 2 supports completing, reopening, and deleting tasks with local persistence.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Validate the complete MVP against its design and quality constraints.

- [X] T007 Run `flutter test test/widget_test.dart` and `flutter analyze` from the project root; resolve any issues in `lib/main.dart` and `test/widget_test.dart`.
  - Manually confirm the app remains a single-screen, local-only app with no login, backend, notifications, categories, deadlines, search, or filters.

---

## Phase 6: Save Reliability (Review Follow-up)

**Purpose**: Ensure an older save result cannot hide a newer save failure, and document the workflow.

- [X] T008 [US2] Add a deterministic widget regression test in `test/widget_test.dart` that controls completion order of two overlapping saves: newer fails, older succeeds, error stays visible, then a later successful save clears it while all tasks remain visible.
- [X] T009 [US2] Fix overlapping save result handling in `lib/main.dart` with `SaveRequestTracker`, so only the most recent save request updates the save-error indicator.
- [X] T010 Add `README.md` (setup, run, test, format, Spec Kit feature selection), run `dart format`, `flutter pub get`, `flutter analyze`, and `flutter test`, and record actual results in `README.md`. Verify persistence on a device or emulator if available.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; start immediately.
- **Foundational (Phase 2)**: Depends on T001 completing so `shared_preferences` is available; blocks both user stories.
- **User Story 1 (Phase 3)**: Depends on T002; delivers task entry and list presentation.
- **User Story 2 (Phase 4)**: Depends on T002 and the list presentation from US1 (T004).
- **Polish (Phase 5)**: Depends on both stories being implemented.

### User Story Dependencies

- **US1 (P1)**: Starts after the foundation; independent of other stories.
- **US2 (P1)**: Starts after the foundation and US1 task-list presentation; its controls act on tasks displayed by US1.

### Within Each User Story

- Write the focused widget tests before implementing the corresponding interactions.
- Keep implementation in `lib/main.dart` and interaction coverage in `test/widget_test.dart`.
- Complete US1 before US2 because US2's task controls operate on the list rendered by US1.

### Parallel Opportunities

- There are no parallelizable implementation tasks in this plan: dependency setup, shared persistence, and story work have direct prerequisites, and each story's test and implementation tasks intentionally run test-first.
- Once the foundation is complete, US1 work can begin; US2 follows the list presentation.

---

## Parallel Example: User Story 1

US1 tasks both modify or validate `test/widget_test.dart` and `lib/main.dart` in test-first order, so they should be completed sequentially rather than run in parallel.

## Implementation Strategy

### MVP First (User Story 1)

1. Complete T001 and T002 for dependency setup and shared task persistence.
2. Complete T003 and T004 to deliver task entry, listing, blank-input rejection, and persistence.
3. Validate US1 independently before proceeding.

### Incremental Delivery

1. Complete the shared setup and foundation.
2. Deliver US1 as the first usable increment.
3. Add US2 completion and deletion behavior and its persistence coverage.
4. Run the focused widget tests and analyzer.
