window.HQuery =
  drawChart: (type, title, keys, values) ->
    r = Raphael "chart"
    r.g.txtattr.font = "12px 'Fontin Sans', Fontin-Sans, sans-serif"
    r.g.text(320, 100, title).attr({"font-size": 20})

    switch type
      when 'pie'
        fin = ->
          @sector.stop()
          @sector.scale 1.1, 1.1, @cx, @cy
          @flag = r.g.popup(@cx, @cy, @sector.value.value or "0")
          if @label
            @label[0].stop()
            @label[0].scale 1.5
            @label[1].attr {"font-weight": 800}
        fout = ->
          @sector.animate {scale: [1, 1, @cx, @cy]}, 500, "bounce"
          @flag.animate {opacity: 0}, 300, ->
                                          this.remove()
          if @label
            @label[0].animate {scale: 1}, 500, "bounce"
            @label[1].attr {"font-weight": 400}

        pie = r.g.piechart 320, 240, 100, values, {legend: keys, legendpos: "west"}
        pie.hover fin, fout
      when 'bar'
        fin = -> @flag = r.g.popup(@bar.x, @bar.y, @bar.value or "0").insertBefore(this)
        fout = -> @flag.animate {opacity: 0}, 300, ->
                                                  this.remove()
        chart = r.g.barchart 100, 100, 300, 300, values
        chart.label keys
        chart.hover fin, fout