class QueryBuilder::TableFrom(T) < QueryBuilder::From(T)
  include AliasableFrom

  private property table : String
  getter params : Array(T) = [] of T

  def initialize(@table : String, @alias : String? = nil)
  end

  def build : String
    String.build do |s|
      s << "`#{table}`"
      s << " AS `#{self.alias}`" unless self.alias.nil?
    end
  end
end
