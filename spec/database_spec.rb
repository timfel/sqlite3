require File.expand_path("../spec_helper", __FILE__)

describe "FFI Sqlite3 Database" do
  def self.version_guard(version_string)
    if RUBY_VERSION =~ /#{version_string}/
      yield
    end
  end

  describe "file based initialization" do
    before(:each) do
      @db_filename = "test_database.db"
      File.delete(@db_filename) if File.exists?(@db_filename)
      @db = SQLite3::Database.new(@db_filename)
    end

    after(:each) do
      File.delete(@db_filename) if File.exists?(@db_filename)
    end

    it "should database_file_exists" do
      File.exists?(@db_filename).should == true
    end

    it "should database_opened" do
      @db.closed?.should == false
    end

    it "should database_closing" do
      @db.close
      @db.closed?.should == true
    end

    version_guard "1.9" do
      it "should encoding_conversion_from_utf_16_to_utf_8" do
        expected_string = "test"
        db_filename = "test_database_encoding.db"
        File.delete(db_filename) if File.exists?(db_filename)
        db = SQLite3::Database.new(db_filename, :encoding => "utf-16le")
        db.execute("CREATE TABLE t1(t TEXT)")
        db.execute("INSERT INTO t1 VALUES (?)", expected_string.encode(Encoding::UTF_8))
        db.execute("INSERT INTO t1 VALUES (?)", expected_string.encode(Encoding::UTF_16LE))
        rows = db.execute("SELECT * FROM t1")
        2.should == rows.size
        expected_string.encode(Encoding::UTF_16LE).should == rows[0][0]
        Encoding::UTF_16LE.should ==  rows[0][0].encoding
        expected_string.encode(Encoding::UTF_16LE).should == rows[1][0]
        Encoding::UTF_16LE.should ==  rows[1][0].encoding
        db.close
        db = SQLite3::Database.new(db_filename)
        rows = db.execute("SELECT * FROM t1")
        2.should == rows.size
        expected_string.should ==  rows[0][0]
        Encoding::UTF_8.should ==  rows[0][0].encoding
        expected_string.should ==  rows[1][0]
        Encoding::UTF_8.should ==  rows[1][0].encoding
        File.delete(db_filename) if File.exists?(db_filename)
      end
    end
  end

  describe "statement" do
    before(:each) do
      @db = SQLite3::Database.new(":memory:")
      @db.execute("CREATE TABLE t1(id INTEGER PRIMARY KEY ASC, t TEXT, nu1 NUMERIC, i1 INTEGER, i2 INTEGER, no BLOB)")
      @statement = @db.prepare("INSERT INTO t1 VALUES(:ID, :T, :NU1, :I1, :I2, :NO)")
    end

    after(:each) do
      @statement.close
      @db.close
    end

    it "should bind param by name" do
      @statement.bind_param("T", "test")
    end


    it "should bind param by name with colon" do
      @statement.bind_param(":T", "test")
    end

    it "should bind param by number" do
      @statement.bind_param(1, "test")
    end

    it "should bind non existing param name" do
      lambda { @statement.bind_param(":NONEXISTING", "test") }.should raise_exception SQLite3::Exception
    end

    it "should execute statement" do
      @statement.execute
    end

    it "should execute statement multiple times" do
      @statement.bind_param("T", "test")
      @statement.execute
      @statement.bind_param("NU1", 500)
      @statement.execute
    end
  end

  describe "queries" do
    before(:each) do
      @db = SQLite3::Database.new(":memory:", :encoding => "utf-16")
      @db.execute("CREATE TABLE t1(id INTEGER PRIMARY KEY ASC, t TEXT, nu1 NUMERIC, i1 INTEGER, i2 INTEGER, no BLOB)")
    end

    after(:each) do
      @db.close
    end

    version_guard "1.9" do
      describe "using utf-16" do
        let(:driver_encoding) { Encoding::UTF_16LE }
        it_should_behave_like "utf queries"
      end
    end

    describe "using utf-8" do
      let(:driver_encoding) { $KCODE }
      version_guard("1.9") { let(:driver_encoding) { Encoding::UTF_16LE } }

      it_should_behave_like "utf queries"
    end
  end
end
