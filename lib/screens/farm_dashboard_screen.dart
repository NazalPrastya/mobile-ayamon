import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'farm_list_screen.dart';
import 'farm_input_screen.dart';
import 'farm_finance_screen.dart';
import 'farm_schedule_screen.dart';

class FarmDashboardScreen extends StatefulWidget {
  final Farm farm;
  const FarmDashboardScreen({super.key, required this.farm});

  @override
  State<FarmDashboardScreen> createState() => _FarmDashboardScreenState();
}

class _FarmDashboardScreenState extends State<FarmDashboardScreen> {
  int _selectedIndex = 0;

  // Dummy chart data – produktivitas 7 hari
  final List<FlSpot> _chartSpots = const [
    FlSpot(0, 780),
    FlSpot(1, 795),
    FlSpot(2, 788),
    FlSpot(3, 800),
    FlSpot(4, 792),
    FlSpot(5, 785),
    FlSpot(6, 769),
  ];

  final List<String> _chartLabels = [
    '05-02',
    '05-03',
    '05-04',
    '05-05',
    '05-06',
    '05-07',
    '05-08',
  ];

  final List<_Schedule> _schedules = const [
    _Schedule('Vaksin ND', '2026-05-08', 'Vaksin', Colors.blue, true),
    _Schedule(
      'Vitamin B Kompleks',
      '2026-05-08',
      'Vitamin',
      Colors.green,
      true,
    ),
    _Schedule(
      'Pembersihan Kandang',
      '2026-05-11',
      'Pembersihan',
      Colors.brown,
      true,
    ),
    _Schedule('Vaksin Gumboro', '2026-05-22', 'Vaksin', Colors.blue, false),
  ];

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
      body: SingleChildScrollView(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFF1E88E5),
            size: 18,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '3 jadwal perlu diselesaikan: Vaksin ND, Vitamin B Kompleks, Pembersihan Kandang',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF1E88E5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats Grid ─────────────────────────────────────────────────────────────
  Widget _buildStatsGrid() {
    final stats = [
      _StatItem('🥚', 'Telur Hari Ini', '769', '47.7 kg', null),
      _StatItem('📊', 'Hen-day (7hr)', '79.5%', 'Target 80%', null),
      _StatItem('🐔', 'Ayam Hidup', '1.000', 'dari 1.000 ekor', null),
      _StatItem('💀', 'Kematian', '0', '0.0%', null),
      _StatItem(
        '💰',
        'Pendapatan',
        'Rp 8.620.000',
        'Rp -4.217.200',
        const Color(0xFFE53935),
      ),
      _StatItem('📅', 'Data Hari', '7', 'total entry', null),
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
              Text(item.emoji, style: const TextStyle(fontSize: 14)),
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
                maxY: 900,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 200,
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 200,
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
    const double progress = 0.137;
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
              const Text(
                'Progress: Rp 8.620.000',
                style: TextStyle(fontSize: 13, color: Color(0xFF555555)),
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
          const Text(
            'Target modal: Rp 62.837.200',
            style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 4),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
              children: [
                TextSpan(text: 'Sisa: '),
                TextSpan(
                  text: 'Rp 54.217.200',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: ' · Est. '),
                TextSpan(
                  text: '50 hari lagi',
                  style: TextStyle(
                    color: Color(0xFFFF6B00),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Schedule ───────────────────────────────────────────────────────────────
  Widget _buildScheduleCard() {
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
          ...List.generate(_schedules.length, (i) {
            final s = _schedules[i];
            return Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.circle, color: s.color, size: 10),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
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
                        color: s.isUrgent
                            ? const Color(0xFFFFF0F0)
                            : const Color(0xFFFFF8F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s.isUrgent ? 'Segera' : 'Soon',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: s.isUrgent
                              ? const Color(0xFFE53935)
                              : const Color(0xFFFF6B00),
                        ),
                      ),
                    ),
                  ],
                ),
                if (i < _schedules.length - 1)
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
              if (i == 1) {
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
              } else if (i == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FarmFinanceScreen(
                      farm: widget.farm,
                      selectedNavIndex: 2,
                      onNavTap: (idx) {
                        Navigator.pop(context);
                        if (idx != 2) setState(() => _selectedIndex = idx);
                      },
                    ),
                  ),
                );
              } else if (i == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FarmScheduleScreen(
                      farm: widget.farm,
                      selectedNavIndex: 3,
                      onNavTap: (idx) {
                        Navigator.pop(context);
                        if (idx != 3) setState(() => _selectedIndex = idx);
                      },
                    ),
                  ),
                );
              } else {
                setState(() => _selectedIndex = i);
              }
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
  final String emoji;
  final String label;
  final String value;
  final String sub;
  final Color? subColor;
  const _StatItem(this.emoji, this.label, this.value, this.sub, this.subColor);
}

class _Schedule {
  final String name;
  final String date;
  final String type;
  final Color color;
  final bool isUrgent;
  const _Schedule(this.name, this.date, this.type, this.color, this.isUrgent);
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
