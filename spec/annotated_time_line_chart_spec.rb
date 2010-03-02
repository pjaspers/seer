require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Seer::AnnotatedTimeLineChart" do
  
  before :each do
    class Data
          attr_accessor :date, :quantity, :id
    end
    @chart = Seer::AnnotatedTimeLineChart.new(
        :data => ["Koala","10to1"],
        :data_label   => 'to_s',
        :data_series => [[Time.utc(1983,"nov",26,20,15,1),3, "Koala"],[Time.utc(1983,"nov",26,20,15,1),8,"10to1"]],
        :date_method => 'first',
        :chart_options  => {},
        :chart_element  => 'chart'
     )
  end
  
  describe 'defaults' do
  
    it 'colors' do
      @chart.colors.should == Seer::Chart::DEFAULT_COLORS
    end
    
  end

  describe 'graph options' do
    [:allowHtml, :allowRedraw, :allowRedraw, :allValuesSuffix, :annotationsWidth, :colors, :dateFormat, :displayAnnotations, :displayAnnotationsFilter, :displayDateBarSeparator, :displayExactValues, :displayLegendDots, :displayLegendValues, :displayRangeSelector, :displayZoomButtons, :fill, :highlightDot, :legendPosition, :max, :min, :numberFormats, :scaleColumns, :scaleType, :thickness, :wmode, :zoomEndTime, :zoomStartTime].each do |accessor|
      it "sets its #{accessor} value" do
        @chart.send("#{accessor}=", 'foo')
        @chart.send(accessor).should == 'foo'
      end
    end
  end
  
  it 'renders as JavaScript' do
    (@chart.to_js =~ /javascript/).should be_true
    (@chart.to_js =~ /AnnotatedTimeLine/).should be_true
  end
  
  it 'sets its data columns' do
    @chart.data_columns.should =~ /addColumn\('date', 'Date'\)/
    @chart.data_columns.should =~ /addColumn\('number', 'Koala'\)/
    @chart.data_columns.should =~ /addColumn\('string', 'text1'\)/
    @chart.data_columns.should =~ /addColumn\('string', 'title1'\)/
    @chart.data_columns.should =~ /addColumn\('number', '10to1'\)/
    @chart.data_columns.should =~ /addColumn\('string', 'text2'\)/
    @chart.data_columns.should =~ /addColumn\('string', 'title2'\)/
  end
  
  it 'sets its data table' do
    @chart.data_table.to_s.should =~ /addRows\(\[\)/
    @chart.data_table.to_s.should =~ /\[new Date\(1983, 11 ,26\),3, undefined, undefined,8, undefined, undefined\]/
    @chart.data_table.to_s.should =~ /\]\);/
  end
  
end
