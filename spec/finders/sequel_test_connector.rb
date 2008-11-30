require 'sequel'
DB = Sequel.sqlite
DB.create_table :cars do
  primary_key :id, :integer, :auto_increment => true
  column :name, :text
  column :notes, :text
end

class Car < Sequel::Model
  include WillPaginate::Sequel

  def self.setup
    Car.create(:name => 'Shelby', :notes => "Man's best friend")
    Car.create(:name => 'Aston Martin', :notes => "Woman's best friend")
    Car.create(:name => 'Corvette', :notes => 'King of the Jungle')
  end
end

Car.setup
