require "../../spec_helper"


describe QueryBuilder::OrCriteria do
  it "should chain 2 criterias" do
    criteria1 = Sqlite3::Criteria.equals("column1", 5)
    criteria2 = Sqlite3::Criteria.contains("column2", "test")

    subject = criteria1.or(criteria2)
    subject.build.should eq("(`column1` = ? OR `column2` LIKE ?)")
    subject.params.should eq([5, "%test%"])
  end
end
