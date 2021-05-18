module QueryBuilder::AliasableFrom
  protected property alias : String? = nil

  def alias(name : String)
    self.alias = name
    self
  end

  def aliased?
    !self.alias.nil?
  end
end
