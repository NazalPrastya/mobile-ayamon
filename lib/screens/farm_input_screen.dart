import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'farm_list_screen.dart';
import '../models/daily_production_model.dart';
import '../services/daily_production_service.dart';

class FarmInputScreen extends StatefulWidget {
  final Farm farm;
  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;
  final bool embedded;

  const FarmInputScreen({
    super.key,
    required this.farm,
    required this.selectedNavIndex,
    required this.onNavTap,
    this.embedded = false,
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

  List<DailyProductionModel> _riwayat = [];
  bool _riwayatLoading = true;
  bool _isSaving = false;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _loadingMore = false;

  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    setState(() {
      _riwayatLoading = true;
      _currentPage = 1;
    });
    final (list, lastPage, _) = await DailyProductionService.instance.getList(
      widget.farm.id,
      page: 1,
    );
    if (mounted) {
      setState(() {
        _riwayat = list ?? [];
        _lastPage = lastPage ?? 1;
        _riwayatLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    final nextPage = _currentPage + 1;
    final (list, lastPage, _) = await DailyProductionService.instance.getList(
      widget.farm.id,
      page: nextPage,
    );
    if (mounted) {
      setState(() {
        if (list != null) {
          _riwayat.addAll(list);
          _currentPage = nextPage;
          _lastPage = lastPage ?? _lastPage;
        }
        _loadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
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

  void _simpanData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Format date as dd-MM-yyyy per API requirement
    final d = _selectedDate;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

    final (_, error) = await DailyProductionService.instance.create({
      'farm_id': widget.farm.id,
      'date': dateStr,
      'egg_count': int.tryParse(_telurCtrl.text.trim()) ?? 0,
      'egg_weight': double.tryParse(_beratCtrl.text.trim()) ?? 0.0,
      'chicken_death': int.tryParse(_matiCtrl.text.trim()) ?? 0,
      'feed_sold': double.tryParse(_pakanCtrl.text.trim()) ?? 0.0,
      'note': _catatanCtrl.text.trim(),
    });

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Data berhasil disimpan!'),
        backgroundColor: const Color(0xFFFF6B00),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    _telurCtrl.text = '0';
    _beratCtrl.text = '0.0';
    _matiCtrl.text = '0';
    _pakanCtrl.text = '0.0';
    _catatanCtrl.clear();
    _loadRiwayat(); // refresh table
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
      appBar: widget.embedded ? null : _buildAppBar(dateStr),
      bottomNavigationBar: widget.embedded ? null : _buildBottomNav(),
      body: SingleChildScrollView(
        controller: _scrollCtrl,
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
                onPressed: _isSaving ? null : _simpanData,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.save_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                label: Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan Data',
                  style: const TextStyle(
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
          if (_riwayatLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
              ),
            )
          else if (_riwayat.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Belum ada data harian.',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                ),
              ),
            )
          else
            Column(
              children: [
                // Table header
                const Row(
                  children: [
                    _TableHeader('Tanggal', flex: 2),
                    _TableHeader('Telur', flex: 2),
                    _TableHeader('Berat kg', flex: 2),
                    _TableHeader('Mati', flex: 1),
                    _TableHeader('Pakan kg', flex: 2),
                  ],
                ),
                const Divider(height: 14, color: Color(0xFFF0F0F0)),
                ...List.generate(_riwayat.length, (i) {
                  final r = _riwayat[i];
                  return Column(
                    children: [
                      Row(
                        children: [
                          _tableCell(r.shortDate, flex: 2),
                          _tableCell(r.eggCount.toString(), flex: 2),
                          _tableCell(r.eggWeight.toStringAsFixed(1), flex: 2),
                          _tableCell(r.chickenDeath.toString(), flex: 1),
                          _tableCell(r.feedSold.toStringAsFixed(1), flex: 2),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            iconSize: 18,
                            icon: const Icon(
                              Icons.more_vert,
                              color: Color(0xFFCCCCCC),
                              size: 18,
                            ),
                            onSelected: (value) {
                              if (value == 'edit') _showEditSheet(r);
                              if (value == 'delete') _deleteRecord(r);
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 15,
                                      color: Color(0xFF555555),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Edit',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      size: 15,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Hapus',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (i < _riwayat.length - 1)
                        const Divider(height: 18, color: Color(0xFFF5F5F5)),
                    ],
                  );
                }),
                if (_loadingMore)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF6B00),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  )
                else if (_currentPage < _lastPage)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _loadMore,
                        icon: const Icon(
                          Icons.expand_more,
                          color: Color(0xFFFF6B00),
                          size: 18,
                        ),
                        label: const Text(
                          'Muat Lebih',
                          style: TextStyle(
                            color: Color(0xFFFF6B00),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF6B00)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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

  void _showEditSheet(DailyProductionModel record) {
    final editDate = ValueNotifier<DateTime>(
      DateTime.tryParse(record.date) ?? DateTime.now(),
    );
    final telurCtrl = TextEditingController(text: record.eggCount.toString());
    final beratCtrl = TextEditingController(
      text: record.eggWeight.toStringAsFixed(1),
    );
    final matiCtrl = TextEditingController(
      text: record.chickenDeath.toString(),
    );
    final pakanCtrl = TextEditingController(
      text: record.feedSold.toStringAsFixed(1),
    );
    final catatanCtrl = TextEditingController(text: record.note ?? '');
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const Text(
                      'Edit Data Harian',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Date picker
                    ValueListenableBuilder<DateTime>(
                      valueListenable: editDate,
                      builder: (_, date, _) => GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: date,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
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
                          if (picked != null) editDate.value = picked;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(date),
                                style: const TextStyle(fontSize: 14),
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _sheetField(telurCtrl, 'Jumlah Telur', false),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _sheetField(beratCtrl, 'Berat (kg)', true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _sheetField(matiCtrl, 'Kematian', false),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _sheetField(pakanCtrl, 'Pakan (kg)', true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: catatanCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Catatan',
                        labelStyle: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: saving
                            ? null
                            : () async {
                                setSheet(() => saving = true);
                                final d = editDate.value;
                                final dateStr =
                                    '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
                                final (_, error) = await DailyProductionService
                                    .instance
                                    .update(record.id, {
                                      'farm_id': widget.farm.id,
                                      'date': dateStr,
                                      'egg_count':
                                          int.tryParse(telurCtrl.text) ?? 0,
                                      'egg_weight':
                                          double.tryParse(beratCtrl.text) ??
                                          0.0,
                                      'chicken_death':
                                          int.tryParse(matiCtrl.text) ?? 0,
                                      'feed_sold':
                                          double.tryParse(pakanCtrl.text) ??
                                          0.0,
                                      'note': catatanCtrl.text.trim(),
                                    });
                                setSheet(() => saving = false);
                                if (!mounted) return;
                                Navigator.pop(ctx);
                                if (error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(error),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } else {
                                  _loadRiwayat();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetField(TextEditingController ctrl, String label, bool decimal) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          decimal ? RegExp(r'^\d*\.?\d*') : RegExp(r'^\d*'),
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF888888), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _deleteRecord(DailyProductionModel record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data'),
        content: Text(
          'Hapus data tanggal ${record.shortDate}? Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final error = await DailyProductionService.instance.delete(record.id);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      _loadRiwayat();
    }
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
