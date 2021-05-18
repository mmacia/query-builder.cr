abstract class QueryBuilder::Criteria(T)
  abstract def build : String
  abstract def params : Array(T)

  private class_property? not : Bool = false

  def self.parse(stm : String) : Criteria(T)
    parser = CriteriaParser(T).new
    parser.parse(stm)
  end

  #
  # Null
  #
  def self.is_null(column : String)
    is_null Projection(T).column(column)
  end

  def self.is_null(column : Projection)
    BasicCriteria.new column, Operator::IsNull, nil
  end

  def self.is_not_null(column : String)
    is_not_null Projection(T).column(column)
  end

  def self.is_not_null(column : Projection)
    BasicCriteria.new column, Operator::IsNotNull, nil
  end

  #
  # Basic criterias
  #
  def self.not
    self.not = true
    self
  end

  def self.equals(column : String, value : T)
    equals Projection(T).column(column), value
  end

  def self.equals(column : Projection, value : T)
    op = not? ? Operator::NotEquals : Operator::Equals
    self.not = false
    BasicCriteria(T).new column, op, value
  end

  def self.equals(left_column : Projection, right_column : Projection)
    op = not? ? Operator::NotEquals : Operator::Equals
    self.not = false
    BasicCriteria(T).new left_column, op, right_column
  end

  def self.greater_than(column : String, value : T)
    greater_than Projection(T).column(column), value
  end

  def self.greater_than(column : Projection, value : T)
    BasicCriteria(T).new column, Operator::Greater, value
  end

  def self.lesser_than(column : String, value : T)
    lesser_than Projection(T).column(column), value
  end

  def self.lesser_than(column : Projection, value : T)
    BasicCriteria(T).new column, Operator::Lesser, value
  end

  def self.greater_than_or_equals(column : String, value : T)
    greater_than_or_equals Projection(T).column(column), value
  end

  def self.greater_than_or_equals(column : Projection, value : T)
    BasicCriteria(T).new column, Operator::GreaterOrEquals, value
  end

  def self.lesser_than_or_equals(column : String, value : T)
    lesser_than_or_equals Projection(T).column(column), value
  end

  def self.lesser_than_or_equals(column : Projection, value : T)
    BasicCriteria(T).new column, Operator::LesserOrEquals, value
  end

  #
  # String only criterias
  #
  def self.starts_with(column : String, value : String)
    starts_with Projection(T).column(column), value
  end

  def self.starts_with(column : Projection, value : String)
    op = not? ? Operator::NotLike : Operator::Like
    self.not = false
    BasicCriteria(T).new column, op, "#{value}%"
  end

  def self.ends_with(column : String, value : String)
    ends_with Projection(T).column(column), value
  end

  def self.ends_with(column : Projection, value : String)
    op = not? ? Operator::NotLike : Operator::Like
    self.not = false
    BasicCriteria.new column, op, "%#{value}"
  end

  def self.contains(column : String, value : String)
    contains Projection(T).column(column), value
  end

  def self.contains(column : Projection, value : String)
    op = not? ? Operator::NotLike : Operator::Like
    self.not = false
    BasicCriteria.new column, op, "%#{value}%"
  end

  #
  # Between
  #
  def self.between(column : String, min_value : T, max_value : T)
    between Projection(T).column(column), min_value, max_value
  end

  def self.between(column : Projection, min_value : T, max_value : T)
    BetweenCriteria.new column, min_value, max_value
  end

  def self.value_between(column_min : String, column_max : String, value : T)
    value_between Projection(T).column(column_min), Projection(T).column(column_max), value
  end

  def self.value_between(column_min : Projection, column_max : Projection, value : T)
    ValueBetweenCriteria(T).new column_min, column_max, value
  end

  #
  # Exists
  #
  def self.exists(subquery : SqlBuilder)
    negated = not? ? true : false
    self.not = false
    ExistsCriteria.new subquery, negated
  end

  #
  # In
  #
  def self.in(column : String, values : Array(T))
    self.in Projection(T).column(column), values
  end

  def self.in(column : Projection, values : Array(T))
    negated = not? ? true : false
    self.not = false
    InCriteria.new column, values, negated
  end

  #
  # Logic chains
  #
  def and(criteria : Criteria)
    AndCriteria.new(self, criteria)
  end

  def or(criteria : Criteria)
    OrCriteria.new(self, criteria)
  end
end

require "../sql_operator"
require "./basic_criteria"
require "./between_criteria"
require "./value_between_criteria"
require "./exists_criteria"
require "./in_criteria"
require "./and_criteria"
require "./or_criteria"
require "./criteria_parser"
