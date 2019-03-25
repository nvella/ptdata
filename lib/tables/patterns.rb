require_relative '../table'

module PTSheets::Tables
  class Patterns < PTSheets::Table
    SCHEMA = {
      "stop_id" => 0,
      "stop_suburb" => "",
      "stop_name" => "",
      "route_id" => 0,
      "run_id" => 0,
      "direction_id" => 0,
      "scheduled_departure_utc" => "2019-03-25T05:21:56.040Z",
      "estimated_departure_utc" => "2019-03-25T05:21:56.040Z",
      "at_platform" => true,
      "platform_number" => "string",
      "flags" => "string",
      "departure_sequence" => 0,
    }

    def self.get(route_type_id, run_id)
      pattern = PTSheets::PTV.pattern(run_id, route_type_id, {
        expand: 'all'
      })

      PTSheets::Table.new(
        "",
        SCHEMA.keys,
        pattern['departures'].map do |departure|
          {
            vals: departure.merge({
              'route_name' => pattern['routes'][departure['route_id'].to_s]['route_name'],
              'stop_name' => pattern['stops'][departure['stop_id'].to_s]['stop_name'],
              'stop_suburb' => pattern['stops'][departure['stop_id'].to_s]['stop_suburb'],
            }),
            links: {
              'route_id' => "/q/stops?route_type_id=#{route_type_id}&route_id=#{departure['route_id']}",
              'route_name' => "/q/stops?route_type_id=#{route_type_id}&route_id=#{departure['route_id']}"
            }
          }
        end
      )
    end
  end
end