import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sejerslev_demo/single_chart_page.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SingleReaderPage extends StatefulWidget {
  final List<double> values;
  final String title;
  const SingleReaderPage({Key? key, required this.values, required this.title}) : super(key: key);

  @override
  State<SingleReaderPage> createState() => _SingleReaderPageState();
}

class _SingleReaderPageState extends State<SingleReaderPage> {
  Timer? _timer;
  bool isOn = true;

  void startTimer() async {
    Random rand = Random();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        setState(() {
          for (var i = 0; i < widget.values.length; i++) {
            if (widget.values[i] < 5) {
              widget.values[i] += rand.nextInt(15) + 10;
            } else if (widget.values[i] > 95) {
              widget.values[i] -= rand.nextInt(15);
            } else if (widget.values[i] < 40) {
              widget.values[i] += rand.nextInt(15) + 5;
            } else {
              widget.values[i] += rand.nextInt(10) - 5;
            }
          }
        });
      },
    );
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SingleChartPage()));
              },
              icon: const Icon(Icons.bar_chart_rounded))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const Text('Status:'),
              Text(
                isOn ? 'Operational' : 'Offline',
                style: TextStyle(color: isOn ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: isOn ? Colors.blue : Colors.black),
                onPressed: () {
                  setState(() {
                    isOn = !isOn;
                    if (isOn) {
                      startTimer();
                    } else {
                      widget.values[0] = 0;
                      widget.values[1] = 0;
                      _timer?.cancel();
                    }
                  });
                },
                // color: isOn ? Colors.blue : Colors.black,
                child: const SizedBox(
                  height: 70,
                  child: Icon(
                    Icons.power_settings_new,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(height: 280, child: DetailGaugeDial(value: widget.values[0], isPressure: true)),
              SizedBox(height: 280, child: DetailGaugeDial(value: widget.values[1], isPressure: false)),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailGaugeDial extends StatelessWidget {
  final double value;
  final bool isPressure;
  const DetailGaugeDial({Key? key, required this.value, required this.isPressure}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color1, color2, color3;
    double start1, start2, start3, end;
    String title;
    if (isPressure) {
      start1 = 0;
      start2 = 40;
      start3 = 60;
      end = 100;
      color1 = Colors.white;
      color2 = Colors.green;
      color3 = Colors.blue;
      title = 'Pressure';
    } else {
      start1 = 0;
      start2 = 25;
      start3 = 75;
      end = 100;
      color1 = Colors.green;
      color2 = Colors.orange;
      color3 = Colors.red;
      title = 'Usage';
    }

    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 100,
          // showLabels: false,
          ranges: <GaugeRange>[
            GaugeRange(startValue: start1, endValue: start2, color: color1),
            GaugeRange(startValue: start2, endValue: start3, color: color2),
            GaugeRange(startValue: start3, endValue: end, color: color3)
          ],
          pointers: <GaugePointer>[
            NeedlePointer(
              // knobStyle: const KnobStyle(knobRadius: 0.1, borderWidth: 20),
              // tailStyle: const TailStyle(width: 2, length: 0.2),
              // needleLength: 0.9,
              // needleStartWidth: 2,
              // needleEndWidth: 3,
              animationDuration: 1000,
              animationType: AnimationType.ease,
              enableAnimation: true,
              value: value,
            )
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${value.round()}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                ],
              ),
              angle: 90,
              positionFactor: 0.6,
            )
          ],
        )
      ],
    );
  }
}
