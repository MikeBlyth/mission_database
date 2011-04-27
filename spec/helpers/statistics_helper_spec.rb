describe StatisticsHelper do

  describe 'frequency table' do
    
    it 'makes basic list' do
      data = [ {a: 'cat'}, {a: 'dog'}, {a: 'cat'}, {a: 'dog'}, {a: 'cat'}, {a: 'dog'}, {a: 'dog'}]
      table = freq(data, :a)
      table['cat'].should == 3
      table['dog'].should == 4
      table['Total'].should == 7
    end
    
    it 'works with symbol & string keys' do
      data = [ {a: 'cat'}, {'a'=> 'dog'}, {a: 'cat'}, {'a'=> 'dog'}, {a: 'cat'}, {a: 'dog'}, {a: 'dog'}]
      table = freq(data, :a)
      table['cat'].should == 3
      table['dog'].should == 4
      table['Total'].should == 7
    end

    it 'works with symbol & string keys as arguments for freq' do
      data = [ {a: 'cat'}, {'a'=> 'dog'}, {a: 'cat'}, {'a'=> 'dog'}, {a: 'cat'}, {a: 'dog'}, {a: 'dog'}]
      table = freq(data, 'a')
      table['cat'].should == 3
      table['dog'].should == 4
      table['Total'].should == 7
    end

    it 'works when there are unneeded keys' do
      data = [ {a: 'cat', b: 'male'}, {a: 'dog'}, {a: 'cat', c: 75}, {a: 'dog'}, {a: 'cat'}, {a: 'dog'}, {a: 'dog'}]
      table = freq(data, :a)
      table['cat'].should == 3
      table['dog'].should == 4
      table['Total'].should == 7
    end
    
    it 'works with object methods as well as hashes' do
      class XX < Object
        attr_accessor :a
        def initialize(a)
          @a = a
        end
      end
      data = [ XX.new('cat'), XX.new('dog'), {a: 'cat'}, {a: 'dog'}, {a: 'cat'}, {a: 'dog'}, {a: 'dog'}]
      table = freq(data, :a)
      table['cat'].should == 3
      table['dog'].should == 4
      table['Total'].should == 7
    end
    
    it 'works with nil values' do
      data = [ {a: nil}, {a: nil}, {a: 'cat'}, {'a'=> 'dog'}, {a: 'cat'}, {'a'=> 'dog'}, {a: 'cat'}, {a: 'dog'}, {a: 'dog'}]
      table = freq(data, 'a')
      table[''].should == 2
      table['cat'].should == 3
      table['dog'].should == 4
      table['Total'].should == 9
    end

    it 'returns nil for empty data' do
      freq([], 'a').should be_nil
    end      
      
    
  end # frequency table
  
  describe 'crosstab' do
    before(:each) do
      @data = [ {a: 'cat', b: 'm'}, {a: 'dog', b: 'm'}, {a: 'cat', b: 'm'}, {a: 'dog', b: 'f'}, 
               {a: 'cat', b: 'f'}, {a: 'dog', b: 'f'}, {a: 'dog', b: 'f'}]
    end

    it 'makes basic 2x2 table' do
      table = ctab(@data, 'a', 'b')
      table['cat']['Total'].should == 3
      table['cat']['m'].should == 2
      table['cat']['f'].should == 1
      table['cat']['Total'].should == 3
      table['dog']['m'].should == 1
      table['dog']['f'].should == 3
      table['dog']['Total'].should == 4
      table['Totals']['Total'].should == 7
    end

    it 'returns nil for empty data' do
      ctab([], 'a', 'b').should be_nil
    end      

    it 'works with symbol & string keys' do
      @data << {'a'=>'dog', 'b'=>'f'}
      table = ctab(@data, 'a', 'b')
      table['cat']['Total'].should == 3
      table['cat']['m'].should == 2
      table['cat']['f'].should == 1
      table['cat']['Total'].should == 3
      table['dog']['m'].should == 1
      table['dog']['f'].should == 4
      table['dog']['Total'].should == 5
      table['Totals']['Total'].should == 8
    end

    it 'makes 3x3 table' do
      @data << {'a'=>'rat', 'b'=>"?"}
      table = ctab(@data, 'a', 'b')
      table['cat']['Total'].should == 3
      table['cat']['m'].should == 2
      table['cat']['f'].should == 1
      table['cat']['?'].should == 0
      table['cat']['Total'].should == 3
      table['dog']['m'].should == 1
      table['dog']['f'].should == 3
      table['dog']['?'].should == 0
      table['dog']['Total'].should == 4
      table['rat']['m'].should == 0
      table['rat']['f'].should == 0
      table['rat']['?'].should == 1
      table['Totals']['Total'].should == 8
    end

    it 'works with object methods as well as hashes' do
      class XX < Object
        attr_accessor :a, :b
        def initialize(a, b)
          @a = a
          @b = b
        end
      end
      # make new array filled with XX objects corresponding to the hash
      xdata = @data.map {|d| XX.new(d[:a], d[:b])}      
      table = ctab(xdata, 'a', 'b')
      table['cat']['Total'].should == 3
      table['cat']['m'].should == 2
      table['cat']['f'].should == 1
      table['cat']['Total'].should == 3
      table['dog']['m'].should == 1
      table['dog']['f'].should == 3
      table['dog']['Total'].should == 4
      table['Totals']['Total'].should == 7
    end
  end # ctab  

end

