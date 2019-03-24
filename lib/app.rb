require 'sinatra/base'
require 'ruby_ptv'
require 'date'

require_relative './table'
require_relative './tables/routes'
require_relative './tables/stops'
require_relative './tables/departures'

module PTSheets
  PTV = RubyPtv::Client.new(dev_id: ENV['PTV_ID'], secret_key: ENV['PTV_SECRET'])
  ROUTE_TYPES = {
    'Train' => 0,
    'Tram' => 1,
    'Bus' => 2,
    'Regional Train/Coach' => 3,
    'Night Bus' => 4
  }

  class App < Sinatra::Application
    set app_file: './app.rb'

    get '/' do
      erb(:index, layout: :layout)
    end
    
    get '/routes/:route_type' do
      erb(:table, layout: :layout, locals: {
        table: PTSheets::Tables::Routes.get(params[:route_type]), 
        query_params: {}
      })
    end
    
    get '/stops/:route_type_id/:route_id' do
      erb(:table, layout: :layout, locals: {
        table: PTSheets::Tables::Stops.get(params[:route_type_id], params[:route_id]),
        query_params: {}
      })
    end
    
    get '/departures/:route_type_id/:stop_id' do
      date = /^\d\d\d\d-\d\d-\d\d$/.match(params[:date]) ? Date.parse(params[:date]) : Date.today
    
      erb(:table, layout: :layout, locals: {
        table: PTSheets::Tables::Departures.get(params[:route_type_id], params[:stop_id], date),
        query_params: {
          date: {
            label: 'Date (yyyy-mm-dd format)',
            val: date.iso8601,
            type: :input
          }
        }
      })
    end
    
    get '/about' do
      erb(:about, layout: :layout)
    end
  end
end

