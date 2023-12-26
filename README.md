# How To Start Up The Team 9's Web Application

## Loading Up The Web Application

note that ruby and ruby-dev must already be installed for "bundle install" to work correctly,
to install ruby-dev use "sudo apt-get install ruby-dev" on a ubuntu system,
if typing "sinatra" doesn't work just type "ruby app.rb"

1. cd in to project using the terminal.
2. `bundle install` to install the Ruby gems.
3. Type `sinatra` in the terminal and click on the generated link.

## Using The Web Application.
 
You can login in with multiple different users, for example, the learner and as the admin.

| Username  | Password  |
| --------- | --------- |
| testuser  | password  |
| admin1    | admin1    |
| learner1  | learner1  |
| moderator1| moderator1|
| manager1  | manager1  |
| provider1 | provider1 |

## Running Tests

1. Use `rspec spec` to run unit tests
2. LOC Coverage report generated in `./coverage` directory
