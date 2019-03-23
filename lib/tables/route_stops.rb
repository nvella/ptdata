require_relative '../table'

module PTSheets::Tables
  class RouteStops < PTSheets::Table
    SCHEMA = {
      "stop_suburb" => "string",
      "stop_name" => "string",
      "stop_id" => 0,
      "route_type" => 0,
      "stop_latitude" => 0,
      "stop_longitude" => 0,
      "stop_sequence" => 0
    }

    def self.get(route_id, route_type_id)
      PTSheets::Table.new(
        "#{PTSheets::ROUTE_TYPES.select {|k,v| v == route_type_id.to_i}.first[0]} Route #{route_id} Stops",
        SCHEMA.keys,
        PTSheets::PTV.stops_for_route(route_id, route_type_id).map do |stop|
          {
            vals: route,
            links: {
              'stop_name' => "/stop/#{route_type_id}/#{stop['stop_id']}"
            }
          }
        end
      )
    end
  end
end