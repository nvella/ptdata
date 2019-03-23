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

        def self.get(route_type_id)
            PTSheets::Table.new(
                "#{PTSheets::ROUTE_TYPES.select {|k,v| v == route_type_id.to_i}.first[0]} Routes",
                SCHEMA.keys,
                PTSheets::PTV.routes(route_types: [route_type_id]).map do |route|
                    {
                        vals: route,
                        links: {
                            'route_name' => "/routes/#{route_type_id}/#{route['route_id']}"
                        }
                    }
                end
            )
        end
    end
end