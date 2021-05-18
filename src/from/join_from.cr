class QueryBuilder::JoinFrom(T) < QueryBuilder::From(T)
  private getter left : From(T)
  private getter right : From(T)
  private getter join_type : String
  private getter criteria : Criteria(T)

  def initialize(@left : From, @right : From, @join_type : String, @criteria : Criteria)
  end

  def on_or(left_column : String, right_column : String)
    on_or(Criteria(T).equals(Projection(T).column(left_column), Projection(T).column(right_column)))
  end

  def on_or(criteria : Criteria)
    @criteria = self.criteria.or(criteria)
    self
  end

  def on_and(left_column : String, right_column : String)
    on_and(Criteria(T).equals(Projection(T).column(left_column), Projection(T).column(right_column)))
  end

  def on_and(criteria : Criteria)
    @criteria = self.criteria.and(criteria)
    self
  end

  def build : String
    "#{left.build} #{join_type} #{right.build} ON #{criteria.build}"
  end

  def params : Array(T)
    ret = [] of T
    ret += left.params
    ret += right.params
    ret += criteria.params
    ret
  end
end
