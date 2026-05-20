import 'package:flutter/material.dart';
import 'farm_list_screen.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class _ScheduleItem {
  final String id;
  String name;
  String type;
  DateTime date;
  String repeat; // Sekali, Mingguan, Bulanan
  String note;
  bool isDone;

  _ScheduleItem({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.repeat,
    required this.note,
  }) : isDone = false;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class FarmScheduleScreen extends StatefulWidget {
  final Farm farm;
  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;

  const FarmScheduleScreen({
    super.key,
    required this.farm,
    required this.selectedNavIndex,
    required this.onNavTap,
  });

  @override
  State<FarmScheduleScreen> createState() => _FarmScheduleScreenState();
}

class _FarmScheduleScreenState extends State<FarmScheduleScreen> {
  final _nameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _selDate = DateTime.now();
  String _selType = 'Vaksin';
  String _selRepeat = 'Sekali';

  final List<String> _types = [
    'Vaksin',
    'Vitamin',
    'Obat',
    'Pembersihan',
    'Lainnya',
  ];
  final List<String> _repeats = ['Sekali', 'Mingguan', 'Bulanan'];

  final List<_ScheduleItem> _schedules = [
    _ScheduleItem(
      id: '1',
      name: 'Vaksin ND',
      type: 'Vaksin',
      date: DateTime(2026, 5, 8),
      repeat: 'Sekali',
      note: '0.5ml/ekor tetes mata',
    ),
    _ScheduleItem(
      id: '2',
      name: 'Vitamin B Kompleks',
      type: 'Vitamin',
      date: DateTime(2026, 5, 8),
      repeat: 'Mingguan',
      note: '1g/L air minum',
    ),
    _ScheduleItem(
      id: '3',
      name: 'Pembersihan Kandang',
      type: 'Pembersihan',
      date: DateTime(2026, 5, 11),
      repeat: 'Mingguan',
      note: '',
    ),
    _ScheduleItem(
      id: '4',
      name: 'Vaksin Gumboro',
      type: 'Vaksin',
      date: DateTime(2026, 5, 22),
      repeat: 'Sekali',
      note: '0.5ml/ekor',
    ),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatDateDisplay(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _timeAgo(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.isNegative) {
      final pos = d.difference(now);
      if (pos.inDays > 0) return '${pos.inDays}hr lagi';
      if (pos.inHours > 0) return '${pos.inHours}jam lagi';
      return 'Hari ini';
    }
    if (diff.inDays > 0) return 'ʊ${diff.inDays}hr';
    if (diff.inHours > 0) return 'ʊ${diff.inHours}hr';
    return 'Baru';
  }

  bool _isUrgent(DateTime d) =>
      DateTime.now().isAfter(d) || d.difference(DateTime.now()).inDays <= 2;

  Color _typeColor(String type) {
    switch (type) {
      case 'Vaksin':
        return const Color(0xFF1E88E5);
      case 'Vitamin':
        return const Color(0xFF43A047);
      case 'Obat':
        return const Color(0xFFE53935);
      case 'Pembersihan':
        return const Color(0xFF8D6E63);
      default:
        return const Color(0xFF8E24AA);
    }
  }

  void _addSchedule() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nama kegiatan wajib diisi'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    setState(() {
      _schedules.add(
        _ScheduleItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameCtrl.text.trim(),
          type: _selType,
          date: _selDate,
          repeat: _selRepeat,
          note: _noteCtrl.text.trim(),
        ),
      );
      _nameCtrl.clear();
      _noteCtrl.clear();
      _selDate = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Jadwal ditambahkan!'),
        backgroundColor: const Color(0xFFFF6B00),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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

