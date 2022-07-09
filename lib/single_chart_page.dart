import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SingleChartPage extends StatefulWidget {
  const SingleChartPage({Key? key}) : super(key: key);

  @override
  State<SingleChartPage> createState() => _SingleChartPageState();
}

class _SingleChartPageState extends State<SingleChartPage> {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff23b6e6),
  ];
  List<Color> gradientColors2 = [
    Color.fromARGB(255, 230, 129, 35),
    Color.fromARGB(255, 230, 129, 35),
    // Color.fromARGB(255, 255, 243, 74),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chart')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.black45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(onPressed: () {}, child: Text('1 Month')),
                  ElevatedButton(onPressed: () {}, child: Text('1 Year')),
                  TextButton(onPressed: () {}, child: Text('5 Years')),
                  TextButton(onPressed: () {}, child: Text('All')),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 1.7,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(18),
                  ),
                  // color: Color(0xff232d37),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: 18.0, left: 12.0, top: 24, bottom: 12),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 1,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: const Color(0xff37434d),
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: const Color(0xff37434d),
                            strokeWidth: 1,
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
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: bottomTitleWidgets,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: leftTitleWidgets,
                            reservedSize: 42,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
                      minX: 0,
                      maxX: 11,
                      minY: 0,
                      maxY: 6,
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 3),
                            FlSpot(2.6, 2),
                            FlSpot(4.9, 5),
                            FlSpot(6.8, 3.1),
                            FlSpot(8, 4),
                            FlSpot(9.5, 3),
                            FlSpot(11, 4),
                          ],
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          barWidth: 5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: false,
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 1),
                            FlSpot(2.6, 0),
                            FlSpot(4.9, 2),
                            FlSpot(6.8, 5.1),
                            FlSpot(8, 2),
                            FlSpot(9.5, 4),
                            FlSpot(11, 2),
                          ],
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: gradientColors2,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          barWidth: 5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: false,
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: gradientColors2.map((color) => color.withOpacity(0.3)).toList(),
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
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleAvatar(radius: 10, backgroundColor: Colors.blue),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Pressure')),
                  VerticalDivider(width: 30),
                  CircleAvatar(radius: 10, backgroundColor: Colors.orange),
                  Padding(padding: EdgeInsets.all(8.0), child: Text('Usage')),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.save), label: const Text('Save as Excell')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('MAR', style: style);
        break;
      case 5:
        text = const Text('JUN', style: style);
        break;
      case 8:
        text = const Text('SEP', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K';
        break;
      case 3:
        text = '30k';
        break;
      case 5:
        text = '50k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
