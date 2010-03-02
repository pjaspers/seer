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
  #     
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
  class MotionChart
  
    include Seer::Chart
    
    # Graph options
    attr_accessor :allowHtml, :allowRedraw, :allowRedraw, :allValuesSuffix, :annotationsWidth, :colors, :dateFormat, :displayAnnotations, :displayAnnotationsFilter, :displayDateBarSeparator, :displayExactValues, :displayLegendDots, :displayLegendValues, :displayRangeSelector, :displayZoomButtons, :fill, :highlightDot, :legendPosition, :max, :min, :numberFormats, :scaleColumns, :scaleType, :thickness, :wmode, :zoomEndTime, :zoomStartTime
    
    # Graph data
    attr_accessor :data, :data_label, :data_methods, :series_labels, :date_method, :data_series, :data_table
    
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
      @data_series = data_series
    end
        #   data.addColumn('date', 'Date');
        # data.addColumn('number', 'Sold Pencils');
        # data.addColumn('string', 'title1');
        # data.addColumn('string', 'text1');
        # data.addColumn('number', 'Sold Pens');
        # data.addColumn('string', 'title2');
        # data.addColumn('string', 'text2');

    def data_columns #:nodoc:
      _data_columns =  "           data.addColumn('string', '#{data_label}');\r"
      _data_columns <<  "           data.addColumn('date', 'Date');\r"
      series_labels.each do |label|
        _data_columns << "           data.addColumn('number', '#{label}');\r"
      end
      _data_columns
    end
    
    
    def data_table #:nodoc:
      _rows          = []
      @data_table << "           data.addRows([\r"
      # First loop through our array objects
      @data_series.each do |serie|
        if serie.first.respond_to?(date_method.to_sym)
          serie = serie.group_by(&date_method.to_sym)
        else
          serie = serie.flatten.group_by(&date_method.to_sym)
        end if

        # Now loop through our objects array
        serie.each do |date, content|
          # Getting the date in JS
          date         = date.to_date
          date_part    = ["new Date(#{date.year}, #{date.month} ,#{date.day})"]

          # Getting the quantities
          ids          = @data
          quantities   = []
          label = ""
          ids.each_with_index do |id, i|
            label = id.to_s
            #q          = content.select{ |ts| ts== id}
            data_methods.each do |method|
              quantities << "#{content.send(method)}"
            end
            _rows << "               [ #{label}, " + (date_part + quantities).join(",") + "]"
          end
        end 
      end
      @data_table << _rows.join(",\r")
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
      graph = Seer::MotionChart.new(
        :data => data,
        :data_label    => args[:series][:data_label],
        :date_method     => args[:series][:date_method],
        :data_series    => args[:series][:data_series],
        :chart_options  => args[:chart_options],
        :chart_element  => args[:in_element] || 'chart'
      )
      graph.to_js
    end
    
  end  

end
