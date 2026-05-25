import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import '../config/api_config.dart';
import 'farm_list_screen.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class _ReportSummary {
  final int totalEggs;
  final double totalEggWeight;
  final double totalIncome;
  final double totalCost;
  final double netProfit;
  final int totalDeath;
  final double deathRate;
  final int daysLogged;

  const _ReportSummary({
    required this.totalEggs,
    required this.totalEggWeight,
    required this.totalIncome,
    required this.totalCost,
    required this.netProfit,
    required this.totalDeath,
    required this.deathRate,
    required this.daysLogged,
  });
}

class _MonthlyPoint {
  final String month;
  final double value;
  const _MonthlyPoint(this.month, this.value);
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
  _ReportSummary? _summary;
  List<_MonthlyPoint> _monthlyProduction = [];
  List<_MonthlyPoint> _monthlyHenDay = [];
  List<_MonthlyPoint> _monthlyDeath = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final token = await AuthService.instance.getToken();
    if (token == null) {
      setState(() {
        _error = 'Token tidak ditemukan, silakan login ulang.';
        _loading = false;
      });
      return;
    }
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.dashboardReportUrl(widget.farm.id)),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] as Map<String, dynamic>;
        final s = data['summary'] as Map<String, dynamic>;
        final charts = data['charts'] as Map<String, dynamic>;

        setState(() {
          _summary = _ReportSummary(
            totalEggs: (s['total_eggs'] as num?)?.toInt() ?? 0,
            totalEggWeight: (s['total_egg_weight'] as num?)?.toDouble() ?? 0,
            totalIncome: (s['total_income'] as num?)?.toDouble() ?? 0,
            totalCost: (s['total_cost'] as num?)?.toDouble() ?? 0,
            netProfit: (s['net_profit'] as num?)?.toDouble() ?? 0,
            totalDeath: (s['total_death'] as num?)?.toInt() ?? 0,
            deathRate: (s['death_rate'] as num?)?.toDouble() ?? 0,
            daysLogged: (s['days_logged'] as num?)?.toInt() ?? 0,
          );
          _monthlyProduction =
              (charts['monthly_production'] as List<dynamic>? ?? [])
                  .map(
                    (e) => _MonthlyPoint(
                      e['month']?.toString() ?? '',
                      (e['egg_count'] as num?)?.toDouble() ?? 0,
                    ),
                  )
                  .toList();
          _monthlyHenDay = (charts['monthly_hen_day'] as List<dynamic>? ?? [])
              .map(
                (e) => _MonthlyPoint(
                  e['month']?.toString() ?? '',
                  (e['hen_day'] as num?)?.toDouble() ?? 0,
                ),
              )
              .toList();
          _monthlyDeath = (charts['monthly_death'] as List<dynamic>? ?? [])
              .map(
                (e) => _MonthlyPoint(
                  e['month']?.toString() ?? '',
                  (e['chicken_death'] as num?)?.toDouble() ?? 0,
                ),
              )
              .toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Gagal memuat laporan (${response.statusCode})';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

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

  String _fmtRp(double v) {
    final s = v.abs().toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${v < 0 ? '-' : ''}Rp ${buf.toString()}';
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
    final s = _summary!;
    final avgPerDay = s.daysLogged > 0 ? s.totalEggs / s.daysLogged : 0.0;
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
        _buildSummaryGrid(s, avgPerDay),
        const SizedBox(height: 16),
        if (_monthlyProduction.isNotEmpty) ...[
          _buildBarChart(_monthlyProduction),
          const SizedBox(height: 16),
          _buildHenDayChart(_monthlyHenDay),
          const SizedBox(height: 16),
          _buildDeathChart(_monthlyDeath),
        ] else
          _emptyCard(),
      ],
    );
  }

  // ─── Summary Grid ─────────────────────────────────────────────────────────────

  Widget _buildSummaryGrid(_ReportSummary s, double avgPerDay) {
    final items = [
      _Stat(
        label: 'Total Telur',
        value: _fmt(s.totalEggs.toDouble()),
        sub: '${s.totalEggWeight.toStringAsFixed(1)} kg',
        color: const Color(0xFF1A1A1A),
      ),
      _Stat(
        label: 'Rata-rata/hari',
        value: _fmt(avgPerDay),
        sub: 'butir',
        color: const Color(0xFF1A1A1A),
      ),
      _Stat(
        label: 'Total Pendapatan',
        value: _fmtRp(s.totalIncome),
        color: const Color(0xFF43A047),
      ),
      _Stat(
        label: 'Net Profit',
        value: _fmtRp(s.netProfit),
        color: s.netProfit >= 0
            ? const Color(0xFF43A047)
            : const Color(0xFFE53935),
      ),
      _Stat(
        label: 'Kematian',
        value: s.totalDeath.toString(),
        sub: '${s.deathRate.toStringAsFixed(1)}%',
        color: s.totalDeath > 0
            ? const Color(0xFFE53935)
            : const Color(0xFF1A1A1A),
      ),
      _Stat(
        label: 'Hari Tercatat',
        value: s.daysLogged.toString(),
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
              fontSize: 18,
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

  Widget _buildBarChart(List<_MonthlyPoint> monthly) {
    final maxY =
        (monthly.map((m) => m.value).reduce((a, b) => a > b ? a : b) * 1.25)
            .ceilToDouble()
            .clamp(1.0, double.infinity);

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
                    toY: e.value.value,
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
                        monthly[idx].month,
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
                  '${monthly[group.x].month}\n${_fmt(rod.toY)} butir',
                  const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Line Chart: Hen-day Bulanan ──────────────────────────────────────────────

  Widget _buildHenDayChart(List<_MonthlyPoint> monthly) {
    final spots = monthly
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    final maxY = spots.isEmpty
        ? 100.0
        : (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.3)
              .ceilToDouble()
              .clamp(1.0, double.infinity);

    return _chartCard(
      icon: Icons.show_chart,
      title: 'Hen-day Bulanan (%)',
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
            titlesData: _lineTitles(monthly.map((m) => m.month).toList()),
            gridData: _lineGrid(),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) =>
                    const Color(0xFF1A1A1A).withOpacity(0.85),
                getTooltipItems: (touched) => touched.map((s) {
                  return LineTooltipItem(
                    '${monthly[s.x.toInt()].month}\n${s.y.toStringAsFixed(1)}%',
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

  Widget _buildDeathChart(List<_MonthlyPoint> monthly) {
    final maxY = monthly.isEmpty
        ? 1.0
        : (monthly.map((m) => m.value).reduce((a, b) => a > b ? a : b) * 1.3)
              .ceilToDouble()
              .clamp(1.0, double.infinity);

    final spots = monthly
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
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
            titlesData: _lineTitles(monthly.map((m) => m.month).toList()),
            gridData: _lineGrid(),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) =>
                    const Color(0xFF1A1A1A).withOpacity(0.85),
                getTooltipItems: (touched) => touched.map((s) {
                  return LineTooltipItem(
                    '${monthly[s.x.toInt()].month}\n${s.y.toInt()} ekor',
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
