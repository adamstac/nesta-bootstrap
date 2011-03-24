module Nesta
  class App
    use Rack::Static, :urls => ['/base'], :root => 'themes/base/public'
    
    get '/css/:sheet.css' do
      content_type 'text/css', :charset => 'utf-8'
      cache sass(params[:sheet].to_sym, Compass.sass_engine_options)
    end
  end
end
