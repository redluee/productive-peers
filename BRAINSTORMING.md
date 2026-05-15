# Brainstorming: Goal Progress and Creation

## 1. Display of Progress for Goals

### Habit
- **Daily Tracking**: Simple checkbox or button to mark as "done" for the current day.
- **Streaks**:
    - Display a streak counter (e.g., "🔥 14 days").
    - The streak increments for each consecutive day the habit is completed on a scheduled day.
    - The streak resets to 0 if a scheduled day is missed.
- **Calendar/Heatmap View**:
    - A monthly calendar view for each habit.
    - Days the habit was successfully completed are highlighted.
    - The color intensity can reflect the consistency or number of times (if a habit can be done multiple times a day).

### Goal
- **Progress Bar**: A standard progress bar to show overall completion percentage.
- **Milestones**:
    - Inside a goal's detail view, the user can create milestones.
    - Each milestone has a `description` (e.g., "Finish user authentication") and a `percentage` (e.g., 25%).
    - When a user marks a milestone as complete, the goal's overall progress is updated to that milestone's percentage.
    - On the progress bar there should be a little line to indicate a milestone, when completed it should be coloured but when not completed it should be grey.
    - Milestones can be checked off, and the UI will reflect which ones are completed.

### Study
- **Date-Based Milestones**:
    - Milestones are tied to specific dates.
    - Each milestone has a `description` (e.g., "Read Chapter 5") and a `targetDate`.
    - The UI should clearly show upcoming deadlines for study milestones.
    - On the progress bar the milestone should appear as a small line, in colour when completed and grey when not completed.
- **Timeline View**:
    - A visual timeline or a list sorted by date to show the study schcommandedule.
    - It should indicate which milestones are overdue, upcoming, and completed.
- **End Date**:
    - A study goal can have an optional `endDate`.
    - If an `endDate` is set, the timeline can show a countdown or the time remaining.

## 2. Goal Creation Flow

### Current (Assumed)
1.  User clicks "Add Goal".
2.  User selects a type (Goal, Habit, Study).
3.  Relevant input fields show and the user fills them.
4.  User saves.

### Refined Flow
1.  **Entry Point**: User clicks a floating action button or a prominent "Add" button.
2.  **Type Selection First**: A dialog or screen appears, asking the user to choose the type: **Habit**, **Goal**, or **Study**. This is a critical first step as the subsequent form will depend on it.
3.  **Dynamic Form**:
    *   **If Habit:**
        *   `Title` (e.g., "Read for 30 minutes").
        *   `Description` (optional).
        *   `Frequency`:
            *   Repeats every x times a day/week/month/year. (default 2 times a week)
            *   Selection of days in the week when week is selected or day of a month when month is selected. (this option should only appear when week or month is selected)
        *   `End Date` (optional).
    *   **If Goal:**
        *   `Title` (e.g., "Build a mobile app").
        *   `Description` (optional).
        *   `End date` (optional).
        *   `Target Percentage` (defaults to 100%).
    *   **If Study:**
        *   `Title` (e.g., "Learn Flutter").
        *   `Description` (optional).
        *   `Start Date` (defaults to today).
        *   `End Date` (optional).
4.  **Confirmation**: A summary of the created goal is shown before saving.
5.  **Post-Creation**:
    *   For **Goal** and **Study** types, the user could be prompted to add their first milestone right away to encourage breaking down the work.
