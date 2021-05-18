require "../projection"
require "../sql_operator"

class QueryBuilder::BasicCriteria(T) < QueryBuilder::Criteria(T)
  getter projection : Projection(T)
  getter operator : Operator
  getter value : T | Projection(T)

  def initialize(@projection : Projection(T), @operator : Operator, @value : T | Projection(T))
    if value.nil?
      if operator == Operator::IsNull || operator == Operator::Equals || operator == Operator::Like
        @operator = Operator::IsNull
      else
        @operator = Operator::IsNotNull
      end
    end
  end

  def build : String
    String.build do |s|
      s << "#{projection.build} #{operator} "

      if value.is_a?(Projection)
        s << value.as(Projection(T)).build
      else
        s << "?" unless value.nil?
      end
    end.rstrip(" ")
  end

  def params : Array(T)
    ret = Array(T).new

    ret += projection.params unless projection.nil?

    if value.is_a?(Projection)
      ret += value.as(Projection(T)).params
    else
      ret << value.as(T) unless value.nil?
    end

    ret
  end
end
