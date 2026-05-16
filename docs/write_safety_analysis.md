# Analysis: Why the Refactor Plan Missed "Write Safety"

Hey there! As we hit that wall of test failures after renaming the database columns, it's important to pause and look at *why* our original plan didn't catch those issues earlier. This is a classic "senior moment"—even with a detailed roadmap, we missed a fundamental piece of database refactoring: **Write Safety**.

## The Core Concept: Expand-Contract
When refactoring a database in a living application, we typically follow the **Expand and Contract** pattern. This pattern breaks a breaking change into smaller, safe steps:

1.  **Expand (Schema)**: Add the new table/column.
2.  **Expand (Writes)**: Update the app to write to *both* old and new locations.
3.  **Migrate**: Backfill the new location with old data.
4.  **Contract (Reads)**: Update the app to read from the new location only.
5.  **Contract (Writes)**: Stop writing to the old location.
6.  **Contract (Schema)**: Finally, drop the old column.

## What Went Wrong?
In our initial plan (`metadata_refactor_todo.md`), we performed steps 1, 3, and 4 (Expand Schema, Migrate Data, and Contract Reads). However, we skipped **Contract (Writes)** and jumped straight to **Contract (Schema)**.

### 1. The "Read-Only" Bias
As developers, we often focus on how the app *displays* data. We refactored the `Show` model to delegate `runtime` and `poster_path` to the new metadata payload. Once the UI looked right and the model specs passed, we assumed the "Refactor" was complete. We audited where these values were **read**, but we didn't audit where they were **assigned**.

### 2. The "Invisible" Dependency (Test Blindness)
The biggest reason this wasn't discovered earlier is that our test suite was effectively "lying" to us. 

Many of our tests and seed scripts were performing **Legacy Writes**. They were calling `Show.create(runtime: '30 min')`. Because those columns still existed in the database, the writes succeeded silently. 

When the test then called `show.runtime`, our delegation logic looked at the (empty) metadata, found nothing, and gracefully "fell back" to the legacy column. The test passed, but it was testing the **fallback logic**, not the **refactor**.

### 3. ORM Mass-Assignment
Sequel (and most ORMs) handles object creation by mapping hash keys to column names. By renaming the columns to `deprecated_runtime`, we didn't just break the database; we broke the **Model Interface**. 

The moment the column was renamed, `Show.create(runtime: '...')` became an attempt to call a method (`runtime=`) that no longer existed. This triggered a `Sequel::MassAssignmentRestriction` error across the entire suite.

## Why We Discovered It Late
We only discovered this at Step 7 (Rename Columns) because that was the first time we **enforced** the change at the database level. Up until that point, the legacy columns acted as a "safety net" that allowed our buggy, non-modernized tests to continue passing.

## Lessons for Next Time
1.  **Lock the Interface Early**: In Step 2 (Delegation), we should have added `set_restricted_columns` to the `Show` model immediately. This would have forced the tests to fail the moment we added the "Read" delegation, exposing the "Write" dependencies much sooner.
2.  **Audit Creation, Not Just Usage**: A refactor isn't just about where a variable is used; it's about the entire lifecycle of the data. 
3.  **Modernize Factories First**: If we had updated our `FactoryBot` definitions to use metadata payloads in Step 2, we would have seen that the rest of the application was still relying on the legacy column "crutch."

The new Step 7 ("Enforce Write-Safety") we added to the roadmap is designed to fix this exact gap. By locking the model and auditing the creation calls *before* touching the database, we ensure the code is truly decoupled from the physical schema.

Great job catching this during the rename phase—that's exactly why we use the "Rename-then-Drop" strategy!
