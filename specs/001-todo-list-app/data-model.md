# Data Model: Simple To-Do List Application

## Task

One user-created item in the local task list.

| Field | Type | Rules |
|---|---|---|
| `id` | String | Unique and stable for the lifetime of the task; used to target state changes and deletion |
| `title` | String | Trimmed user-entered text; must contain at least one non-whitespace character |
| `isCompleted` | Boolean | Defaults to `false`; toggles between `false` and `true` |

## Relationships and persistence

The application owns an ordered list of zero or more tasks. There are no relationships to other entities. Persist the list locally as serialized task records under one preference key; an absent key represents an empty list. No account or network identity is stored.

## State transitions

- **Add**: valid title → create a new task with a unique ID and `isCompleted: false`, then persist the updated list.
- **Toggle**: existing task → invert only that task's `isCompleted` value, then persist the updated list.
- **Delete**: existing task → remove only that task, then persist the updated list.
- Invalid blank or whitespace-only input produces no state change and no persisted task.
