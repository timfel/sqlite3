require File.expand_path("../spec_helper", __FILE__)
require "active_record"
require "active_support/core_ext/class/attribute_accessors"
require "active_support/core_ext/module/delegation"

class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login
      t.integer :login_count
      t.binary :avatar
      t.float :ranking
      t.date :birthdate
      t.boolean :active
      t.datetime :expires_at
      t.text :about_me
      t.timestamps
      end
    end

  def self.down
    drop_table :users
  end
end

class User < ActiveRecord::Base; end

describe "ActiveRecord using FFI SQLite3" do

  let(:login) { "bob" }
  let(:avatar) { open(File.expand_path("../fixtures/SQLite.gif", __FILE__), "rb").read }
  let(:login_count) { 0 }
  let(:ranking) { 1.0 }
  let(:active) { true }
  let(:birthdate) { Date.new(1969, 12, 1) }
  let(:expires_at) { DateTime.new(2100, 12, 1, 12, 54, 22) }
  let(:about_me) { "aboutme" * 500 }

  before(:each) do
    ActiveRecord::Base.establish_connection(:adapter  => "sqlite3", :database => ":memory:")
    ActiveRecord::Base.default_timezone = :utc
    ActiveRecord::Migration.verbose = false
    CreateUsers.migrate(:up)
  end

  describe "reading" do
    it "should be able to count the number of Users" do
      User.count.should == 0
    end

    it "should be able to get the columns for Users" do
      User.column_names.should == ["id", "login", "login_count", "avatar",
          "ranking", "birthdate", "active", "expires_at", "about_me",
          "created_at", "updated_at"]
    end

    it "should be able to read strings" do
      User.create(:login => login)
      User.first.login.should == login
    end

    it "should be able to read integers" do
      User.create(:login_count => login_count)
      User.first.login_count.should == login_count
    end

    it "should be able to read binary data" do
      User.create(:avatar => avatar)
      User.first.avatar.should == avatar
    end

    it "should be able to read float" do
      User.create(:ranking => ranking)
      User.first.ranking.should == ranking
    end

    it "should be able to read date" do
      User.create(:birthdate => birthdate)
      User.first.birthdate.should == birthdate
    end

    it "should be able to read boolean" do
      User.create(:active => active)
      User.first.active.should == active
    end

    it "should be able to read datetime" do
      User.create(:expires_at => expires_at)
      User.first.expires_at.should == expires_at
    end

    it "should be able to read text" do
      User.create(:about_me => about_me)
      User.first.about_me.should == about_me
    end

    it "should be able to read timestamps" do
      User.create
      User.first.created_at.class.should be Time
    end
  end

  describe "creation" do
    it "should be able to create an empty record" do
      User.create.should == User.first
    end

    it "should be able to create a record with data" do
      User.create(:login => login,
                  :login_count => login_count,
                  :avatar => avatar,
                  :ranking => ranking,
                  :active => active,
                  :birthdate => birthdate,
                  :expires_at => expires_at,
                  :about_me => about_me).should == User.first
    end

    it "should save a record" do
      User.new.save.should == true
      User.count.should == 1
    end

    it "should save a record with a bang without error" do
      lambda { User.new.save! }.should_not raise_exception
    end
  end

  describe "update" do
    it "should update a user" do
      User.create!(:login => "bob")
      user = User.first
      "bob".should == user.login
      user.update_attributes(:login => "alice")
      user = User.first
      "alice".should == user.login
    end

    it "should track dirty attributes" do
      User.create!(:login => "bob")
      user = User.first
      "bob".should == user.login
      user.login = "alice"
      user.login_changed?.should == true
      "alice".should == user.login
      "bob".should == user.login_was
    end

    it "should reload a record" do
      User.create!(:login => "bob")
      user = User.first
      "bob".should == user.login
      user.login = "alice"
      "alice".should == user.login
      user.reload
      "bob".should == user.login
    end

    it "should be able to assign attributes" do
      user = User.new
      user.update_attribute(:avatar, avatar)
      user.reload
      user.avatar.should == avatar
      1.should == User.count
    end
  end

  describe "transactions" do
    it "should commit within a transaction block" do
      User.transaction do
        User.create!
      end
      1.should == User.count
    end

    it "should it should do a rollback if the transaction fails" do
      User.transaction do
        User.create!
        raise ActiveRecord::Rollback
      end
      0.should == User.count
    end
  end

  describe "delete" do
    it "should delete a user" do
      User.create!(:login => "bob")
      user = User.first
      "bob".should == user.login
      user.destroy
      0.should == User.count
    end
  end
end
