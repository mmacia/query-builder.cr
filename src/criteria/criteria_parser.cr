class QueryBuilder::CriteriaParser(T)
  STM_RE = /([\w\d_\.]+)\s+(=|!=|>|<|<=|>=|like)\s+([\w\d_\.\"]+)/i

  private class Statement(T)
    @value : T = nil
    @is_value : Bool

    def initialize(stm : String)
      if stm.starts_with?("\"") && stm.ends_with?("\"") # seems a string
        @value = stm.strip("\"")
        @is_value = true
      elsif stm =~ /\d+\.\d+/                           # seems a float
        @value = stm.to_f64
        @is_value = true
      elsif stm =~ /\d+/                                # seems an integer
        @value = stm.to_i64
        @is_value = true
      else                                              # seems that's not a value
        @value = stm
        @is_value = false
      end
    end

    def value? : Bool
      @is_value
    end

    def column? : Bool
      !value?
    end

    def value : T
      @value.as(T)
    end

    def projection : Projection(T)
      Projection(T).column(@value.to_s)
    end
  end

  def parse(expression : String) : Criteria(T)
    _lhs, operator, _rhs = split_expression expression

    lhs = Statement(T).new(_lhs)
    rhs = Statement(T).new(_rhs)

    case operator
    when Operator::Equals
      if rhs.value?
        Criteria(T).equals(lhs.projection, rhs.value)
      else
        Criteria(T).equals(lhs.projection, rhs.projection)
      end

    when Operator::NotEquals
      if rhs.value?
        Criteria(T).not.equals(lhs.projection, rhs.value)
      else
        Criteria(T).not.equals(lhs.projection, rhs.projection)
      end

    when Operator::Lesser
      Criteria(T).lesser_than(lhs.projection, rhs.value)

    when Operator::Greater
      Criteria(T).greater_than(lhs.projection, rhs.value)

    when Operator::GreaterOrEquals
      Criteria(T).greater_than_or_equals(lhs.projection, rhs.value)

    when Operator::LesserOrEquals
      Criteria(T).lesser_than_or_equals(lhs.projection, rhs.value)

    else
      raise RuntimeError.new("Unprocessable expression: unknown operator '#{operator}'")
    end
  end

  private def split_expression(expression : String)
    matches = expression.match(STM_RE)
    raise RuntimeError.new("Unprocessable expression") if matches.nil? || matches.not_nil!.size != 4

    lhs = matches.not_nil![1]
    operator = Operator.parse(matches.not_nil![2].downcase)
    rhs = matches.not_nil![3]

    {lhs, operator, rhs}
  end
end
