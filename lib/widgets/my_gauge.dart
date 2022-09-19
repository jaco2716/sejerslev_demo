import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gauges/gauges.dart';

class DetailGaugeDial extends StatelessWidget {
  final double value;
  final bool isPressure;
  final String title;
  final String messureUnit;
  final double start, start1, start2, start3, end;
  const DetailGaugeDial({
    Key? key,
    required this.value,
    required this.isPressure,
    required this.title,
    required this.messureUnit,
    this.start = 0,
    this.start1 = 0,
    this.start2 = 40,
    this.start3 = 60,
    this.end = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color1, color2, color3;
    double minAngle = -140;
    double maxAngle = 140;
    if (isPressure) {
      color1 = Colors.white;
      color2 = Colors.green;
      color3 = Colors.blue;
    } else {
      color1 = Colors.green;
      color2 = Colors.orange;
      color3 = Colors.red;
    }
    return Padding(
      padding: const EdgeInsets.all(4),
      // color: Colors.red,
      // height: 165,
      // width: 155,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              GaugeAnootation(
                // valueRange: end - start1,
                valueStart: start1,
                valueEnd: end,
                interval: (end - start1) / 10,
              ),
              SizedBox(
                height: 125,
                width: 125,
                child: TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    tween: Tween<double>(begin: 0.0, end: value),
                    builder: (context, double tweenValue, child) {
                      return RadialGauge(
                        axes: [
                          RadialGaugeAxis(
                            minValue: start1,
                            maxValue: end,
                            minAngle: minAngle,
                            maxAngle: maxAngle,
                            radius: 0.9,
                            width: 0.17,
                            color: Colors.transparent,
                            pointers: [
                              RadialNeedlePointer(
                                  value: tweenValue,
                                  thicknessStart: 16,
                                  thicknessEnd: 0,
                                  length: 0.85,
                                  knobRadiusAbsolute: 8,
                                  color: Colors.white,
                                  knobColor: Colors.white)
                            ],
                            ticks: [
                              RadialTicks(
                                  interval: (end - start1) / 10,
                                  alignment: RadialTickAxisAlignment.inside,
                                  color: Colors.white,
                                  length: 0.22,
                                  children: [
                                    RadialTicks(
                                      // interval: 50,
                                      ticksInBetween: 5,
                                      length: 0.2,
                                      color: Colors.grey,
                                    ),
                                  ]),
                            ],
                            segments: [
                              RadialGaugeSegment(
                                minValue: start1,
                                maxValue: start2,
                                minAngle: minAngle + 30,
                                maxAngle: -50,
                                color: color1,
                              ),
                              RadialGaugeSegment(
                                minValue: start2,
                                maxValue: start3,
                                minAngle: -50,
                                maxAngle: 50,
                                color: color2,
                              ),
                              RadialGaugeSegment(
                                minValue: start3,
                                maxValue: end,
                                minAngle: 50,
                                maxAngle: maxAngle,
                                color: color3,
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      messureUnit,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    SizedBox(
                        width: 60,
                        height: 22,
                        child: FittedBox(
                          child: Text(
                            value.toStringAsFixed(2),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // child: Text('820.88', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                        )),
                    // Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );

    // return SfRadialGauge(
    //   axes: <RadialAxis>[
    //     RadialAxis(
    //       minimum: 0,
    //       maximum: 100,
    //       // showLabels: false,
    //       ranges: <GaugeRange>[
    //         GaugeRange(startValue: start1, endValue: start2, color: color1),
    //         GaugeRange(startValue: start2, endValue: start3, color: color2),
    //         GaugeRange(startValue: start3, endValue: end, color: color3)
    //       ],
    //       pointers: <GaugePointer>[
    //         NeedlePointer(
    //           // knobStyle: const KnobStyle(knobRadius: 0.1, borderWidth: 20),
    //           // tailStyle: const TailStyle(width: 2, length: 0.2),
    //           // needleLength: 0.9,
    //           // needleStartWidth: 2,
    //           // needleEndWidth: 3,
    //           animationDuration: 1000,
    //           animationType: AnimationType.ease,
    //           enableAnimation: true,
    //           value: value,
    //         )
    //       ],
    //       annotations: <GaugeAnnotation>[
    //         GaugeAnnotation(
    //           widget: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               Text('${value.round()}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
    //               Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
    //             ],
    //           ),
    //           angle: 90,
    //           positionFactor: 0.6,
    //         )
    //       ],
    //     )
    //   ],
    // );
  }
}

class GaugeAnootation extends StatelessWidget {
  // final double valueRange;
  final double valueStart;
  final double valueEnd;
  final double interval;
  const GaugeAnootation({
    Key? key,
    // required this.valueRange,
    this.interval = 10,
    required this.valueStart,
    required this.valueEnd,
  }) : super(key: key);

  final double radius = 45.0;

  List<Widget> list() {
    List<int> data = [];
    double currentAngle = 2.3;
    double angleDiff = 0.483;
    for (var i = valueStart; i < valueEnd + 1; i += interval) {
      data.add(i.toInt());
    }
    return data.map((int value) {
      final x = cos(currentAngle) * radius;
      final y = sin(currentAngle) * radius;
      currentAngle += angleDiff;
      return _radialListItem(x, y, value);
    }).toList();
  }

  Widget _radialListItem(double x, double y, int value) {
    return Center(
      child: Transform(
          transform: Matrix4.translationValues(x, y, 0.0),
          child: Text(
            '$value',
            style: const TextStyle(fontSize: 8, color: Colors.grey),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: list(),
    );
  }
}
