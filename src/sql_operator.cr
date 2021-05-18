enum QueryBuilder::Operator
  Equals
  NotEquals
  IsNull
  IsNotNull
  Greater
  Lesser
  GreaterOrEquals
  LesserOrEquals
  Like
  NotLike

  def to_s : String
    mapping = {
      "Equals": "=",
      "NotEquals": "!=",
      "Greater": ">",
      "Lesser": "<",
      "GreaterOrEquals": ">=",
      "LesserOrEquals": "<=",
      "IsNull": "IS NULL",
      "IsNotNull": "IS NOT NULL",
      "Like": "LIKE",
      "NotLike": "NOT LIKE",
    }

    ret = mapping[super]?
    raise ArgumentError.new "Operator #{super} not exists." unless ret

    ret.not_nil!
  end

  def self.parse(str : String)
    case str.downcase
    when "="
      Equals
    when "!="
      NotEquals
    when ">"
      Greater
    when "<"
      Lesser
    when ">="
      GreaterOrEquals
    when "<="
      LesserOrEquals
    when "like"
      Like
    else
      super(str)
    end
  end
end
