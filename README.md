Silo Night README
================

A lifestyle for those tired of binging shows. This project provides a multi-user website for managing weekly TV schedules.

# The Name

This app is named after an amazing tv show: [Silo](https://en.wikipedia.org/wiki/Silo_(TV_series)). Watch it, if you haven't already.

# Running the App

The app is rack-compatible, so you can launch it as follows:

```bash
rackup -I lib
```

# Testing

Currently, there are two different test methodologies / frameworks in use for
testing this app. The first is *Rspec*, which is used for unit-style testing.
This tests the internal libraries driving the core functionality of the app. 

You can run the Rspec test wih the following code:

```bash
rspec spec/*.rb -I lib -I .
```

In addition, there is a higher level of testing for the behavior of the overall
app itself. This app is using *Cucumber* for that level of testing.

You can run the cucumber tests with the following code:

```bash
cucumber features/*.feature
```

# The Architecture

Any good system can be broken down into a series of loops. 

## What am I watching tonight?

This is the first and most straightforward question, and the simplest answer.  Your weekly schedule is stored on the back-end: JSON data stored in a sqlite3 database. Today's date and weekday are fed into the system, and the simple output of what is on your schedule is returned.

## Setting my schedule 

When I'm ready to change shows, or re-order my schedule, then I want to be able to go to an "edit" page, and change the overall parameters of what I want to watch.  The schedule should provide immediate feedback and display very clearly what I'm watching each day and each week.

## Populating the data

The Silo Night app needs a backend data store with lookup information for any show. When a user is trying to plan out their weekly schedule, we want to provide information like average runtime, number of seasons, number of episodes, etc.

# Future Work

Information tagged for further development

## Show Metadata

Currently, the application appears to rely on local data seeding (`data/seed.rb`) and static JSON files (`public/static/justephanie/shows.json`).  To scale this effectively, we should integrate with a public TV metadata API such as **The Movie Database (TMDB)** or **TVMaze**.

In future versions of this site, we'll rely on caching show metadata from a public metadata API like the ones mentioned above. Further investigation needs to be done to determine if one API serves the needs of the service better than the other.

## Data Storage

Given that this site is meant to be publicly facing, the current sqlite3 data backend is not expeted to scale. The ideal production environment for this code will be running on a container orchestration cluster, like AWS's Elastic Kubernetes Service, or GCP's Google Kubernetes Engine.

Ideally, the backend of this server will run on a relational database engine, such as PostreSQL. Existing seed data and schema files will need to be adapted to run against an external database.

## User Authentication

As of the protype release (v0.0.1) no user authentication exists. While this is a low priority, it will need to be implemented, before being released for beta testing. User authentication can be simple and straightforward, relying on existing libraries. There will be an expectation to add some level of role-based access control at a future development point.
