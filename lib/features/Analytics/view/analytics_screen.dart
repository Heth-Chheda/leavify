import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // App Colors
  final Color primaryColor = const Color(0xFF7BA5B8);
  final Color secondaryColor = const Color(0xFFFFCDD2);
  final Color tertiaryColor = const Color(0xFFB4E7C1);
  final Color darkColor = const Color(0xFF2C3E50);

  // Animation Trigger Flag
  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();
    // Trigger animation after the widget is mounted
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _startAnimation = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    "Total Leaves",
                    "1,240",
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    "Avg. Attendance",
                    "94%",
                    Icons.people_outline,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. Line Chart
            _buildSectionTitle("Leave Trends (Yearly)"),
            const SizedBox(height: 12),
            _buildChartContainer(height: 300, child: _buildLineChart()),
            const SizedBox(height: 24),

            // 3. Bar Chart
            _buildSectionTitle("Department Wise Usage"),
            const SizedBox(height: 12),
            _buildChartContainer(height: 300, child: _buildBarChart()),
            const SizedBox(height: 24),

            // 4. Pie & Radar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Leave Types"),
                      const SizedBox(height: 12),
                      _buildChartContainer(
                        height: 250,
                        child: _buildPieChart(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Team Health"),
                      const SizedBox(height: 12),
                      _buildChartContainer(
                        height: 250,
                        child: _buildRadarChart(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // COMPONENTS
  // ---------------------------------------------------------------------------

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: darkColor,
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildChartContainer({required Widget child, required double height}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ---------------------------------------------------------------------------
  // CHARTS (WITH ANIMATION LOGIC)
  // ---------------------------------------------------------------------------

  // 1. LINE CHART
  Widget _buildLineChart() {
    return LineChart(
      duration: const Duration(milliseconds: 800), // Animation Duration
      curve: Curves.easeInOutCubic, // Animation Curve
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: Color(0xff68737d),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                String text;
                switch (value.toInt()) {
                  case 1:
                    text = 'JAN';
                    break;
                  case 3:
                    text = 'MAR';
                    break;
                  case 5:
                    text = 'MAY';
                    break;
                  case 7:
                    text = 'JUL';
                    break;
                  case 9:
                    text = 'SEP';
                    break;
                  case 11:
                    text = 'NOV';
                    break;
                  default:
                    return Container();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(text, style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Color(0xff67727d),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            // ANIMATION LOGIC: If not started, map all Y values to 0
            spots: _startAnimation
                ? const [
                    FlSpot(0, 3),
                    FlSpot(2.6, 2),
                    FlSpot(4.9, 5),
                    FlSpot(6.8, 2.5),
                    FlSpot(8, 4),
                    FlSpot(9.5, 3),
                    FlSpot(11, 4),
                  ]
                : const [
                    FlSpot(0, 0),
                    FlSpot(2.6, 0),
                    FlSpot(4.9, 0),
                    FlSpot(6.8, 0),
                    FlSpot(8, 0),
                    FlSpot(9.5, 0),
                    FlSpot(11, 0),
                  ],
            isCurved: true,
            color: primaryColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: primaryColor.withOpacity(0.2),
            ),
          ),
          LineChartBarData(
            // ANIMATION LOGIC: If not started, map all Y values to 0
            spots: _startAnimation
                ? const [
                    FlSpot(0, 1),
                    FlSpot(2.6, 1.5),
                    FlSpot(4.9, 1),
                    FlSpot(6.8, 1.5),
                    FlSpot(8, 1),
                    FlSpot(9.5, 2.5),
                    FlSpot(11, 1.5),
                  ]
                : const [
                    FlSpot(0, 0),
                    FlSpot(2.6, 0),
                    FlSpot(4.9, 0),
                    FlSpot(6.8, 0),
                    FlSpot(8, 0),
                    FlSpot(9.5, 0),
                    FlSpot(11, 0),
                  ],
            isCurved: true,
            color: secondaryColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  // 2. BAR CHART
  Widget _buildBarChart() {
    return BarChart(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutQuad,
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Color(0xff7589a2),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                Widget text;
                switch (value.toInt()) {
                  case 0:
                    text = const Text('Tech', style: style);
                    break;
                  case 1:
                    text = const Text('HR', style: style);
                    break;
                  case 2:
                    text = const Text('Sales', style: style);
                    break;
                  case 3:
                    text = const Text('Mkt', style: style);
                    break;
                  case 4:
                    text = const Text('Ops', style: style);
                    break;
                  default:
                    text = const Text('', style: style);
                    break;
                }
                return SideTitleWidget(meta: meta, space: 16, child: text);
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          _makeGroupData(0, 15, 6),
          _makeGroupData(1, 10, 8),
          _makeGroupData(2, 8, 12),
          _makeGroupData(3, 12, 5),
          _makeGroupData(4, 14, 9),
        ],
        gridData: const FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          // ANIMATION LOGIC: Check flag, otherwise return 0
          toY: _startAnimation ? y1 : 0,
          color: primaryColor,
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
        BarChartRodData(
          // ANIMATION LOGIC: Check flag, otherwise return 0
          toY: _startAnimation ? y2 : 0,
          color: secondaryColor,
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  // 3. PIE CHART
  Widget _buildPieChart() {
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          duration: const Duration(milliseconds: 800),
          curve: Curves.decelerate,
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 35,
            sections: [
              PieChartSectionData(
                color: primaryColor,
                value: 40,
                // ANIMATION LOGIC: Animate radius for "Pop" effect
                radius: _startAnimation ? 40 : 0,
                title: '40%',
                titleStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(_startAnimation ? 1 : 0),
                ),
              ),
              PieChartSectionData(
                color: secondaryColor,
                value: 30,
                radius: _startAnimation ? 40 : 0,
                title: '30%',
                titleStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(_startAnimation ? 1 : 0),
                ),
              ),
              PieChartSectionData(
                color: tertiaryColor,
                value: 15,
                radius: _startAnimation ? 40 : 0,
                title: '15%',
                titleStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(_startAnimation ? 1 : 0),
                ),
              ),
              PieChartSectionData(
                color: const Color(0xFFF3E5F5),
                value: 15,
                radius: _startAnimation ? 40 : 0,
                title: '15%',
                titleStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54.withOpacity(_startAnimation ? 1 : 0),
                ),
              ),
            ],
          ),
        ),
        const Text(
          "Type",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // 4. RADAR CHART
  Widget _buildRadarChart() {
    return RadarChart(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      RadarChartData(
        dataSets: [
          RadarDataSet(
            fillColor: primaryColor.withOpacity(0.4),
            borderColor: primaryColor,
            entryRadius: 2,
            dataEntries: [
              // ANIMATION LOGIC: Multiply values by 0 if not started
              RadarEntry(value: _startAnimation ? 3 : 0),
              RadarEntry(value: _startAnimation ? 2 : 0),
              RadarEntry(value: _startAnimation ? 3 : 0),
              RadarEntry(value: _startAnimation ? 2.5 : 0),
              RadarEntry(value: _startAnimation ? 3 : 0),
            ],
          ),
          RadarDataSet(
            fillColor: secondaryColor.withOpacity(0.4),
            borderColor: secondaryColor,
            entryRadius: 2,
            dataEntries: [
              RadarEntry(value: _startAnimation ? 2 : 0),
              RadarEntry(value: _startAnimation ? 3 : 0),
              RadarEntry(value: _startAnimation ? 1.5 : 0),
              RadarEntry(value: _startAnimation ? 2 : 0),
              RadarEntry(value: _startAnimation ? 2 : 0),
            ],
          ),
        ],
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        radarBorderData: const BorderSide(color: Colors.transparent),
        titlePositionPercentageOffset: 0.2,
        titleTextStyle: const TextStyle(color: Colors.grey, fontSize: 10),
        getTitle: (index, angle) {
          switch (index) {
            case 0:
              return const RadarChartTitle(text: 'Att.');
            case 1:
              return const RadarChartTitle(text: 'Perf.');
            case 2:
              return const RadarChartTitle(text: 'Comp.');
            case 3:
              return const RadarChartTitle(text: 'Qual.');
            case 4:
              return const RadarChartTitle(text: 'Speed');
            default:
              return const RadarChartTitle(text: '');
          }
        },
        tickCount: 1,
        ticksTextStyle: const TextStyle(color: Colors.transparent),
        gridBorderData: BorderSide(
          color: Colors.grey.withOpacity(0.1),
          width: 2,
        ),
      ),
    );
  }
}
