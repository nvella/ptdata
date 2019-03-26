require_relative '../table'

module PTData::Queries
  class Routes < PTData::Query
    id :routes
    title 'Routes by Route Type'

    input_param :route_type, label: 'Route Type', type: :number, required: true

    SCHEMA = {
      "route_type" => 0,
      "route_id" => 0,
      "route_number" => "string",
      "route_name" => "string",
      "route_gtfs_id" => "string"
    }

    def execute(params)
      PTData::Table.new(
        "#{PTData::ROUTE_TYPES.select {|k,v| v == params[:route_type]}.first[0]} Routes",
        SCHEMA.keys,
        PTData::PTV.routes(route_types: [params[:route_type]]).map do |route|
          {
            vals: route,
            links: {
              'route_id' => "/q/stops?route_type=#{params[:route_type]}&route_id=#{route['route_id']}",
              'route_name' => "/q/stops?route_type=#{params[:route_type]}&route_id=#{route['route_id']}"
            }
          }
        end
      )
    end
  end
end