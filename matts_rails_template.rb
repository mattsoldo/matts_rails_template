def heroku(command = {})
  in_root do
    if command.is_a?(Symbol)
      log 'running', "heroku #{command}"
      run "heroku #{command}"
    else
      command.each do |command, options|
        log 'running', "heroku #{command} #{options}"
        run("heroku #{command} #{options}")
      end
    end
  end
end

plugin 'delayed_job', :git => "git://github.com/tobi/delayed_job.git"

file 'Gemfile', <<-ENDEND
  gem "rails", "3.0.pre"
  gem 'pg'
  gem 'haml'
  gem 'will_paginate'
  gem 'formtastic', :git => "git://github.com/justinfrench/formtastic.git", :branch => "rails3"
  gem "factory_girl"
  gem 'shoulda', :git => "git://github.com/thoughtbot/shoulda.git", :branch => "rails3"
  gem 'hassle'  
ENDEND

## Create the database

rake "db:create"

##############  commands #################

git :init

file ".gitignore", <<-END
.DS_Store
log/*.log
log/*.log*
tmp/**/*
config/database.yml
db/*.sqlite3
END

run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run "cp config/database.yml config/example_database.yml"

git :add => "."
git :commit => "-m 'initial commit'"

generate :formtastic

git :add => "."
git :commit => "-m 'formtastic stylesheets'"

generate :controller, "welcome index"
route "map.root :controller => 'welcome'"
git :rm => "public/index.html"

git :add => "."
git :commit => "-m 'adding welcome controller'"

generate 'nifty_layout --haml' 

git :add => "."
git :commit => "-m 'nifty layout'"

## Delpoy to Heroku
heroku :create
git :push => "heroku master"
heroku :rake => "db:migrate"