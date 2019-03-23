require 'date'
require_relative '../table'

module PTSheets::Tables
  class Departures < PTSheets::Table
    SCHEMA = {
      "stop_id" => 0,
      "route_id" => 0,
      "route_number" => 0,
      "route_name" => "",
      "run_id" => 0,
      "direction_id" => 0,
      "direction_name" => "",
      "scheduled_departure_utc" => "2019-03-23T12:29:20.532Z",
      "scheduled_departure_human" => "",
      # "estimated_departure_utc" => "2019-03-23T12:29:20.532Z",
      # "estimated_departure_human" => "",
      "at_platform" => true,
      "platform_number" => "string",
      "flags" => "string",
      "departure_sequence" => 0
    }

    def self.get(route_type_id, stop_id, date = Date.today)
      data = PTSheets::PTV.departures(route_type_id, stop_id, {
        max_results: 1000,
        date_utc: date.to_time.getutc.to_datetime.iso8601,
        include_cancelled: true,
        expand: "[stop,direction,route]"
      })

      return PTSheets::Table.new(
        "#{data['stops'][stop_id]['stop_name']} Departures for #{date}",
        SCHEMA.keys,
        data['departures']
          .filter {|d| DateTime.parse(d['scheduled_departure_utc']).to_time.localtime.to_date == date}
          .sort_by {|d| DateTime.parse(d["scheduled_departure_utc"])}
          .map do |departure|
            {
              vals: departure.merge({
                "route_name" => data["routes"][departure["route_id"].to_s]["route_name"],
                "route_number" => data["routes"][departure["route_id"].to_s]["route_number"],
                "direction_name" => data["directions"][departure["direction_id"].to_s]["direction_name"],
                "scheduled_departure_human" => DateTime.parse(departure["scheduled_departure_utc"]).to_time.localtime.to_datetime.strftime("%Y-%m-%d %H:%M:%S"),
                #"estimated_departure_human" => departure["estimated_departure_utc"] ? 
                #  DateTime.parse(departure["estimated_departure_utc"]).to_time.localtime.to_datetime.strftime("%Y/%m/%d %H:%M:%S") : nil,
              }),
              links: {
                'route_id' => "/stops/#{route_type_id}/#{departure['route_id']}",
                'route_name' => "/stops/#{route_type_id}/#{departure['route_id']}",
                'route_number' => "/stops/#{route_type_id}/#{departure['route_id']}"
              }
            }
          end
      )
    end
  end
end