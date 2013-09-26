
(function(){
  var margin = {top: 20, right: 20, bottom: 30, left: 40},
      width = 960 - margin.left - margin.right,
      height = 500 - margin.top - margin.bottom;

  var x = d3.scale.linear()
      .range([0, width]);

  var y = d3.scale.linear()
      .range([height, 0]);

  var color = d3.scale.category10();

  var xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom");

  var yAxis = d3.svg.axis()
      .scale(y)
      .orient("left");

  var svg = d3.select("#plot-goes-here").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .attr("class","data-plot")
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  var plotData = this.plotData = function(name, domain, range){
    $.ajax({
      type:'POST',
      url:'/ajax/data',
      data:{type:name},
      success: function(data) {
        console.log(data);
        data = data.data;
        console.log(domain,range);

        x.domain(d3.extent(data, function(d) { return d.data[domain]; })).nice();
        y.domain(d3.extent(data, function(d) { return d.data[range]; })).nice();
        console.log(height);
        svg.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + height + ")")
            .call(xAxis)
            .append("text")
            .attr("class", "label")
            .attr("x", width)
            .attr("y", -6)
            .style("text-anchor", "end")
            .text(domain);

        svg.append("g")
            .attr("class", "y axis")
            .call(yAxis)
            .append("text")
            .attr("class", "label")
            .attr("transform", "rotate(-90)")
            .attr("y", 6)
            .attr("dy", ".71em")
            .style("text-anchor", "end")
            .text(range)

        svg.selectAll(".dot")
            .data(data)
            .enter().append("circle")
            .attr("class", "dot")
            .attr("r", 3)
            .attr("cx", function(d) { console.log('x', d.data[domain]); return x(d.data[domain]); })
            .attr("cy", function(d) { console.log('y', d.data[range]); return y(d.data[range]); })
            .style("fill", function(d) { return 'black'; });


      }
    });
  };
  $('#plot-that').click(function(){
    var name = $('#type').val();
    var domain = $('#domain').val();
    var range = $('#range').val();
    plotData(name, domain, range);
  });
}).apply(window);