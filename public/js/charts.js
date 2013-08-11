/* Create a bar chart of the data in monthDomain grouped by month */
function monthlyBarChart(location, monthDimension, monthDomain) {
  var monthGroup = monthDimension.group().reduceCount().orderNatural();

  var monthChart = dc.barChart(location)
    .width(900)
    .height(250)
    .gap(2)
    .dimension(monthDimension)
    .group(monthGroup)
    .centerBar(true)
    .x(d3.time.scale().domain(monthDomain))
    .xUnits(d3.time.months)
    .margins({top: 10, right: 50, bottom: 30, left: 60});

  monthChart.xAxis().ticks(d3.time.months, 2)
    .tickFormat(d3.time.format("%b %Y"));
}

function commChart(location, communityDimension) {
  var communityGroup = communityDimension.group().reduceCount().orderNatural();

  var commChart = dc.pieChart(location)
    .width(300)
    .height(300)
    .radius(100)
    .dimension(communityDimension)
    .group(communityGroup)
    .colors(['#F1A82F', '#F1CD91']);
}

function percentMergedChart(location, mergeDimension) {
  var mergeGroup = mergeDimension.group().reduceCount().orderNatural();

  var mergeChart = dc.pieChart(location)
    .width(300)
    .height(300)
    .radius(100)
    .dimension(mergeDimension)
    .group(mergeGroup)
    .colors(['#7D64AC', '#501FAC']);
}

function perRepositoryChart(location, repoDimension) {
  var repoGroup = repoDimension.group().reduceCount().orderNatural();

  var repoChart = dc.rowChart(location)
    .width(400)
    .height(200)
    .group(repoGroup)
    .dimension(repoDimension)
    .colors(['#501FAC', '#6742AC', '#7D64AC', '#9487AC']);

  repoChart.xAxis().ticks(5);
}

function pullRequestsPerWeek(location, weekDimension, weekDomain) {

  var weekGroup = weekDimension.group().reduceCount().orderNatural();

  var weekChart = dc.barChart(location)
    .width(900)
    .height(250)
    .gap(2)
    .dimension(weekDimension)
    .group(weekGroup)
    .centerBar(true)
    .x(d3.time.scale().domain(weekDomain))
    .xUnits(d3.time.weeks)
    .margins({top: 10, right: 10, bottom: 30, left: 60});

  weekChart.xAxis().ticks(d3.time.weeks, 6)
    .tickFormat(d3.time.format("%m/%y"));
}

function lifetimesPerMonth(location, monthDimension, monthDomain) {
  var lifetimeGroup = monthDimension.group().reduce(
      function(p,v){
        ++p.count;
        p.sum_ttl += v.ttl;
        p.avg = p.sum_ttl / p.count;
        return p;
      },
      function(p,v){
        --p.count;p.sum_ttl -= v.ttl;
        p.avg = p.sum_ttl / p.count;
        return p;
      },
      function(){
        return {count: 0, sum_ttl: 0, avg: 0};
      }
      );

  var lifetimes = dc.lineChart(location)
    .width(900)
    .height(250)
    .dimension(monthDimension)
    .group(lifetimeGroup)
    .x(d3.time.scale().domain(monthDomain))
    .xUnits(d3.time.months)
    .renderArea(true)
    .margins({top: 10, right: 50, bottom: 30, left: 60});

  lifetimes.xAxis().ticks(d3.time.months, 2)
    .tickFormat(d3.time.format("%b %Y"));

  lifetimes.valueAccessor(function(p) { return p.value.avg; });
}
