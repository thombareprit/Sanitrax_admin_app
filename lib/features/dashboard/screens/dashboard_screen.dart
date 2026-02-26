import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sanitrix_admin_app/core/services/data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String selectedArea = "rajapeth";
  String? selectedToiletId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Qualitative cleaning logic for the judges
  String getCleanlinessLabel(double score) {
    if (score < 0.4) return "Poor";
    if (score < 0.7) return "Average";
    return "Excellent";
  }

  @override
  Widget build(BuildContext context) {
    final data = MockDataService.getAreaAnalytics(selectedArea);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LEFT PANEL: Data & Infographics
                        _buildDataSidePanel(data),
                        const SizedBox(width: 12),

                        // CENTER: OpenStreetMap Scatter Map
                        Expanded(child: _buildScatterMap()),
                        const SizedBox(width: 12),

                        // RIGHT: Urgent Alerts
                        _buildAlertPanel(data['alerts'] ?? []),
                      ],
                    ),
                  ),
                ),
                _bottomStatus(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TOP NAVIGATION & FILTERS
  // ==========================================
  Widget _buildTopBar() {
    return Container(
      height: 65,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            labelColor: const Color(0xFF1B263B),
            indicatorColor: const Color(0xFF1B263B),
            onTap: (_) => setState(() {}),
            tabs: const [
              Tab(text: "WARD SUMMARY"),
              Tab(text: "TOILET DETAILS"),
            ],
          ),
          const Spacer(),
          _dropLabel(
            "WARD:",
          ), // Grouped by Area but labeled Ward for local context
          const SizedBox(width: 8),
          _simpleDrop(
            selectedArea,
            MockDataService.getLocations(),
            (v) => setState(() {
              selectedArea = v!;
              selectedToiletId = null;
            }),
          ),
          const SizedBox(width: 25),
          _dropLabel("TOILET ID:"),
          const SizedBox(width: 8),
          _simpleDrop(
            selectedToiletId,
            MockDataService.getToiletsInArea(
              selectedArea,
            ).map((e) => e['id'].toString()).toList(),
            (v) => setState(() {
              selectedToiletId = v;
              _tabController.animateTo(1);
            }),
            hint: "Select ID",
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LEFT PANEL: ANALYTICS & HARDWARE
  // ==========================================
  Widget _buildDataSidePanel(Map<String, dynamic> d) {
    if (_tabController.index == 1 && selectedToiletId != null)
      return _buildSingleToiletInfo();

    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("WARD HARDWARE TOTALS"),
          const SizedBox(height: 12),
          _hardwareSummary(d),
          const SizedBox(height: 25),
          _gauge(
            "Average Water Storage",
            d['avgWater'] ?? 0.0,
            Colors.blue,
            "${((d['avgWater'] ?? 0) * 100).toInt()}%",
          ),
          const SizedBox(height: 20),
          _gauge(
            "Cleaning Index",
            d['avgClean'] ?? 0.0,
            Colors.teal,
            "${getCleanlinessLabel(d['avgClean'] ?? 0.0)} (${((d['avgClean'] ?? 0) * 10).toInt()}/10)",
          ),
          const SizedBox(height: 25),
          _sectionTitle("TOILET CATEGORIES"),
          const SizedBox(height: 10),
          _pieWithLegend(d['types']),
          const Spacer(),
          _sectionTitle("USAGE TREND (24H)"),
          const SizedBox(height: 10),
          Expanded(child: _buildLineTrend()),
        ],
      ),
    );
  }

  // ==========================================
  // CENTER PANEL: SCATTER MAP (OSM)
  // ==========================================
  Widget _buildScatterMap() {
    final toilets = MockDataService.getToiletsInArea(selectedArea);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black12),
      ),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(20.918655, 77.757865), // Amravati Center
          initialZoom: 14.5,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.sanitrix.admin',
          ),
          CircleLayer(
            circles: toilets.map((t) {
              final usage = t['usageCountToday'] as int;
              // Usage Intensity Color Logic
              final dotColor = usage > 25
                  ? Colors.redAccent.withValues(alpha: 0.8)
                  : const Color(0xFF415A77).withValues(alpha: 0.7);

              return CircleMarker(
                point: LatLng(t['lat'] as double, t['lng'] as double),
                radius: 6.0 + (usage / 10), // Dot grows with usage
                useRadiusInMeter: false,
                color: dotColor,
                borderColor: Colors.white,
                borderStrokeWidth: 2,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TOILET DETAIL VIEW
  // ==========================================
  Widget _buildSingleToiletInfo() {
    final t = MockDataService.getToiletDetails(selectedToiletId!)!;
    double waterPercent = (t['waterLevel'] as num).toDouble() / 100;
    double cleanScore = (t['cleanlinessScore'] as num).toDouble() / 10;

    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TOILET: ${t['id']}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Color(0xFF1B263B),
            ),
          ),
          Text(
            t['location'].toString().toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(height: 30),
          _detailRow(
            "Live Status",
            t['operationalStatus'],
            isBold: true,
            color: t['operationalStatus'] == "Open" ? Colors.green : Colors.red,
          ),
          _detailRow("Footfall Today", t['usageCountToday'].toString()),
          const SizedBox(height: 20),
          _sectionTitle("HARDWARE INVENTORY"),
          const SizedBox(height: 10),
          _infraGrid(t),
          const SizedBox(height: 30),
          _gauge(
            "Water Level",
            waterPercent,
            Colors.blue,
            "${(waterPercent * 100).toInt()}% (${t['waterLevel']}L / ${t['waterTankCapacity']}L)",
          ),
          const SizedBox(height: 20),
          _gauge(
            "Cleanliness",
            cleanScore,
            Colors.teal,
            "${getCleanlinessLabel(cleanScore)} (${t['cleanlinessScore']}/10)",
          ),
          const Spacer(),
          Text(
            "Last Cleaned: ${t['lastCleanedAt']}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // REUSABLE UI COMPONENTS
  // ==========================================

  Widget _hardwareSummary(Map d) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _minStat("M-Seats", d['seatsM']),
        _minStat("F-Seats", d['seatsF']),
        _minStat("Urinals", d['urinals']),
        _minStat("Basins", d['basins']),
      ],
    ),
  );

  Widget _infraGrid(Map t) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      _chip(Icons.man, "Male", t['seatsMale']),
      _chip(Icons.woman, "Female", t['seatsFemale']),
      _chip(Icons.waves, "Urinals", t['urinals']),
      _chip(Icons.water_drop, "Basins", t['washBasins']),
    ],
  );

  Widget _chip(IconData i, String l, dynamic v) => Container(
    width: 70,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Column(
      children: [
        Icon(i, size: 14, color: Colors.blueGrey),
        Text(
          v.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(l, style: const TextStyle(fontSize: 8, color: Colors.grey)),
      ],
    ),
  );

  Widget _minStat(String l, dynamic v) => Column(
    children: [
      Text(
        v.toString(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      Text(l, style: const TextStyle(fontSize: 8, color: Colors.grey)),
    ],
  );

  Widget _gauge(String title, double val, Color c, String statusText) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: c,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      LinearProgressIndicator(
        value: val,
        color: c,
        backgroundColor: c.withOpacity(0.1),
        minHeight: 10,
      ),
    ],
  );

  Widget _pieWithLegend(Map<String, int>? data) {
    if (data == null) return const SizedBox();
    final colors = [
      const Color(0xFF1B263B),
      const Color(0xFF415A77),
      const Color(0xFF778DA9),
    ];
    return Row(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: PieChart(
            PieChartData(
              sections: data.entries
                  .map(
                    (e) => PieChartSectionData(
                      value: e.value.toDouble(),
                      color: colors[data.keys.toList().indexOf(e.key) % 3],
                      radius: 15,
                      showTitle: false,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries
                .map(
                  (e) => Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        color: colors[data.keys.toList().indexOf(e.key) % 3],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${e.key} (${e.value})",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLineTrend() => LineChart(
    LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: [
            const FlSpot(0, 2),
            const FlSpot(4, 4),
            const FlSpot(8, 3),
            const FlSpot(12, 7),
            const FlSpot(16, 5),
            const FlSpot(20, 6),
          ],
          isCurved: true,
          color: const Color(0xFF415A77),
          barWidth: 4,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF415A77).withOpacity(0.2),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildAlertPanel(List alerts) => Container(
    width: 280,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("URGENT ISSUES"),
        const SizedBox(height: 15),
        Expanded(
          child: ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (ctx, i) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                border: Border(
                  left: BorderSide(color: Colors.redAccent, width: 3),
                ),
              ),
              child: Text(
                "Toilet ${alerts[i]['id']}: System Alert",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.blueGrey,
      fontSize: 10,
      letterSpacing: 1.2,
    ),
  );
  Widget _buildSidebar() => Container(
    width: 60,
    color: const Color(0xFF0D1B2A),
    child: const Column(
      children: [
        SizedBox(height: 40),
        Icon(Icons.analytics_rounded, color: Colors.white70),
      ],
    ),
  );
  Widget _simpleDrop(
    String? v,
    List<String> i,
    Function(String?) o, {
    String? hint,
  }) => DropdownButton<String>(
    value: v,
    hint: Text(hint ?? ""),
    underline: const SizedBox(),
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFF1B263B),
      fontSize: 13,
    ),
    items: i
        .map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())))
        .toList(),
    onChanged: o,
  );
  Widget _dropLabel(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 9,
      color: Colors.grey,
      fontWeight: FontWeight.w900,
    ),
  );
  Widget _detailRow(String l, String v, {bool isBold = false, Color? color}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l,
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
            Text(
              v,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
                color: color ?? const Color(0xFF1B263B),
              ),
            ),
          ],
        ),
      );
  Widget _bottomStatus() => Container(
    height: 35,
    color: const Color(0xFF0D1B2A),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: const Row(
      children: [
        Icon(Icons.circle, color: Colors.green, size: 7),
        SizedBox(width: 8),
        Text(
          "COMMAND CENTER ACTIVE | SENSORS: ONLINE",
          style: TextStyle(
            color: Colors.white60,
            fontSize: 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    ),
  );
}
