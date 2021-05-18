class QueryBuilder::InCriteria(T) < QueryBuilder::Criteria(T)
  private getter column : Projection(T)
  private getter values : Array(T)
  private getter? negated : Bool

  def initialize(@column : Projection(T), @values : Array(T), @negated : Bool = false)
  end

  def build : String
    String.build do |s|
      s << column.build

      if negated?
        s << " NOT IN("
        s << "1=1" if values.empty?
      else
        s << " IN("
        s << "1=0" if values.empty?
      end

      s << values.map { |v| v.nil? ? "NULL" : "?" }.join(", ").rstrip
      s << ")"
    end
  end

  def params : Array(T)
    ret = [] of T
    ret += column.params
    values.each do |v|
      ret << v unless v.nil?
    end
    ret
  end
end
