class QueryBuilder::AliasedProjection(T) < QueryBuilder::Projection(T)
  private getter projection : Projection(T)
  private getter name : String

  def initialize(@projection : Projection(T), @name : String)
  end

  def alias(@name : String) : Projection(T)
    self
  end

  def cast_date : Projection(T)
    self.projection = projection.cast_date
    self
  end

  def cast_datetime : Projection(T)
    self.projection = projection.cast_datetime
    self
  end

  def cast_real : Projection(T)
    self.projection = projection.cast_real
    self
  end

  def cast_int : Projection(T)
    self.projection = projection.cast_int
    self
  end

  def cast_string : Projection(T)
    self.projection = projection.cast_string
    self
  end

  def build : String
    "#{projection.build} AS `#{name}`"
  end

  def params : Array(T)
    projection.params
  end
end
