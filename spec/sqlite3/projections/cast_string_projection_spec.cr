require "../../spec_helper"

describe QueryBuilder::CastStringProjection do
  it "should project a cast to string" do
    subject = QueryBuilder.builder_for("sqlite3")
    subject.select(Sqlite3::Projection.column("name").cast_string).from("students")

    subject.build.should eq("SELECT CAST(`name` AS TEXT) FROM `students`;")
    subject.params.should eq([] of DB::Any)
  end
end
