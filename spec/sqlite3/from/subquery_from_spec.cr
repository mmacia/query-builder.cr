require "../../spec_helper"

describe QueryBuilder::SubqueryFrom do
  subject = QueryBuilder.builder_for("sqlite3")

  it "should select from a subquery" do
    subquery = QueryBuilder.builder_for("sqlite3")

    subquery.select("nickname", "name").from("users")
    subject.reset!.select("name").from(subquery)

    subject.build.should eq(
      "SELECT `name` FROM (SELECT `nickname`, `name` FROM `users`);"
    )
    subject.params.should eq([] of DB::Any)
  end

  it "should select from a subquery with alias" do
    subquery = QueryBuilder.builder_for("sqlite3")

    subquery.select("nickname", "name").from("users")
    aliased_subquery = Sqlite3::From.subquery(subquery, "t")
    subject.reset!.select("t.name").from(aliased_subquery)

    subject.build.should eq(
      "SELECT `t`.`name` FROM (SELECT `nickname`, `name` FROM `users`) AS `t`;"
    )
    subject.params.should eq([] of DB::Any)
  end
end
