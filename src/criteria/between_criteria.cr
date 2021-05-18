class QueryBuilder::BetweenCriteria(T) < QueryBuilder::Criteria(T)
  private getter projection : Projection(T)
  private getter min_value : T
  private getter max_value : T

  def initialize(@projection : Projection(T), @min_value : T, @max_value : T)
  end

  def build : String
    String.build do |s|
      s << projection.build
      s << " BETWEEN "
      s << (min_value.nil? ? "NULL" : "?")
      s << " AND "
      s << (max_value.nil? ? "NULL" : "?")
    end
  end

  def params : Array(T)
    ret = [] of T
    ret += projection.params
    ret << min_value unless min_value.nil?
    ret << max_value unless max_value.nil?
    ret
  end
end
