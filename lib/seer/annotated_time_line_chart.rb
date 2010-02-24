module Seer

  # =USAGE
  # 
  # In your controller:
  #
  #   @data = Widgets.all # Must be an array, and must respond
  #                       # to the data method specified below (in this example, 'quantity')
  #
  #   @series = @data.map{|w| w.widget_stats} # An array of arrays
  #
  # In your view:
  #
  #   <div id="chart" class="chart"></div>
  #
  #   <%= Seer::visualize(
  #         @data, 
  #         :as => :area_chart,
  #         :in_element => 'chart',
  #         :series => {
  #           :series_label => 'name',
  #           :data_label => 'date',
  #           :data_method => 'quantity',
  #           :data_series => @series
  #         },
  #         :chart_options => { 
  #           :height => 300,
  #           :width => 300,
  #           :axis_font_size => 11,
  #           :colors => ['#7e7587','#990000','#009900'],
  #           :title => "Widget Quantities",
  #           :point_size => 5
  #         }
  #        )
  #    -%>
  #
  # For details on the chart options, see the Google API docs at 
  # http://code.google.com/apis/visualization/documentation/gallery/annotatedtimeline.html
  #
  class AnnotatedTimeLineChart
  
    include Seer::Chart
    
    # Graph options
    attr_accessor :allowHtml, :allowRedraw, :allowRedraw, :allValuesSuffix, :annotationsWidth, :colors, :dateFormat, :displayAnnotations, :displayAnnotationsFilter, :displayDateBarSeparator, :displayExactValues, :displayLegendDots, :displayLegendValues, :displayRangeSelector, :displayZoomButtons, :fill, :highlightDot, :legendPosition, :max, :min, :numberFormats, :scaleColumns, :scaleType, :thickness, :wmode, :zoomEndTime, :zoomStartTime
    
    # Graph data
    attr_accessor  :data_labels, :data, :data_methods, :date_method, :data_series
    
    def initialize(args={}) #:nodoc:

      # Standard options
      args.each{ |method,arg| self.send("#{method}=",arg) if self.respond_to?(method) }

      # Chart options
      args[:chart_options].each{ |method, arg| self.send("#{method}=",arg) if self.respond_to?(method) }

      # Handle defaults      
      @colors ||= args[:chart_options][:colors] || DEFAULT_COLORS
      @height ||= args[:chart_options][:height] || DEFAULT_HEIGHT
      @width  ||= args[:chart_options][:width] || DEFAULT_WIDTH

      @data_table = []
      
    end
        #   data.addColumn('date', 'Date');
        # data.addColumn('number', 'Sold Pencils');
        # data.addColumn('string', 'title1');
        # data.addColumn('string', 'text1');
        # data.addColumn('number', 'Sold Pens');
        # data.addColumn('string', 'title2');
        # data.addColumn('string', 'text2');

    def data_columns #:nodoc:
      # The first column is of type date or datetime, and specifies the
      # X value of the point on the chart. If this column is of type
      # date (and not datetime) then the smallest time resolution on the
      # X axis will be one day.
      _data_columns =  "           data.addColumn('date', 'Date');\r"
      data_labels.each_with_index do |label, i|
        _data_columns << "           data.addColumn('number', '#{label}');\r"
        _data_columns << "           data.addColumn('string', 'title#{i}');\r"
        _data_columns << "           data.addColumn('string', 'text#{i}');\r"
      end
      _data_columns
    end
    
    def data_table #:nodoc:
      _rows = data_series.first.map{|d| d.send(date_method)}.uniq
      _data_rows = []
      @data_table << "data.addRows([\r"
      data_series.each do |serie|
        serie.each do |row|
          date = row.send(date_method).to_date
          number = row.send(data_methods.first)
          _data_rows << "[new Date(#{date.year}, #{date.month} ,#{date.day}), #{number}, undefined, undefined]"
        end
      end
      
      @data_table << _data_rows.map().join(",\r")
      @data_table << "]);"
    end

    def nonstring_options #:nodoc:
      [:allowHtml, :allowRedraw, :annotationsWidth, :colors, :displayAnnotations, :displayAnnotationsFilter, :displayDateBarSeparator, :displayExactValues, :displayLegendDots, :displayLegendValues, :displayRangeSelector, :displayZoomButtons, :fill, :max, :min, :scaleColumns, :thickness, :zoomEndTime, :zoomStartTime]
    end
    
    def string_options #:nodoc:
      [:allValuesSuffix, :dateFormat, :highlightDot, :legendPosition, :numberFormats, :scaleType, :wmode]
    end
    
    def to_js #:nodoc:

      %{
        <script type="text/javascript">
          google.load('visualization', '1', {'packages':['annotatedtimeline']});
          google.setOnLoadCallback(drawChart);
          function drawChart() {
            var data = new google.visualization.DataTable();
#{data_columns}
#{data_table.to_s}
            var options = {};
#{options}
            var container = document.getElementById('chart');
            var chart = new google.visualization.AnnotatedTimeLine(container);
            chart.draw(data, options);
          }
        </script>
      }
    end
      
    def self.render(data, args) #:nodoc:
      graph = Seer::AnnotatedTimeLineChart.new(
        :data => data,
        :series_label   => args[:series][:series_label],
        :data_labels    => args[:series][:data_labels],
        :date_method     => args[:series][:date_method],
        :data_methods    => args[:series][:data_methods],
        :data_series    => args[:series][:data_series],
        :chart_options  => args[:chart_options],
        :chart_element  => args[:in_element] || 'chart'
      )
      graph.to_js
    end
    
  end  

end
