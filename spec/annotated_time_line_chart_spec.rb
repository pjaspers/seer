require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Seer::AnnotatedTimeLineChart" do

  before :each do

    # Setting up the label objects
    # Make sure there is a shared method between the label objects
    # and the data objects (e.g. sortable_id)
    # This is used to copule them.

    @koala = mock("Koala")
    @tentoone = mock("10to1")

    # Setting up the data objects.
    # These don't have to be the same models, they only need to support
    # the same methods.
    @data_1 = mock("first_data_object")
    @data_2 = mock("second_data_object")

    @chart = Seer::AnnotatedTimeLineChart.new(
        :data => [@koala,@tentoone],
        :data_label   => 'name',
        :data_series => [[@data_1], [@data_2]],
        :sort_method => 'sortable_id',
        :quantity_method => 'quantity',
        :date_method => 'datum',
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
    @koala.should_receive(:sortable_id).once.and_return("1")
    @koala.should_receive(:name).once.and_return("10to1")
    @tentoone.should_receive(:sortable_id).once.and_return("2")
    @tentoone.should_receive(:name).once.and_return("10to1")


    @data_1.should_receive(:datum).once.and_return(Time.utc(1983,"nov",26,20,15,1))
    @data_1.should_receive(:quantity).once.and_return(3)
    @data_1.should_receive(:sortable_id).twice.and_return("1")

    @data_2.should_receive(:datum).and_return(Time.utc(1983,"nov",26,20,15,1))
    @data_2.should_receive(:quantity).and_return(8)
    @data_2.should_receive(:sortable_id).twice.and_return("2")

    js_output = @chart.to_js
    (js_output =~ /javascript/).should be_true
    (js_output =~ /AnnotatedTimeLine/).should be_true
  end

  it 'sets its data columns' do
    @koala.should_receive(:name).once.and_return("Koala")
    @tentoone.should_receive(:name).once.and_return("10to1")
    data_columns = @chart.data_columns
    data_columns.should add_column('date', 'Date')
    data_columns.should add_column('number', 'Koala')
    data_columns.should add_column('string', 'text1')
    data_columns.should add_column('string', 'title1')
    data_columns.should add_column('number', '10to1')
    data_columns.should add_column('string', 'text2')
    data_columns.should add_column('string', 'title2')
  end

  it 'sets its data table' do
    @koala.should_receive(:sortable_id).once.and_return("1")
    @tentoone.should_receive(:sortable_id).once.and_return("2")

    @data_1.should_receive(:datum).once.and_return(Time.utc(1983,"nov",26,20,15,1))
    @data_1.should_receive(:quantity).once.and_return(3)
    @data_1.should_receive(:sortable_id).twice.and_return("1")

    @data_2.should_receive(:datum).and_return(Time.utc(1983,"nov",26,20,15,1))
    @data_2.should_receive(:quantity).and_return(8)
    @data_2.should_receive(:sortable_id).twice.and_return("2")

    data_table = @chart.data_table.to_s
    data_table.should =~ /addRows\(\[/
    data_table.should =~ /\[new Date\(1983, 11 ,26\),3, undefined, undefined,8, undefined, undefined\]/
    data_table.should =~ /\]\);/
  end

end
