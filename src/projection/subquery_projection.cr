class QueryBuilder::SubqueryProjection(T) < QueryBuilder::Projection(T)
  private getter subquery : SqlBuilder(T)

  def initialize(@subquery : SqlBuilder(T))
  end

  def build : String
    "(#{subquery.build.rchop(';')})"
  end

  def params : Array(T)
    subquery.params
  end
end
