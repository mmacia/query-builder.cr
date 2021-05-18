class QueryBuilder::AggregateProjection(T) < QueryBuilder::Projection(T)
  private getter projection : Projection(T)
  private getter type : Type

  enum Type
    Min
    Max
    Sum
    Avg
    Count
  end

  def initialize(@projection : Projection(T), @type : Type)
  end

  def build : String
    ret = projection.build

    case type
    when Type::Min
      ret = "MIN(#{ret})"
    when Type::Max
      ret = "MAX(#{ret})"
    when Type::Sum
      ret = "SUM(#{ret})"
    when Type::Avg
      ret = "AVG(#{ret})"
    when Type::Count
      ret = "COUNT(#{ret})"
    end

    ret
  end

  def params : Array(T)
    projection.params
  end
end
