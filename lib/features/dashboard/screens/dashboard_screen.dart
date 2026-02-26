import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sanitrix_admin_app/core/services/data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String selectedArea = "rajapeth"; 
  String? selectedToiletId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Qualitative labeling logic
  String getCleanlinessLabel(double score) {
    if (score < 0.4) return "Poor";
    if (score < 0.8) return "Average";
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
                        _buildDataSidePanel(data),
                        const SizedBox(width: 12),
                        Expanded(child: _buildMapPlaceholder()),
                        const SizedBox(width: 12),
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
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            labelColor: const Color(0xFF1B263B),
            indicatorColor: const Color(0xFF1B263B),
            onTap: (_) => setState(() {}),
            tabs: const [Tab(text: "WARD SUMMARY"), Tab(text: "TOILET DETAILS")],
          ),
          const Spacer(),
          _dropText("WARD:"),
          _simpleDrop(selectedArea, MockDataService.getLocations(), (v) => setState(() { selectedArea = v!; selectedToiletId = null; })),
          const SizedBox(width: 25),
          _dropText("TOILET ID:"),
          _simpleDrop(selectedToiletId, MockDataService.getToiletsInArea(selectedArea).map((e) => e['id'].toString()).toList(), (v) => setState(() { selectedToiletId = v; _tabController.animateTo(1); }), hint: "Select ID"),
        ],
      ),
    );
  }

  Widget _buildDataSidePanel(Map<String, dynamic> d) {
    if (_tabController.index == 1 && selectedToiletId != null) return _buildSingleToiletInfo();

    return Container(
      width: 350,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("WARD OVERVIEW", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 10, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Row(
            children: [
              _kpiBox("Toilets", d['total'].toString(), const Color(0xFF415A77)),
              const SizedBox(width: 8),
              _kpiBox("Faulty", d['closed'].toString(), Colors.redAccent),
            ],
          ),
          const SizedBox(height: 20),
          _hardwareSummary(d),
          const SizedBox(height: 25),
          _bigGauge("Average Water Storage", d['avgWater'] ?? 0.0, Colors.blue, "${((d['avgWater'] ?? 0) * 100).toInt()}%"),
          const SizedBox(height: 20),
          _bigGauge("Cleaning Index", d['avgClean'] ?? 0.0, Colors.teal, "${getCleanlinessLabel(d['avgClean'] ?? 0.0)} (${((d['avgClean'] ?? 0) * 10).toInt()}/10)"),
          const SizedBox(height: 25),
          const Text("Toilet Categories", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 10),
          _simplePie(d['types']),
          const Spacer(),
          const Text("FOOTFALL TREND (LAST 24h)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.blueGrey)),
          const SizedBox(height: 10),
          Expanded(child: _buildTrendChart()),
        ],
      ),
    );
  }

  Widget _buildSingleToiletInfo() {
    final t = MockDataService.getToiletDetails(selectedToiletId!)!;
    double waterPercent = (t['waterLevel'] as num).toDouble() / 100;
    double cleanScore = (t['cleanlinessScore'] as num).toDouble() / 10;
    
    return Container(
      width: 350,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("TOILET: ${t['id']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF1B263B))),
          Text(t['location'].toString().toUpperCase(), style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
          const Divider(height: 30),
          _detailRow("Live Status", t['operationalStatus'], isBold: true, color: t['operationalStatus'] == "Open" ? Colors.green : Colors.red),
          _detailRow("Footfall Today", t['usageCountToday'].toString()),
          const SizedBox(height: 15),
          const Text("INFRASTRUCTURE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          _infraGrid(t),
          const SizedBox(height: 25),
          _bigGauge(
            "Water Supply", 
            waterPercent, 
            Colors.blue, 
            "${(waterPercent * 100).toInt()}% (${t['waterLevel']}L / ${t['waterTankCapacity']}L)"
          ),
          const SizedBox(height: 20),
          _bigGauge(
            "Cleanliness", 
            cleanScore, 
            Colors.teal, 
            "${getCleanlinessLabel(cleanScore)} (${t['cleanlinessScore']}/10)"
          ),
          const Spacer(),
          Text("Last Cleaned: ${t['lastCleanedAt']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey)),
        ],
      ),
    );
  }

  // --- REUSABLE COMPONENTS ---

  Widget _hardwareSummary(Map d) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(4)),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      _miniStat("M-Seats", d['seatsM'].toString()),
      _miniStat("F-Seats", d['seatsF'].toString()),
      _miniStat("Urinals", d['urinals'].toString()),
      _miniStat("Basins", d['basins'].toString()),
    ]),
  );

  Widget _infraGrid(Map t) => Wrap(
    spacing: 8, runSpacing: 8,
    children: [
      _infraChip(Icons.man, "Male", t['seatsMale'].toString()),
      _infraChip(Icons.woman, "Female", t['seatsFemale'].toString()),
      _infraChip(Icons.waves, "Urinals", t['urinals'].toString()),
      _infraChip(Icons.water_drop, "Basins", t['washBasins'].toString()),
    ],
  );

  Widget _infraChip(IconData icon, String label, String val) => Container(
    width: 70, padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(4)),
    child: Column(children: [
      Icon(icon, size: 14, color: Colors.blueGrey),
      Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
    ]),
  );

  Widget _miniStat(String label, String val) => Column(children: [
    Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
  ]);

  Widget _bigGauge(String title, double val, Color c, String statusText) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        Text(statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: c)),
      ]),
      const SizedBox(height: 8),
      LinearProgressIndicator(value: val, color: c, backgroundColor: c.withValues(alpha: .1), minHeight: 10),
    ],
  );

  Widget _simplePie(Map<String, int>? data) {
    if (data == null) return const SizedBox();
    final colors = [const Color(0xFF1B263B), const Color(0xFF415A77), const Color(0xFF778DA9)];
    return Row(
      children: [
        SizedBox(width: 80, height: 80, child: PieChart(PieChartData(sections: data.entries.map((e) => PieChartSectionData(value: e.value.toDouble(), color: colors[data.keys.toList().indexOf(e.key) % 3], radius: 15, showTitle: false)).toList()))),
        const SizedBox(width: 15),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.entries.map((e) => Row(children: [
            Container(width: 8, height: 8, color: colors[data.keys.toList().indexOf(e.key) % 3]),
            const SizedBox(width: 6),
            Text("${e.key} (${e.value})", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ])).toList(),
        ))
      ],
    );
  }

  Widget _buildTrendChart() => LineChart(LineChartData(
    gridData: FlGridData(show: false), 
    titlesData: FlTitlesData(show: false), 
    borderData: FlBorderData(show: false), 
    lineBarsData: [LineChartBarData(
      spots: [const FlSpot(0, 2), const FlSpot(4, 4), const FlSpot(8, 3), const FlSpot(12, 7), const FlSpot(16, 5), const FlSpot(20, 6)], 
      isCurved: true, 
      color: const Color(0xFF415A77), 
      barWidth: 4, 
      dotData: FlDotData(show: false), 
      belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [const Color(0xFF415A77).withValues(alpha:0.2), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter))
    )]));

  Widget _kpiBox(String label, String val, Color c) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: c.withValues(alpha: 0.05), border: Border.all(color: c.withValues(alpha: 0.1))), child: Column(children: [Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: c)), Text(label.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.blueGrey))])));
  Widget _buildAlertPanel(List alerts) => Container(width: 280, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)), padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("CRITICAL MONITOR", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.redAccent, fontSize: 11, letterSpacing: 1.2)), const SizedBox(height: 15), Expanded(child: ListView.builder(itemCount: alerts.length, itemBuilder: (ctx, i) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.05), border: Border(left: BorderSide(color: Colors.redAccent, width: 3))), child: Text("Toilet ${alerts[i]['id']}: System Alert", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)))))]));
  Widget _buildSidebar() => Container(width: 60, color: const Color(0xFF0D1B2A), child: const Column(children: [SizedBox(height: 40), Icon(Icons.analytics_rounded, color: Colors.white70)]));
  Widget _buildMapPlaceholder() => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black12)), child: const Center(child: Text("LIVE DATA MAP VIEW", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 2))));
  Widget _simpleDrop(String? val, List<String> items, Function(String?) onChg, {String? hint}) => DropdownButton<String>(value: val, hint: Text(hint ?? "", style: const TextStyle(fontSize: 12)), underline: const SizedBox(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B263B), fontSize: 13), items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(), onChanged: onChg);
  Widget _dropText(String t) => Text(t, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w900));
  Widget _detailRow(String l, String v, {bool isBold = false, Color? color}) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)), Text(v, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, color: color ?? const Color(0xFF1B263B)))]));
  Widget _bottomStatus() => Container(height: 35, color: const Color(0xFF0D1B2A), padding: const EdgeInsets.symmetric(horizontal: 20), child: const Row(children: [Icon(Icons.circle, color: Colors.green, size: 7), SizedBox(width: 8), Text("COMMAND CENTER ACTIVE | SENSORS: ONLINE", style: TextStyle(color: Colors.white60, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1))]));
}

