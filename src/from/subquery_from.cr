class QueryBuilder::SubqueryFrom(T) < QueryBuilder::From(T)
  include AliasableFrom

  private getter subquery : SqlBuilder(T)

  def initialize(@subquery : SqlBuilder)
  end

  def build : String
    String.build do |s|
      s << "(#{subquery.build.rchop(';')})"
      s << " AS `#{self.alias}`" unless self.alias.nil?
    end
  end

  def params : Array(T)
    subquery.params
  end
end
