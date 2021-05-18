require "../../spec_helper"

describe QueryBuilder::CastIntegerProjection do
  it "should project a cast to date" do
    subject = QueryBuilder.builder_for("sqlite3")
    subject.select(Sqlite3::Projection.column("age").cast_int).from("students")

    subject.build.should eq("SELECT CAST(`age` AS INTEGER) FROM `students`;")
    subject.params.should eq([] of DB::Any)
  end
end
