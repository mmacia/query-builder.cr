require "./spec_helper"

describe QueryBuilder do
  it "should instantiate a new builder" do
    subject = QueryBuilder.builder_for("sqlite3")
    subject.should be_a(Sqlite3::QueryBuilder)
  end

  it "should raise an exception  when driver not exists" do
    expect_raises(ArgumentError) do
      QueryBuilder.builder_for("unknown")
    end
  end
end
