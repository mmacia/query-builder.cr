require "../../spec_helper"

describe QueryBuilder::CriteriaParser do
  parser = QueryBuilder::CriteriaParser(DB::Any).new

  it "should parse expression: column = string" do
    subject = parser.parse "name = \"jhon\""
    subject.build.should eq("`name` = ?")
    subject.params.should eq(["jhon"])
  end

  it "should parse expression: column = integer" do
    subject = parser.parse "age = 23"
    subject.build.should eq("`age` = ?")
    subject.params.should eq([23])
  end

  it "should parse expression: column = float" do
    subject = parser.parse "temperature = 23.5"
    subject.build.should eq("`temperature` = ?")
    subject.params.should eq([23.5])
  end

  it "should parse expression: column = column" do
    subject = parser.parse "pl.product_id = p.id"
    subject.build.should eq("`pl`.`product_id` = `p`.`id`")
    subject.params.should eq([] of DB::Any)
  end

  it "should parse expression: column != string" do
    subject = parser.parse "name != \"jhon\""
    subject.build.should eq("`name` != ?")
    subject.params.should eq(["jhon"])
  end

  it "should parse expression: column != integer" do
    subject = parser.parse "age != 23"
    subject.build.should eq("`age` != ?")
    subject.params.should eq([23])
  end

  it "should parse expression: column != float" do
    subject = parser.parse "temperature != 23.5"
    subject.build.should eq("`temperature` != ?")
    subject.params.should eq([23.5])
  end

  it "should parse expression: column != column" do
    subject = parser.parse "pl.product_id != p.id"
    subject.build.should eq("`pl`.`product_id` != `p`.`id`")
    subject.params.should eq([] of DB::Any)
  end

  it "should parse expression: column > string" do
    subject = parser.parse "age > 18"
    subject.build.should eq("`age` > ?")
    subject.params.should eq([18])
  end

  it "should parse expression: column < integer" do
    subject = parser.parse "age < 18"
    subject.build.should eq("`age` < ?")
    subject.params.should eq([18])
  end

  it "should parse expression: column >= float" do
    subject = parser.parse "age >= 18"
    subject.build.should eq("`age` >= ?")
    subject.params.should eq([18])
  end

  it "should parse expression: column <= string" do
    subject = parser.parse "age <= 18"
    subject.build.should eq("`age` <= ?")
    subject.params.should eq([18])
  end

  it "should raise an exception on invalid expression" do
    expect_raises RuntimeError, "Unprocessable expression" do
      parser.parse "age @ 18"
    end
  end
end
