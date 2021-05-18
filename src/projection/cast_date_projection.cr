class QueryBuilder::CastDateProjection(T) < QueryBuilder::Projection(T)
  private getter projection : Projection(T)

  def initialize(@projection : Projection(T))
  end

  def build : String
    "DATE(#{projection.build})"
  end

  def params : Array(T)
    projection.params
  end
end
