require File.dirname(__FILE__) + '/../spec_helper'
require 'will_paginate/finders/sequel'
require File.dirname(__FILE__) + '/sequel_test_connector'

require 'will_paginate'

describe WillPaginate::Finders::Sequel do

  it "should make #paginate available to Sequel::Model classes" do
    Car.should respond_to(:paginate)
  end

  it "should paginate" do
    Car.paginate(:page => 1, :per_page => 2) == [Car[1], Car[2]]
  end

  it "should NOT to paginate_by_sql" do
    Car.should_not respond_to(:paginate_by_sql)
  end

  it "should alter the select clauses through :select" do
    result = Car.paginate(:select => "name as foo".lit, :page => 1, :per_page => 2, :order => :name)
    result.size.should == 2
    result.first.values[:foo].should == "Aston Martin"
  end

  it "should not blow up with an explicit :all argument" do
    lambda { Car.paginate :page => nil, :count => nil }.should_not raise_error
  end

  it "should support conditional pagination" do
    filtered_result = Car.paginate(:name => 'Shelby', :page => nil)
    filtered_result.size.should == 1
    filtered_result.first.should == Car.first(:name => 'Shelby')
  end

  it "should support passing in conditions in a hash" do
    filtered_result = Car.paginate(:conditions => ["name = ?",'Shelby'], :page => nil)
    filtered_result.size.should == 1
    filtered_result.first.should == Car.first(:name => 'Shelby')
  end

  describe "counting" do
    it "should ignore nil in :count parameter" do
      lambda { Car.paginate :page => nil, :count => nil }.should_not raise_error
    end

    it "should guess the total count" do
      Car.expects(:count).never
      Car.paginate(:page => 2, :per_page => 2).total_entries.should == 3
    end

    it "should guess that there are no records" do
      Car.delete_all
      Car.expects(:count).never

      result = Car.paginate :page => 1, :per_page => 4
      result.total_entries.should == 0
      Car.setup
    end
  end

end
