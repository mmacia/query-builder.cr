# QueryBuilder for Crystal

QueryBuilder is a fluent library for building `SELECT`, `INSERT`, `UPDATE` and
`DELETE` statements for SQLite (for the moment).

Easy as ORM. Powerful as SQL.

```crystal
qb = QueryBuilder.builder_for "sqlite3"

qb.select("name", "id", "email")
  .from("users")
  .where(name: "pepe")

db = DB.open "sqlite3://%3Amemory%3A"
db.query qb.build, qb.params
```

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     query-builder:
       github: mmacia/query-builder.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "query-builder"
```

There are many ways to build a query: you can build the query using the
QueryBuilder primitives such as Projections, Criterias, etc. in a more formal
way or you can use the syntactic sugar shortcuts.

For the most common operations it's more convenient to use the shortcuts. They
feel like a common ORM fluent interface (ActiveRecord, SQLAlchemy, etc.).

If you want to take advantage of SQL and build more complex sentences, you can
use the formal method and get the best of both worlds: the powerful of SQL
without the burden of building it concatenating strings neither using a ORM that
dont't allow you to use the more advanced features.

Of course, you can mix formal and syntactic sugar shortcuts at you own will.

### Basic SELECT statement

```crystal
qb = QueryBuilder.builder_for "sqlite3"

qb.select("column1", "column2", "column3").from("table_name")

puts qb.build
# -> SELECT `column1`, `column2`, `column3` FROM `table_name`;
```

You can also call `select()` separatelly for each column (or mix both
approaches).

```crystal
qb = QueryBuilder.builder_for "sqlite3"

