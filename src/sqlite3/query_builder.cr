require "sqlite3"
require "db"

require "../projection"
require "../sql_query_type"
require "../sql_builder"
require "../projection"
require "../from"
require "../criteria"
require "../order"

module Sqlite3
  alias Projection = ::QueryBuilder::Projection(DB::Any)
  alias SqlBuilder = ::QueryBuilder::SqlBuilder(DB::Any)
  alias QueryType  = ::QueryBuilder::SqlQueryType
  alias From       = ::QueryBuilder::From(DB::Any)
  alias TableFrom  = ::QueryBuilder::TableFrom(DB::Any)
  alias Criteria   = ::QueryBuilder::Criteria(DB::Any)
  alias Order      = ::QueryBuilder::Order(DB::Any)

  class QueryBuilder < SqlBuilder
    private property projections : Array(Projection) = [] of Projection
    private property from : From? = nil
    private property criteria : Criteria? = nil
    private property orders_by : Array(Order) = [] of Order
    private property groups_by : Array(Projection) = [] of Projection
    private property having : Criteria? = nil
    private property? union_all : Bool = false
    private property union_queries : Array(SqlBuilder) = [] of SqlBuilder
    private property query_type : QueryType = QueryType::None
    private property take_rows : Int32? = nil
    private property offset : Int32? = nil
    private property? distinct : Bool = false

    # insert stuff
    private property insert_projections : Array(Projection) = [] of Projection
    private property insert_values : Array(DB::Any) = [] of DB::Any
    private property insert_subquery : SqlBuilder? = nil

    # update stuff
    private property update_projections : Array(Projection) = [] of Projection
    private property update_values : Array(DB::Any) = [] of DB::Any

    def select(*columns)
      self.query_type = QueryType::Select

      columns.each do |c|
        if c.is_a? String
          @projections << Projection.column(c)
        elsif c.is_a? Projection
          @projections << c
        else
          raise ArgumentError.new("Cannot select '#{c}' (#{c.class})")
        end
      end
      self
    end

    def select(columns : Array(String | Projection))
      self.query_type = QueryType::Select

      columns.each do |c|
        if c.is_a? String
          @projections << Projection.column(c)
        elsif c.is_a? Projection
          @projections << c
        end
      end
      self
    end

    def from(table : String)
      t = TableFrom.parse_table(table)
      self.from(t)
      self
    end

    def from(subquery : SqlBuilder)
      from(From.subquery(subquery))
      self
    end

    def from(from : From)
      self.from = from
      self
    end

    def left_join(table : String, condition : String)
      t = From.parse_table(table)
      c = Criteria.parse(condition)
      self.from = self.from.not_nil!.left_join(t).on(c)
      self
    end

    def inner_join(table : String, condition : String)
      t = From.parse_table(table)
      c = Criteria.parse(condition)
      self.from = self.from.not_nil!.inner_join(t).on(c)
      self
    end

    def join(table : String, condition : String)
      inner_join table, condition
    end

    def where(criteria : Criteria)
      if self.criteria.nil?
        self.criteria = criteria
      else
        self.criteria = self.criteria.not_nil!.and(criteria)
      end

      self
    end

    def where(**conditions)
      conditions.each do |field, value|
        if value.is_a? Array
          values = [] of DB::Any
          values += value
          where Criteria.in(field.to_s, values)
        elsif value.is_a? Range
          where Criteria.between(field.to_s, value.min, value.max)
        else
          where Criteria.equals(field.to_s, value)
        end
      end

      self
    end

    def or(criteria : Criteria)
      if self.criteria.nil?
        self.criteria = criteria
      else
        self.criteria = self.criteria.not_nil!.or(criteria)
      end

      self
    end

    def or(**conditions)
      conditions.each do |field, value|
        if value.is_a? Array
          values = [] of DB::Any
          values += value
          self.or Criteria.in(field.to_s, values)
        elsif value.is_a? Range
          self.or Criteria.between(field.to_s, value.min, value.max)
        else
          self.or Criteria.equals(field.to_s, value)
        end
      end

      self
    end

    def group_by(*columns)
      columns.each do |c|
        if c.is_a? String
          groups_by << Projection.column(c)
        elsif  c.is_a? Projection
          groups_by << c
        else
          raise ArgumentError.new("Cannot order by '#{c}' (#{c.class})")
        end
      end
      self
    end

    def having(criteria : Criteria)
      self.having = criteria
      self
    end

    def order_by(*columns, sort : String = "ASC", ignore_case : Bool = false)
      columns.each do |c|
        if c.is_a? String || c.is_a? Projection
          orders_by << Order.order_by(c, sort, ignore_case)
        else
          raise ArgumentError.new("Cannot order by '#{c}' (#{c.class})")
        end
      end
      self
    end

    def limit(rows : Int32, offset : DB::Any? = nil)
      self.take_rows = rows
      self.offset = offset
      self
    end

    def distinct
      @distinct = true
      self
    end

    def not_distinct
      @distinct = false
    end

    def union(query : SqlBuilder)
      self.union_all = false
      union_queries << query
      self
    end

    def union_all(query : SqlBuilder)
      self.union_all = true
      union_queries << query
      self
    end

    def reset!
      self.projections        = [] of Projection
      self.from               = nil
      self.criteria           = nil
      self.orders_by          = [] of Order
      self.groups_by          = [] of Projection
      self.having             = nil
      self.union_all          = false
      self.union_queries      = [] of SqlBuilder
      self.query_type         = QueryType::Select
      self.take_rows          = nil
      self.offset             = nil
      self.distinct           = false
      self.query_type         = QueryType::None

      self.insert_projections = [] of Projection
      self.insert_values      = [] of DB::Any
      self.insert_subquery    = nil

      self.update_projections = [] of Projection
      self.update_values      = [] of DB::Any
      self
    end

    def reset_limit!
      self.take_rows = nil
      self.offset = nil
    end

    def reset_group_by!
      self.groups_by = [] of Projection
    end

    def reset_order_by!
      self.orders_by = [] of Order
    end

    #
    # Insert specifics
    #
    def insert
      self.query_type = QueryType::Insert
      self
    end

    def into(table : String, aliased_name : String? = nil)
      t = From.table(table)
      aliased_name.nil? ? into(t) : into(t.alias(aliased_name))
    end

    def into(table : From)
      self.from = table
      self
    end

    def from_select(subquery : SqlBuilder)
      self.insert_subquery = subquery
      self
    end

    def columns(*insert_columns)
      insert_columns.each do |c|
        if c.is_a? String
          insert_projections << Projection.column(c)
        elsif c.is_a? Projection
          insert_projections << c
        else
          raise ArgumentError.new("Cannot insert column '#{c}' (#{c.class})")
        end
      end
      self
    end

    def columns(insert_columns : Array(String | Projection))
      insert_columns.each do |c|
        if c.is_a? String
          insert_projections << Projection.column(c)
        else
          insert_projections << c
        end
      end
      self
    end

    def values(*ivalues)
      ivalues.each { |iv| self.insert_values << iv }
      self
    end

    def values(ivalues : Array(DB::Any))
      ivalues.each { |iv| self.insert_values << iv }
      self
    end

    #
    # Update specifics
    #
    def update(table : String)
      self.query_type = QueryType::Update
      update(From.table(table))
    end

    def update(table : From)
      self.query_type = QueryType::Update
      self.from = table
      self
    end

    def set(column : String, value : T)
      set(Projection.column(column), value)
    end

    def set(column : Projection, value : T)
      self.update_projections << column
      self.update_values << value
      self
    end

    #
    # Delete
    #
    def delete(table : String)
      self.query_type = QueryType::Delete
      delete(From.table(table))
    end

    def delete(table : From)
      self.query_type = QueryType::Delete
      self.from = table
      self
    end

    def build : String
      case query_type
      when QueryType::Select
        build_select
      when QueryType::Insert
        build_insert
      when QueryType::Update
        build_update
      when QueryType::Delete
        build_delete
      else
        ""
      end
    end

    def params : Array(DB::Any)
      case query_type
      when QueryType::Select
        params_select
      when QueryType::Insert
        params_insert
      when QueryType::Update
        params_update
      when QueryType::Delete
        params_delete
      else
        [] of DB::Any
      end
    end

    private def params_select : Array(DB::Any)
      ret = Array(DB::Any).new

      ret += projections.reduce([] of DB::Any) { |memo, prj| memo + prj.params }
      ret += from.not_nil!.params unless from.nil?
      ret += criteria.not_nil!.params unless criteria.nil?
      ret += having.not_nil!.params unless having.nil?

      union_queries.each { |q| ret += q.params }

      if take_rows
        ret << take_rows
        ret << offset if offset
      end

      ret
    end

    private def build_select : String
      String.build do |s|
        s << "SELECT "
        s << "DISTINCT " if distinct?
        s << projections.map { |p| p.build.as(String) }.join(", ")
        s << " FROM #{from.not_nil!.build}" if from
        s << " WHERE #{criteria.not_nil!.build}" if criteria
        s << " GROUP BY #{groups_by.map { |g| g.build.as(String) }.join(", ")}" unless groups_by.empty?
        s << " HAVING #{having.not_nil!.build}" if having

        unless union_queries.empty?
          union_type = union_all? ? " UNION ALL " : " UNION "
          s << union_type

          s << union_queries.map do |u|
            u = u.dup
            u.reset_limit!
            u.reset_order_by!

            u.build.rchop(";")
          end.join(union_type)
        end

        s << " ORDER BY #{orders_by.map {|o| o.build.as(String) }.join(", ")}" unless orders_by.empty?

        if take_rows
          s << " LIMIT ?"
          s << " OFFSET ?" if offset
        end

        s << ";"
      end
    end

    private def params_insert : Array(DB::Any)
      ret = Array(DB::Any).new
      ret += insert_values
      ret += insert_subquery.not_nil!.params unless insert_subquery.nil?
      ret
    end

    private def build_insert : String
      String.build do |s|
        s << "INSERT "
        s << "INTO #{from.not_nil!.build}" if from

        if insert_projections && insert_subquery.nil?
          s << " (#{insert_projections.map { |p| p.build.as(String) }.join(", ")})"
          s << " VALUES(#{insert_projections.map { |_| "?" }.join(", ")})"
        elsif insert_projections && insert_subquery
          s << " (#{insert_projections.map { |p| p.build.as(String) }.join(", ")}) "
          s << insert_subquery.not_nil!.build.rstrip(";")
        end

        s << ";"
      end
    end

    private def params_update : Array(DB::Any)
      ret = [] of DB::Any
      ret += update_values
      ret += criteria.not_nil!.params unless criteria.nil?
      ret
    end

    private def build_update : String
      String.build do |s|
        s << "UPDATE "
        s << from.not_nil!.build if from
        s << " SET "
        s << update_projections.map { |prj| "#{prj.build} = ?" }.join(", ")
        s << " WHERE #{criteria.not_nil!.build}" if criteria

        s << ";"
      end
    end

    private def params_delete : Array(DB::Any)
      ret = [] of DB::Any
      ret += criteria.not_nil!.params unless criteria.nil?
      ret
    end

    private def build_delete : String
      String.build do |s|
        s << "DELETE"
        s << " FROM #{from.not_nil!.build}" if from
        s << " WHERE #{criteria.not_nil!.build}" if criteria

        s << ";"
      end
    end
  end
end
