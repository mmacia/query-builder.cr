require "../spec_helper"

describe Sqlite3::QueryBuilder do
  subject = QueryBuilder.builder_for("sqlite3")

  it "should select columns from String" do
    subject.reset!.select("name", "id", "price")

    subject.build.should eq("SELECT `name`, `id`, `price`;")
  end

  it "should select from a table" do
    subject.reset!
      .select("name", "id", "price")
      .from("items")

    subject.build.should eq("SELECT `name`, `id`, `price` FROM `items`;")
  end

  it "should filter by Criteria" do
    subject.reset!
      .select("name", "id", "price")
      .from("items")
      .where(Sqlite3::Criteria.equals("name", "pepe"))

    subject.build.should eq("SELECT `name`, `id`, `price` FROM `items` WHERE `name` = ?;")
    subject.params.should eq(["pepe"])
  end

  context "filter by NamedTuple" do
    it "should compose equals Criteria" do
      subject.reset!
        .select("name", "id", "price")
        .from("items")
        .where(name: "pepe")

      subject.build.should eq("SELECT `name`, `id`, `price` FROM `items` WHERE `name` = ?;")
      subject.params.should eq(["pepe"])
    end

    it "should compose between Criteria" do
      subject.reset!
        .select("name", "id", "price")
        .from("items")
        .where(price: 20..50)

      subject.build.should eq("SELECT `name`, `id`, `price` FROM `items` WHERE `price` BETWEEN ? AND ?;")
      subject.params.should eq([20, 50])
    end

    it "should compose inclusion Criteria" do
      subject.reset!
        .select("name", "id", "price")
        .from("items")
        .where(name: ["pepe", "manolo"])

      subject.build.should eq("SELECT `name`, `id`, `price` FROM `items` WHERE `name` IN(?, ?);")
      subject.params.should eq(["pepe", "manolo"])
    end
  end

  context "where OR" do
    it "should chain a new criteria" do
      subject.reset!
        .select("name", "id", "price")
        .from("items")
        .where(name: "pepe")
        .where.or(name: "manolo")

      subject.build.should eq("SELECT `name`, `id`, `price` FROM `items` WHERE (`name` = ? OR `name` = ?);")
      subject.params.should eq(["pepe", "manolo"])
    end
  end

  it "should limit result" do
    subject.reset!
      .select("name", "id", "price")
      .from("items")
      .limit(25)

    subject.build.should eq("SELECT `name`, `id`, `price` FROM `items` LIMIT ?;")
    subject.params.should eq([25])
  end

  it "should offset the limit" do
    subject.reset!
      .select("name", "id", "price")
      .from("items")
      .limit(25, 100)

    subject.build.should eq("SELECT `name`, `id`, `price` FROM `items` LIMIT ? OFFSET ?;")
    subject.params.should eq([25, 100])
  end

  it "should group by" do
    subject.reset!
      .select("name", "id", "price")
      .from("items")
      .group_by("name", "id")

    subject.build.should eq("SELECT `name`, `id`, `price` FROM `items` GROUP BY `name`, `id`;")
  end

  it "should union queries" do
    q1 = QueryBuilder.builder_for("sqlite3")
    q1
      .select("q1.c1", "q1.c2")
      .from("q1.table1")
      .where("q1.c1": 10)

    q2 = QueryBuilder.builder_for("sqlite3")
    q2
      .select("q2.c1", "q2.c2")
      .from("q2.table2")
      .where("q2.c1": 15)

    subject = q1.union(q2)

    subject.build.should eq(
      "SELECT `q1`.`c1`, `q1`.`c2` FROM `table1` AS `q1` WHERE `q1`.`c1` = ?" +
      " UNION " +
      "SELECT `q2`.`c1`, `q2`.`c2` FROM `table2` AS `q2` WHERE `q2`.`c1` = ?;"
    )
    subject.params.should eq([10, 15])
  end

  it "should union all queries" do
    q1 = QueryBuilder.builder_for("sqlite3")
    q1
      .select("q1.c1", "q1.c2")
      .from("q1.table1")
      .where("q1.c1": 10)

    q2 = QueryBuilder.builder_for("sqlite3")
    q2
      .select("q2.c1", "q2.c2")
      .from("q2.table2")
      .where("q2.c1": 15)

    subject = q1.union_all(q2)

    subject.build.should eq(
      "SELECT `q1`.`c1`, `q1`.`c2` FROM `table1` AS `q1` WHERE `q1`.`c1` = ?" +
      " UNION ALL " +
      "SELECT `q2`.`c1`, `q2`.`c2` FROM `table2` AS `q2` WHERE `q2`.`c1` = ?;"
    )
    subject.params.should eq([10, 15])
  end

  it "should build a disctinct clause" do
    subject.reset!
      .select("q1.c1", "q1.c2")
      .distinct
      .from("q1.table1")
      .where("q1.c1": 10)

    subject.build.should eq("SELECT DISTINCT `q1`.`c1`, `q1`.`c2` FROM `table1` AS `q1` WHERE `q1`.`c1` = ?;")
    subject.params.should eq([10])
  end

  it "should build a simple having clause" do
    subject.reset!
      .select("album_id", Sqlite3::Projection.count("track_id"))
      .from("tracks")
      .group_by("album_id")
      .having(Sqlite3::Criteria.equals("album_id", 1))

    subject.build.should eq("SELECT `album_id`, COUNT(`track_id`) FROM `tracks` GROUP BY `album_id` HAVING `album_id` = ?;")
    subject.params.should eq([1])
  end

  it "should build a complex having clause" do
    subject.reset!
      .select("album_id", Sqlite3::Projection.count("track_id"))
      .from("tracks")
      .group_by("album_id")
      .having(Sqlite3::Criteria.between(Sqlite3::Projection.count("album_id"), 18, 20))
      .order_by("album_id")

    subject.build.should eq(
      "SELECT `album_id`, COUNT(`track_id`) FROM `tracks` GROUP BY `album_id` HAVING COUNT(`album_id`) BETWEEN ? AND ? ORDER BY `album_id` ASC;"
    )
    subject.params.should eq([18, 20])
  end
end
