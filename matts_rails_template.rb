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

plugin 'delayed_job'

gem 'haml'
gem 'will_paginate'
gem 'formtastic'
gem "factory_girl"
gem 'shoulda'
gem 'hassle'
gem 'nifty-generator'
gem 'heroku'

file ".gems", <<-END
dry_scaffold  
will_paginate  
formtastic  
factory_girl  
shoulda
hassle
END

## Create the database

rake "db:create"

##############  commands #################

git :init

file ".gitignore", <<-END
.DS_Store
log/*.log
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