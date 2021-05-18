require "../../spec_helper"

describe QueryBuilder::SubqueryProjection do
  it "should project a subquery" do
    subquery = QueryBuilder.builder_for("sqlite3")
    subquery.select(Sqlite3::Projection.max("age")).from("students")

    subject = QueryBuilder.builder_for("sqlite3")
    subject.select(Sqlite3::Projection.subquery(subquery, "max_age"))

    subject.build.should eq("SELECT (SELECT MAX(`age`) FROM `students`) AS `max_age`;")
    subject.params.should eq([] of DB::Any)
  end
end
