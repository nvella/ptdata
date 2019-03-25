module PTData
  class Table
    attr_accessor :title, :cols, :rows
  
    def initialize(title, cols = [], rows = [])
      @title = title
      @cols = cols
      @rows = rows
    end
  
    def to_csv
  
    end

    def keys; @cols; end
  end
end