require "./sqlite3/*"

module QueryBuilder
  VERSION = "0.1.0"

  def self.builder_for(name : String)
    case name.downcase
    when "sqlite3"
      Sqlite3::QueryBuilder.new
    else
      raise ArgumentError.new "#{name} is not a valid driver"
    end
  end
end
