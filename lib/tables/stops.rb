require_relative '../table'

module PTData::Tables
  class Stops < PTData::Table
    SCHEMA = {
      "stop_suburb" => "string",
      "stop_name" => "string",
      "stop_id" => 0,
      "route_type" => 0,
      "stop_latitude" => 0,
      "stop_longitude" => 0,
      "stop_sequence" => 0
    }

    def self.get(route_type, route_id)
      self.new(
        "#{PTData::ROUTE_TYPES.select {|k,v| v == route_type.to_i}.first[0]} Route ID #{route_id} Stops",
        SCHEMA.keys,
        PTData::PTV.stops_for_route(route_id, route_type).map do |stop|
          {
            vals: stop,
            links: {
              'stop_id' => "/q/departures?route_type=#{route_type}&stop_id=#{stop['stop_id']}",
              'stop_name' => "/q/departures?route_type=#{route_type}&stop_id=#{stop['stop_id']}"
            }
          }
        end
      )
    end
  end
end