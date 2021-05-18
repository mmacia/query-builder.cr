abstract class QueryBuilder::Projection(T)
  abstract def build : String
  abstract def params : Array(T)

  #
  # simple columns
  #
  def self.column(col : String) : ColumnProjection(T)
    parts = col.split(".")
    if parts.size == 2
      table, name = parts
      ColumnProjection(T).new(name, table)
    else
      ColumnProjection(T).new(col)
    end
  end

  def self.column(table : String, column : String) : ColumnProjection(T)
    ColumnProjection(T).new(name, table)
  end

  #
  # constant
  #
  def self.constant(constant : T) : ConstantProjection(T)
    ConstantProjection(T).new(constant)
  end

  #
  # aggregate functions
  #
  def self.min(column : String) : AggregateProjection(T)
    min(column(column))
  end

  def self.min(projection : Projection) : AggregateProjection(T)
    AggregateProjection.new projection, AggregateProjection::Type::Min
  end

  def self.max(column : String) : AggregateProjection(T)
    max(column(column))
  end

  def self.max(projection : Projection) : AggregateProjection(T)
    AggregateProjection.new projection, AggregateProjection::Type::Max
  end

  def self.sum(column : String) : AggregateProjection(T)
    sum(column(column))
  end

  def self.sum(projection : Projection) : AggregateProjection(T)
    AggregateProjection.new projection, AggregateProjection::Type::Sum
  end

  def self.avg(column : String) : AggregateProjection(T)
    avg(column(column))
  end

  def self.avg(projection : Projection) : AggregateProjection(T)
    AggregateProjection.new projection, AggregateProjection::Type::Avg
  end

  def self.count(column : String) : AggregateProjection(T)
    count(column(column))
  end

  def self.count(projection : Projection) : AggregateProjection(T)
    AggregateProjection.new projection, AggregateProjection::Type::Count
  end

  def self.count : AggregateProjection(T)
    AggregateProjection.new column("*"), AggregateProjection::Type::Count
  end

  #
  # subquery
  #
  def self.subquery(subquery : SqlBuilder) : SubqueryProjection(T)
    SubqueryProjection.new subquery
  end

  def self.subquery(subquery : SqlBuilder, _as : String) : AliasedProjection(T)
    SubqueryProjection.new(subquery).alias(_as)
  end

  #
  # Alias and casts
  #
  def alias(name : String) : Projection(T)
    AliasedProjection.new self, name
  end

  def cast_date : Projection(T)
    CastDateProjection.new self
  end

  def cast_datetime : Projection(T)
    CastDatetimeProjection.new self
  end

  def cast_real : Projection(T)
    CastRealProjection.new self
  end

  def cast_int : Projection(T)
    CastIntegerProjection.new self
  end

  def cast_string : Projection(T)
    CastStringProjection.new self
  end
end

require "./column_projection"
require "./constant_projection"
require "./aggregate_projection"
require "./subquery_projection"
require "./aliased_projection"
require "./cast_date_projection"
require "./cast_datetime_projection"
require "./cast_real_projection"
require "./cast_integer_projection"
require "./cast_string_projection"
