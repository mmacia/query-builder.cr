require "../spec_helper"

describe Sqlite3::QueryBuilder do
  it "build basic delete clausule" do
    subject = QueryBuilder.builder_for("sqlite3")
    subject
      .delete("students")
      .where(id: 1)

    subject.build.should eq("DELETE FROM `students` WHERE `id` = ?;")
    subject.params.should eq([1])
  end
end
