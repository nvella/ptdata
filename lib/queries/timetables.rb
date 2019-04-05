require 'date'
require_relative '../table'
require 'json'


module PTData::Queries
  class Timetables < PTData::Query
    id :timetables
    title 'Timetables by Route Type, Route ID, Direction ID and Date'

    input_param :route_type, label: 'Route Type', type: :number, required: true
    input_param :route_id, label: 'Route ID', type: :number, required: true
    input_param :direction_id, label: 'Direction ID', type: :number, required: true
    input_param :date, label: 'Date', type: :date

    def execute(params)
      # Get stop sequence for route
      stops = PTData::PTV.stops_for_route(params[:route_id], params[:route_type], direction_id: params[:direction_id]).sort_by {|stop| stop['stop_sequence']}
      # Get departures for the first stop
      stop_departures = [stops[0]].map do |stop| 
        [
          stop['stop_id'], 
          PTData::PTV.departures_for_route(params[:route_type], stop['stop_id'], params[:route_id].to_s, {
            max_results: 1000,
            date_utc: params[:date].to_time.getutc.to_datetime.iso8601,
            include_cancelled: true
          })['departures'].select {|d| DateTime.parse(d['scheduled_departure_utc']).to_time.localtime.to_date == params[:date]}
        ]
      end.to_h
      # Collect patterns from unique run ids
      patterns = stop_departures.map {|stop_id, deps| deps.map {|dep| dep['run_id']}}.flatten.uniq.map do |run_id|
        [
          run_id,
          PTData::PTV.pattern(run_id, params[:route_type], {
            expand: 'all'
          })
        ]
      end.to_h
      # Get route
      route = patterns.first.last['routes'][params[:route_id].to_s]
      # Get direction
      direction = patterns.first.last['directions'][params[:direction_id].to_s]
      # Create table
      return PTData::Table.new(
        "Timetable for Route ID #{params[:route_id]}; #{route['route_name']} towards #{direction['direction_name']}, for #{params[:date]}",
        ['stop_id', 'stop_name', *patterns.keys.map {|k| k.to_s}],
        stops.map do |stop| 
          {
            vals: {
              'stop_id' => stop['stop_id'],
              'stop_name' => stop['stop_name'],
            }.merge(
              patterns.map do |run_id, pattern|
                [run_id, pattern['departures'].select do |departure|
                  departure['stop_id'] == stop['stop_id']
                end.first]
              end.select {|run_id, v| !v.nil?}.map do |run_id, departure|
               [run_id.to_s, DateTime.parse(departure["scheduled_departure_utc"]).to_time.localtime.strftime("%H.%M")]
              end.to_h
            ),
            links: {
              'stop_id' => @app.lq(:departures, route_type: params[:route_type], stop_id: stop['stop_id']),
              'stop_name' => @app.lq(:departures, route_type: params[:route_type], stop_id: stop['stop_id'])
            }
          }
        end
      )
    end
  end
end