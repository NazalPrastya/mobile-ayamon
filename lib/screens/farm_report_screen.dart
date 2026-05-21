import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/daily_production_model.dart';
import '../services/daily_production_service.dart';
import 'farm_list_screen.dart';

// ─── Monthly aggregation ──────────────────────────────────────────────────────

class _MonthData {
  final String label; // e.g. "2026-05"
  int totalEgg = 0;
  double totalWeight = 0;
  int totalDeath = 0;
  int days = 0;
  double totalFeed = 0;

  _MonthData(this.label);
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class FarmReportScreen extends StatefulWidget {
  final Farm farm;
  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;
  final bool embedded;

  const FarmReportScreen({
    super.key,
    required this.farm,
    required this.selectedNavIndex,
    required this.onNavTap,
    this.embedded = false,
  });

  @override
  State<FarmReportScreen> createState() => _FarmReportScreenState();
}

class _FarmReportScreenState extends State<FarmReportScreen> {
  bool _loading = true;
  String? _error;
  List<DailyProductionModel> _all = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _all = [];
    });

    int page = 1;
    int lastPage = 1;
    final buffer = <DailyProductionModel>[];

    do {
      final result = await DailyProductionService.instance.getList(
        widget.farm.id,
        page: page,
      );
      final list = result.$1;
      final lp = result.$2;
      final err = result.$3;

      if (err != null) {
        setState(() {
          _error = err;
          _loading = false;
        });
        return;
      }
      buffer.addAll(list ?? []);
      lastPage = lp ?? 1;
      page++;
    } while (page <= lastPage);

    setState(() {
      _all = buffer;
      _loading = false;
    });
  }

  // ─── Aggregations ─────────────────────────────────────────────────────────────

  int get _totalEgg => _all.fold(0, (s, e) => s + e.eggCount);
  double get _totalWeight => _all.fold(0.0, (s, e) => s + e.eggWeight);
  int get _totalDeath => _all.fold(0, (s, e) => s + e.chickenDeath);
  int get _days => _all.length;
  double get _avgEggPerDay => _days == 0 ? 0 : _totalEgg / _days;
  double get _totalFeed => _all.fold(0.0, (s, e) => s + e.feedSold);

  List<_MonthData> get _byMonth {
    final map = <String, _MonthData>{};
    for (final e in _all) {
      try {
        final d = DateTime.parse(e.date);
        final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
        map.putIfAbsent(key, () => _MonthData(key));
        map[key]!.totalEgg += e.eggCount;
        map[key]!.totalWeight += e.eggWeight;
        map[key]!.totalDeath += e.chickenDeath;
        map[key]!.days += 1;
        map[key]!.totalFeed += e.feedSold;
      } catch (_) {}
    }
    final sorted = map.values.toList()
      ..sort((a, b) => a.label.compareTo(b.label));
    return sorted;
  }

  // hen-day: no chickenCount in Farm — display N/A or show raw avg
  // We'll just show (egg/day) as a proxy percentage (egg per day / 1000 * 100)
  // Actually show raw avg eggs per day on the second chart instead.

  // ─── Formatter ────────────────────────────────────────────────────────────────

  String _fmt(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final dateStr =
        '${dayNames[now.weekday - 1]}, ${now.day} ${monthNames[now.month]} ${now.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: widget.embedded ? null : _buildAppBar(dateStr),
      bottomNavigationBar: widget.embedded ? null : _buildBottomNav(),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
            )
          : _error != null
          ? _buildError()
          : RefreshIndicator(
              color: const Color(0xFFFF6B00),
              onRefresh: _load,
              child: _buildBody(),
            ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 52, color: Color(0xFFFF6B00)),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final monthly = _byMonth;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        const Text(
          'Laporan',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Analisis performa keseluruhan',
          style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
        ),
        const SizedBox(height: 20),
        _buildSummaryGrid(),
        const SizedBox(height: 16),
        if (monthly.isNotEmpty) ...[
          _buildBarChart(monthly),
          const SizedBox(height: 16),
          _buildAvgEggChart(monthly),
          const SizedBox(height: 16),
          _buildDeathChart(monthly),
        ] else
          _emptyCard(),
      ],
    );
  }

  // ─── Summary Grid ─────────────────────────────────────────────────────────────

  Widget _buildSummaryGrid() {
    final items = [
      _Stat(
        label: 'Total Telur',
        value: _fmt(_totalEgg.toDouble()),
        sub: '${_totalWeight.toStringAsFixed(1)} kg',
        color: const Color(0xFF1A1A1A),
      ),
      _Stat(
        label: 'Rata-rata/hari',
        value: _fmt(_avgEggPerDay),
        sub: 'butir',
        color: const Color(0xFF1A1A1A),
      ),
      _Stat(
        label: 'Total Pakan',
        value: _totalFeed.toStringAsFixed(1),
        sub: 'kg',
        color: const Color(0xFF1A1A1A),
      ),
      _Stat(
        label: 'Total Berat Telur',
        value: _totalWeight.toStringAsFixed(1),
        sub: 'kg',
        color: const Color(0xFF1A1A1A),
      ),
      _Stat(
        label: 'Kematian',
        value: _totalDeath.toString(),
        sub: _days > 0
            ? '${(_totalDeath / (_days.toDouble() + 1) * 100).toStringAsFixed(2)}%'
            : '0.0%',
        color: _totalDeath > 0
            ? const Color(0xFFE53935)
            : const Color(0xFF1A1A1A),
      ),
      _Stat(
        label: 'Hari Tercatat',
        value: _days.toString(),
        color: const Color(0xFF1A1A1A),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: items.map((s) => _statCard(s)).toList(),
    );
  }

  Widget _statCard(_Stat s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            s.label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            s.value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: s.color,
            ),
          ),
          if (s.sub != null) ...[
            const SizedBox(height: 2),
            Text(
              s.sub!,
              style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Bar Chart: Produksi Bulanan ─────────────────────────────────────────────

  Widget _buildBarChart(List<_MonthData> monthly) {
    final maxY =
        (monthly
                    .map((m) => m.totalEgg.toDouble())
                    .reduce((a, b) => a > b ? a : b) *
                1.25)
            .ceilToDouble();

    return _chartCard(
      icon: Icons.bar_chart,
      title: 'Produksi Bulanan',
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            minY: 0,
            barGroups: monthly.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.totalEgg.toDouble(),
                    color: const Color(0xFFFF6B00),
                    width: monthly.length == 1 ? 40 : 24,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48,
                  getTitlesWidget: (v, _) => Text(
                    _fmt(v),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF888888),
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final idx = v.toInt();
                    if (idx < 0 || idx >= monthly.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        monthly[idx].label,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF888888),
                        ),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: Color(0xFFF0F0F0), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) =>
                    const Color(0xFF1A1A1A).withOpacity(0.85),
                getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                  '${monthly[group.x].label}\n${_fmt(rod.toY)} butir',
                  const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Line Chart: Rata-rata Produksi Harian ────────────────────────────────────

  Widget _buildAvgEggChart(List<_MonthData> monthly) {
    final spots = monthly.asMap().entries.map((e) {
      final avg = e.value.days == 0 ? 0.0 : e.value.totalEgg / e.value.days;
      return FlSpot(e.key.toDouble(), avg);
    }).toList();

    final maxY = spots.isEmpty
        ? 100.0
        : (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.3)
              .ceilToDouble()
              .clamp(1.0, double.infinity);

    return _chartCard(
      icon: Icons.show_chart,
      title: 'Rata-rata Produksi Harian',
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: const Color(0xFFFF6B00),
                barWidth: 2.5,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFFFF6B00),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFFFF6B00).withOpacity(0.08),
                ),
              ),
            ],
            titlesData: _lineTitles(monthly.map((m) => m.label).toList()),
            gridData: _lineGrid(),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) =>
                    const Color(0xFF1A1A1A).withOpacity(0.85),
                getTooltipItems: (touched) => touched.map((s) {
                  return LineTooltipItem(
                    '${monthly[s.x.toInt()].label}\n${s.y.toStringAsFixed(1)} butir/hari',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Line Chart: Kematian Bulanan ─────────────────────────────────────────────

  Widget _buildDeathChart(List<_MonthData> monthly) {
    final maxDeathRaw = monthly
        .map((m) => m.totalDeath.toDouble())
        .reduce((a, b) => a > b ? a : b);
    final maxY = (maxDeathRaw * 1.3).ceilToDouble().clamp(1.0, double.infinity);

    final spots = monthly
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.totalDeath.toDouble()))
        .toList();

    return _chartCard(
      icon: Icons.pets_outlined,
      title: 'Kematian Bulanan',
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: const Color(0xFFE53935),
                barWidth: 2.5,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFFE53935),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFFE53935).withOpacity(0.08),
                ),
              ),
            ],
            titlesData: _lineTitles(monthly.map((m) => m.label).toList()),
            gridData: _lineGrid(),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) =>
                    const Color(0xFF1A1A1A).withOpacity(0.85),
                getTooltipItems: (touched) => touched.map((s) {
                  return LineTooltipItem(
                    '${monthly[s.x.toInt()].label}\n${s.y.toInt()} ekor',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Chart helpers ────────────────────────────────────────────────────────────

  FlTitlesData _lineTitles(List<String> labels) => FlTitlesData(
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        getTitlesWidget: (v, _) => Text(
          v.toStringAsFixed(0),
          style: const TextStyle(fontSize: 10, color: Color(0xFF888888)),
        ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (v, _) {
          final idx = v.toInt();
          if (idx < 0 || idx >= labels.length) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              labels[idx],
              style: const TextStyle(fontSize: 10, color: Color(0xFF888888)),
            ),
          );
        },
      ),
    ),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );

  FlGridData _lineGrid() => FlGridData(
    show: true,
    drawVerticalLine: false,
    getDrawingHorizontalLine: (_) =>
        const FlLine(color: Color(0xFFF0F0F0), strokeWidth: 1),
  );

  Widget _chartCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFF6B00), size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Belum ada data produksi',
          style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
        ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(String dateStr) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(62),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/logo-single.png',
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Ayamon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                dateStr,
                style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Nav ───────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    const navItems = [
      _NavItem(Icons.grid_view_rounded, 'Dashboard'),
      _NavItem(Icons.edit_outlined, 'Input'),
      _NavItem(Icons.attach_money, 'Keuangan'),
      _NavItem(Icons.show_chart, 'Jadwal'),
      _NavItem(Icons.bar_chart_outlined, 'Laporan'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (i) {
          final selected = i == widget.selectedNavIndex;
          return GestureDetector(
            onTap: () => widget.onNavTap(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  navItems[i].icon,
                  size: 24,
                  color: selected
                      ? const Color(0xFFFF6B00)
                      : const Color(0xFFAAAAAA),
                ),
                const SizedBox(height: 4),
                Text(
                  navItems[i].label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? const Color(0xFFFF6B00)
                        : const Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Data models ──────────────────────────────────────────────────────────────

class _Stat {
  final String label;
  final String value;
  final String? sub;
  final Color color;
  const _Stat({
    required this.label,
    required this.value,
    this.sub,
    required this.color,
  });
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
