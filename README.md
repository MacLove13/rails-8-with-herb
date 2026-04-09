# Rails 8 with Herb

A Rails 8 application demonstrating the integration of **Solid Queue**, **Mission Control – Jobs**, and the **[Herb](https://herb-tools.dev)** HTML+ERB toolchain.

## Stack

| Component | Version | Description |
|---|---|---|
| **Rails** | 8.1.3 | Full-stack web framework |
| **Solid Queue** | 1.4.0 | Database-backed Active Job backend |
| **Mission Control – Jobs** | 1.1.0 | Web dashboard for monitoring Solid Queue |
| **Herb** | 0.9.5 | HTML-aware ERB rendering engine & toolchain |
| **SQLite** | ≥ 2.1 | Database for app data and job queues |

## Features

- **Solid Queue** powers background job processing via Active Job, with SQLite as the storage backend.
- **Mission Control – Jobs** provides a web dashboard at `/jobs` to monitor queues, inspect failed/scheduled/in-progress jobs, and manage workers.
- **Herb::Engine** replaces the default Erubi ERB renderer, providing HTML-aware template parsing, validation, and richer developer tooling for all `.html.erb` views.

## Getting started

```bash
# Install dependencies
bundle install

# Set up the database
bin/rails db:create db:migrate

# Load the Solid Queue schema
bin/rails runner "load 'db/queue_schema.rb'"

# Start the server
bin/rails server
```

Visit `http://localhost:3000` for the home page and `http://localhost:3000/jobs` for the Mission Control dashboard.

## Background Jobs

A sample `GreetingJob` is included in `app/jobs/greeting_job.rb`. Enqueue it from the console:

```ruby
GreetingJob.perform_later("Rails")
```

## Screenshots

### Home page

![Home page](https://github.com/user-attachments/assets/ed420291-958f-40b8-b2ed-d72a136f2169)

### Mission Control – Jobs dashboard

![Mission Control dashboard](https://github.com/user-attachments/assets/f3d1fabf-94e7-498c-8521-987bbd662c9b)
