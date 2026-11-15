<!-- Sync Impact Report
- Version change: 1.2.0 → 1.2.0
- Modified principles: none
- Added sections: none
- Removed sections: none
- Deferred items: none
-->

# To Do List Constitution

## Core Principles

### I. Tight MVP Scope
This project MUST remain a small Flutter to-do list MVP focused on the core task flows: adding a
task, displaying tasks, marking a task complete or incomplete, and deleting a task. Any feature
outside this scope is out of bounds unless the project explicitly adds a new requirement and updates
this constitution.

### II. Local Persistence and Data Safety
Tasks MUST be saved locally so they remain available after the app restarts. The app MUST avoid
data loss during normal use and MUST keep the persistence mechanism simple, reliable, and easy to
understand.

### III. Simplicity Over Architecture
The implementation MUST prefer the simplest code that meets the requirements. We MUST avoid
unnecessary packages, abstractions, complex architecture, and heavy state management. Readable
code, clear naming, and straightforward logic are required over theoretical purity.

### IV. Verified Task Behavior
All behavior-changing work MUST include basic validation and tests for the primary task flows. At
minimum, the project MUST test adding a task, toggling completion state, and deleting a task. No
task behavior is considered complete without evidence that it works.

## Project Constraints
This project is a single-screen Flutter app. It MUST stay easy to read, easy to maintain, and easy to
validate. The implementation MUST avoid authentication, backend services, notifications,
categories, deadlines, search, filtering, and complex architecture. It MUST NOT require Clean
Architecture, SOLID layers, Cubit, Bloc, Repository Pattern, or Hive.

## Development Workflow
Each change MUST be scoped to the MVP and validated against the existing requirements. Work MUST
prefer direct, understandable implementation over abstraction. Before completion, the project MUST
verify the task flows with targeted tests and basic validation for empty or invalid task input.

## Governance
This constitution governs all decisions for this project. It supersedes informal preferences and any
implementation detail that conflicts with it. Any amendment MUST state the reason for the change,
the affected principle or workflow, and any impact on the MVP. Changes require review before
implementation is considered complete, and compliance review MUST confirm that the project remains
aligned with the scope, simplicity, and validation requirements stated here.

**Version**: 1.2.0 | **Ratified**: 2026-11-15 | **Last Amended**: 2026-11-15
