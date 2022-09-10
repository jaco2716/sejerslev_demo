import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/providers/select_type_provider.dart';

class MySingleChart extends StatefulWidget {
  // final double flowValue;
  final double value;
  // final double pressureValue;

  const MySingleChart({
    Key? key,
    required this.value,
    // required this.pressureValue,
  }) : super(key: key);

  @override
  State<MySingleChart> createState() => _MySingleChartState();
}

class _MySingleChartState extends State<MySingleChart> {
  double chartIndex = 0;
  // List<double> minY = [0, 0];
  // List<double> maxY = [0, 0];
  double minY = 0;
  double maxY = 0;
  double chartValue = 0;
  // List<double> chartValue = [0, 0];
  // bool loading = false;

  List<Stream<List<int>>> streams = [];
  List<FlSpot> chartValues = [];
  // List<List<FlSpot>> chartValues = [[], []];
  final Color gridColor = Color.fromARGB(255, 42, 42, 42);
  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff23b6e6),
  ];
  final List<Color> gradientColors2 = [
    const Color.fromARGB(255, 230, 129, 35),
    const Color.fromARGB(255, 230, 129, 35),
  ];

  @override
  Widget build(BuildContext context) {
    // var selectTypeListProvider = Provider.of<SelectTypeListProvider>(context);
    chartValues.add(FlSpot(chartIndex, (widget.value * 100).roundToDouble() / 100));
    // chartValues[0].add(FlSpot(chartIndex, (widget.value * 100).roundToDouble() / 100));
    // chartValues[1].add(FlSpot(chartIndex, (widget.pressureValue * 100).roundToDouble() / 100));
    if (chartValues.length > 60) {
      chartValues.removeAt(0);
    }

    // if (chartValues[0].length > 60) {
    //   chartValues[0].removeAt(0);
    // }
    // if (chartValues[1].length > 60) {
    //   chartValues[1].removeAt(0);
    // }

    minY = chartValues.reduce((curr, next) => curr.y < next.y ? curr : next).y;
    maxY = chartValues.reduce((curr, next) => curr.y > next.y ? curr : next).y;
    // minY =
    //     chartValues.reduce((curr, next) => curr.y < next.y ? curr : next).y;
    // maxY =
    //     chartValues.reduce((curr, next) => curr.y > next.y ? curr : next).y;
    chartIndex++;

    return Stack(
      children: [
        AspectRatio(
          // aspectRatio: 0.8,
          aspectRatio: 1.6,
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(18),
              ),
              // color: Color(0xff232d37),
            ),
            child: Padding(
              padding: EdgeInsets.zero, // const EdgeInsets.only(right: 4.0, left: 6.0, top: 8, bottom: 8),
              child: LineChart(
                LineChartData(
                  // backgroundColor: Colors.black38,

                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: calculateInterval(maxY, minY),
                    // horizontalInterval: calculateInterval(maxY, minY),
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: gridColor,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: gridColor,
                        strokeWidth: 0.5,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: const Text(
                        '',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                      axisNameSize: 10,
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        // interval: (maxY.ceil() + 1) / 4,
                        interval: calculateInterval(maxY, minY),
                        getTitlesWidget: leftTitleWidgets,
                        reservedSize: 32,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: gridColor, width: 1)),
                  minX: chartValues.first.x,
                  maxX: chartValues.first.x + 60, //60 secounds of data
                  // minY = min - difference from max to min divided by 10, with .5 margin
                  minY: minY - ((maxY - minY) / 10 + .5),
                  // minX = min + difference from max to min divided by 10, with .5 margin
                  maxY: maxY + ((maxY - minY) / 10 + .5),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartValues,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double calculateInterval(double maxY, double minY) {
    // return 10 * (80 / 100);
    double difference = maxY - minY;
    double interval;
    // if (maxY == minY) return 0.1;

    if (difference < 0.5) {
      interval = 0.1;
    } else if (difference < 1) {
      interval = 0.2;
    } else if (difference < 2) {
      interval = 0.4;
    } else if (difference < 30) {
      interval = (0.5 * ((difference) / 5).ceil()).toDouble();
      // interval = 0.5;
      // } else if (difference < 10) {
      //   // interval = ( ((difference) / 10).ceil()).toDouble();

      //   // interval = 1;
      // } else if (difference < 15) {
      //   interval = 1.5;
      // } else if (difference < 20) {
      //   // interval = (((difference) / 8)).toDouble();
      //   interval = 2;
      // } else if (difference < 25) {
      //   interval = 2.5;
      // } else if (difference < 30) {
      //   interval = 3;
    } else {
      // interval = (((difference) / 10).ceil()).toDouble();
      interval = (5 * ((difference) / 50).round()).toDouble();
    }

    // if (difference < 0.5) {
    //   interval = 0.1;
    // } else if (difference < 1) {
    //   interval = 0.2;
    // } else if (difference < 3) {
    //   interval = 0.5;
    // } else if (difference < 5) {
    //   interval = 1;
    // } else if (difference < 10) {
    //   interval = 1.2;
    // } else if (difference < 15) {
    //   interval = 1.7;
    // } else if (difference < 20) {
    //   interval = 2;
    // } else if (difference < 50) {
    //   interval = 10;
    // } else {
    //   interval = (10 * ((difference) / 50).ceil()).toDouble();
    // }
    return interval;
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    if (meta.max == value || meta.min == value) {
      return const Text('');
    }
    const style = TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.w500,
      fontSize: 11,
    );
    String text = value.toStringAsFixed(1);
    String intText = value.toInt().toString();
    var remain = value - value.floor();
    if (remain > 0) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          text,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white54,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        intText,
        style: style,
        textAlign: TextAlign.right,
      ),
    );
  }
}
