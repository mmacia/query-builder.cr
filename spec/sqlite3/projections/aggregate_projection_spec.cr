require "../../spec_helper"

describe QueryBuilder::AggregateProjection do
  subject = QueryBuilder.builder_for("sqlite3")

  it "should aggregate min function" do
    subject.reset!.select(Sqlite3::Projection.min("age"))

    subject.build.should eq("SELECT MIN(`age`);")
    subject.params.should eq([] of DB::Any)
  end

  it "should aggregate max function" do
    subject.reset!.select(Sqlite3::Projection.max("age"))

    subject.build.should eq("SELECT MAX(`age`);")
    subject.params.should eq([] of DB::Any)
  end

  it "should aggregate sum function" do
    subject.reset!.select(Sqlite3::Projection.sum("age"))

    subject.build.should eq("SELECT SUM(`age`);")
    subject.params.should eq([] of DB::Any)
  end

  it "should aggregate avg function" do
    subject.reset!.select(Sqlite3::Projection.avg("age"))

    subject.build.should eq("SELECT AVG(`age`);")
    subject.params.should eq([] of DB::Any)
  end

  it "should aggregate count function" do
    subject.reset!.select(Sqlite3::Projection.count("age"))

    subject.build.should eq("SELECT COUNT(`age`);")
    subject.params.should eq([] of DB::Any)
  end

  it "should count all rows" do
    subject.reset!.select(Sqlite3::Projection.count)

    subject.build.should eq("SELECT COUNT(*);")
    subject.params.should eq([] of DB::Any)
  end
end
