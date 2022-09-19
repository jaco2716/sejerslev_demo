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

    double tempMin = chartValues.reduce((curr, next) => curr.y < next.y ? curr : next).y;
    double tempMax = chartValues.reduce((curr, next) => curr.y > next.y ? curr : next).y;
    minY = tempMin - ((tempMax * 1.2 - tempMin) / 10 + .5);
    maxY = tempMax + ((tempMax * 1.2 - tempMin) / 10 + .5);

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
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: gridColor, width: 1)),
                  minX: chartValues.first.x,
                  maxX: chartValues.first.x + 60, //60 secounds of data
                  // minY = min - difference from max to min divided by 10, with .5 margin
                  minY: minY,
                  // minX = min + difference from max to min divided by 10, with .5 margin
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      curveSmoothness: 0,
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
    double difference = maxY - minY;
    double interval;
    // if (maxY >= 1000) {
    //   difference = difference / 1000;
    //   if (difference < 0.5) {
    //     interval = 10;
    //   } else if (difference < 1) {
    //     interval = 20;
    //   } else if (difference < 2) {
    //     interval = 50;
    //   } else if (difference < 30) {
    //     interval = (50 * ((difference) / 50).ceil()).toDouble();
    //     print('interval');
    //   } else {
    //     interval = (50 * ((difference) / 500).ceil()).toDouble();
    //   }
    // } else
    if (difference < 1.2) {
      interval = 0.1;
    } else if (difference < 3) {
      interval = 0.2;
    } else if (difference < 5) {
      interval = 0.4;
    } else if (difference < 30) {
      interval = (0.5 * ((difference) / 5).ceil()).toDouble();
    } else if (difference < 300) {
      interval = (5 * ((difference) / 50).round()).toDouble();
    } else if (difference < 1500) {
      interval = (50 * ((difference) / 500).round()).toDouble();
    } else if (difference < 5000) {
      interval = (250 * ((difference) / 2500).round()).toDouble();
    } else {
      interval = (500 * ((difference) / 5000).round()).toDouble();
    }
    return interval;
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    if (meta.max == value || meta.min == value) {
      return const Text('');
    }
    String suffix = '';
    int decimals = 2;
    double newValue = value;
    if ((value >= 1000 && value < 1000000) || (value <= -1000 && value > -1000000)) {
      newValue = value / 1000;
      suffix = 'K';
    } else if ((value >= 1000000) || (value <= -1000000)) {
      newValue = value / 1000000;
      suffix = 'M';
    }
    if ((newValue >= 10 && newValue < 100) || (newValue <= -10 && newValue > -100)) {
      decimals = 1;
    } else if (newValue >= 100 || newValue <= -100) {
      decimals = 0;
    }

    var style = const TextStyle();
    var remain = newValue - newValue.floor();
    String text = '';
    if (remain > 0) {
      text = '${newValue.toStringAsFixed(decimals)}$suffix';

      style = const TextStyle(
        fontSize: 10,
        color: Colors.white54,
      );
    } else {
      if (meta.max >= 1000 && value < 1000) {
        text = '${newValue.toInt().toString()}$suffix';
        style = const TextStyle(
          fontSize: 10,
          color: Colors.white54,
        );
      } else {
        text = '${newValue.toInt().toString()}$suffix';
        style = const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Text(text, textAlign: TextAlign.right, style: style),
    );
  }
}
