class QueryBuilder::CastRealProjection(T) < QueryBuilder::Projection(T)
  private getter projection : Projection(T)

  def initialize(@projection : Projection(T))
  end

  def build : String
    "CAST(#{projection.build} AS REAL)"
  end

  def params : Array(T)
    projection.params
  end
end
