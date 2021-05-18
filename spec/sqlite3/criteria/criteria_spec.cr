require "../../spec_helper"

describe QueryBuilder::Criteria do
  it "should build a Is Null criteria" do
    subject = Sqlite3::Criteria.is_null("column")
    subject.build.should eq("`column` IS NULL")
  end

  it "should build a Not Is Null criteria" do
    subject = Sqlite3::Criteria.is_not_null("column")
    subject.build.should eq("`column` IS NOT NULL")
  end

  it "should build a Equals criteria" do
    subject = Sqlite3::Criteria.equals("column", 2)
    subject.build.should eq("`column` = ?")
    subject.params.should eq([2])
  end

  it "should build a Equals criteria with 2 columns" do
    subject = Sqlite3::Criteria.equals(Sqlite3::Projection.column("column1"), Sqlite3::Projection.column("column2"))
    subject.build.should eq("`column1` = `column2`")
  end

  it "should build a Is Null criteria when equals to nil" do
    subject = Sqlite3::Criteria.equals("column", nil)
    subject.build.should eq("`column` IS NULL")
  end

  it "should build a Not Equals criteria" do
    subject = Sqlite3::Criteria.not.equals("column", 2)
    subject.build.should eq("`column` != ?")
    subject.params.should eq([2])
  end

  it "should build a Is Not Null criteria when equals to nil" do
    subject = Sqlite3::Criteria.not.equals("column", nil)
    subject.build.should eq("`column` IS NOT NULL")
  end

  it "should build a Greater than criteria" do
    subject = Sqlite3::Criteria.greater_than("column", 2)
    subject.build.should eq("`column` > ?")
    subject.params.should eq([2])
  end

  it "should build a Lesser than criteria" do
    subject = Sqlite3::Criteria.lesser_than("column", 2)
    subject.build.should eq("`column` < ?")
    subject.params.should eq([2])
  end

  it "should build a Greater or Equals criteria" do
    subject = Sqlite3::Criteria.greater_than_or_equals("column", 2)
    subject.build.should eq("`column` >= ?")
    subject.params.should eq([2])
  end

  it "should build a Lesser or Equals criteria" do
    subject = Sqlite3::Criteria.lesser_than_or_equals("column", 2)
    subject.build.should eq("`column` <= ?")
    subject.params.should eq([2])
  end

  it "should build a starts with criteria" do
    subject = Sqlite3::Criteria.starts_with("column", "test")
    subject.build.should eq("`column` LIKE ?")
    subject.params.should eq(["test%"])
  end

  it "should build a not starts with criteria" do
    subject = Sqlite3::Criteria.not.starts_with("column", "test")
    subject.build.should eq("`column` NOT LIKE ?")
    subject.params.should eq(["test%"])
  end

  it "should build a ends with criteria" do
    subject = Sqlite3::Criteria.ends_with("column", "test")
    subject.build.should eq("`column` LIKE ?")
    subject.params.should eq(["%test"])
  end

  it "should build a not ends with criteria" do
    subject = Sqlite3::Criteria.not.ends_with("column", "test")
    subject.build.should eq("`column` NOT LIKE ?")
    subject.params.should eq(["%test"])
  end

  it "should build a contains criteria" do
    subject = Sqlite3::Criteria.contains("column", "test")
    subject.build.should eq("`column` LIKE ?")
    subject.params.should eq(["%test%"])
  end

  it "should build a not contains criteria" do
    subject = Sqlite3::Criteria.not.contains("column", "test")
    subject.build.should eq("`column` NOT LIKE ?")
    subject.params.should eq(["%test%"])
  end

  it "should build a Between criteria" do
    subject = Sqlite3::Criteria.between("column", 1, 10)
    subject.build.should eq("`column` BETWEEN ? AND ?")
    subject.params.should eq([1, 10])
  end

  it "should build a Between criteria with null" do
    subject = Sqlite3::Criteria.between("column", nil, 10)
    subject.build.should eq("`column` BETWEEN NULL AND ?")
    subject.params.should eq([10])
  end

  it "should build a Value Between criteria" do
    subject = Sqlite3::Criteria.value_between("column1", "column2", 10)
    subject.build.should eq("? BETWEEN `column1` AND `column2`")
    subject.params.should eq([10])
  end

  it "should build a Value Between criteria with null" do
    subject = Sqlite3::Criteria.value_between("column1", "column2", nil)
    subject.build.should eq("NULL BETWEEN `column1` AND `column2`")
    subject.params.should eq([] of DB::Any)
  end

  it "should build a Exists criteria" do
    subquery = QueryBuilder.builder_for("sqlite3")
    subquery.select("id").from("students")

    subject = Sqlite3::Criteria.exists(subquery)
    subject.build.should eq("EXISTS(SELECT `id` FROM `students`)")
    subject.params.should eq([] of DB::Any)
  end

  it "should build a Not Exists criteria" do
    subquery = QueryBuilder.builder_for("sqlite3")
    subquery.select("id").from("students")

    subject = Sqlite3::Criteria.not.exists(subquery)
    subject.build.should eq("NOT EXISTS(SELECT `id` FROM `students`)")
    subject.params.should eq([] of DB::Any)
  end

  it "should build an In criteria" do
    values = [] of DB::Any
    values += [1, 2, 3]
    subject = Sqlite3::Criteria.in("column", values)
    subject.build.should eq("`column` IN(?, ?, ?)")
    subject.params.should eq(values)
  end

  it "should build an In criteria with nulls" do
    values = [] of DB::Any
    values += [1, 2, 3, nil]
    subject = Sqlite3::Criteria.in("column", values)
    subject.build.should eq("`column` IN(?, ?, ?, NULL)")
    subject.params.should eq([1, 2, 3])
  end

  it "should build a Not In criteria" do
    values = [] of DB::Any
    values += [1, 2, 3]
    subject = Sqlite3::Criteria.not.in("column", values)
    subject.build.should eq("`column` NOT IN(?, ?, ?)")
    subject.params.should eq(values)
  end

  it "should build a Not In criteria with nulls" do
    values = [] of DB::Any
    values += [1, 2, 3, nil]
    subject = Sqlite3::Criteria.not.in("column", values)
    subject.build.should eq("`column` NOT IN(?, ?, ?, NULL)")
    subject.params.should eq([1, 2, 3])
  end
end
