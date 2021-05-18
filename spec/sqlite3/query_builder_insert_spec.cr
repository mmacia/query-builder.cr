require "../spec_helper"

describe Sqlite3::QueryBuilder do
  subject = QueryBuilder.builder_for("sqlite3")

  it "build basic insert clausule" do
    subject.reset!
      .insert
      .into("students")
      .columns("name", "age", "genre")
      .values("jhon", 13, "male")

    subject.build.should eq("INSERT INTO `students` (`name`, `age`, `genre`) VALUES(?, ?, ?);")
    subject.params.should eq(["jhon", 13, "male"])
  end

  it "build insert clausule with select" do
    subquery = QueryBuilder.builder_for("sqlite3")
    subquery
      .select("name", "address", "city", "postal_code")
      .from("supliers")

    subject.reset!
      .insert
      .into("customers")
      .columns("name", "address", "city", "postal_code")
      .from_select(subquery)

    subject.build.should eq(
      "INSERT INTO `customers` (`name`, `address`, `city`, `postal_code`)" +
      " SELECT `name`, `address`, `city`, `postal_code` FROM `supliers`;"
    )
    subject.params.should eq([] of DB::Any)
  end
end
