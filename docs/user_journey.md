# User Persona: Structured Sam

**"I love great TV, but I hate the feeling of wasting my evening scrolling through menus or accidentally binging until 2 AM."**

*   **Demographics:** 28, Remote Software Engineer, lives in a medium-sized city.
*   **Behavioral Patterns:** Sam is highly organized in his professional life but finds himself suffering from "decision paralysis" when it comes to entertainment. He values high-quality storytelling (like the show *Silo*) but often ends up binging mediocre content because it's "just there."
*   **Goals and Needs:**
    *   To establish a predictable evening routine with a clear "stop" time.
    *   To make steady progress through a curated list of shows without feeling overwhelmed.
    *   To remove the friction of choosing what to watch each night.
*   **Pain Points:**
    *   **Decision Fatigue:** Spending 30 minutes looking for something to watch and eventually giving up.
    *   **Binge Burnout:** Feeling regret and exhaustion after staying up too late watching "just one more episode."
    *   **Content Overload:** A massive "watch list" across five different streaming services that feels like a chore to manage.
*   **Mental Model:** Sam views his time as a budget. He wants to allocate his "entertainment budget" (e.g., 45 minutes on a Tuesday) as efficiently as possible to maximize his enjoyment without sacrificing sleep or other hobbies.

---

This doc describes the user journey for the initial prototype of the Silo Night app. This document will be used for planning purposes, as well as generating BDD-style tests using the Cucumber / Gherkin tooling.

For more details on what a user journey entails, see the [User journey article](https://en.wikipedia.org/wiki/User_journey) on Wikipedia.

For the purposes of the prototpye, no authentication is set up. When the user comes to the root page "/", they are presented with a list of existing users, or a prompt to create a new user, with an empty text box.

# Creating a New User

Creating a new user should be simple. All a user needs to provide is their username. That can be added into the text box, and the user will click a button labeled "Create".

Clicking the button will take the user to the next page, to confirm that the user is created. If a username is specified that already exists, then the user will be prompted to create a new username on the original page.

# Existing User

When a user clicks on their name, they will be taken to the "shows and schedule" page mentioned below. The main difference between a new user and an existing user, is that for an existing user, the shows and schedule portions will already be filled out.

# Shows and Schedule Page

All users when they get to their show / schedule page will see two sections, one for shows and one for schedule. For a new user, their show and schedule page will be empty, with some suggested shows and a suggested schedule, based on common patterns from the site.

The shows section will have a search bar where users can type in show names to look for. The search bar will have drop down suggestions with show thumbnails and genre, and year broadcast, to make it easier to recognize the show. Once they choose a show, it will be added to the list. This list of shows is draggable and orderable, and also displays the runtime for each show.

The other section of the page is for schedule configuration. Each day of the week will be listed, so that the user can choose which days they want to have available to watch tv shows. Then for each date, the available time is specified in minutes. The user can edit available times and dates until they are ready for their schedule to be complete.

Once a user has configured their schedule, and their list of shows, they'll be ready to move to the Final Guide. This is created by the website examining the runtime of each show, along with the availability for each night, and fitting available shows to available nights.

# Final Guide

The "final guide" page could be a page separate from the shows and schedule page, or it could be the same page in "edit" mode. That disctinction can be determined later. The key component of the final guide page is that it will clearly show the weekly schedule, with a highlight on the shows to watch on the day that matches today's date.