qb.select("column1, "column2")
  .select("column3")
  .from("table_name")

puts qb.build
# -> SELECT `column1`, `column2`, `column3` FROM `table_name`;
```

Arrays of strings are also accepted.

```crystal
qb = QueryBuilder.builder_for "sqlite3"

qb.select(%w(column1 column2 column3))
  .from("table_name")

puts qb.build
# -> SELECT `column1`, `column2`, `column3` FROM `table_name`;
```

### Complex SELECT clause

Projections are used to create complex `SELECT` columns or expressions.

```crystal
# you can define an alias to avoid type all the class namespace
alias Projection = Sqlite3::Projection

# Column with explicitly declared table (table name or table alias)
.select(Projection.column("table_name", "column1"))

# Constants (e.g. SELECT "Test", 5 FROM table_name)
.select(Projection.constant("Test"), Projection.constant(5))

# Aggregate functions
.select(Projection.min("column1"))
.select(Projection.max("column1"))
.select(Projection.sum("column1"))
.select(Projection.avg("column1"))
.select(Projection.count("column1"))
.select(Projection.count) // e.g. SELECT COUNT(*) FROM table_name

# Aliases. ANY Projection can be aliased by calling "alias"
.select(Projection.column("column1").as("c1"))
.select(Projection.constant(5).as("my_alias"))
.select(Projection.min("column1").as("min_col"))

# Aliases. These 3 sentences are exactly the same
.select("aliased_table.column1")
.select(Projection.column("aliased_table.column1"))
.select(Projection.column("aliased_table", "column1"))

# Casts. You can cast ANY projection to date, datetime, real, integer or string
.select(Projection.column("column1").cast_date)
.select(Projection.column("column1").cast_datetime)
.select(Projection.column("column1").cast_real)
.select(Projection.column("column1").cast_int)
.select(Projection.column("column1").cast_string)
```

### Basic INSERT statement
### Basic UPDATE statement
### Basic DELETE statement

### Subquery projections

```crystal
alias Projection = Sqlite3::Projection

subquery = QueryBuilder.builder_for "sqlite3"
subquery.select(Projection.max("subcolumn")).from("subtable")

qb = QueryBuilder.builder_for "sqlite3"
qb.select(Projection.subquery(subquery).alias("max"))
  .from("table_name")

puts qb.build
# -> SELECT (SELECT MAX(`subcolumn`) FROM `subtable`) AS `max` FROM `table_name`;
```

### FROM clause

For simple `FROM` clauses the `from` method is enough. For more complex `FROM`
clauses you can use the `From` class.

```crystal
alias From = Sqlite3::From

# Simple from
.from("table_name")

# Aliased table. These 2 sentences are equal
.from(From.table("table1").alias("t"))
.from("t.table1")
```

### Subqueries in FROM clauses

```crystal
alias From = Sqlite3::From

subquery = QueryBuilder.builder_for "sqlite3"
subquery.from("subtable");

qb = QueryBuilder.builder_for "sqlite3"
qb.from(subquery);

# you can also JOIN sub-queries:
.from(From.subQuery(subquery).inner_join("table").on("col_from_subquery", "col_from_table")
.from(From.table("table").inner_join(subquery).on("col_from_table", "col_from_subquery")
.from(From.subquery(subquery1).inner_join(subquery2).on("col_from_subquery1", "col_from_subquery2")
```

### Inner & left JOINs

Note that in this example `table3` is aliased so the `left_join` is performed by
using `Projection` so that the `column4` can be fully qualified with the table
alias.

```crystal
alias From = Sqlite3::From

qb = QueryBuilder.builder_for "sqlite3"

qb.select("column1", "t.column4")
  .from(
    From.table("table1").inner_join("table2")
      .on("column1", "column2")
    .left_join("t.table3")
      .on("column3", "t.column4")
      .on_and(column5: 0)
  )
```

You can use `#join` instead of `#inner_join`.

### WHERE clause

The `WHERE` clause is built by using the `Criteria` class. It allows to write
simple and complex criterias and chain them together with `AND`/`OR`. The
`Criteria` class works together with the `Projection` class, so you can create
criterias that compare sub-queries, constants and anything that a `Projection`
is able to create.

Here is an example that tries to show a broad range of usages of the `Criteria`
class.

```crystal
alias Projection = Sqlite3::Projection
alias From = Sqlite3::From
alias Criteria = Sqlite3::Criteria

subquery1 = QueryBuilder.builder_for "sqlite3"
subquery1.select("1").from("subtable");

subquery2 = QueryBuilder.builder_for "sqlite3"
subquery2.select(Projection.max("subquery_column1")).from("subtable");

qb = QueryBuilder.builder_for "sqlite3"
qb.select("column1")
  .from("table")
  .where_and(
    Criteria.equals("column1", 1)
      .and(Criteria.in("column2", [1, 2, 3]))
      .or(Criteria.greater_than(Projection.subquery(subquery2), 5))
      .and(Criteria.exists(subquery))
  )
```

These are all the methods provided by the `Criteria` class:

#### NULL operators

```crystal
alias Projection = Sqlite3::Projection
alias Criteria = Sqlite3::Criteria

Criteria.is_null("column")
Criteria.is_null(Projection.column("column"))

Criteria.is_not_null("column")
Criteria.is_not_null(Projection.column("column"))
```

#### Basic operators

Basic operator for strings, numbers and dates.

When passing a `Time` as parameter, these operators will cast the database
column to `DATE` or `DATETIME` accordingly.

When passing a `Projection` as a parameter these operators will not parameterize
this value and use the `Projection` directly (this is useful for creating a
criteria that compares two columns, e.g.
`SELECT column3 FROM table WHERE column1 = column2`).

```crystal
alias Criteria = Sqlite3::Criteria
alias Projection = Sqlite3::Projection

# equality
Criteria.equals("column", 5)
Criteria.equals(Projection.column("column"), 5)
Criteria.equals(Projection.column("column1"), Projection.column("column2"))

# inequality, same as above but chaining .not
# .not method only negates the following method in the chain
Criteria.not.equals

# greater than
Criteria.greater_than("column", 5)
Criteria.greater_than(Projection.column("column"), 5)

# lesser than
Criteria.lesser_than("column", 5)
Criteria.lesser_than(Projection.column("column"), 5)

# greater than or equals
Criteria.greater_than_or_equal("column", 5)
Criteria.greater_than_or_equal(Projection.column("column"), 5)

# lesser than or equals
Criteria.lesser_than_or_equal("column", 5)
Criteria.lesser_than_or_equal(Projection.column("column"), 5)
```

#### Between operators

All of then can be combined with `.not` method.

```crystal
alias Criteria = Sqlite3::Criteria
alias Projection = Sqlite3::Projection

Criteria.between("column", min_value: 5, max_value: 10)
Criteria.between(Projection.column("column"), min_value: 5, max_value: 10)

Criteria.value_between(column_min: "column1", column_max: "column2", value: 5)
Criteria.value_between(column_min: Projection.column("column1"), column_max: Projection.column("column2"), value: 5)
```

#### String operators

These are used to create `LIKE` criterias. All of then can be combined with
`.not` method.

```crystal
Criteria = Sqlite3::Criteria
Projection = Sqlite3::Projection

Criteria.starts_with("column", "test")  # e.g. LIKE 'test%'
Criteria.starts_with(Projection.column("column"), "test")

Criteria.ends_with("column", "test")  # e.g. LIKE '%test'
Criteria.ends_with(Projection.column("column"), "test")

Criteria.contains("column", "test")  # e.g. LIKE '%test%'
Criteria.contains(Projection.column("column"), "test")  # e.g. LIKE '%test%'
```

#### IN operators

All of then can be combined with `.not` method.

```crystal
alias Criteria = Criteria::Sqilte3
alias Projection = Projection::Sqlite3

Criteria.in("column", [1, 2, 3])
Criteria.in(Projection.column("column"), [1, 2, 3])
```

#### EXISTS operators (in subqueries)

All of then can be combined with `.not` method.

```crystal
alias Criteria = Criteria::Sqilte3

Criteria.exists(subquery)
```

#### Logical operators

```crystal
alias Criteria = Criteria::Sqilte3

Criteria.and(criteria)
Criteria.or(criteria)
```

### WHERE criteria shortcuts

#### Conditions as NamedTuple

You can write this:

```crystal
alias Crystal = Crystal::Sqlite3

qb.where(Criteria.equals("column": 5))
```

as this:
```crystal
alias Crystal = Criteria::Sqlite3

qb.where(column: 5)
```

Also you can chain `AND` criterias like this:

```crystal
alias Criteria = Criteria::Sqlite3

qb.where(column1: 5, column2: "jhon", column3: true, column4: 5..10)
```

Is the equivalent to:

```crystal
alias Criteria = Criteria::Sqlite3

qb.where(Criteria.equals("column1", 5))
  .where(Criteria.equals("column2", "jhon"))
  .where(Criteria.equals("column3", true))
  .where(Criteria.between("column4", 5, 10))
```

Supported operands:

* `.where(column: 5)` is equivalent to `Criteria.equals("column", 5)`
* `.where(column: 5..10)` is equivalent to `Criteria.between("column", 5, 10)`
* `.where(column: [1, 2, 3])` is equivalent to `Criteria.in("column", [1, 2, 3])`

You can work with aliased columns:

```crystal
alias Criteria = Criteria::Sqlite3

.where("t.column": 5)
```

#### Criteria predicate parser

You can write expressions as:

```crystal
alias Criteria = Criteria::Sqlite3

qb.where("column > 4")
```
Supported opperands are:

* =
* !=
* >
* <
* <=
* >=
* like

Chaining predicates with `AND` or `OR` is not supported at the moment.

### GROUP BY and ORDER BY

```crystal
alias Projection = Projection::Sqlite3

# Group by a column
.group_by("column1", "column2")

# Group by - projections
.group_by(Projection.column("column1"), Projection.column("column2"))

# Group by - mixing projections and strings
.group_by(Projection.column("column1"), "column2")

# Order by ascending
.order_by("column1", "column2", "asc")

# Order by ascending - projections
.order_by(Projection.column("column1"), Projection.column("column2"), "asc")

# Order by ascending - mixing projections and strings
.order_by(Projection.column("column1"), "column2", "asc")

# Order by descending
.order_by("column1", "column2", "desc");

# Order by descending - projections
.order_by(Projection.column("column1"), Projection.column("column2"), "desc")

# Order by ignoring case
.order_by("column1", "asc", ignore_case: true)
.order_by("column1", "desc", ignore_case: true)

# Order by ignoring case - projections
.order_by(Projection.column("column1"), "asc", ignore_case: true)
.order_by(Projection.column("column1"), "desc", ignore_case: true)
```

### LIMIT and OFFSET

```crystal
qb = QueryBuilder.builder_for "sqlite3"
qb.select("column1")
  .from("table1")
  .limit(rows: 10, offset: 100)
```

### UNION queries

When using `UNION` the `ORDER BY` clause, limit and offset of the union queries
will be ignored. Only the `ORDER BY` clause, limit and offset of the root query
will be considered (see example below)

```crystal
builder1 = QueryBuilder.builder_for "sqlite3"
builder1.select("column1")
        .from("table1")
        .order_by("column1") # this WILL be used
        .limit(20, 10) # this WILL be used

builder2 = QueryBuilder.builder_for "sqlite3"
builder2.select("column2")
        .from("table2")
        .order_by("column2") # this WILL NOT be used
        .limit(20, 10) # this WILL NOT be used

builder3 = QueryBuilder.builder_for "sqlite3"
builder3.select("column3")
        .from("table3")
        .order_by("column3") # this WILL NOT be used
        .limit(20, 10) # this WILL NOT be used

builder1.union(builder2).union_all(builder3);

puts builder1.build
# -> SELECT `column1` FROM `table1`
     UNION ALL
     SELECT `column2` FROM `table2`
     UNION ALL
     SELECT `column3` FROM `table3` ORDER BY `column1` ASC LIMIT ? OFFSET ?;
```

### Basic INSERT statement

```crystal
qb = QueryBuilder.builder_for "sqlite3"

qb.insert
  .into("students")
  .columns("name", "age", "genre")
  .values("jhon", 13, "male")

puts qb.build
# -> INSERT INTO `students` (`name`, `age`, `genre`) VALUES(?, ?, ?);
```
#### INSERT with SELECT clause

```crystal
subquery = QueryBuilder.builder_for "sqlite3"
subquery
  .select("name", "address", "city", "postal_code")
  .from("supliers")

qb = QueryBuilder.builder_for "sqlite3"
qb.insert
  .into("customers")
  .columns("name", "address", "city", "postal_code")
  .from_select(subquery)

puts qb.build
# -> INSERT INTO `customers` (`name`, `address`, `city`, `postal_code`)
     SELECT `name`, `address`, `city`, `postal_code` FROM `supliers`;
```

### Basic UPDATE statement

```crystal
qb = QueryBuilder.builder_for "sqlite3"
columns = ["name", "age", "genre"]
values = ["jhon", 13, "male"]

qb
  .update("students")

columns.zip(values).each do |col, val|
  qb.set(col, val)
end

qb.where(id: 1)

puts qb.build
# -> UPDATE `students` SET `name` = ?, `age` = ?, `genre` = ? WHERE `id` = ?;
```

### Basic DELETE statement

```crystal
qb = QueryBuilder.builder_for "sqlite3"
qb
  .delete("students")
  .where(id: 1)

puts qb.build
# -> DELETE FROM `students` WHERE `id` = ?;
```

## Contributing

1. Fork it (<https://github.com/mmacia/query-builder.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Moisès Macià](https://github.com/mmacia) - creator and maintainer
