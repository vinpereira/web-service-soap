Dir['lib/**/*.rb'].sort.each { |file| require(File.dirname(__FILE__) + '/' + file) }

run WebApp
