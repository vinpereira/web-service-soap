# Description

A simple code that access a Web Service through a couple of actions to get some nice info and save it into a Elasticsearch index.

# How to Use
1. Install Ruby (https://www.ruby-lang.org/en/downloads/)
    * Put Ruby in your PATH
    * Once Ruby is installed execute **ruby -v**
2. Install the Bundler gem
    * Open your terminal
    * Run **gem install bundler**
3. Install all dependencies*
    * Again at your terminal
    * Go to this folder's root
    * Run **bundle install**
4. Execute the program
    * For a _stress test_, run: **ruby main.rb "provider_code" "username" "password" "from_date" "to_date"**
    * For a _Web API_, run: **puma main.ru**
        * Access _localhost:9292/getAllRequestsIds_ 
        * Access _localhost:9292/getRequestDetails/[id]_

* At Windows, to install all dependencies first you need to install Dev-Kit (see here: http://rubyinstaller.org/downloads/)
