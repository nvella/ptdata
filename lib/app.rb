require 'sinatra/base'
require 'ruby_ptv'
require 'date'

require_relative './query'
require_relative './table'
require_relative './tables/routes'
require_relative './tables/stops'
require_relative './tables/departures'
require_relative './tables/patterns'

module PTData
  PTV = RubyPtv::Client.new(dev_id: ENV['PTV_ID'], secret_key: ENV['PTV_SECRET'])
  ROUTE_TYPES = {
    'Train' => 0,
    'Tram' => 1,
    'Bus' => 2,
    'Regional Train/Coach' => 3,
    'Night Bus' => 4
  }

  class App < Sinatra::Application
    attr_accessor :queries
    set app_file: './app.rb'

    def initialize
      super
      @tables = {}
    end

    def self.query(p, &block)
      @@queries ||= {}
      @@queries[p[:id]] = Query.new(self, p, block)
    end
    
    get '/' do
      erb(:index, layout: :layout, locals: {
        queries: @@queries.map {|k, v| ["/q/#{k}", v.title]}
      })
    end

    query(
      id: 'routes',
      title: 'Routes by Route Type',
      params: {
        route_type_id: {label: 'Route Type ID', type: :number}
      }
    ) do |params|
      Tables::Routes.get(params[:route_type_id])
    end

    query(
      id: 'stops',
      title: 'Stops by Route Type and ID',
      params: {
        route_type_id: {label: 'Route Type ID', type: :number},
        route_id: {label: 'Route ID', type: :number}
      },
    ) do |params|
      Tables::Stops.get(params[:route_type_id], params[:route_id])
    end

    query(
      id: 'departures',
      title: 'Departures by Route Type, Stop ID and Date',
      params: {
        route_type_id: {label: 'Route Type ID', type: :number},
        stop_id: {label: 'Stop ID', type: :number},
        date: {label: 'Date', type: :date}
      }
    ) do |params|
      PTData::Tables::Departures.get(params[:route_type_id], params[:stop_id], params[:date])
    end

    query(
      id: 'patterns',
      title: 'Pattern by Route Type and Run ID',
      params: {
        route_type_id: {label: 'Route Type ID', type: :number},
        run_id: {label: 'Run ID', type: :number},
      }
    ) do |params|
      PTData::Tables::Patterns.get(params[:route_type_id], params[:run_id])
    end
   
    # erb(:table, layout: :layout, locals: {
    #   table: PTData::Tables::Departures.get(params[:route_type_id], params[:stop_id], date),
    #   query_params: {
    #     date: {
    #       label: 'Date (yyyy-mm-dd format)',
    #       val: date.iso8601,
    #       type: :input
    #     }
    #   }
    # })

    get '/q/:_id' do
      halt 404 if !@@queries.has_key? params[:_id]

      query = @@queries[params[:_id]]
      query_params = query.format_params(params)
      p query_params
      result = query.execute(query_params)

      erb(:query, layout: :layout, locals: {
        query: query,
        query_params: query_params,
        result: result
      })
    end
    
    # get '/about' do
    #   erb(:about, layout: :layout)
    # end
  end
end

