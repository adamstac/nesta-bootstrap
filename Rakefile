require 'rubygems'
require 'bundler/setup'

Bundler.require(:default, :test)


require 'nesta/config'
require 'nesta/models'

namespace :heroku do
  desc "Set Heroku config vars from config.yml"
  task :config do
    Nesta::App.environment = ENV['RACK_ENV'] || 'production'
    settings = {}
    Nesta::Config.settings.map do |variable|
      value = Nesta::Config.send(variable)
      value && settings["NESTA_#{variable.upcase}"] = value
    end
    if Nesta::Config.author
      Nesta::Config.author_settings.map do |author_var|
        value = Nesta::Config.author[author_var]
        if value
          value && settings["NESTA_AUTHOR__#{author_var.upcase}"] = value
        end
      end
    end
    params = settings.map { |k, v| %Q{#{k}="#{v}"} }.join(" ")
    system("heroku config:add #{params}")
  end
end

namespace :tumblr do
  desc "Import items from tumblr"
  task :import do
    
    login     = ENV['TUMBLR_EMAIL']
    password  = ENV['TUMBLR_PASSWORD']
    
    tumblr = Tumblr::Reader.new login, password
    tumblr.defaults.merge! :filter => 'none'
    
    posts = tumblr.get_all_posts "thechangelog"
    
    

    posts.each do |post|
      
      slug = post.slug
      date = post.date
      tumblr_id = post.post_id
      tags = post.tags
      
      case post.type
      when :link
        title = post.name
        github_repo = post.url.split("/").reverse[0..1].reverse.join('/') if post.url[/github/]
        content = post.description
        
      when :regular
        title = post.title
        content = post.body
      else
        puts "unhandled #{post.type}"
        next
      end
      
      # Write out the data and content to file
      File.open("content/pages/#{slug}.mdown", "w") do |f|
        
        f.puts "Date: #{date}"
        f.puts "tumblr_id: #{tumblr_id}"
        f.puts "categories: #{tags}"
        f.puts "github_repo: #{github_repo}" unless github_repo.nil?
        f.puts "title: #{title}"
        f.puts "\n"
        f.puts "# #{title}"
        f.puts "\n"
        f.puts content
      end
      
    end
  end
end

