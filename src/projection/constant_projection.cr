class QueryBuilder::ConstantProjection(T) < QueryBuilder::Projection(T)
  private getter constant : T

  def initialize(@constant : T)
  end

  def build : String
    constant.nil? ? "NULL" : "?"
  end

  def params : Array(T)
    ret = [] of T
    ret << constant unless constant.nil?
    ret
  end
end
