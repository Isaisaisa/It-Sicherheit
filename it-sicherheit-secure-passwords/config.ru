# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
#run Rails.application
map '/myapp' do
  run Rails.application
end

map '/' do
  run Rails.application
end
