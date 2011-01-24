describe "database" do
  shared_examples_for "utf queries" do
    it "should get empty tables as empty arrays" do
      [].should == @db.execute("SELECT * FROM t1")
    end

    it "should execute" do
      @db.execute("INSERT INTO t1 VALUES(NULL, 'text1', 1.22, 42, 4294967296, NULL)")
      rows = @db.execute("SELECT * FROM t1")
      1.should == rows.size
      row = rows[0]
      "text1".encode(driver_encoding).should == row[1]
      driver_encoding.should == row[1].encoding
      1.22.should == row[2]
      42.should == row[3]
      4294967296.should == row[4]
      row[5].should == nil
    end

    it "should execute_with_different_encodings" do
      expected_string = "text1"
      @db.execute("INSERT INTO t1 VALUES(NULL, ?, NULL, NULL, NULL, NULL)", expected_string.encode(Encoding::ASCII_8BIT))
      @db.execute("INSERT INTO t1 VALUES(NULL, ?, NULL, NULL, NULL, NULL)", expected_string.encode(Encoding::UTF_8))
      @db.execute("INSERT INTO t1 VALUES(NULL, ?, NULL, NULL, NULL, NULL)", expected_string.encode(Encoding::UTF_16LE))
      @db.execute("INSERT INTO t1 VALUES(NULL, ?, NULL, NULL, NULL, NULL)", expected_string.encode(Encoding::UTF_16BE))
      rows = @db.execute("SELECT * FROM t1")
      4.should == rows.size
      expected_string.should == rows[0][1]
      expected_string.encode(driver_encoding).should == rows[1][1]
      expected_string.encode(driver_encoding).should == rows[2][1]
      expected_string.encode(driver_encoding).should == rows[3][1]
      Encoding::ASCII_8BIT.should == rows[0][1].encoding
      driver_encoding.should == rows[1][1].encoding
      driver_encoding.should == rows[2][1].encoding
      driver_encoding.should == rows[3][1].encoding
    end

    it "should execute_with_bindings" do
      blob = open(File.expand_path("../../fixtures/SQLite.gif", __FILE__), "rb").read
      @db.execute("INSERT INTO t1 VALUES(?, ?, ?, ?, ?, ?)", nil, "text1", 1.22, 42, 4294967296, blob)
      rows = @db.execute("SELECT * FROM t1")
      1.should ==  rows.size
      row = rows[0]
      "text1".encode(driver_encoding).should ==  row[1]
      driver_encoding.should ==  row[1].encoding
      1.22.should ==  row[2]
      42.should ==  row[3]
      4294967296.should ==  row[4]
      blob.should ==  row[5]
      Encoding::ASCII_8BIT.should ==  row[5].encoding
    end

    it "should execute_with_bad_query" do
      lambda { @db.execute("bad query") }.should raise_exception SQLite3::SQLException
      %Q{near "bad": syntax error}.should ==  @db.errmsg
      1.should == @db.errcode
    end

    it "should last_insert_row_id" do
      @db.execute("INSERT INTO t1 VALUES(NULL, NULL, NULL, NULL, NULL, NULL)")
      id = @db.last_insert_row_id
      rows = @db.execute("SELECT * FROM t1 WHERE id = #{id}")
      1.should == rows.size
    end

    it "should execute_with_closed_database" do
      @db.close
      @db.execute("SELECT * FROM t1")
    end
  end
end
