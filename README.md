Silo Night README
================

An app for those burnt out on binging shows. Decide the shows you want to watch, on a weekly schedule.

# The Name

This app is named after an amazing tv show: [Silo](https://en.wikipedia.org/wiki/Silo_(TV_series)). Watch it, if you haven't already.

# Running the App

The app is rack-compatible, so you can launch it as follows:

```bash
rackup
```

# Testing

Currently, there are two different test methodologies / frameworks in use for
testing this app. The first is *Rspec*, which is used for unit-style testing.
This tests the internal libraries driving the core functionality of the app. 

You can run the Rspec test wih the following code:

```bash
rake test:spec
```

In addition, there is a higher level of testing for the behavior of the overall
app itself. This app is using *Cucumber* for that level of testing.

You can run the cucumber tests with the following code:

```bash
rake test:cucumber
```

User the following command to run the entire test suite:

```bash
rake test
```

For more information on testing, see the [testing doc](./docs/testing.md)

# User Scenarios

The best way to understand how the site works is to frame interactions in terms of different possible scenarios.

## Logging in and adding new users

As of the protype release (v0.0.1) no user authentication exists. New users can be added by simply going to the website and click the box to specify a user name.

While authentication is a low priority, it will need to be implemented, before being released for beta testing. User authentication can be simple and straightforward, relying on existing libraries. There will be an expectation to add some level of role-based access control at a future development point.

## What to watch tonight?

This is the first and most straightforward question, and the simplest answer.  Your weekly schedule is stored on the back-end: JSON data stored in a sqlite3 database. Today's date and weekday are fed into the system, and the simple output of what is on your schedule is returned.

## Setting the schedule

When you are ready to change shows, or re-order your schedule, then go to the "edit schedule" page, and change the overall parameters of what you want to watch.  The schedule should provide immediate feedback and display very clearly what you're watching each day and each week.

## Populating the data

The Silo Night app needs a backend data store with lookup information for any show. When a user is trying to plan out their weekly schedule, we want to provide information like average runtime, show genre, number of seasons, number of episodes, etc. This information should be pulled from existing sites like TMDB or TVMaze, and then stored in the database.

# Future Work

Information tagged for further development

## Show Metadata

Currently, the application relies on local data seeding (`data/seed.rb`) and static JSON files (`public/static/justephanie/shows.json`).  To scale this effectively, the site should integrate with a public TV metadata API such as **The Movie Database (TMDB)** or **TVMaze**.

Future versions of this site will rely on caching show metadata from a public metadata API like the ones mentioned above. Further investigation needs to be done to determine if one API serves the needs of the service better than the other.

## Data Storage

Given that this site is meant to be publicly facing, the current sqlite3 data backend is not expeted to scale. The ideal production environment for this code will be running on a container orchestration cluster, like AWS's Elastic Kubernetes Service, or GCP's Google Kubernetes Engine.

Ideally, the backend of this server will run on a relational database engine, such as PostreSQL. Existing seed data and schema files will need to be adapted to run against an external database.

