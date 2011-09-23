window.HQuery = 
  drawChart: (type, title, keys, values) ->
    r = Raphael "chart"
    r.g.txtattr.font = "12px 'Fontin Sans', Fontin-Sans, sans-serif"
    r.g.text(320, 100, title).attr({"font-size": 20})
  
    switch type
      when 'pie'
        r.g.piechart 320, 240, 100, values, {legend: keys, legendpos: "west"}
      when 'bar'
        fin = -> this.flag = r.g.popup(@bar.x, @bar.y, @bar.value or "0").insertBefore(this)
        fout = -> this.flag.animate {opacity: 0}, 300, ->
                                                  this.remove()
        chart = r.g.barchart 100, 100, 300, 300, values
        chart.label keys
        chart.hover fin, fout