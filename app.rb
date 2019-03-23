require 'bundler/setup'
require 'sinatra'
require 'ruby_ptv'

require_relative './lib/table'
require_relative './lib/tables/routes'

module PTSheets
  PTV = RubyPtv::Client.new(dev_id: ENV['PTV_ID'], secret_key: ENV['PTV_SECRET'])
  ROUTE_TYPES = {
    'Train' => 0,
    'Tram' => 1,
    'Bus' => 2,
    'Regional Train/Coach' => 3,
    'Night Bus' => 4
  }
end

get '/' do
  erb(:index, layout: :layout)
end

get '/routelist/:route_type' do
  erb(:table, layout: :layout, locals: {table: PTSheets::Tables::Routes.get(params[:route_type])})
end

get '/routelist/:route_type/csv' do

end
