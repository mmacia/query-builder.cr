require "../../spec_helper"

describe QueryBuilder::CastDateProjection do
  it "should project a cast to date" do
    subject = QueryBuilder.builder_for("sqlite3")
    subject.select(Sqlite3::Projection.column("birthday").cast_date).from("students")

    subject.build.should eq("SELECT DATE(`birthday`) FROM `students`;")
    subject.params.should eq([] of DB::Any)
  end
end
