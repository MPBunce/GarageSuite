# Contributing to GarageSuite

Thanks for your interest in contributing! GarageSuite is a Ruby on Rails
application for automotive shop management, currently used in production by
2for2tires.ca. Contributions, bug reports, and feature suggestions are all
welcome.

## Getting Started

1. Fork the repo and clone your fork:
   ```
   git clone https://github.com/<your-username>/GarageSuite.git
   cd GarageSuite
   ```
2. Install the correct Ruby version (see `.ruby-version`) and dependencies:
   ```
   bundle install
   ```
3. Set up the database:
   ```
   bin/rails db:create db:migrate
   ```
4. Start the app locally:
   ```
   bin/dev
   ```
   (uses `Procfile.dev`)

## Running Tests

```
bin/rails test
```

Please make sure the test suite passes before opening a pull request. If
you're fixing a bug, add a regression test where practical. New features
should include test coverage.

## Code Style

This project uses Rubocop (see `.rubocop.yml`). Run it before submitting:

```
bundle exec rubocop
```

## Making Changes

1. Create a branch off `main`:
   ```
   git checkout -b your-feature-name
   ```
2. Make your changes, with focused, well-described commits.
3. Push to your fork and open a pull request against `main`.
4. In the PR description, explain **what** changed and **why**, and link any
   related issue.

## Areas to Contribute

Check the [Issues](../../issues) tab for open items, including some
lower-effort ones such as:

- Site name / header color updates
- Making price optional on listings
- Removing date/time picking for customers
- Logo update
- Footer banner
- Contact us page

If you'd like to work on something not yet filed as an issue, please open one
first so we can discuss the approach before you invest time in a PR.

## Reporting Bugs

When filing a bug report, please include:
- Steps to reproduce
- Expected vs. actual behavior
- Ruby/Rails version and OS, if relevant
- Any relevant logs or error messages

## Questions

Feel free to open an issue for questions or discussion — no need for it to be
a fully-formed bug report or feature request.