    final active = _schedules.where((s) => !s.isDone).toList();
    final done = _schedules.where((s) => s.isDone).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: _buildAppBar(dateStr),
      bottomNavigationBar: _buildBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jadwal',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Vaksin, vitamin & obat-obatan',
              style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 20),

            // ── Form Card ──
            _buildFormCard(),
            const SizedBox(height: 16),

            // ── Active schedules ──
            if (active.isNotEmpty) ...[
              _buildListCard(
                'Jadwal Aktif',
                Icons.calendar_today_outlined,
                active,
              ),
              const SizedBox(height: 16),
            ],

            // ── Done schedules ──
            if (done.isNotEmpty)
              _buildListCard('Selesai', Icons.check_circle_outline, done),
          ],
        ),
      ),
    );
  }

  // ─── AppBar ──────────────────────────────────────────────────────────────────
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

  // ─── Form Card ───────────────────────────────────────────────────────────────
  Widget _buildFormCard() {
    return _card([
      Row(
        children: const [
          Icon(Icons.add, color: Color(0xFFFF6B00), size: 18),
          SizedBox(width: 8),
          Text(
            'Tambah Jadwal',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _formField(
              label: 'Nama Kegiatan',
              child: TextFormField(
                controller: _nameCtrl,
                decoration: _inputDec('cth: Vaksin ND'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _formField(
              label: 'Jenis',
              child: _dropdownField(
                value: _selType,
                items: _types,
                onChanged: (v) => setState(() => _selType = v!),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _formField(
              label: 'Tanggal',
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                    builder: (c, child) => Theme(
                      data: Theme.of(c).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFFFF6B00),
                          onPrimary: Colors.white,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setState(() => _selDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDateDisplay(_selDate),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Color(0xFF888888),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _formField(
              label: 'Pengulangan',
              child: _dropdownField(
                value: _selRepeat,
                items: _repeats,
                onChanged: (v) => setState(() => _selRepeat = v!),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _formField(
        label: 'Dosis / Catatan',
        child: TextFormField(
          controller: _noteCtrl,
          decoration: _inputDec('opsional'),
        ),
      ),
      const SizedBox(height: 18),
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _addSchedule,
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: const Text(
            'Tambah Jadwal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
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
    ]);
  }

  // ─── List Card ───────────────────────────────────────────────────────────────
  Widget _buildListCard(
    String title,
    IconData icon,
    List<_ScheduleItem> items,
  ) {
    return _card([
      Row(
        children: [
          Icon(icon, color: const Color(0xFFFF6B00), size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      ...items.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        final urgent = _isUrgent(s.date);
        final typeColor = _typeColor(s.type);

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dot
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: s.isDone ? const Color(0xFFCCCCCC) : typeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: s.isDone
                              ? const Color(0xFFAAAAAA)
                              : const Color(0xFF1A1A1A),
                          decoration: s.isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(
                            _formatDate(s.date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888888),
                            ),
                          ),
                          if (!s.isDone) ...[
                            _badge(s.type, typeColor),
                            if (s.note.isNotEmpty)
                              Text(
                                '· ${s.note}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF888888),
                                ),
                              ),
                            Text(
                              '· ${_timeAgo(s.date)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status badge
                if (!s.isDone)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: urgent
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      urgent ? 'Segera' : 'Mendatang',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: urgent
                            ? const Color(0xFFE53935)
                            : const Color(0xFFFF6B00),
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                // Done button
                GestureDetector(
                  onTap: () => setState(() => s.isDone = !s.isDone),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: s.isDone
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: s.isDone
                          ? const Color(0xFF43A047)
                          : const Color(0xFF43A047),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Delete button
                GestureDetector(
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hapus Jadwal'),
                        content: Text('Hapus jadwal "${s.name}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      setState(
                        () => _schedules.removeWhere((x) => x.id == s.id),
                      );
                    }
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ),
              ],
            ),
            if (i < items.length - 1)
              const Divider(height: 20, color: Color(0xFFF5F5F5)),
          ],
        );
      }),
    ]);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
        children: children,
      ),
    );
  }

  Widget _formField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF888888),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );

  Widget _dropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
          items: items
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ─── Bottom Nav ──────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
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
        children: List.generate(items.length, (i) {
          final selected = i == widget.selectedNavIndex;
          return GestureDetector(
            onTap: () => widget.onNavTap(i),
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

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
