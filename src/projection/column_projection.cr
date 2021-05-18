class QueryBuilder::ColumnProjection(T) < QueryBuilder::Projection(T)
  getter name : String
  getter table : String? = nil
  getter params : Array(T)

  def initialize(@name : String, @table : String? = nil)
    @params = [] of T
  end

  def build : String
    String.build do |s|
      s << "`#{table}`." if table
      if name == "*"
        s << name
      else
        s << "`#{name}`"
      end
    end
  end
end
