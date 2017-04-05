# Description

A simple code that access a Web Service SOAP from ANATEL (Brazil)
Through a couple of actions, this code gets some info and save it into a Elasticsearch index (for a better search).
Also, it could be use as a stress test for the Web Service.

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
    * For a _stress test_, run: **ruby main.rb**

* At Windows, to install all dependencies first you need to install Dev-Kit (see here: http://rubyinstaller.org/downloads/)
