module PTSheets
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
    
    class TableRow
        attr_accessor :vals, :links
    
        def initialize(vals, links = [])
            @vals = vals
            @links = links
        end
    
        def to_a
            @vals
        end
    
        def [](k)
            @vals[k]
        end
    
        def []=(k, v)
            @vals[k] = v
        end
    end 
end