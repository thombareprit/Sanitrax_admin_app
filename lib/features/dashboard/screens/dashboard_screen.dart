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

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String selectedArea = "rajapeth"; 
  String? selectedToiletId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  String getCleanLabel(double score) => score < 0.4 ? "Poor" : (score < 0.7 ? "Avg" : "Excellent");

  @override
  Widget build(BuildContext context) {
    final data = MockDataService.getAreaAnalytics(selectedArea);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
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
                        SizedBox(
                          width: 380,
                          child: _tabController.index == 0 
                              ? _buildWardBento(data) 
                              : _buildToiletBento(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _buildMapSection()),
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

  // ==========================================
  // WARD BENTO (FIXED OVERFLOW & NO HEADINGS)
  // ==========================================
  Widget _buildWardBento(Map<String, dynamic> d) {
    return Column(
      children: [
        _bentoBox(
          flex: 3, // Increased flex to fix 11px overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _sectionLabel("WARD INVENTORY"),
              const SizedBox(height: 12),
              _hardwareSummary(d),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _bentoBox(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel("TYPE DISTRIBUTION"),
              Expanded(child: _pieWithLegend(d['types'])),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _bentoBox(
          flex: 3,
          child: Center( // Center only the charts, no heading
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _circularMetric("Hygiene", d['avgClean'] ?? 0.0, Colors.teal),
                _circularMetric("Water", d['avgWater'] ?? 0.0, Colors.blue),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _bentoBox(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel("24H USAGE TREND"),
              Expanded(child: _lineChart()),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TOILET BENTO (CONSISTENT STYLE)
  // ==========================================
  Widget _buildToiletBento() {
    if (selectedToiletId == null) return _bentoBox(child: const Center(child: Text("Select a Toilet ID")));
    final t = MockDataService.getToiletDetails(selectedToiletId!)!;

    return Column(
      children: [
        _bentoBox(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("ID: ${t['id']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                  _ratingBadge(t['avgRating'] ?? 0.0),
                ],
              ),
              Text(t['location']?.toString().toUpperCase() ?? "", style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _bentoBox(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel("INTERNAL ASSETS"),
              const SizedBox(height: 15),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.8,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _gridIconBox(Icons.man, "Male", t['seatsMale']),
                    _gridIconBox(Icons.woman, "Female", t['seatsFemale']),
                    _gridIconBox(Icons.waves, "Urinals", t['urinals']),
                    _gridIconBox(Icons.wash, "Basins", t['washBasins']),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _bentoBox(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel("TELEMETRY STATUS"),
              const Spacer(),
              _gauge("Water Tank", (t['waterLevel'] as num? ?? 0)/100, Colors.blue, "${t['waterLevel']}%"),
              const SizedBox(height: 20),
              _gauge("Sanitation", (t['cleanlinessScore'] as num? ?? 0)/10, Colors.teal, "${t['cleanlinessScore']}/10"),
              const Spacer(),
              _statusFooter("Last Cleaned", t['lastCleanedAt']?.toString() ?? "-"),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // BENTO UI ATOMICS
  // ==========================================

  Widget _bentoBox({required Widget child, int flex = 1}) => Expanded(
    flex: flex,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: child,
    ),
  );

  Widget _circularMetric(String label, double value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 85, width: 85,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(value: value, color: color, strokeWidth: 8, backgroundColor: color.withValues(alpha: 0.1)),
              Text("${(value * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
      ],
    );
  }

  Widget _hardwareSummary(Map d) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _iconStat(Icons.man, "M-Seats", d['seatsM']),
      _iconStat(Icons.woman, "F-Seats", d['seatsF']),
      _iconStat(Icons.waves, "Urinals", d['urinals']),
      _iconStat(Icons.wash, "Basins", d['basins']),
    ],
  );

  Widget _iconStat(IconData i, String l, dynamic v) => Column(children: [Icon(i, size: 24, color: const Color(0xFF415A77)), const SizedBox(height: 4), Text(v.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(l, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold))]);

  Widget _gridIconBox(IconData icon, String label, dynamic val) => Container(
    decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 32, color: const Color(0xFF1B263B)),
        const SizedBox(width: 12),
        Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(val.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        ])
      ],
    ),
  );

  // --- STANDARD HELPERS (No changes) ---

  Widget _pieWithLegend(Map<String, int>? data) {
    if (data == null) return const SizedBox();
    final colors = [const Color(0xFF6366F1), const Color(0xFFEC4899), const Color(0xFF10B981)];
    return Column(children: [
        
        Expanded(child: PieChart(PieChartData(centerSpaceRadius: 30, sections: data.entries.map((e) => PieChartSectionData(value: e.value.toDouble(), color: colors[data.keys.toList().indexOf(e.key) % colors.length], radius: 22, showTitle: false)).toList()))),
        const SizedBox(height: 8),
        Wrap(spacing: 12, children: data.entries.map((e) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: colors[data.keys.toList().indexOf(e.key) % colors.length], shape: BoxShape.circle)), const SizedBox(width: 6), Text("${e.key} (${e.value})", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))])).toList()),
      ]);
  }
  Widget _lineChart() => LineChart(LineChartData(gridData: FlGridData(show: false), titlesData: FlTitlesData(show: false), borderData: FlBorderData(show: false), lineBarsData: [LineChartBarData(spots: [const FlSpot(0, 3), const FlSpot(5, 6), const FlSpot(10, 4), const FlSpot(15, 8), const FlSpot(20, 7)], isCurved: true, color: const Color(0xFF6366F1), barWidth: 4, dotData: FlDotData(show: false), belowBarData: BarAreaData(show: true, color: const Color(0xFF6366F1).withValues(alpha: 0.1)))]));
  Widget _sectionLabel(String t) => Text(t, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 11, letterSpacing: 1.2));
  Widget _ratingBadge(double rating) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)), child: Row(children: [const Icon(Icons.star, size: 14, color: Colors.white), const SizedBox(width: 4), Text(rating.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))]));
  Widget _gauge(String t, double v, Color c, String s) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), Text(s, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: c))]), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: v, color: c, backgroundColor: c.withValues(alpha: 0.1), minHeight: 12))]);
  Widget _statusFooter(String l, String v) => Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(fontSize: 11, color: Colors.grey)), Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))]));
  Widget _buildTopBar() => Container(height: 65, color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [TabBar(controller: _tabController, isScrollable: true, labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14), indicatorColor: const Color(0xFF1B263B), tabs: const [Tab(text: "WARD SUMMARY"), Tab(text: "TOILET DETAILS")]), const Spacer(), _topDrop(selectedArea, MockDataService.getLocations(), (v) => setState(() { selectedArea = v!; selectedToiletId = null; })), const SizedBox(width: 25), _topDrop(selectedToiletId, MockDataService.getToiletsInArea(selectedArea).map((e) => e['id'].toString()).toList(), (v) => setState(() { selectedToiletId = v; _tabController.animateTo(1); }), hint: "Select ID")]));
  Widget _topDrop(String? v, List<String> i, Function(String?) o, {String? hint}) => DropdownButton<String>(value: v, hint: Text(hint ?? ""), underline: const SizedBox(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B263B), fontSize: 15), items: i.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(), onChanged: o);
  Widget _buildSidebar() => Container(width: 60, color: const Color(0xFF0D1B2A), child: const Column(children: [SizedBox(height: 40), Icon(Icons.analytics_rounded, color: Colors.white70)]));
  Widget _buildMapSection() => ClipRRect(borderRadius: BorderRadius.circular(16), child: Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black12)), child: FlutterMap(options: MapOptions(initialCenter: LatLng(20.918655, 77.757865), initialZoom: 14.0), children: [TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', subdomains: const ['a', 'b', 'c']), CircleLayer(circles: MockDataService.getToiletsInArea(selectedArea).map((t) => CircleMarker(point: LatLng(t['lat'] as double, t['lng'] as double), radius: 8.0, color: (t['usageCountToday'] ?? 0) > 25 ? Colors.redAccent.withValues(alpha: 0.8) : const Color(0xFF1B263B).withValues(alpha: 0.8), borderColor: Colors.white, borderStrokeWidth: 2)).toList())])));
  Widget _buildAlertPanel(List alerts) => SizedBox(width: 300, child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_sectionLabel("OPERATIONAL ALERTS"), const SizedBox(height: 12), Expanded(child: ListView.builder(itemCount: alerts.length, itemBuilder: (ctx, i) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.05), border: Border(left: BorderSide(color: Colors.redAccent, width: 4))), child: Row(children: [const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.redAccent), const SizedBox(width: 10), Expanded(child: Text("Toilet ${alerts[i]['id']}: System Alert", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)))]))))])));
  Widget _bottomStatus() => Container(height: 35, color: const Color(0xFF0D1B2A), padding: const EdgeInsets.symmetric(horizontal: 20), child: const Row(children: [Icon(Icons.circle, color: Colors.green, size: 7), SizedBox(width: 8), Text("COMMAND CENTER ACTIVE", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))]));
}