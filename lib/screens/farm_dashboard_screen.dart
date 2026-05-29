import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'farm_list_screen.dart';
import 'farm_input_screen.dart';
import 'farm_finance_screen.dart';
import 'farm_schedule_screen.dart';
import 'farm_report_screen.dart';
import '../services/dashboard_service.dart';

class FarmDashboardScreen extends StatefulWidget {
  final Farm farm;
  const FarmDashboardScreen({super.key, required this.farm});

  @override
  State<FarmDashboardScreen> createState() => _FarmDashboardScreenState();
}

class _FarmDashboardScreenState extends State<FarmDashboardScreen> {
  int _selectedIndex = 0;

  // ── API state ──────────────────────────────────────────────────────────────
  bool _loading = true;
  DashboardDailyData? _daily;
  DashboardResume? _resume;
  DashboardExpensesData? _expensesData;

  // chart computed
  List<FlSpot> _chartSpots = [];
  List<String> _chartLabels = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final farmId = widget.farm.id;
    final results = await Future.wait([
      DashboardService.instance.fetchDailyData(farmId),
      DashboardService.instance.fetchProductivity(farmId, days: 7),
      DashboardService.instance.fetchResume(farmId),
      DashboardService.instance.fetchExpenses(farmId),
    ]);

    final daily = results[0] as DashboardDailyData?;
    final productivity = results[1] as List<ProductivityPoint>;
    final resume = results[2] as DashboardResume?;
    final expensesData = results[3] as DashboardExpensesData?;

    // Build chart spots from productivity data
    final spots = <FlSpot>[];
    final labels = <String>[];
    for (var i = 0; i < productivity.length; i++) {
      spots.add(FlSpot(i.toDouble(), productivity[i].eggCount.toDouble()));
      final parts = productivity[i].date.split('-');
      labels.add(
        parts.length >= 3 ? '${parts[1]}-${parts[2]}' : productivity[i].date,
      );
    }

