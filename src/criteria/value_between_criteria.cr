class QueryBuilder::ValueBetweenCriteria(T) < QueryBuilder::Criteria(T)
  private getter value : T
  private getter column_min : Projection(T)
  private getter column_max : Projection(T)

  def initialize(@column_min : Projection(T), @column_max : Projection(T), @value : T)
  end

  def build : String
    String.build do |s|
      s << (value.nil? ? "NULL" : "?")
      s << " BETWEEN "
      s << column_min.build
      s << " AND "
      s << column_max.build
    end
  end

  def params : Array(T)
    ret = [] of T
    ret << value unless value.nil?
    ret += column_min.params
    ret += column_max.params
    ret
  end
end
