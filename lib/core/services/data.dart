// import 'dart:convert';
// import 'package:flutter/services.dart';

// class MockDataService {
//   static List<dynamic> _allToilets = [];

//   static Future<void> init() async {
//     final String response = await rootBundle.loadString('assets/MockData.json');
//     _allToilets = json.decode(response);
//   }

//   static List<String> getLocations() {
//     return _allToilets.map((e) => e['area'].toString()).toSet().toList()..sort();
//   }

//   static List<dynamic> getToiletsInArea(String area) {
//     if (area == "All Areas") return _allToilets;
//     return _allToilets.where((t) => t['area'] == area).toList();
//   }

//   static List<dynamic> getToiletsForMap(String area) {
//     if (area == "All Areas" || area == "All") return _allToilets;
//     return _allToilets.where((t) => t['area'] == area).toList();
//   }

//   static Map<String, dynamic> getAreaAnalytics(String area) {
//     final filtered = getToiletsInArea(area);
//     if (filtered.isEmpty) return {};

//     int total = filtered.length;
//     Map<String, int> typeCounts = {};
//     int m = 0, f = 0, u = 0, b = 0;

//     for (var t in filtered) {
//       var types = t['toiletType'];
//       if (types is List) {
//         for (var type in types) {
//           typeCounts[type.toString()] = (typeCounts[type.toString()] ?? 0) + 1;
//         }
//       } else {
//         typeCounts[types.toString()] = (typeCounts[types.toString()] ?? 0) + 1;
//       }
//       m += (t['seatsMale'] as int? ?? 0);
//       f += (t['seatsFemale'] as int? ?? 0);
//       u += (t['urinals'] as int? ?? 0);
//       b += (t['washBasins'] as int? ?? 0);
//     }

//     double avgWater = filtered.map((e) => (e['waterLevel'] as num).toDouble()).reduce((a, b) => a + b) / total;
//     double avgClean = filtered.map((e) => (e['cleanlinessScore'] as num).toDouble()).reduce((a, b) => a + b) / total;

//     return {
//       'total': total,
//       'closed': filtered.where((t) => t['operationalStatus'] == 'Closed').length,
//       'avgWater': avgWater / 100,
//       'avgClean': avgClean / 10,
//       'types': typeCounts,
//       'seatsM': m, 'seatsF': f, 'urinals': u, 'basins': b,
//       'alerts': filtered.where((t) => t['currentPriority'] == 'high').toList(),
//     };
//   }

//   static Map<String, dynamic>? getToiletDetails(String id) {
//     try {
//       return _allToilets.firstWhere((t) => t['id'].toString() == id);
//     } catch (e) { return null; }
//   }
// }

import 'dart:convert';
import 'package:flutter/services.dart';

class MockDataService {
  static List<dynamic> _allToilets = [];

  static Future<void> init() async {
    final String response = await rootBundle.loadString('assets/MockData.json');
    _allToilets = json.decode(response);
  }

  static List<String> getLocations() {
    return _allToilets.map((e) => e['area'].toString()).toSet().toList()..sort();
  }

  static List<dynamic> getToiletsInArea(String area) {
    if (area == "All Areas" || area == "All") return _allToilets;
    return _allToilets.where((t) => t['area'] == area).toList();
  }

  static Map<String, dynamic> getAreaAnalytics(String area) {
    final filtered = getToiletsInArea(area);
    if (filtered.isEmpty) return {};

    int total = filtered.length;
    Map<String, int> typeCounts = {};
    int m = 0, f = 0, u = 0, b = 0;

    for (var t in filtered) {
      var types = t['toiletType'];
      if (types is List) {
        for (var type in types) {
          typeCounts[type.toString()] = (typeCounts[type.toString()] ?? 0) + 1;
        }
      } else {
        typeCounts[types.toString()] = (typeCounts[types.toString()] ?? 0) + 1;
      }
      m += (t['seatsMale'] as int? ?? 0);
      f += (t['seatsFemale'] as int? ?? 0);
      u += (t['urinals'] as int? ?? 0);
      b += (t['washBasins'] as int? ?? 0);
    }

    double avgWater = filtered.map((e) => (e['waterLevel'] as num).toDouble()).reduce((a, b) => a + b) / total;
    double avgClean = filtered.map((e) => (e['cleanlinessScore'] as num).toDouble()).reduce((a, b) => a + b) / total;

    return {
      'total': total,
      'closed': filtered.where((t) => t['operationalStatus'] == 'Closed').length,
      'avgWater': avgWater / 100,
      'avgClean': avgClean / 10,
      'types': typeCounts,
      'seatsM': m, 'seatsF': f, 'urinals': u, 'basins': b,
      'alerts': filtered.where((t) => t['currentPriority'] == 'high').toList(),
    };
  }

  static Map<String, dynamic>? getToiletDetails(String id) {
    try {
      return _allToilets.firstWhere((t) => t['id'].toString() == id);
    } catch (e) { return null; }
  }
}