    setState(() {
      _daily = daily;
      _resume = resume;
      _expensesData = expensesData;
      _chartSpots = spots;
      _chartLabels = labels;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final months = [
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
        '${days[now.weekday - 1]}, ${now.day} ${months[now.month]} ${now.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: _buildHeader(dateStr),
      ),
      bottomNavigationBar: _buildBottomNav(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // 0 – Dashboard
          _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
                )
              : RefreshIndicator(
                  color: const Color(0xFFFF6B00),
                  onRefresh: _loadAll,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAlertBanner(),
                        const SizedBox(height: 14),
                        _buildStatsGrid(),
                        const SizedBox(height: 16),
                        _buildChartCard(),
                        const SizedBox(height: 16),
                        _buildBepCard(),
                        const SizedBox(height: 16),
                        _buildScheduleCard(),
                        const SizedBox(height: 16),
                        _buildInputCard(),
                      ],
                    ),
                  ),
                ),
          // 1 – Input
          FarmInputScreen(
            farm: widget.farm,
            selectedNavIndex: 1,
            onNavTap: (_) {},
            embedded: true,
          ),
          // 2 – Keuangan
          FarmFinanceScreen(
            farm: widget.farm,
            selectedNavIndex: 2,
            onNavTap: (_) {},
            embedded: true,
          ),
          // 3 – Jadwal
          FarmScheduleScreen(
            farm: widget.farm,
            selectedNavIndex: 3,
            onNavTap: (_) {},
            embedded: true,
          ),
          // 4 – Laporan
          FarmReportScreen(
            farm: widget.farm,
            selectedNavIndex: 4,
            onNavTap: (_) {},
            embedded: true,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String dateStr) {
    return AppBar(
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
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
    );
  }

  // ─── Alert Banner ───────────────────────────────────────────────────────────
  Widget _buildAlertBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(12),
      ),
      // child: Row(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     const Icon(
      //       Icons.warning_amber_rounded,
      //       color: Color(0xFF1E88E5),
      //       size: 18,
      //     ),
      //     const SizedBox(width: 8),
      //     const Expanded(
      //       child: Text(
      //         '3 jadwal perlu diselesaikan: Vaksin ND, Vitamin B Kompleks, Pembersihan Kandang',
      //         style: TextStyle(
      //           fontSize: 13,
      //           color: Color(0xFF1E88E5),
      //           fontWeight: FontWeight.w500,
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  // ─── Stats Grid ─────────────────────────────────────────────────────────────
  Widget _buildStatsGrid() {
    final d = _daily;
    final r = _resume;

    String fmtRp(double v) {
      final abs = v.abs();
      final s = abs >= 1000000
          ? 'Rp ${(abs / 1000000).toStringAsFixed(1)} jt'
          : 'Rp ${abs.toStringAsFixed(0)}';
      return v < 0 ? '-$s' : s;
    }

    final stats = [
      _StatItem(
        Icons.egg_outlined,
        const Color(0xFFFF6B00),
        'Telur Hari Ini',
        d != null ? '${d.eggCount}' : '-',
        d != null ? '${d.eggWeightKg.toStringAsFixed(1)} kg' : '-',
        null,
      ),
      _StatItem(
        Icons.track_changes_outlined,
        const Color(0xFF1E88E5),
        'Hen-day',
        d != null ? '${d.henDayPercent.toStringAsFixed(1)}%' : '-',
        d != null ? 'Target ${d.henDayTarget.toStringAsFixed(1)}%' : '-',
        null,
      ),
      _StatItem(
        Icons.flutter_dash,
        const Color(0xFF43A047),
        'Ayam Hidup',
        d != null ? '${d.chickenAlive}' : '-',
        d != null ? 'dari ${d.chickenCount} ekor' : '-',
        null,
      ),
      _StatItem(
        Icons.trending_down_rounded,
        const Color(0xFFE53935),
        'Kematian',
        d != null ? '${d.chickenDeath}' : '-',
        d != null && d.chickenCount > 0
            ? '${(d.chickenDeath / d.chickenCount * 100).toStringAsFixed(1)}%'
            : '-',
        null,
      ),
      _StatItem(
        Icons.account_balance_wallet_outlined,
        const Color(0xFF8E24AA),
        'Pendapatan',
        d != null ? fmtRp(d.income) : '-',
        d != null ? fmtRp(d.netIncome) : '-',
        d != null && d.netIncome < 0 ? const Color(0xFFE53935) : null,
      ),
      _StatItem(
        Icons.calendar_today_outlined,
        const Color(0xFF00897B),
        'Data Hari',
        r != null
            ? '${r.totalIncome > 0 ? r.totalIncome.toInt() : d?.totalEntry ?? 0}'
            : (d != null ? '${d.totalEntry}' : '-'),
        'total entry',
        null,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, i) => _buildStatCard(stats[i]),
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          Row(
            children: [
              Icon(item.icon, size: 14, color: item.iconColor),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.sub,
            style: TextStyle(
              fontSize: 11,
              color: item.subColor ?? const Color(0xFF888888),
              fontWeight: item.subColor != null
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Chart ──────────────────────────────────────────────────────────────────
  Widget _buildChartCard() {
    final maxY = _chartSpots.isEmpty
        ? 100.0
        : (_chartSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2)
              .clamp(10.0, double.infinity);
    final interval = (maxY / 4).ceilToDouble().clamp(1.0, double.infinity);
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart, color: Color(0xFFFF6B00), size: 18),
              SizedBox(width: 8),
              Text(
                'Produktivitas 7 Hari',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: interval,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= _chartLabels.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _chartLabels[idx],
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _chartSpots,
                    isCurved: true,
                    color: const Color(0xFFFF6B00),
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (s, x, bar, i) => FlDotCirclePainter(
                        radius: 3.5,
                        color: const Color(0xFFFF6B00),
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFFF6B00).withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── BEP ────────────────────────────────────────────────────────────────────
  Widget _buildBepCard() {
    final r = _resume;
    final progress = r != null
        ? (r.bepProgressPercent / 100).clamp(0.0, 1.0)
        : 0.0;

    String fmtRp(double v) {
      final abs = v.abs();
      final s = abs >= 1000000
          ? 'Rp ${(abs / 1000000).toStringAsFixed(2)} jt'
          : 'Rp ${abs.toStringAsFixed(0)}';
      return v < 0 ? '-$s' : s;
    }

    final capital = r?.capital ?? 0;
    final totalIncome = r?.totalIncome ?? 0;
    final bepRemaining = r?.bepRemaining ?? 0;
    final bepDays = r?.bepEstimatedDays ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          const Row(
            children: [
              Icon(
                Icons.access_time_filled,
                color: Color(0xFFFF6B00),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Kembali Modal (BEP)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress: ${fmtRp(totalIncome)}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFF6B00),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Target modal: ${fmtRp(capital)}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
              children: [
                const TextSpan(text: 'Sisa: '),
                TextSpan(
                  text: fmtRp(bepRemaining),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (bepDays > 0) ...[
                  const TextSpan(text: ' · Est. '),
                  TextSpan(
                    text: '$bepDays hari lagi',
                    style: const TextStyle(
                      color: Color(0xFFFF6B00),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ] else if (bepDays == 0 && r != null) ...[
                  const TextSpan(text: ' · '),
                  const TextSpan(
                    text: 'BEP tercapai 🎉',
                    style: TextStyle(
                      color: Color(0xFF43A047),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Schedule ───────────────────────────────────────────────────────────────
  Widget _buildScheduleCard() {
    final schedules = _expensesData?.allSchedules ?? [];

    // warna per tipe
    Color typeColor(String type) {
      final t = type.toLowerCase();
      if (t.contains('vaksin') || t.contains('vaccine')) return Colors.blue;
      if (t.contains('vitamin') || t.contains('obat')) return Colors.green;
      if (t.contains('bersih') || t.contains('clean')) return Colors.brown;
      if (t.contains('pakan') || t.contains('pakan')) return Colors.orange;
      return const Color(0xFF9E9E9E);
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month, color: Color(0xFFFF6B00), size: 18),
              SizedBox(width: 8),
              Text(
                'Jadwal Mendekati',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (schedules.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Tidak ada jadwal mendekati',
                  style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                ),
              ),
            )
          else
            ...List.generate(schedules.length, (i) {
              final s = schedules[i];
              return Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.circle, color: typeColor(s.type), size: 10),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name.isNotEmpty ? s.name : s.type,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              '${s.date} · ${s.type}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: s.isOverdue
                              ? const Color(0xFFFFF0F0)
                              : const Color(0xFFFFF8F0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s.isOverdue ? 'Terlambat' : 'Segera',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: s.isOverdue
                                ? const Color(0xFFE53935)
                                : const Color(0xFFFF6B00),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (i < schedules.length - 1)
                    const Divider(height: 20, color: Color(0xFFF0F0F0)),
                ],
              );
            }),
        ],
      ),
    );
  }

  // ─── Input Card ─────────────────────────────────────────────────────────────
  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          const Row(
            children: [
              Icon(Icons.star_outline, color: Color(0xFFFF6B00), size: 18),
              SizedBox(width: 8),
              Text(
                'Input Hari Ini',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FarmInputScreen(
                      farm: widget.farm,
                      selectedNavIndex: 1,
                      onNavTap: (idx) {
                        Navigator.pop(context);
                        if (idx != 1) setState(() => _selectedIndex = idx);
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tambah Data Harian',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Nav ─────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      _NavItem(Icons.grid_view_rounded, 'Dashboard'),
      _NavItem(Icons.edit_outlined, 'Input'),
      _NavItem(Icons.attach_money, 'Keuangan'),
      _NavItem(Icons.calendar_today_outlined, 'Jadwal'),
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
        children: List.generate(items.length, (i) {
          final selected = i == _selectedIndex;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = i);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  items[i].icon,
                  size: 24,
                  color: selected
                      ? const Color(0xFFFF6B00)
                      : const Color(0xFFAAAAAA),
                ),
                const SizedBox(height: 4),
                Text(
                  items[i].label,
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

// ─── Data Models ──────────────────────────────────────────────────────────────

class _StatItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String sub;
  final Color? subColor;
  const _StatItem(
    this.icon,
    this.iconColor,
    this.label,
    this.value,
    this.sub,
    this.subColor,
  );
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
