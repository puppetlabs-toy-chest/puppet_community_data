# PuppetCommunityData

The goal of this project is to create a dashboard to monitor how Puppet Labs is doing responding to pull requests and the general state of the open source repositories.

The application is currently being hosted in Heroku and is viewable [here](http://pullrequestmetrics.herokuapp.com/).

## Usage

As mentioned, this application is hosted in [Heroku](https://devcenter.heroku.com/articles/ruby) and the data is stored in a [Heroku PostgreSQL](https://postgres.heroku.com/) database. Therefor, you will  need your own Heroku login in order to host the application. 

This project uses Bundler as it is required for Heroku. To install the needed gems simply do:

    $ bundle install

To populate the database with new information, run:

    $ heroku run bundle exec rake job:import

Since the application is using the GitHub API, it's important to set your authorization token, otherwise GitHub will
greatly limit how much data you can get at a time. The `application.rb` is responsible for creating the GitHub client. It will look for your authorization token to be
stored as an environment variable called `PCD_GITHUB_OAUTH_TOKEN`.

If you wish to change the repositories which will be queried you can do so in the Rakefile by changing which repositories are passed into `generate_repositories` by changing the `repo_names` variable. The variable is an array of strings where each string is a full repository name (i.e. name/owner).

## Tools

This project uses a lot of different languages, tools, and libraries. If you're going to develop on this project, it's probably a good idea to be somewhat familiar with the following:

* [Active Record](http://api.rubyonrails.org/classes/ActiveRecord/Base.html)
* [PostreSQL](http://www.postgresql.org/)
* [Heroku](https://devcenter.heroku.com/articles/ruby)
    * [Heroku PostgreSQL](https://devcenter.heroku.com/categories/heroku-postgres)
    * [Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler)
* [dc.js](http://nickqizhu.github.io/dc.js/)
* [Sinatra](http://www.sinatrarb.com/)
* [Bootstrap](http://getbootstrap.com/)
