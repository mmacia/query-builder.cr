class QueryBuilder::CastDatetimeProjection(T) < QueryBuilder::Projection(T)
  private getter projection : Projection(T)

  def initialize(@projection : Projection(T))
  end

  def build : String
    "DATETIME(#{projection.build})"
  end

  def params : Array(T)
    projection.params
  end
end
