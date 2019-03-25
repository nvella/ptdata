require 'date'

module PTData
  class Query
    attr_reader :title, :params

    def initialize(app, params, executor)
      @app = app
      @title = params[:title]
      @params = params[:params]
      @executor = executor
    end

    def format_params(input)
      missing_parameters = @params.select {|k, props| props[:required] && !input.has_key?(k)}
      if !missing_parameters.empty?
        raise QueryParameterError, "The following required parameters are missing from your query: " +
        "#{missing_parameters.map {|k, props| props[:label]}.join(', ').chomp(', ')}.";
      end

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

  class QueryParameterError < Exception
  end
end