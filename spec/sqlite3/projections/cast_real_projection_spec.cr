require "../../spec_helper"

describe QueryBuilder::CastRealProjection do
  it "should project a cast real" do
    subject = QueryBuilder.builder_for("sqlite3")
    subject.select(Sqlite3::Projection.column("age").cast_real).from("students")

    subject.build.should eq("SELECT CAST(`age` AS REAL) FROM `students`;")
    subject.params.should eq([] of DB::Any)
  end
end
