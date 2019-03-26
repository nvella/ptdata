require_relative '../table'

module PTData::Tables
  class Patterns < PTData::Table
    SCHEMA = {
      "stop_id" => 0,
      "stop_name" => "",
      "stop_suburb" => "",
      "route_id" => 0,
      "run_id" => 0,
      "direction_id" => 0,
      "scheduled_departure_utc" => "2019-03-25T05:21:56.040Z",
      "scheduled_departure_human" => "",
      #"estimated_departure_utc" => "2019-03-25T05:21:56.040Z",
      "at_platform" => true,
      "platform_number" => "string",
      "flags" => "string",
      "departure_sequence" => 0,
    }

    def self.get(route_type, run_id)
      pattern = PTData::PTV.pattern(run_id, route_type, {
        expand: 'all'
      })
      first_stop = pattern['stops'][pattern['departures'].first['stop_id'].to_s]['stop_name']
      last_stop = pattern['stops'][pattern['departures'].last['stop_id'].to_s]['stop_name']

      PTData::Table.new(
        "Run #{run_id} from #{first_stop} to #{last_stop}",
        SCHEMA.keys,
        pattern['departures'].map do |departure|
          {
            vals: departure.merge({
              'route_name' => pattern['routes'][departure['route_id'].to_s]['route_name'],
              'stop_name' => pattern['stops'][departure['stop_id'].to_s]['stop_name'],
              'stop_suburb' => pattern['stops'][departure['stop_id'].to_s]['stop_suburb'],
              'scheduled_departure_human' => DateTime.parse(departure["scheduled_departure_utc"]).to_time.localtime.to_datetime.strftime("%Y-%m-%d %H:%M:%S"),
            }),
            links: {
              'stop_id' => "/q/departures?route_type=#{route_type}&stop_id=#{departure['stop_id']}",
              'stop_name' => "/q/departures?route_type=#{route_type}&stop_id=#{departure['stop_id']}",
              'route_id' => "/q/stops?route_type=#{route_type}&route_id=#{departure['route_id']}",
              'route_name' => "/q/stops?route_type=#{route_type}&route_id=#{departure['route_id']}"
            }
          }
        end
      )
    end
  end
end