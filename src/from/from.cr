abstract class QueryBuilder::From(T)
  abstract def build : String
  abstract def params : Array(T)

  class PartialJoin(T)
    private getter left : From(T)
    private getter right : From(T)
    private getter join_type : String

    def initialize(@left : From, @right : From, @join_type : String)
    end

    def on(left_column : String, right_column : String) : JoinFrom
      on(Criteria(T).equals(Projection(T).column(left_column), Projection(T).column(right_column)))
    end

    def on(criteria : Criteria) : JoinFrom
      JoinFrom(T).new left, right, join_type, criteria
    end
  end

  def self.table(table : String, _as : String? = nil) : TableFrom(T)
    TableFrom(T).new(table, _as)
  end

  def self.subquery(subquery : SqlBuilder, _as : String? = nil) : SubqueryFrom(T)
    sq = SubqueryFrom(T).new subquery
    sq.alias(_as) if _as
    sq
  end

  def self.parse_table(table : String) : TableFrom(T)
    if table.index('.')
      _as, table_name = table.split(".")
      self.table(table_name, _as)
    else
      self.table(table)
    end
  end

  def inner_join(table : String, aliased_name : String? = nil) : PartialJoin
    t = From(T).table(table)
    aliased_name.nil? ? inner_join(t) : inner_join(t.alias(aliased_name))
  end

  def inner_join(table : From) : PartialJoin
    PartialJoin(T).new self, table, "INNER JOIN"
  end

  def inner_join(subquery : SqlBuilder, aliased_name : String? = nil) : PartialJoin
    s = From(T).subquery(subquery)
    aliased_name.nil? ? inner_join(s) : inner_join(s.alias(aliased_name))
  end

  def left_join(table : String, aliased_name : String? = nil) : PartialJoin
    t = From(T).table(table)
    aliased_name.nil? ? left_join(t) : left_join(t.alias(aliased_name))
  end

  def left_join(table : From) : PartialJoin
    PartialJoin(T).new self, table, "LEFT JOIN"
  end

  def left_join(subquery : SqlBuilder, aliased_name : String? = nil) : PartialJoin
    s = From(T).subquery(subquery)
    aliased_name.nil? ? left_join(s) : left_join(s.alias(aliased_name))
  end
end

require "./aliasable_from"
require "./table_from"
require "./subquery_from"
require "./join_from"
