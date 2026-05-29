import 'package:flutter/material.dart';
import 'farm_list_screen.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class FarmScheduleScreen extends StatefulWidget {
  final Farm farm;
  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;
  final bool embedded;

  const FarmScheduleScreen({
    super.key,
    required this.farm,
    required this.selectedNavIndex,
    required this.onNavTap,
    this.embedded = false,
  });

  @override
  State<FarmScheduleScreen> createState() => _FarmScheduleScreenState();
}

class _FarmScheduleScreenState extends State<FarmScheduleScreen> {
  final _activityCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _selDate = DateTime.now();
  String _selCategory = 'ayam';
  String _selLoop = 'sekali';

  final List<String> _categories = [
    'ayam', 'vaksin', 'vitamin', 'obat', 'pembersihan', 'lainnya',
  ];
  final List<String> _loops = ['sekali', 'sehari', 'seminggu', 'sebulan'];

  List<ScheduleModel> _schedules = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMsg;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  @override
  void dispose() {
    _activityCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSchedules() async {
    setState(() { _isLoading = true; _errorMsg = null; _currentPage = 1; });
    final (list, lastPage, error) = await ScheduleService.instance.getList(widget.farm.id, page: 1);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (error != null) {
        _errorMsg = error;
      } else {
        _schedules = list ?? [];
        _lastPage = lastPage ?? 1;
      }
    });
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    final nextPage = _currentPage + 1;
    final (list, lastPage, _) = await ScheduleService.instance.getList(widget.farm.id, page: nextPage);
    if (!mounted) return;
    setState(() {
      if (list != null) {
        _schedules.addAll(list);
        _currentPage = nextPage;
        _lastPage = lastPage ?? _lastPage;
      }
      _loadingMore = false;
    });
  }

  Future<void> _addSchedule() async {
    if (_activityCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Nama kegiatan wajib diisi'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    setState(() => _isSaving = true);
    final (model, error) = await ScheduleService.instance.create({
      'farm_id': widget.farm.id,
      'activity': _activityCtrl.text.trim(),
      'category': _selCategory,
      'date': _formatDateApi(_selDate),
      'loop': _selLoop,
      'note': _noteCtrl.text.trim(),
    });
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    _activityCtrl.clear();
    _noteCtrl.clear();
    setState(() => _selDate = DateTime.now());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Jadwal ditambahkan!'),
      backgroundColor: const Color(0xFFFF6B00),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
    _loadSchedules();
  }

  Future<void> _deleteSchedule(ScheduleModel s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: Text('Hapus jadwal "\${s.activity}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final error = await ScheduleService.instance.delete(s.id);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } else {
      _loadSchedules();
    }
  }

  String _formatDateApi(DateTime d) =>
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
    if (diff.inDays > 0) return '${diff.inDays}hr lalu';
    if (diff.inHours > 0) return '${diff.inHours}jam lalu';
    return 'Baru';
  }

  bool _isUrgent(DateTime d) =>
      DateTime.now().isAfter(d) || d.difference(DateTime.now()).inDays <= 2;

  Color _categoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'vaksin': return const Color(0xFF1E88E5);
      case 'vitamin': return const Color(0xFF43A047);
      case 'obat': return const Color(0xFFE53935);
      case 'pembersihan': return const Color(0xFF8D6E63);
      case 'ayam': return const Color(0xFFFF6B00);
      default: return const Color(0xFF8E24AA);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    final dateStr = '${days[now.weekday - 1]}, ${now.day} ${months[now.month]} ${now.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: widget.embedded ? null : _buildAppBar(dateStr),
      bottomNavigationBar: widget.embedded ? null : _buildBottomNav(),
      body: RefreshIndicator(
        color: const Color(0xFFFF6B00),
        onRefresh: _loadSchedules,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Jadwal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 2),
              const Text('Vaksin, vitamin & obat-obatan', style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
              const SizedBox(height: 20),
              _buildFormCard(),
              const SizedBox(height: 16),
              _buildListSection(),
            ],
          ),
        ),
      ),
    );
  }

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
              width: 38, height: 38,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/logo-single.png', width: 38, height: 38, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Ayamon', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text(dateStr, style: const TextStyle(fontSize: 13, color: Color(0xFF888888)))),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return _card([
      Row(children: const [
        Icon(Icons.add, color: Color(0xFFFF6B00), size: 18),
        SizedBox(width: 8),
        Text('Tambah Jadwal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
      ]),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(child: _formField(label: 'Nama Kegiatan', child: TextFormField(controller: _activityCtrl, decoration: _inputDec('cth: Vaksin ND')))),
          const SizedBox(width: 12),
          Expanded(child: _formField(label: 'Kategori', child: _dropdownField(value: _selCategory, items: _categories, onChanged: (v) => setState(() => _selCategory = v!)))),
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
                      data: Theme.of(c).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFFFF6B00), onPrimary: Colors.white)),
                      child: child!,
                    ),
                  );
                  if (picked != null) setState(() => _selDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDateDisplay(_selDate), style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A))),
                      const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF888888)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _formField(label: 'Pengulangan', child: _dropdownField(value: _selLoop, items: _loops, onChanged: (v) => setState(() => _selLoop = v!)))),
        ],
      ),
      const SizedBox(height: 12),
      _formField(label: 'Dosis / Catatan', child: TextFormField(controller: _noteCtrl, decoration: _inputDec('opsional'))),
      const SizedBox(height: 18),
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _isSaving ? null : _addSchedule,
          icon: _isSaving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.add, color: Colors.white, size: 20),
          label: Text(_isSaving ? 'Menyimpan...' : 'Tambah Jadwal', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B00),
            disabledBackgroundColor: const Color(0xFFFFB380),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    ]);
  }

  Widget _buildListSection() {
    if (_isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: CircularProgressIndicator(color: Color(0xFFFF6B00))));
    }
    if (_errorMsg != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 10),
              Text(_errorMsg!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 13)),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _loadSchedules,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
                child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    if (_schedules.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text('Belum ada jadwal.\nTambah dengan form di atas.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
        ),
      );
    }

    return _card([
      Row(children: const [
        Icon(Icons.calendar_today_outlined, color: Color(0xFFFF6B00), size: 18),
        SizedBox(width: 8),
        Text('Jadwal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
      ]),
      const SizedBox(height: 14),
      ...List.generate(_schedules.length, (i) {
        final s = _schedules[i];
        final urgent = _isUrgent(s.dateTime);
        final catColor = _categoryColor(s.category);
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(width: 10, height: 10, decoration: BoxDecoration(color: catColor, shape: BoxShape.circle)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.activity, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(s.shortDate, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                          _badge(s.category, catColor),
                          _badge(s.loop, const Color(0xFF757575)),
                          if ((s.note ?? '').isNotEmpty)
                            Text('· ${s.note}', style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                          Text('· ${_timeAgo(s.dateTime)}', style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: urgent ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    urgent ? 'Segera' : 'Mendatang',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: urgent ? const Color(0xFFE53935) : const Color(0xFFFF6B00)),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _deleteSchedule(s),
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close, size: 16, color: Color(0xFFE53935)),
                  ),
                ),
              ],
            ),
            if (i < _schedules.length - 1) const Divider(height: 20, color: Color(0xFFF5F5F5)),
          ],
        );
      }),
      if (_loadingMore)
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFFFF6B00), strokeWidth: 2))),
        )
      else if (_currentPage < _lastPage)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _loadMore,
              icon: const Icon(Icons.expand_more, color: Color(0xFFFF6B00), size: 18),
              label: const Text('Muat Lebih', style: TextStyle(color: Color(0xFFFF6B00), fontSize: 13, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF6B00)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
    ]);
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _formField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF888888))),
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
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
  );

  Widget _dropdownField({required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
          items: items.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2))],
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
                Icon(items[i].icon, size: 24, color: selected ? const Color(0xFFFF6B00) : const Color(0xFFAAAAAA)),
                const SizedBox(height: 4),
                Text(items[i].label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? const Color(0xFFFF6B00) : const Color(0xFFAAAAAA))),
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
