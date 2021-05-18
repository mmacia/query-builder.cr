module QueryBuilder
  abstract class SqlBuilder(T)
    abstract def build : String
    abstract def params : Array(T)
  end
end
