require_relative '../table'

module PTData::Queries
  class Stops < PTData::Query
    id :stops
    title 'Stops by Route Type and ID'

    input_param :route_type, label: 'Route Type', type: :number, required: true
    input_param :route_id, label: 'Route ID', type: :number, required: true

    SCHEMA = {
      "stop_suburb" => "string",
      "stop_name" => "string",
      "stop_id" => 0,
      "route_type" => 0,
      "stop_latitude" => 0,
      "stop_longitude" => 0,
      "stop_sequence" => 0
    }

    def execute(params)
      PTData::Table.new(
        "#{PTData::ROUTE_TYPES.select {|k,v| v == params[:route_type].to_i}.first[0]} Route ID #{params[:route_id]} Stops",
        SCHEMA.keys,
        PTData::PTV.stops_for_route(params[:route_id], params[:route_type]).map do |stop|
          {
            vals: stop,
            links: {
              'stop_id' => "/q/departures?route_type=#{params[:route_type]}&stop_id=#{stop['stop_id']}",
              'stop_name' => "/q/departures?route_type=#{params[:route_type]}&stop_id=#{stop['stop_id']}"
            }
          }
        end
      )
    end
  end
end