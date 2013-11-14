$ ->
  $('.daterange').datarange
    numberOfMonths: 4
  colors = d3.scale.category10()
  all.color = colors '(全部)'
  type.color = colors type.name for type in types
  rest.color = colors '(其它)'
  rs.locals.query.ends = Number rs.locals.query.ends
  rs.locals.query.starts = Number rs.locals.query.starts
  INTERVAL = rs.locals.query.ends - rs.locals.query.starts
  INTERVAL/= types[0].type.times.length
  HOUR = 3600 * 1000
  DAY = 24 * HOUR
  WEEK = 7 * DAY

  coffeecall = (obj, func, findex, args...)-> 
    lastArg = args.pop()
    args.splice findex, 0, lastArg
    obj[func].apply obj, args

  if $('.graph_time').length
    series = []
    alltypes = [all].concat(types).concat([rest])
    for type, i in alltypes
      series.push 
        name: "#{type.name}" + if i then "" else "-#{metric1.name}"
        type: "spline"
        yAxis: 0
        color: type.color
        visible: !i
        data: type.type.times.map (d)->(d||[0, 0])[0]
        pointInterval: INTERVAL
        pointStart: Number rs.locals.query.starts
      series.push 
        name: "#{type.name}" + if i then "" else "-#{metric2.name}"
        type: "areaspline"
        yAxis: 1
        fillColor : 
          linearGradient : [0, 0, 0, 400],
          stops : [
            [0, type.color]
            [1, 'rgba(255, 255, 255, .6)']
          ]
        visible: !i
        data: type.type.times.map (d)->(d||[0, 0])[1]
        pointInterval: INTERVAL
        pointStart: Number rs.locals.query.starts
    legendItemClick = ->
      if @visible
        @hide()
      else
        @show()
      i = @chart.series.indexOf @
      m = i % 2
      if i - m # 分量
        if @chart.series.filter((s, i)-> i!=m && i % 2 == m && s.visible).length
          @chart.series[m].hide()
        else
          @chart.series[m].show()
      else
        if @visible
          s.hide() for s in @chart.series.filter((s, i)-> i!=m && i % 2 == m && s.visible)

      return false
    chart_time = new Highcharts.Chart
      chart:
        renderTo: $(".graph_time")[0]
      credits: false
      title: ''
      xAxis: 
        type: 'datetime'
      yAxis: [
        title:
          text: metric1.name
      ,
        title:
          text: metric2.name
        opposite: true
      ]
      legend:
        align: 'right'
        verticalAlign: 'middle'
        width: 300
        itemWidth: 150
      tooltip:
        shared: true
      series: series
      plotOptions:
        areaspline: 
          marker:
            enabled: false
          lineWidth: 0 
          fillOpacity: 1
          events:
            legendItemClick: legendItemClick
          zIndex: 10

        spline:
          marker:
            enabled: false
          lineWidth: 2
          events:
            legendItemClick: legendItemClick
          zIndex: 11





  if $('.graph_time_percentage').length
    graph_time_percentage = new Highcharts.Chart
      chart:
        renderTo: $(".graph_time_percentage")[0]
      credits: false
      title: ''
      xAxis: 
        type: 'datetime'
      yAxis: [
        title:
          text: metric1.name
      ]
      legend:
        align: 'right'
        verticalAlign: 'middle'
        width: 150
        itemWidth: 150
      tooltip:
        shared: true
      series: types.concat([rest]).map (type, i)->
        name: "#{type.name}"
        type: "areaspline"
        fillColor: type.color
        fillOpacity: 0.1
        data: type.type.times.map (d)->(d||[0, 0])[0]
        pointInterval: INTERVAL
        pointStart: Number rs.locals.query.starts
      plotOptions:
        areaspline:
          stacking: 'percent'
          marker:
            enabled: false
          lineWidth: 0 







  hichart_data_metric1 = []
  hichart_data_metric2 = []
  for type, i in types.concat([rest])
    hichart_data_metric1.push 
      name: "#{metric1.name}: #{type.name}"
      color: type.color
      y: type.type.sums[m1index]
    hichart_data_metric2.push 
      name: "#{metric2.name}: #{type.name}"
      color: 
        radialGradient: 
          cx: 0.5
          cy: 0.5
          r: 1
        stops: [
          [0, 'rgba(255, 255, 255, .6)']
          [1, type.color]
        ]
      y: type.type.sums[m2index]
  if $('.graph_pie').length


    chart_pie = new Highcharts.Chart
      chart:
        renderTo: $('.graph_pie')[0]
      credits: false
      title: ''
      tooltip:
        shared: true
      series: [
        name: "#{classification.name}-#{metric1.name}"
        type: "pie"
        data: hichart_data_metric1
        center: ['30%', '50%']
      ,
        name: "#{classification.name}-#{metric2.name}"
        type: "pie"
        data: hichart_data_metric2
        center: ['70%', '50%']
      ]
      legend:
        layout: 'vertical'
        align: 'right'
        verticalAlign: 'middle'
        width: 300
        itemWidth: 300

  if $('.graph_bars').length
    chart_bars = new Highcharts.Chart
      chart:
        renderTo: $('.graph_bars')[0]
      credits: false
      title: ''
      tooltip:
        shared: true
      xAxis: 
        categories: types.map((type)->type.name).concat ['其它']
      series: [
        name: "#{metric1.name}"
        type: "column"
        data: hichart_data_metric1.map (d)-> d.y
      ,
        name: "#{metric2.name}"
        type: "column"
        data: hichart_data_metric2.map (d)-> d.y
      ]

  if $('.graph_weeks').length
    type = all
    
    days = []
    cur =  rs.locals.query.starts
    while true
      unless day?.ends > cur
        days.push day =
          name: type.name
          hours: []
        day.starts = cur
        day.ends = cur + DAY
      
      day.hours.push 
        starts: cur
        value: coffeecall type.type.times, 'reduce', 0, 0, (s, time, i)->
          t = rs.locals.query.starts + INTERVAL * i
          return s + (time||[0])[0] if cur <= t < cur + HOUR
          return s
      cur+= HOUR
      break if cur >= rs.locals.query.ends
    days.splice 0, days.length - 7

    colors = [
      '#702f9d'
      '#352f9e'
      '#2f659e'
      '#2fa09c'
      '#3fa42c'
      '#9ab12d'
      '#bdb82c'
      '#bd9b2c'
      '#bd7f2c'
      '#bd5c2b'
    ]
    maxvalue = 0
    for day in days
      for hour in day.hours
        maxvalue = Math.max maxvalue, hour.value||0
    color =  d3.scale.linear().domain([0, maxvalue]).range([0, colors.length - 1])
    x = d3.scale.linear().domain([0, 24]).range([100, 2400 + 100])
    y = d3.scale.linear().domain([0, 7]).range([100, 700 + 100])
    # unchained d3,
    #   __select:
    #     __0: '.graph_weeks svg'

    unchained d3,
      __select:
        __0: '.graph_weeks svg'
        __selectAll: 
          __0: 'g.day'
          __data: 
            __0: days
            __1: (day)-> day.starts
            __enter:
              __append:
                __0: 'g'
                classed: 
                  __0: 'day'
                  __1: true
                __append:
                  __0: 'text'
                  text: (day, id)-> moment.langData()._weekdaysShort[id]
                  attr:
                    x: 0
                    y: 30
                  style:
                    'font-size': 24
            __exit:
              __remove: null
            attr:
              transform: (day, id)-> "translate(0, #{y id})"
            __selectAll:
              __0: 'g.hour'
              __data: 
                __0: (day)-> day.hours
                __1: (hour)-> hour.starts
                __enter:
                  __append:
                    __0: 'g'
                    classed:
                      __0: 'hour'
                      __1: true
                    __append:
                      __0: 'rect'
                      attr:
                        width: 0
                        x: 3
                        y: 3
                        height: 100 - 3 * 2
                        rx: 20
                        ry: 20
                      style:
                        fill: (hour, ih)-> colors[Math.floor color hour.value]
                        stroke: (hour, ih)-> d3.rgb(colors[Math.floor color hour.value]).darker 1
                        'stroke-width': 0
                __exit:
                  __remove: null
                attr:
                  transform: (hour, ih)-> "translate(#{x ih}, 0)"
                __select:
                  __0: 'rect'
                  __transition:
                    __delay:
                      __0: (hour, ih, id)-> id * 50 + ih * 10 
                      attr:
                        width: 100 - 3 * 2
                      style:
                        fill: (hour, ih)-> colors[Math.floor color hour.value] 
                  on:
                    'mouseenter': (hour, ih)->
                      d3.select(this).style
                        'stroke-width': 7
                    'mouseleave': (hour, ih)->
                      d3.select(this).style
                        'stroke-width': 0
                          




      














