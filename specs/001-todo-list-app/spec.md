# Feature Specification: Simple To-Do List Application

**Feature Branch**: `001-todo-list-app`

**Created**: 2026-11-15

**Status**: Draft

**Input**: User description: "Create a very simple single-screen to-do list application to add non-empty tasks, mark tasks completed or incomplete, delete tasks, and retain tasks after closing and reopening. No accounts, backend, notifications, categories, deadlines, search, or filters."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Add Tasks (Priority: P1)

The user enters a task title and adds it to the task list.

**Why this priority**: Adding tasks is the core way users capture work.

**Independent Test**: Add a non-empty task and confirm it appears in the list; attempt to add an empty title and confirm it is rejected.

**Acceptance Scenarios**:

1. **Given** the task list is open, **When** the user enters a non-empty title and adds it, **Then** the new task appears in the list.
2. **Given** the title is empty or contains only whitespace, **When** the user attempts to add it, **Then** no task is added.
3. **Given** a task has been added, **When** the user closes and reopens the application, **Then** the task remains in the list.

---

### User Story 2 - Manage Tasks (Priority: P1)

The user marks a task complete or incomplete, or deletes it.

**Why this priority**: Users need to track progress and remove tasks they no longer need.

**Independent Test**: Mark a task complete, mark it incomplete again, delete it, and confirm each change is reflected in the list.

**Acceptance Scenarios**:

1. **Given** an incomplete task, **When** the user marks it complete, **Then** it is shown as completed.
2. **Given** a completed task, **When** the user marks it incomplete, **Then** it is shown as incomplete.
3. **Given** a task in the list, **When** the user deletes it, **Then** it no longer appears in the list.
4. **Given** a task's completion state has changed or it has been deleted, **When** the user closes and reopens the application, **Then** the changed state remains or the deleted task remains absent.

### Edge Cases

- An empty list is shown when the user has not added any tasks.
- A title made up only of whitespace is treated as empty and rejected.
- Completion state changes apply only to the selected task.
- When two saves overlap, only the most recent save's result decides whether the save error is shown. An older save finishing later cannot clear a newer failure, and a newer successful save clears the error.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The application MUST present a single-screen task list.
- **FR-002**: The user MUST be able to enter a task title and add that task to the list.
- **FR-003**: The application MUST reject empty or whitespace-only task titles without adding a task.
- **FR-004**: The user MUST be able to mark a task as completed and mark it incomplete again.
- **FR-005**: The user MUST be able to delete a task from the list.
- **FR-006**: The application MUST retain tasks, their completion states, and deletions after the application is closed and reopened.
  - If loading saved tasks fails, the application MUST show a simple error instead of treating the list as empty and MUST NOT silently discard stored task data.
  - If saving tasks fails after a task is added, completed, reopened, or deleted, the application MUST keep the current in-memory task list and show a simple error message instead of silently discarding the user's latest changes.
- **FR-007**: The application MUST work without login or registration, a backend, or an API.
- **FR-008**: The application MUST NOT include notifications, categories, deadlines, search, or filters.

### Key Entities

- **Task**: A user-entered title and whether the task is completed.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In all acceptance tests, adding a non-empty title adds exactly one task, and an empty or whitespace-only title adds none.
- **SC-002**: In all acceptance tests, a task can be marked complete, marked incomplete again, and deleted with the corresponding list state shown.
- **SC-003**: After each successful awaited local save, tasks and completion states are restored and deleted tasks remain absent after a normal application restart. The application does not guarantee persistence for writes interrupted by unexpected termination or power loss before data is durably stored.
- **SC-004**: A user can perform all specified task actions from the single-screen application without an account or network service.

## Assumptions

- The application is for one user on one device; tasks are not synchronized across devices.
- A task title consists of user-entered text; a title containing only whitespace is considered empty.
- The scope is limited to adding, listing, completing, reopening, and deleting tasks.
