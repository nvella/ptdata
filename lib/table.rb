require 'csv'

module PTData
  class Table
    attr_accessor :title, :cols, :rows
  
    def initialize(title, cols = [], rows = [])
      @title = title
      @cols = cols
      @rows = rows
    end
  
    def to_csv
      CSV.generate do |csv|
        csv << @cols
        @rows.each do |row| 
          csv << @cols.map {|k| row[:vals][k]}
        end
      end
    end

    def keys; @cols; end
  end
end