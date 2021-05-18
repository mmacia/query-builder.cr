require "../../spec_helper"

describe QueryBuilder::JoinFrom do
  subject = QueryBuilder.builder_for("sqlite3")

  context "inner join" do
    it "should join tables" do
      subject.reset!
        .select("o.id", "o.created_at", "i.name", "i.price")
        .from("o.orders")
        .inner_join("ol.order_lines", "ol.order_id = o.id")
        .inner_join("i.items", "ol.item_id = i.id")

      expected = <<-SQL
      SELECT `o`.`id`, `o`.`created_at`, `i`.`name`, `i`.`price` FROM `orders` AS `o`
      INNER JOIN `order_lines` AS `ol` ON `ol`.`order_id` = `o`.`id`
      INNER JOIN `items` AS `i` ON `ol`.`item_id` = `i`.`id`;
      SQL

      subject.build.should eq(expected.gsub("\n", " "))
      subject.params.should eq([] of DB::Any)
    end

    it "should join tables with additional contiditon" do
      date = "2020-12-03"
      condition = Sqlite3::Criteria.equals(
        Sqlite3::Projection.column("ol.created_at"),
        Sqlite3::Projection.constant(date).cast_date
      )

      subject.reset!
        .select("o.id", "o.created_at", "i.name", "i.price")
        .from(
          Sqlite3::From.table("orders", "o")
            .inner_join("order_lines", "ol").on("ol.order_id", "o.id").on_and(condition)
            .inner_join("items", "i").on("ol.item_id", "i.id")
        )

      expected = <<-SQL
      SELECT `o`.`id`, `o`.`created_at`, `i`.`name`, `i`.`price` FROM `orders` AS `o`
      INNER JOIN `order_lines` AS `ol` ON (`ol`.`order_id` = `o`.`id` AND `ol`.`created_at` = DATE(?))
      INNER JOIN `items` AS `i` ON `ol`.`item_id` = `i`.`id`;
      SQL

      subject.build.should eq(expected.gsub("\n", " "))
      subject.params.should eq([date])
    end

    it "should join a subquery" do
      subquery = QueryBuilder.builder_for("sqlite3")

      subquery
        .select("id")
        .from("i.items")
        .where("i.name": "test")

      subject.reset!
        .select("o.id", "o.created_at")
        .from(
          Sqlite3::From.table("orders", "o")
            .inner_join(subquery, "t").on("o.item_id", "t.id")
        )

      expected = <<-SQL
      SELECT `o`.`id`, `o`.`created_at` FROM `orders` AS `o`
      INNER JOIN (SELECT `id` FROM `items` AS `i` WHERE `i`.`name` = ?) AS `t` ON `o`.`item_id` = `t`.`id`;
      SQL

      subject.build.should eq(expected.gsub("\n", " "))
      subject.params.should eq(["test"])
    end
  end

  context "left join" do
    it "should join tables" do
      subject.reset!
        .select("o.id", "o.created_at", "i.name", "i.price")
        .from("o.orders")
        .left_join("ol.order_lines", "ol.order_id = o.id")
        .left_join("i.items", "ol.item_id = i.id")

      expected = <<-SQL
      SELECT `o`.`id`, `o`.`created_at`, `i`.`name`, `i`.`price` FROM `orders` AS `o`
      LEFT JOIN `order_lines` AS `ol` ON `ol`.`order_id` = `o`.`id`
      LEFT JOIN `items` AS `i` ON `ol`.`item_id` = `i`.`id`;
      SQL

      subject.build.should eq(expected.gsub("\n", " "))
      subject.params.should eq([] of DB::Any)
    end

    it "should join tables with additional contiditon" do
      date = "2020-12-03"
      condition = Sqlite3::Criteria.equals(
        Sqlite3::Projection.column("ol.created_at"),
        Sqlite3::Projection.constant(date).cast_date
      )

      subject.reset!
        .select("o.id", "o.created_at", "i.name", "i.price")
        .from(
          Sqlite3::From.table("orders", "o")
            .left_join("order_lines", "ol").on("ol.order_id", "o.id").on_and(condition)
            .left_join("items", "i").on("ol.item_id", "i.id")
        )

      expected = <<-SQL
      SELECT `o`.`id`, `o`.`created_at`, `i`.`name`, `i`.`price` FROM `orders` AS `o`
      LEFT JOIN `order_lines` AS `ol` ON (`ol`.`order_id` = `o`.`id` AND `ol`.`created_at` = DATE(?))
      LEFT JOIN `items` AS `i` ON `ol`.`item_id` = `i`.`id`;
      SQL

      subject.build.should eq(expected.gsub("\n", " "))
      subject.params.should eq([date])
    end

    it "should join a subquery" do
      subquery = QueryBuilder.builder_for("sqlite3")

      subquery
        .select("id")
        .from("i.items")
        .where("i.name": "test")

      subject.reset!
        .select("o.id", "o.created_at")
        .from(
          Sqlite3::From.table("orders", "o")
            .left_join(subquery, "t").on("o.item_id", "t.id")
        )

      expected = <<-SQL
      SELECT `o`.`id`, `o`.`created_at` FROM `orders` AS `o`
      LEFT JOIN (SELECT `id` FROM `items` AS `i` WHERE `i`.`name` = ?) AS `t` ON `o`.`item_id` = `t`.`id`;
      SQL

      subject.build.should eq(expected.gsub("\n", " "))
      subject.params.should eq(["test"])
    end
  end
end
