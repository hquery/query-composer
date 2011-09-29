require 'rubygems'
require 'kramdown'
namespace :doc do
  desc "Generate html from bluecloth."
  task :readme => :environment do
    file = File.open("README.md", "rb")
    contents = file.read
    doc = Kramdown::Document.new(contents)
    File.open('./doc/readme.html','w') do |file|
      file << doc.to_html
    end
  end
end
