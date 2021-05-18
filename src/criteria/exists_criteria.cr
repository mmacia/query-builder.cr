class QueryBuilder::ExistsCriteria(T) < QueryBuilder::Criteria(T)
  private getter subquery : SqlBuilder(T)
  private getter? negated : Bool

  def initialize(@subquery : SqlBuilder(T), @negated : Bool = false)
  end

  def build : String
    String.build do |s|
      s << "NOT " if negated?
      s << "EXISTS(#{subquery.build.rchop(";")})"
    end
  end

  def params : Array(T)
    ret = [] of T
    ret += subquery.params
    ret
  end
end
