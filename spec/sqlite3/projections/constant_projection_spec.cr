require "../../spec_helper"

describe QueryBuilder::ConstantProjection do
  subject = QueryBuilder.builder_for("sqlite3")

  it "should select constant projection" do
    subject.reset!.select(Sqlite3::Projection.constant("Test"), Sqlite3::Projection.constant(5))

    subject.build.should eq("SELECT ?, ?;")
    subject.params.should eq(["Test", 5])
  end

  it "should select constant projection with null value" do
    subject.reset!.select(Sqlite3::Projection.constant("Test"), Sqlite3::Projection.constant(nil))

    subject.build.should eq("SELECT ?, NULL;")
    subject.params.should eq(["Test"])
  end
end
