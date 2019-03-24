require 'date'

module PTSheets
  class Query
    attr_reader :title, :params

    def initialize(app, params, executor)
      @app = app
      @title = params[:title]
      @params = params[:params]
      @executor = executor
    end

    def format_params(input)
      @params.map do |k, props|
        [
          k,
          case props[:type]
          when :number
            input[k].to_i
          when :date
            input[k].class == String ? Date.parse(input[k]) : Date.today
          end
        ]
      end.to_h
    end

    def execute(params); @executor.call(params); end
  end
end