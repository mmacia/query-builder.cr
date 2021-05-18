require "../spec_helper"

describe QueryBuilder::Order do
  subject = QueryBuilder.builder_for("sqlite3")

  it "should order ascending" do
    subject.reset!.select("column1").order_by("column1", "column2")

    subject.build.should eq("SELECT `column1` ORDER BY `column1` ASC, `column2` ASC;")
    subject.params.should eq([] of DB::Any)
  end

  it "should order descending" do
    subject.reset!.select("column1").order_by("column1", "column2", sort: "DESC")

    subject.build.should eq("SELECT `column1` ORDER BY `column1` DESC, `column2` DESC;")
    subject.params.should eq([] of DB::Any)
  end

  it "should order descending and ascending" do
    subject.reset!.select("column1").order_by("column1", sort: "ASC").order_by("column2", sort: "DESC")

    subject.build.should eq("SELECT `column1` ORDER BY `column1` ASC, `column2` DESC;")
    subject.params.should eq([] of DB::Any)
  end

  it "should order ascending ignore case" do
    subject.reset!.select("column1").order_by("column1", "column2", ignore_case: true)

    subject.build.should eq("SELECT `column1` ORDER BY `column1` COLLATE NOCASE ASC, `column2` COLLATE NOCASE ASC;")
    subject.params.should eq([] of DB::Any)
  end

  it "should order descending ignore case" do
    subject.reset!.select("column1").order_by("column1", "column2", sort: "desc", ignore_case: true)

    subject.build.should eq("SELECT `column1` ORDER BY `column1` COLLATE NOCASE DESC, `column2` COLLATE NOCASE DESC;")
    subject.params.should eq([] of DB::Any)
  end

  it "should order ascending and descending ignore case" do
    subject.reset!
      .select("column1")
      .order_by("column1", ignore_case: true)
      .order_by("column2", sort: "desc", ignore_case: true)

    subject.build.should eq("SELECT `column1` ORDER BY `column1` COLLATE NOCASE ASC, `column2` COLLATE NOCASE DESC;")
    subject.params.should eq([] of DB::Any)
  end
end
