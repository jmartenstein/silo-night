# Migration Plan: Flexible Show Metadata

This document outlines the steps required to migrate show metadata from dedicated columns in the `shows` table to a flexible JSON `payload` in the `show_metadata` table.

## Objective
To improve flexibility and extensibility of show data, we are moving metadata (like runtime, poster paths, and wiki links) into a JSON-serialized `payload` column. This allows us to store arbitrary metadata from multiple providers without requiring schema changes for every new field.

## Current Schema
- **shows**: `id`, `name`, `uri_encoded`, `wiki_page`, `page_title`, `runtime`, `poster_path`
- **show_metadata**: `id`, `provider_name`, `external_id`, `payload`, `created_at`, `updated_at`

## Target Schema
- **shows**: `id`, `name`, `uri_encoded`
- **show_metadata**: `id`, `show_id` (new), `provider_name`, `external_id`, `payload`, `created_at`, `updated_at`

---

## Phase 1: Database Migrations

### 1.1 Add `show_id` to `show_metadata`
Create `db/migrations/004_link_shows_to_metadata.rb`:

```ruby
Sequel.migration do
  change do
    alter_table(:show_metadata) do
      add_foreign_key :show_id, :shows, null: true # null: true initially for existing records
    end
  end
end
```

### 1.2 Remove old columns (Wait until Phase 3)
Create `db/migrations/005_remove_old_show_columns.rb` (to be run AFTER data verification):

```ruby
Sequel.migration do
  change do
    alter_table(:shows) do
      drop_column :wiki_page
      drop_column :page_title
      drop_column :runtime
      drop_column :poster_path
    end
  end
end
```

---

## Phase 2: Data Migration Script

Create a script `scripts/migrate_show_metadata.rb` to move data from `shows` to `show_metadata`.

```ruby
require_relative '../lib/database'
require_relative '../lib/show'
require_relative '../lib/show_metadata'

puts "Starting show metadata migration..."

DB.transaction do
  Show.each do |show|
    puts "Migrating metadata for: #{show.name}"
    
    payload = {
      runtime: show.runtime,
      poster_path: show.poster_path,
      wiki_page: show.wiki_page,
      page_title: show.page_title
    }

    # Use upsert logic to avoid duplicates if script is re-run
    ShowMetadata.upsert(
      provider_name: 'internal',
      external_id: show.uri_encoded || show.name.downcase.gsub(' ', '_'),
      payload: payload
    )
    
    # Link the newly created/updated metadata to the show
    metadata = ShowMetadata.find(provider_name: 'internal', external_id: show.uri_encoded || show.name.downcase.gsub(' ', '_'))
    metadata.update(show_id: show.id)
  end
end

puts "Migration complete!"
```

---

## Phase 3: Code Refactoring

### 3.1 Update Models

**lib/show.rb**:
Refactor the class to delegate metadata attributes to the `show_metadata` table.

```ruby
class Show < Sequel::Model
  many_to_many :users
  one_to_many :metadata, class: :ShowMetadata

  def internal_metadata
    @internal_metadata ||= metadata_dataset.first(provider_name: 'internal')
  end

  def average_runtime
    raw_runtime = internal_metadata&.payload&.fetch('runtime', nil) || @values[:runtime]
    return 30 if raw_runtime.nil? || raw_runtime.empty?

    times = raw_runtime.split(/\W+/)
    times.delete("minutes")
    times.delete("min")
    times.delete("")

    return 30 if times.empty?
    sum = times.map(&:to_i).reduce(:+)
    sum / times.count
  end

  def poster_path
    internal_metadata&.payload&.fetch('poster_path', nil) || @values[:poster_path]
  end
end
```

**lib/show_metadata.rb**:
Ensure the relationship is defined.

```ruby
class ShowMetadata < Sequel::Model(:show_metadata)
  many_to_one :show
  # ... existing plugins and methods ...
end
```


### 3.2 Update Services

**lib/metadata_service.rb**:
Implement cache-aside logic.

```ruby
def get_show_metadata(title)
  # 0. Check local cache first
  cached = ShowMetadata.find(provider_name: 'internal', external_id: URI.encode_www_form_component(title.downcase))
  return cached.payload.transform_keys(&:to_sym) if cached && cached.payload

  # 1. Search in TMDB first...
  # ... (existing search logic) ...

  unified = unify_metadata(tmdb_show, tvmaze_show)
  
  # Cache the result if we found something
  if unified
    ShowMetadata.upsert(
      provider_name: 'internal',
      external_id: URI.encode_www_form_component(title.downcase),
      payload: unified
    )
  end

  unified
end
```

**lib/services/user_show.rb**:
Update show creation to link metadata.

```ruby
def self.create_show_from_metadata(name)
  metadata = MetadataService.new.get_show_metadata(name)
  return nil unless metadata

  DB.transaction do
    show = ::Show.create(
      name: metadata[:name],
      uri_encoded: URI.encode_www_form_component(metadata[:name].downcase)
    )

    ShowMetadata.upsert(
      show_id: show.id,
      provider_name: 'internal',
      external_id: show.uri_encoded,
      payload: metadata
    )
    show
  end
end
```


---

## Phase 4: Validation & Cleanup

1. **Verify Data**: Run the application and ensure all show details (posters, runtimes) still appear correctly.
2. **Run Tests**: Ensure all existing tests in `spec/` pass.
3. **Execute 005 Migration**: Once verified, run the migration to drop the old columns from the `shows` table.
4. **Update Factories**: Update any test factories (e.g., `spec/factories/shows.rb` if it exists) to use the new structure.

---

## Junior Engineer / Agent Instructions

1. Run `rake db:migrate` to apply migration `004`.
2. Execute the data migration script: `ruby scripts/migrate_show_metadata.rb`.
3. Modify `lib/show.rb` to use `ShowMetadata` for its attributes.
4. Verify the UI/API still returns correct data.
5. Run `rake db:migrate` to apply migration `005`.
