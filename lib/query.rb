require 'date'

module PTData
  class Query
    class << self
      def id(id); @id = id; end
      def title(title); @title = title; end

      def input_param(key, val)
        @input_params ||= {} 
        @input_params[key] = val
      end
    end

    def initialize(app)
      @app = app
    end

    # Class variable readers
    def id; self.class.instance_variable_get :@id; end 
    def title; self.class.instance_variable_get :@title; end
    def input_params; self.class.instance_variable_get :@input_params; end

    def format_params(input)
      missing_parameters = input_params.select {|k, props| props[:required] && !input.has_key?(k)}
      if !missing_parameters.empty?
        raise QueryParameterError, "The following required parameters are missing from your query: " +
        "#{missing_parameters.map {|k, props| props[:label]}.join(', ').chomp(', ')}.";
      end

      input_params.map do |k, props|
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

    def execute(params); nil; end
  end

  class QueryParameterError < Exception
  end
end