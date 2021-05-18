class QueryBuilder::AndCriteria(T) < QueryBuilder::Criteria(T)
  getter left : Criteria(T)
  getter right : Criteria(T)

  def initialize(@left : Criteria(T), @right : Criteria(T))
  end

  def build : String
    ret = " AND "

    ret = left.build + ret unless left.nil?
    ret = ret + right.build unless right.nil?

    "(#{ret.strip})"
  end

  def params : Array(T)
    ret = Array(T).new

    ret += left.params unless left.nil?
    ret += right.params unless right.nil?

    ret
  end
end
