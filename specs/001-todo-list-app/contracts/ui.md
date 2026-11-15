# UI Contract: Simple To-Do List Application

## Surface

The application presents one screen containing a task-entry field, an add action, and the current task list. When there are no tasks, show an empty-list state. No navigation to another feature area is required.

## Interactions

- Submitting a title with at least one non-whitespace character adds one task and clears the entry field.
- Submitting an empty or whitespace-only title adds nothing.
- Each task presents its title, a completion control, and a delete action.
- Activating a task's completion control changes only that task between incomplete and completed presentation.
- Activating a task's delete action removes only that task from the visible list.
- Adds, completion changes, and deletions are saved locally and remain reflected after the app is closed and reopened.
- The task flows work offline and do not require login or registration.

## Out of scope

Notifications, categories, deadlines, search, filtering, account flows, network APIs, and synchronization are not part of this interface.
