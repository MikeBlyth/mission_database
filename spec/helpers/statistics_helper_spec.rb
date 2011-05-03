include StatisticsHelper
describe StatisticsHelper do

  describe 'frequency table (Freq)' do
    
    it 'makes basic list' do
      data = [ {a: 'cat'}, {a: 'dog'}, {a: 'cat'}, {a: 'dog'}, {a: 'cat'}, {a: 'dog'}, {a: 'dog'}]
      freq = Freq.new(data,{:rows=>:a, :title=>'Title', :rows_label=>'Pet'})
      table = freq.table_rows
      table['cat'].should == 3
      table['dog'].should == 4
      freq.title.should == 'Title'
      freq.rows_label.should == 'Pet'
    end
    
    it 'works with symbol & string keys' do
      data = [ {a: 'cat'}, {'a'=> 'dog'}, {a: 'cat'}, {'a'=> 'dog'}, {a: 'cat'}, {a: 'dog'}, {a: 'dog'}]
      table = Freq.new(data,{:rows=>:a}).table_rows
      table['cat'].should == 3
      table['dog'].should == 4
    end

    it 'works with symbol & string keys as arguments for freq' do
      data = [ {a: 'cat'}, {'a'=> 'dog'}, {a: 'cat'}, {'a'=> 'dog'}, {a: 'cat'}, {a: 'dog'}, {a: 'dog'}]
      table = Freq.new(data,{:rows=>:a}).table_rows
      table['cat'].should == 3
      table['dog'].should == 4
    end

    it 'works when there are unneeded keys' do
      data = [ {a: 'cat', b: 'male'}, {a: 'dog'}, {a: 'cat', c: 75}, {a: 'dog'}, {a: 'cat'}, {a: 'dog'}, {a: 'dog'}]
      table = Freq.new(data,{:rows=>:a}).table_rows
      table['cat'].should == 3
      table['dog'].should == 4
    end
    
    it 'works with object methods as well as hashes' do
      class XX < Object
        attr_accessor :a
        def initialize(a)
          @a = a
        end
      end
      data = [ XX.new('cat'), XX.new('dog'), {a: 'cat'}, {a: 'dog'}, {a: 'cat'}, {a: 'dog'}, {a: 'dog'}]
      table = Freq.new(data,{:rows=>:a}).table_rows
      table['cat'].should == 3
      table['dog'].should == 4
    end
    
    it 'works with nil values' do
      data = [ {a: nil}, {a: nil}, {a: 'cat'}, {'a'=> 'dog'}, {a: 'cat'}, {'a'=> 'dog'}, {a: 'cat'}, {a: 'dog'}, {a: 'dog'}]
      table = Freq.new(data,{:rows=>:a}).table_rows
      table['(none)'].should == 2
      table['cat'].should == 3
      table['dog'].should == 4
    end

    it 'can set row name of nil values' do
      data = [ {a: nil}, {a: nil}, {a: 'cat'}, {'a'=> 'dog'}, {a: 'cat'}, {'a'=> 'dog'}, {a: 'cat'}, {a: 'dog'}, {a: 'dog'}]
      table = Freq.new(data,{:rows=>:a, :nil_label=>'?'}).table_rows
      table['?'].should == 2
    end

    it 'returns nil for empty data' do
      Freq.new([], 'a').table_rows.should be_nil
    end      

    it 'sorts rows by frequency' do
      data = [ {a: nil}, {a: 'rat'}, {a: nil}, {a: 'cat'}, {'a'=> 'dog'}, {a: 'cat'}, 
                {'a'=> 'dog'}, {a: 'cat'}, {a: 'dog'}, {a: 'dog'}]
      freq = Freq.new(data, {:rows=>:a})
      freq.make_sorted_rows.should == [["A", "Count"], ["dog", 4], ["cat", 3], ["(none)", 2], ["rat", 1], ["Total", 10]]
    end            
    
    it 'outputs to text' do
      data = [ {a: nil}, {a: 'rat'}, {a: nil}, {a: 'cat'}, {'a'=> 'dog'}, {a: 'cat'}, 
                {'a'=> 'dog'}, {a: 'cat'}, {a: 'dog'}, {a: 'dog'}]
      freq = Freq.new(data, {:rows=>:a})
      freq.to_s.should == "A\tCount\ndog\t4\ncat\t3\n(none)\t2\nrat\t1\nTotal\t10\n"
    end            
    
  end # frequency table
  
  describe 'CrossTab' do
    before(:each) do
      @data = [ {a: 'cat', b: 'm'}, {a: 'dog', b: 'm'}, {a: 'cat', b: 'm'}, {a: 'dog', b: 'f'}, 
               {a: 'cat', b: 'f'}, {a: 'dog', b: 'f'}, {a: 'dog', b: 'f'}]
    end

    it 'makes basic 2x2 table' do
      xtab = CrossTab.new(@data, {:rows=>'a', :columns=>'b', :title=>'Title', :rows_label=>'Pet', :columns_label=>'Sex'})
      xtab.title.should == 'Title'
      xtab.rows_label.should == 'Pet'
      xtab.columns_label.should == 'Sex'
      table = xtab.table_rows
      table['cat']['Total'].should == 3
      table['cat']['m'].should == 2
      table['cat']['f'].should == 1
      table['cat']['Total'].should == 3
      table['dog']['m'].should == 1
      table['dog']['f'].should == 3
      table['dog']['Total'].should == 4
    end
    
    it 'returns sorted output' do
      xtab = CrossTab.new(@data, {:rows=>'a', :columns=>'b', :title=>'Title', :rows_label=>'Pet', :columns_label=>'Sex'})
      xtab.make_sorted_rows.should == [["", "F", "M", "Total"], ["dog", 3, 1, 4], ["cat", 1, 2, 3], ["Total", 4, 3, 7]] 
    end

    it 'returns sorted output to text' do
      # Naturally this is very "brittle." Any changes to the to_s method will break this test!
      xtab = CrossTab.new(@data, {:rows=>'a', :columns=>'b', :title=>'Title', :rows_label=>'Pet', :columns_label=>'Sex'})
      xtab.to_s.should == "Title\n\t\tSex\n\tF\tM\tTotal\ndog\t3\t1\t4\ncat\t1\t2\t3\nTotal\t4\t3\t7\n"
    end

    it 'returns sorted output to html' do
      # Naturally this is very "brittle." Any changes to the to_s method will break this test!
      xtab = CrossTab.new(@data, {:rows=>'a', :columns=>'b', :title=>'Title', :id =>"pets_sex",
            :rows_label=>'Pet', :columns_label=>'Sex'})
      xtab.to_html.should == "<div class='crosstab' id='pets_sex'><p class='title'>Title</p><table class='crosstab'><tr><th>Pet</th><th>F</th><th>M</th><th>Total</th></tr><tr class='odd dog'><td class='pet row_label'>dog</td><td class='f'>3</td><td class='m'>1</td><td class='total'>4</td></tr><tr class='even cat'><td class='pet row_label'>cat</td><td class='f'>1</td><td class='m'>2</td><td class='total'>3</td></tr><tr class='odd total'><td class='pet row_label'>Total</td><td class='f'>4</td><td class='m'>3</td><td class='total'>7</td></tr></table></div>"
    end

    it 'returns nil for empty data' do
      CrossTab.new([], {:rows=>'a', :columns=>'b'}).table_rows.should be_nil
    end      

    it 'works with symbol & string keys' do
      @data << {'a'=>'dog', 'b'=>'f'}
      table = CrossTab.new(@data, {:rows=>'a', :columns=>'b'}).table_rows
      table['cat']['Total'].should == 3
      table['cat']['m'].should == 2
      table['cat']['f'].should == 1
      table['cat']['Total'].should == 3
      table['dog']['m'].should == 1
      table['dog']['f'].should == 4
      table['dog']['Total'].should == 5
    end

    it 'makes 3x3 table' do
      @data << {'a'=>'rat', 'b'=>"?"}
      table = CrossTab.new(@data, {:rows=>'a', :columns=>'b'}).table_rows
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
      table = CrossTab.new(xdata, {:rows=>'a', :columns=>'b'}).table_rows
      table['cat']['Total'].should == 3
      table['cat']['m'].should == 2
      table['cat']['f'].should == 1
      table['cat']['Total'].should == 3
      table['dog']['m'].should == 1
      table['dog']['f'].should == 3
      table['dog']['Total'].should == 4
    end
  end # ctab  

end

