function getJsTimestamp( timeString ) {
            // split the mssql timestamp, and return it so that we 
            // can create a date in javascript
            var arrMssqldate = timeString.split( ' ' );
            var arrDate = arrMssqldate[0].split( '-', 3 );
            var arrTime = arrMssqldate[1].split( ':', 2);

            var timeObject = new Object;
            timeObject.year = arrDate[0];
            timeObject.month = arrDate[1];
            timeObject.day = arrDate[2];
            timeObject.hour = arrTime[0];
            timeObject.minute = arrTime[1];
            timeObject.second = '00';
            
            return timeObject;
    
}

    function chart0_funct(attachmentpoint)
    {
        var chart;
        var chartData = [];
        var chartCursor;

        AmCharts.ready(function ()
        {
            // generate some data first
            generateChartData();

            // SERIAL CHART    
            chart = new AmCharts.AmSerialChart();
            chart.pathToImages = "../amcharts/images/";
            chart.zoomOutButton = {
                backgroundColor: '#000000',
                backgroundAlpha: 0.15
            };
            chart.dataProvider = chartData;
            chart.categoryField = "date";

            // listen for "dataUpdated" event (fired when chart is rendered) and call zoomChart method when it happens
            chart.addListener("dataUpdated", zoomChart);

            // AXES
            // category
            var categoryAxis = chart.categoryAxis;
            categoryAxis.parseDates = true; // as our data is date-based, we set parseDates to true
            categoryAxis.minPeriod = "DD"; // our data is daily, so we set minPeriod to DD
            categoryAxis.dashLength = 1;
            categoryAxis.gridAlpha = 0.15;
            categoryAxis.axisColor = "#DADADA";

            // value                
            var valueAxis = new AmCharts.ValueAxis();
            valueAxis.axisAlpha = 0.2;
            valueAxis.dashLength = 1;
            chart.addValueAxis(valueAxis);

            // GRAPH
            var graph = new AmCharts.AmGraph();
            graph.title = "red line";
            graph.valueField = "visits";
            graph.bullet = "round";
            graph.bulletBorderColor = "#FFFFFF";
            graph.bulletBorderThickness = 2;
            graph.lineThickness = 2;
            graph.lineColor = "#b5030d";
            graph.negativeLineColor = "#0352b5";
            graph.hideBulletsCount = 50; // this makes the chart to hide bullets when there are more than 50 series in selection
            chart.addGraph(graph);

            // CURSOR
            chartCursor = new AmCharts.ChartCursor();
            chartCursor.cursorPosition = "mouse";
            chart.addChartCursor(chartCursor);

            // SCROLLBAR
            var chartScrollbar = new AmCharts.ChartScrollbar();
            chartScrollbar.graph = graph;
            chartScrollbar.scrollbarHeight = 40;
            chartScrollbar.color = "#FFFFFF";
            chartScrollbar.autoGridCount = true;
            chart.addChartScrollbar(chartScrollbar);

            // WRITE
            chart.write(attachmentpoint);
        });

        // generate some random data, quite different range
        function generateChartData()
        {
            var firstDate = new Date();
            firstDate.setDate(firstDate.getDate() - 500);

            for (var i = 0; i < 500; i++)
            {
                var newDate = new Date(firstDate);
                newDate.setDate(newDate.getDate() + i);

                var visits = Math.round(Math.random() * 40) - 20;

                chartData.push(
                {
                    date: newDate,
                    visits: visits
                });
            }
        }

        // this method is called when chart is first inited as we listen for "dataUpdated" event
        function zoomChart()
        {
            // different zoom methods can be used - zoomToIndexes, zoomToDates, zoomToCategoryValues
            chart.zoomToIndexes(chartData.length - 40, chartData.length - 1);
        }

        // changes cursor mode from pan to select
        function setPanSelect()
        {
            if (document.getElementById("rb1").checked)
            {
                chartCursor.pan = false;
                chartCursor.zoomable = true;

            }
            else
            {
                chartCursor.pan = true;
            }
            chart.validateNow();
        }
    }

    function chart1_funct(attachmentpoint)
    {
        var chart1;
        var chartData1 = [
        {
            date: new Date(2012, 3, 1),
            price: 20
        },
        {
            date: new Date(2012, 3, 2),
            price: 75
        },
        {
            date: new Date(2012, 3, 3),
            price: 15
        },
        {
            date: new Date(2012, 3, 4),
            price: 75
        },
        {
            date: new Date(2012, 3, 5),
            price: 158
        },
        {
            date: new Date(2012, 3, 6),
            price: 57
        },
        {
            date: new Date(2012, 3, 7),
            price: 107
        },
        {
            date: new Date(2012, 3, 8),
            price: 89
        },
        {
            date: new Date(2012, 3, 9),
            price: 75
        },
        {
            date: new Date(2012, 3, 10),
            price: 132
        },
        {
            date: new Date(2012, 3, 11),
            price: 158
        },
        {
            date: new Date(2012, 3, 12),
            price: 56
        },
        {
            date: new Date(2012, 3, 13),
            price: 169
        },
        {
            date: new Date(2012, 3, 14),
            price: 24
        },
        {
            date: new Date(2012, 3, 15),
            price: 147
        }];

        var average = 90.4;

        AmCharts.ready(function ()
        {

            // SERIAL CHART    
            chart1 = new AmCharts.AmSerialChart();
            chart1.pathToImages = "../amcharts/images/";
            chart1.zoomOutButton = {
                backgroundColor: '#000000',
                backgroundAlpha: 0.15
            };
            chart1.dataProvider = chartData1;
            chart1.categoryField = "date";

            // AXES
            // category
            var categoryAxis1 = chart1.categoryAxis;
            categoryAxis1.parseDates = true; // as our data is date-based, we set parseDates to true
            categoryAxis1.minPeriod = "DD"; // our data is daily, so we set minPeriod to DD
            categoryAxis1.dashLength = 1;
            categoryAxis1.gridAlpha = 0.15;
            categoryAxis1.axisColor = "#DADADA";

            // value                
            var valueAxis1 = new AmCharts.ValueAxis();
            valueAxis1.axisColor = "#DADADA";
            valueAxis1.dashLength = 1;
            valueAxis1.logarithmic = true; // this line makes axis logarithmic
            chart1.addValueAxis(valueAxis1);

            // GUIDE for average
            var guide1 = new AmCharts.Guide();
            guide1.value = average;
            guide1.lineColor = "#CC0000";
            guide1.dashLength = 4;
            guide1.label = "average";
            guide1.inside = true;
            guide1.lineAlpha = 1;
            valueAxis1.addGuide(guide1);


            // GRAPH
            var graph1 = new AmCharts.AmGraph();
            graph1.type = "smoothedLine";
            graph1.bullet = "round";
            graph1.bulletColor = "#FFFFFF";
            graph1.bulletBorderColor = "#00BBCC";
            graph1.bulletBorderThickness = 2;
            graph1.bulletSize = 7;
            graph1.title = "Price";
            graph1.valueField = "price";
            graph1.lineThickness = 2;
            graph1.lineColor = "#00BBCC";
            chart1.addGraph(graph1);

            // CURSOR
            var chartCursor1 = new AmCharts.ChartCursor();
            chartCursor1.cursorPosition = "mouse";
            chart1.addChartCursor(chartCursor1);

            // SCROLLBAR
            var chartScrollbar1 = new AmCharts.ChartScrollbar();
            chart1.addChartScrollbar(chartScrollbar1);

            // WRITE
            chart1.write(attachmentpoint);
        });
    }

    function chart2_funct(statOne, statTwo, statThree, attachmentpoint)
    {
        var chart2;

        var chartData2 = [
        {
            country: "Completed jobs",
            jobs: statOne,
            color: "#04D215"
        },
        {
            country: "Pending jobs",
            jobs: statTwo,
            color: "#FF9E01"
        },
        {
            country: "Unstarted jobs",
            jobs: statThree,
            color: "#FF0F00"
        }];
        AmCharts.ready(function ()
        {
            // SERIAL CHART
            chart2 = new AmCharts.AmSerialChart();
            chart2.dataProvider = chartData2;
            chart2.categoryField = "country";
            // the following two lines makes chart 3D
            chart2.depth3D = 20;
            chart2.angle = 30;

            // AXES
            // category
            var categoryAxis2 = chart2.categoryAxis;
            categoryAxis2.labelRotation = 0;
            categoryAxis2.dashLength = 5;
            categoryAxis2.gridPosition = "start";

            // value
            var valueAxis2 = new AmCharts.ValueAxis();
            valueAxis2.title = "Number of jobs";
            valueAxis2.dashLength = 5;
            chart2.addValueAxis(valueAxis2);

            // GRAPH            
            var graph2 = new AmCharts.AmGraph();
            graph2.valueField = "jobs";
            graph2.colorField = "color";
            graph2.balloonText = "[[category]]: [[value]]";
            graph2.type = "column";
            graph2.lineAlpha = 0;
            graph2.fillAlphas = 1;
            chart2.addGraph(graph2);

            // WRITE
            chart2.write(attachmentpoint);
        });
    }
