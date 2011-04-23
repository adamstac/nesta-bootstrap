require 'rubygems'
require 'bundler'
require 'rake'

Bundler.setup
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

## My Rake tasks
desc 'Start the application'
task :start do
  system "bundle exec shotgun config.ru"
end

desc 'Generate a new project at dir=foo'
task :generate do
  # Generate the new 'dir' if it's not already created
  system "mkdir #{(ENV['dir'])}" unless File.exists?(ENV['dir'])
  
  # Archive the current HEAD to 'dir'
  system "git archive HEAD | (cd #{ENV['dir']} && tar -xvf -)"

  puts "\n *** A new project has been generated at: #{(ENV['dir'])} ***"
end

namespace :styles do
  
  desc "Run compass stats"
  task :stats => ["stats:default"]

  namespace :stats do

    task :default do
      puts "*** Running compass stats ***"
      system "compass stats"
    end

    desc "Create a log of compass stats"
    task :log do
      t = DateTime.now
      filename = "compass-stats-#{t.strftime("%Y%m%d")}-#{t.strftime("%H%M%S")}.log"
      log_dir = "log"
      puts "*** Logging stats ***"
      system "compass stats > #{log_dir}/#{filename}"
      puts "Created #{log_dir}/#{filename}"
    end
    
  end
  
  desc "Clear the styles"
  task :clear => ["compile:clear"]

  desc "Watch the styles and compile new changes"
  task :watch do
    system "compass watch"
  end
  
  desc "List the styles"
  task :list do
    system "ls -lh public/stylesheets"
  end
  
  desc "Compile new styles"
  task :compile => ["compile:default"]

  namespace :compile do
    
    task :clear do
      puts "*** Clearing styles ***"
      system "rm -Rfv public/stylesheets/*"
    end

    task :default => :clear do
      puts "*** Compiling styles ***"
      system "compass compile"
    end

    desc "Compile new styles for production"
    task :production => :clear do
      puts "*** Compiling styles ***"
      system "compass compile --output-style compressed --force"
    end

  end
  
end