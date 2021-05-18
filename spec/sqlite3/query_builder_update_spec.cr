require "../spec_helper"

describe Sqlite3::QueryBuilder do
  it "build basic update clausule" do
    columns = ["name", "age", "genre"]
    values = ["jhon", 13, "male"]

    subject = QueryBuilder.builder_for("sqlite3")
    subject
      .update("students")

    columns.zip(values).each do |col, val|
      subject.set(col, val)
    end

    subject.where(id: 1)

    subject.build.should eq("UPDATE `students` SET `name` = ?, `age` = ?, `genre` = ? WHERE `id` = ?;")
    subject.params.should eq(["jhon", 13, "male", 1])
  end
end
