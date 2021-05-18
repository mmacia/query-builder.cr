require "../../spec_helper"

describe QueryBuilder::TableFrom do
  subject = QueryBuilder.builder_for("sqlite3")

  it "should select from a table" do
    subject.reset!.select("name").from("students")

    subject.build.should eq("SELECT `name` FROM `students`;")
    subject.params.should eq([] of DB::Any)
  end

  it "should select from a table with alias" do
    subject.reset!.select("name").from("s.students")

    subject.build.should eq("SELECT `name` FROM `students` AS `s`;")
    subject.params.should eq([] of DB::Any)
  end

  it "should aliase table name" do
    table = Sqlite3::From.table("students")
    table.alias("s")

    table.build.should eq("`students` AS `s`")
  end

  it "should aliase table name directly in constructor" do
    table = Sqlite3::From.table("students", "s")
    table.build.should eq("`students` AS `s`")
  end
end
