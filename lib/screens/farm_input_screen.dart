import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'farm_list_screen.dart';

class DailyRecord {
  final String date;
  final int telur;
  final double beratKg;
  final int mati;
  final double pakanKg;

  const DailyRecord({
    required this.date,
    required this.telur,
    required this.beratKg,
    required this.mati,
    required this.pakanKg,
  });
}

class FarmInputScreen extends StatefulWidget {
  final Farm farm;
  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;

  const FarmInputScreen({
    super.key,
    required this.farm,
    required this.selectedNavIndex,
    required this.onNavTap,
  });

  @override
  State<FarmInputScreen> createState() => _FarmInputScreenState();
}

class _FarmInputScreenState extends State<FarmInputScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();

  final _telurCtrl = TextEditingController(text: '0');
  final _beratCtrl = TextEditingController(text: '0.0');
  final _matiCtrl = TextEditingController(text: '0');
  final _pakanCtrl = TextEditingController(text: '0.0');
  final _catatanCtrl = TextEditingController();

  // Dummy riwayat data
  final List<DailyRecord> _riwayat = const [
    DailyRecord(
      date: '05-02',
      telur: 769,
      beratKg: 47.7,
      mati: 0,
      pakanKg: 152.9,
    ),
    DailyRecord(
      date: '05-03',
      telur: 789,
      beratKg: 48.9,
      mati: 0,
      pakanKg: 157.4,
    ),
    DailyRecord(
      date: '05-04',
      telur: 825,
      beratKg: 51.1,
      mati: 0,
      pakanKg: 154.7,
    ),
    DailyRecord(
      date: '05-05',
      telur: 803,
      beratKg: 49.8,
      mati: 0,
      pakanKg: 149.0,
    ),
    DailyRecord(
      date: '05-06',
      telur: 799,
      beratKg: 49.5,
      mati: 0,
      pakanKg: 157.5,
    ),
    DailyRecord(
      date: '05-07',
      telur: 788,
      beratKg: 48.9,
      mati: 0,
      pakanKg: 157.7,
    ),
    DailyRecord(
      date: '05-08',
      telur: 789,
      beratKg: 48.9,
      mati: 0,
      pakanKg: 156.7,
    ),
  ];

  @override
  void dispose() {
    _telurCtrl.dispose();
    _beratCtrl.dispose();
    _matiCtrl.dispose();
    _pakanCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFFF6B00),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _simpanData() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Data berhasil disimpan!'),
          backgroundColor: const Color(0xFFFF6B00),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _telurCtrl.text = '0';
      _beratCtrl.text = '0.0';
      _matiCtrl.text = '0';
      _pakanCtrl.text = '0.0';
      _catatanCtrl.clear();
    }
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
      appBar: _buildAppBar(dateStr),
      bottomNavigationBar: _buildBottomNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page title
            const Text(
              'Input Harian',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Catat produksi telur setiap hari',
              style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 20),

            // ── Form Card ──
            _buildFormCard(),

            const SizedBox(height: 20),

            // ── Riwayat Card ──
            _buildRiwayatCard(),
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
    return Container(
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            const Row(
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFFFF6B00), size: 18),
                SizedBox(width: 8),
                Text(
                  'Data Produksi Harian',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tanggal
            _fieldLabel('Tanggal'),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(_selectedDate),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Color(0xFF888888),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Jumlah Telur & Berat Total
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Jumlah Telur (butir)'),
                      const SizedBox(height: 6),
                      _numberField(controller: _telurCtrl, isDecimal: false),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Berat Total (kg)'),
                      const SizedBox(height: 6),
                      _numberField(controller: _beratCtrl, isDecimal: true),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Kematian & Pakan Habis
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Kematian (ekor)'),
                      const SizedBox(height: 6),
                      _numberField(controller: _matiCtrl, isDecimal: false),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Pakan Habis (kg)'),
                      const SizedBox(height: 6),
                      _numberField(controller: _pakanCtrl, isDecimal: true),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Catatan
            _fieldLabel('Catatan'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _catatanCtrl,
              minLines: 2,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'opsional...',
                hintStyle: const TextStyle(
                  color: Color(0xFFBBBBBB),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Simpan Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _simpanData,
                icon: const Icon(
                  Icons.save_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  'Simpan Data',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF666666),
    ),
  );

  Widget _numberField({
    required TextEditingController controller,
    required bool isDecimal,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          isDecimal ? RegExp(r'^\d*\.?\d*') : RegExp(r'^\d*'),
        ),
      ],
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
    );
  }

  // ─── Riwayat Card ────────────────────────────────────────────────────────────
  Widget _buildRiwayatCard() {
    return Container(
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
        children: [
          const Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: Color(0xFFFF6B00),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Riwayat Data',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Table header
          const Row(
            children: [
              _TableHeader('Tanggal', flex: 2),
              _TableHeader('Telur', flex: 2),
              _TableHeader('Berat kg', flex: 2),
              _TableHeader('Mati', flex: 1),
              _TableHeader('Pakan kg', flex: 2),
              SizedBox(width: 28),
            ],
          ),
          const Divider(height: 14, color: Color(0xFFF0F0F0)),

          // Rows
          ...List.generate(_riwayat.length, (i) {
            final r = _riwayat[i];
            return Column(
              children: [
                Row(
                  children: [
                    _tableCell(r.date, flex: 2),
                    _tableCell(r.telur.toString(), flex: 2),
                    _tableCell(r.beratKg.toString(), flex: 2),
                    _tableCell(r.mati.toString(), flex: 1),
                    _tableCell(r.pakanKg.toString(), flex: 2),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Color(0xFFFF6B00),
                        ),
                      ),
                    ),
                  ],
                ),
                if (i < _riwayat.length - 1)
                  const Divider(height: 18, color: Color(0xFFF5F5F5)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _tableCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
      ),
    );
  }

  // ─── Bottom Nav ──────────────────────────────────────────────────────────────
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

class _TableHeader extends StatelessWidget {
  final String text;
  final int flex;
  const _TableHeader(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF888888),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
