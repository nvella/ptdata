require 'sinatra/base'
require 'ruby_ptv'
require 'date'
require 'ostruct'

require_relative './table'
require_relative './query'
require_relative './queries/routes'
require_relative './queries/stops'
require_relative './queries/departures'
require_relative './queries/patterns'

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
    attr_reader :queries
    set app_file: './app.rb'

    def initialize
      super
      
      register_query Queries::Routes
      register_query Queries::Stops
      register_query Queries::Departures
      register_query Queries::Patterns
    end

    def register_query query_class
      @queries ||= OpenStruct.new
      query = query_class.new(self)
      @queries[query.id] = query
    end

    get '/' do
      erb(:index, layout: :layout, locals: {
        queries: @queries.to_h.map {|k, v| ["/q/#{k}", v.title]}
      })
    end

    get '/q/:_id' do
      query_key = params[:_id].to_sym
      halt 404 if @queries.dig(query_key).nil?

      query = @queries[query_key]
      query_params = begin
        query.format_params(params)
      rescue QueryParameterError => e
        status 400
        return erb(:query, layout: :layout, locals: {
          query: query,
          query_error: e
        });
      end
      
      result = query.execute(query_params)

      # CSV download
      if params[:csv] == 'yes'
        attachment "PTData_#{params[:_id]}_#{result.title.gsub(/[^a-z0-9]/i, '_')}.csv"
        return result.to_csv
      end

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

