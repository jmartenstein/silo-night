# Silo Night README

A lifestyle for those tired of binging shows

## The Name

This app is named after an amazing tv show: [Silo](https://en.wikipedia.org/wiki/Silo_(TV_series)). Watch it, if you haven't already.

## Running the App

The app is rack-compatible, so you can launch it as follows:

```bash
rackup
```

If you want to be able to reload the app on code changes, you can use the 'rerun' gem.

```bash
rerun rackup
```

## Testing

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

## Loading the Data

## The Architecture

Any good system can be broken down into a series of loops. 

### What am I watching tonight?

This is the first and most straightforward question, and the simplest answer.
Your weekly schedule is stored on the back-end (SQL? JSON?). Today's date and
weekday are fed into the system, and the simple output of what is on your
schedule is returned.

### Setting my schedule 

When I'm ready to change shows, or re-order my schedule, then I want to be able
to go to an "edit" page, and change the overall parameters of what I want to watch.
The schedule should provide immediate feedback and display very clearly what I'm
watching each day and each week.

### Populating the data

The Silo Night app needs a backend data store with lookup information for any
show. When a user is trying to plan out their weekly schedule, we want to
provide information like average runtime, number of seasons, number of episodes,
etc.
