require_relative '../table'

module PTData::Queries
  module SearchExecutor
    def execute(params)
      schema_keys = self.class.instance_variable_get(:@schema).keys
      index = case id
      when :stops_search
        'stops'
      when :routes_search
        'routes'
      when :outlets_search
        'outlets'
      else
        throw 'internal error occurred'
      end

      PTData::Table.new(
        "Search query \"#{params[:search_term]}\"",
        self.class.instance_variable_get(:@schema).keys,
        PTData::PTV.search(params[:search_term], {
          match_stop_by_suburb:  params[:match_by_suburb] && id == :stops_search,
          match_route_by_suburb: params[:match_by_suburb] && id == :routes_search,
          include_outlets: id == :outlets_search
        })[index].map do |row|
          {
            vals: if schema_keys.include?('route_type')
              row.merge({'route_type_human' => @app.route_type_human(row['route_type'])})
            else
              row
            end,
            links: {
              'route_id'   => @app.lq(:stops, route_type: row['route_type'], route_id: row['route_id']), 
              'route_name' => @app.lq(:stops, route_type: row['route_type'], route_id: row['route_id']),

              'stop_id'   => @app.lq(:departures, route_type: row['route_type'], stop_id: row['stop_id']),
              'stop_name' => @app.lq(:departures, route_type: row['route_type'], stop_id: row['stop_id']),

              'route_type'       => @app.lq(:routes, route_type: row['route_type']),
              'route_type_human' => @app.lq(:routes, route_type: row['route_type']),
            }
          }
        end
      )
    end
  end

  class StopsSearch < PTData::Query
    include SearchExecutor

    id :stops_search
    title 'Search Stops by Search Term'
    input_param :search_term, label: 'Search Term', type: :text, required: true
    input_param :match_by_suburb, label: 'Match by Suburb in Search Term?', type: :bool, required: false, default: false

    @schema = {
      "stop_distance" => 0,
      "stop_suburb" => "string",
      "stop_name" => "string",
      "stop_id" => 0,
      "route_type" => 0,
      "route_type_human" => '',
      "stop_latitude" => 0,
      "stop_longitude" => 0,
      "stop_sequence" => 0
    }
  end

  class RoutesSearch < PTData::Query
    include SearchExecutor

    id :routes_search
    title 'Search Routes by Search Term'
    input_param :search_term, label: 'Search Term', type: :text, required: true
    input_param :match_by_suburb, label: 'Match by Suburb in Search Term?', type: :bool, required: false, default: false

    @schema = {
      "route_name" => "string",
      "route_number" => "string",
      "route_type" => 0,
      "route_id" => 0,
      "route_gtfs_id" => "string"
    }
  end

  class OutletsSearch < PTData::Query
    include SearchExecutor

    id :outlets_search
    title 'Search Outlets by Search Term'
    input_param :search_term, label: 'Search Term', type: :text, required: true
    input_param :match_by_suburb, label: 'Match by Suburb in Search Term?', type: :bool, required: false, default: false
    
    @schema = {
      "outlet_distance" => 0,
      "outlet_slid_spid" => "string",
      "outlet_name" => "string",
      "outlet_business" => "string",
      "outlet_latitude" => 0,
      "outlet_longitude" => 0,
      "outlet_suburb" => "string",
      "outlet_postcode" => 0,
      "outlet_business_hour_mon" => "string",
      "outlet_business_hour_tue" => "string",
      "outlet_business_hour_wed" => "string",
      "outlet_business_hour_thur" => "string",
      "outlet_business_hour_fri" => "string",
      "outlet_business_hour_sat" => "string",
      "outlet_business_hour_sun" => "string",
      "outlet_notes" => "string"
    }
  end
end
