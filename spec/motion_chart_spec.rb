require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Seer::MotionChart" do
  
  before :each do
    tweets = [[Time.utc(1983,"nov",26,20,15,1),1, "Kid"],[Time.utc(1983,"nov",26,20,15,1),3, "Koala"],[Time.utc(1983,"nov",26,20,15,1),8,"10to1"]];
    hits = [[Time.utc(1983,"nov",26,20,15,1),10, "Kid"],[Time.utc(1983,"dec",26,20,15,1),30, "Koala"],[Time.utc(1983,"dec",26,20,15,1),80,"10to1"]];
    @chart = Seer::MotionChart.new(
        :data => ["Kid","Koala","10to1"],
        :data_label   => 'User',
        :series_labels => ["Tweets", "Hits"],
        :data_series => [tweets, hits],
        :data_methods => ['second','third'],
        :date_method => 'second',
        :chart_options  => {},
        :chart_element  => 'chart'
     )
  end
  
  describe 'defaults' do
  
    it 'colors' do
      @chart.colors.should == Seer::Chart::DEFAULT_COLORS
    end
    
  end

  # describe 'graph options' do
  #   [:allowHtml, :allowRedraw, :allowRedraw, :allValuesSuffix, :annotationsWidth, :colors, :dateFormat, :displayAnnotations, :displayAnnotationsFilter, :displayDateBarSeparator, :displayExactValues, :displayLegendDots, :displayLegendValues, :displayRangeSelector, :displayZoomButtons, :fill, :highlightDot, :legendPosition, :max, :min, :numberFormats, :scaleColumns, :scaleType, :thickness, :wmode, :zoomEndTime, :zoomStartTime].each do |accessor|
  #     it "sets its #{accessor} value" do
  #       @chart.send("#{accessor}=", 'foo')
  #       @chart.send(accessor).should == 'foo'
  #     end
  #   end
  # end
  
  it 'renders as JavaScript' do
    (@chart.to_js =~ /javascript/).should be_true
    (@chart.to_js =~ /MotionChart/).should be_true
  end
  
  it 'sets its data columns' do
    @chart.data_columns.should =~ /addColumn\('string', 'User'\)/
    @chart.data_columns.should =~ /addColumn\('date', 'Date'\)/
    @chart.data_columns.should =~ /addColumn\('number', 'Tweets'\)/
    @chart.data_columns.should =~ /addColumn\('number', 'Hits'\)/
  end
  
  it 'sets its data table' do
    @chart.data_table.to_s.should =~ /addRows\(\[\)/
    @chart.data_table.to_s.should =~ /\['Kid',new Date \(1983,11,26\),1,10\]/
    @chart.data_table.to_s.should =~ /\['Koala',new Date \(1983,11,26\),3,30\]/
    @chart.data_table.to_s.should =~ /\['10to1',new Date \(1983,11,26\),8,80\]/
    @chart.data_table.to_s.should =~ /\]\);/
  end
  
end
