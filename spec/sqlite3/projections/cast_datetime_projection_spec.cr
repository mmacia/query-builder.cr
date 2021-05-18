require "../../spec_helper"

describe QueryBuilder::CastDatetimeProjection do
  it "should project a cast to datetime" do
    subject = QueryBuilder.builder_for("sqlite3")
    subject.select(Sqlite3::Projection.column("updated_at").cast_datetime).from("students")

    subject.build.should eq("SELECT DATETIME(`updated_at`) FROM `students`;")
    subject.params.should eq([] of DB::Any)
  end
end
