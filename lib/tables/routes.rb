require_relative '../table'

module PTSheets::Tables
  class Routes < PTSheets::Table
    SCHEMA = {
      "route_type" => 0,
      "route_id" => 0,
      "route_number" => "string",
      "route_name" => "string",
      "route_gtfs_id" => "string"
    }

    def self.get(route_type_id)
      PTSheets::Table.new(
        "#{PTSheets::ROUTE_TYPES.select {|k,v| v == route_type_id.to_i}.first[0]} Routes",
        SCHEMA.keys,
        PTSheets::PTV.routes(route_types: [route_type_id]).map do |route|
          {
            vals: route,
            links: {
              'route_id' => "/stops/#{route_type_id}/#{route['route_id']}",
              'route_name' => "/stops/#{route_type_id}/#{route['route_id']}"
            }
          }
        end
      )
    end
  end
end