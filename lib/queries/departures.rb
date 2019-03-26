require 'date'
require_relative '../table'

module PTData::Queries
  class Departures < PTData::Query
    id :departures
    title 'Departures by Route Type, Stop ID and Date'

    input_param :route_type, label: 'Route Type', type: :number, required: true
    input_param :stop_id, label: 'Stop ID', type: :number, required: true
    input_param :date, label: 'Date', type: :date

    schema \
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

    def execute(params)
      data = PTData::PTV.departures(params[:route_type], params[:stop_id], {
        max_results: 1000,
        date_utc: params[:date].to_time.getutc.to_datetime.iso8601,
        include_cancelled: true,
        expand: "[stop,direction,route]"
      })

      return PTData::Table.new(
        "#{data['stops'][params[:stop_id].to_s]['stop_name']} Departures for #{params[:date]}",
        schema.keys,
        data['departures']
          .filter {|d| DateTime.parse(d['scheduled_departure_utc']).to_time.localtime.to_date == params[:date]}
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
                'route_id' => "/q/stops?route_type=#{params[:route_type]}&route_id=#{departure['route_id']}",
                'route_name' => "/q/stops?route_type=#{params[:route_type]}&route_id=#{departure['route_id']}",
                'route_number' => "/q/stops?route_type=#{params[:route_type]}&route_id=#{departure['route_id']}",
                'run_id' => "/q/patterns?route_type=#{params[:route_type]}&run_id=#{departure['run_id']}"
              }
            }
          end
      )
    end
  end
end