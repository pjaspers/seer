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
  class AnnotatedTimeLineChart

    include Seer::Chart

    # Graph options
    attr_accessor :allowHtml, :allowRedraw, :allowRedraw, :allValuesSuffix, :annotationsWidth, :dateFormat, :displayAnnotations, :displayAnnotationsFilter, :displayDateBarSeparator, :displayExactValues, :displayLegendDots, :displayLegendValues, :displayRangeSelector, :displayZoomButtons, :fill, :highlightDot, :legendPosition, :max, :min, :numberFormats, :scaleColumns, :scaleType, :thickness, :wmode, :zoomEndTime, :zoomStartTime, :height, :width

    # Graph data
    attr_accessor :data, :data_label, :date_method, :data_series, :data_table, :data_annotations, :sort_method, :quantity_method

    def initialize(args={}) #:nodoc:
      # setup_logger

      # Standard options
      args.each{ |method,arg| self.send("#{method}=",arg) if self.respond_to?(method) }

      # Chart options
      args[:chart_options].each{ |method, arg| self.send("#{method}=",arg) if self.respond_to?(method) }

      # Handle defaults
      @colors ||= args[:chart_options][:colors] || DEFAULT_COLORS
      @data_table = []
      @data_series = data_series
      @annotations = data_annotations || []
    end

    # A handy way to set up a logger.
    def setup_logger
      logfile = File.open('/Users/junkiesxl/seer.log', 'a')
      logfile.sync = true
      @logger = Logger.new(logfile)
      @logger.info "Intialized."
    end

    def height=
        raise ArgumentError, "You must set height explicitly on the div element."
    end

    def width=
        raise ArgumentError, "You must set width explicitly on the div element."
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
      data.each_with_index do |d, i|
        _data_columns << "           data.addColumn('number', '#{escape_javascript(d.send(data_label))}');\r"
        _data_columns << "           data.addColumn('string', 'text#{i+1}');\r"
        _data_columns << "           data.addColumn('string', 'title#{i+1}');\r"
      end
      _data_columns
    end

    def date_from_time time
      Date.new(time.year, time.month, time.day)
    end

    def get_date_from_date date
        date.to_s.to_date rescue date_from_time(Time.at(Integer(date)))
    end

    def annotations_by_date
      unless @annotations_by_date
        @annotations_by_date = { }
        @annotations.group_by(&date_method.to_sym).each do |timestamp, annotation|
          date = get_date_from_date(timestamp)
          unless  @annotations_by_date.has_key?(date)
            @annotations_by_date[date] = []
          end
          @annotations_by_date[date] << annotation
        end
      end
      @annotations_by_date
    end

    def data_table #:nodoc:
      rows          = "    data.addRows([\r"

      if @data_series.first.respond_to?(date_method.to_sym)
        @data_series = @data_series.group_by(&date_method.to_sym)
      else
        @data_series = @data_series.flatten.group_by(&date_method.to_sym)
      end



      _rows = []
      @data_series.each do |date, _data|
        # Getting the date in JS
        date         = get_date_from_date(date)
        date_part    = ["new Date(#{date.year}, #{date.month-1} ,#{date.day})"]

        # Getting the quantities
        ids          = @data.map{ |d| d.send(sort_method)}
        quantities   = []
        ids.each do |id|
          sorted = _data.select{ |ts| ts.send(sort_method) == id}
          q = 0
          unless sorted.empty?
            if sorted.first.respond_to?(quantity_method.to_sym)
              q = sorted.first.send(quantity_method.to_sym)
            else
              q = sorted.send(quantity_method.to_sym)
            end
          end
          if annotation = annotation_for_date_and_id(date, id)
            title = "'#{escape_javascript(annotation.title)}'"
            description = "'#{escape_javascript(annotation.description)}'"
            description = 'undefined' if (annotation.title == annotation.description)
            quantities << "#{q}, #{title}, #{description}"
          else
            quantities << "#{escape_javascript(q.to_s)}, undefined, undefined"
          end

        end
        _rows << "      [" + (date_part + quantities).join(",") + "]" if date_part
      end

      rows << _rows.join(", \r")
      rows << "]);"
      rows
    end

    def annotation_for_date_and_id date, id
      annotations_sorted_by_date = annotations_by_date
      annotation = nil
      if annotations = annotations_sorted_by_date[date]
        annotations.flatten.each do |ant|
          if ant.send(sort_method) == id
            annotation = ant
          end
        end
      end
      annotation
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
#{data_table}
            var options = {};
#{options}
            var container = document.getElementById('#{chart_element}');
            var chart = new google.visualization.AnnotatedTimeLine(container);
            chart.draw(data, options);
          }
        </script>
      }
    end

    def self.render(data, args) #:nodoc:
      graph = Seer::AnnotatedTimeLineChart.
        new(
            :data => data,
            :data_label    => args[:series][:data_label],
            :date_method     => args[:series][:date_method],
            :quantity_method => args[:series][:quantity_method],
            :sort_method     => args[:series][:sort_method] || 'user_id',
            :data_series    => args[:series][:data_series],
            :data_annotations => args[:series][:annotations],
            :chart_options  => args[:chart_options],
            :chart_element  => args[:in_element] || 'chart'
            )
      graph.to_js
    end

  end

end

class Array
  def second
    at(1)
  end
end
