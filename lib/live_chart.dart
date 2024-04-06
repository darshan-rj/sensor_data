import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class LiveChart extends StatefulWidget {
  const LiveChart({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LiveChartState createState() => _LiveChartState();
}

class _LiveChartState extends State<LiveChart> {
  bool isLoading = true;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var url = "https://wellness-c445b-default-rtdb.firebaseio.com/.json";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          isLoading = false;
        });
      } else {
        // ignore: avoid_print
        print("HTTP Error: ${response.statusCode}");
      }
    } catch (error) {
      // ignore: avoid_print
      print("Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Charts"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Body Temperature', ),
                      _buildGraph("Body Temperature", data?['BodyTemperature']),
                      const SizedBox(height: 32),

                      const Text('Heart Rate', ),
                      _buildGraph("Heart Rate", data?['HeartRate']),
                      const SizedBox(height: 32),

                      const Text('SpO2 Sensor', ),
                      _buildGraph("SpO2", data?['SpO2']),
                      const SizedBox(height: 32),

                      const Text('Gas Sensor', ),
                      _buildGraph("Gas Sensor", data?['Gas']?['Level']),
                      const SizedBox(height: 32),

                      const Text('Room Humidity'),
                      _buildGraph("Room Humidity", data?['Room']?['Humidity']),
                      const SizedBox(height: 32),

                      const Text('Flame Sensor'),
                      _buildGraph("Flame Sensor", data?['Flame']),
                      const SizedBox(height: 32),

                      const Text('Room Temperature'),
                      _buildGraph(
                          "Room Temperature", data?['Room']?['Temperature']),
                      const SizedBox(height: 32),
                      
                      const Text('Vibration Sensor'),
                      _buildGraph(
                          "Vibration Sensor", data?['Vibration']?['Detection']),
                      const SizedBox(height: 32),

                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildGraph(String title, Map<String, dynamic>? data) {
    List<FlSpot> spots = [];
    int index = 0;
    data?.forEach((key, value) {
      if (index < 45) {
        spots.add(FlSpot(index.toDouble(), value.toDouble()));
        index++;
      }
    });

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 400,
      child: Card(
        child: AspectRatio(
          aspectRatio: 1.5,
          child: Center(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: const FlTitlesData(show: true),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX: spots.length.toDouble() - 1,
                minY: 0,
                maxY: _calculateMaxY(data), // Adjust the maxY value
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _calculateMaxY(Map<String, dynamic>? data) {
    double maxY = 0;
    data?.forEach((key, value) {
      if (value.toDouble() > maxY) {
        maxY = value.toDouble();
      }
    });
    return maxY + 10; // Add some padding to maxY
  }
}

void main() {
  runApp(const MaterialApp(
    home: LiveChart(),
  ));
}
