class QueryBuilder::Order(T)
  protected getter projection : Projection(T)
  protected getter sort : String
  protected getter? ignore_case : Bool

  def initialize(@projection : Projection(T), sort : String, @ignore_case : Bool)
    unless ["DESC", "ASC"].includes?(sort.upcase)
      raise ArgumentError.new("Cannot sort the order by '#{sort}', only ASC or DESC")
    end

    @sort = sort.upcase
  end

  def self.order_by(column : String, sort : String, ignore_case : Bool)
    order_by Projection(T).column(column), sort, ignore_case
  end

  def self.order_by(column : Projection, sort : String, ignore_case : Bool)
    self.new column, sort, ignore_case
  end

  def build : String
    String.build do |s|
      s << projection.build
      s << " COLLATE NOCASE" if ignore_case?
      s << " #{sort}"
    end
  end

  def params : Array(T)
    projection.params
  end
end
