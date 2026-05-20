import 'package:flutter/material.dart';
import 'farm_dashboard_screen.dart';
import 'farm_form_screen.dart';
import '../services/auth_service.dart';
import '../services/farm_service.dart';
import '../models/farm_model.dart';

class Farm {
  final String id;
  final String name;
  final String location;
  final String period;

  const Farm({
    required this.id,
    required this.name,
    required this.location,
    required this.period,
  });
}

class FarmListScreen extends StatefulWidget {
  const FarmListScreen({super.key});

  @override
  State<FarmListScreen> createState() => _FarmListScreenState();
}

class _FarmListScreenState extends State<FarmListScreen> {
  String _userName = '...';
  List<FarmModel> _farms = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadFarms();
  }

  Future<void> _loadUserName() async {
    final name = await AuthService.instance.getUserName();
    if (mounted && name != null) {
      setState(() => _userName = name);
    }
  }

  Future<void> _loadFarms() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    final (farms, error) = await FarmService.instance.getFarms();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (error != null) {
        _errorMsg = error;
      } else {
        _farms = farms ?? [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              const Text(
                'Selamat datang,',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$_userName 👋',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Keluar'),
                          content: const Text('Yakin ingin keluar dari akun?'),
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
                              child: const Text('Keluar'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && mounted) {
                        await AuthService.instance.logout();
                        if (mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0E8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.logout,
                            size: 14,
                            color: Color(0xFFFF6B00),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF6B00),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih peternakan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FarmFormScreen(),
                        ),
                      );
                      if (result == true) _loadFarms();
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B00),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF6B00),
                        ),
                      )
                    : _errorMsg != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 40,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _errorMsg!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: _loadFarms,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B00),
                              ),
                              child: const Text(
                                'Coba Lagi',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _farms.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada peternakan.\nTambah dengan tombol +',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 14,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFFFF6B00),
                        onRefresh: _loadFarms,
                        child: ListView.separated(
                          itemCount: _farms.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final farm = _farms[index];
                            return _FarmCard(
                              farm: farm,
                              onEdit: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FarmFormScreen(farm: farm),
                                  ),
                                );
                                if (result == true) _loadFarms();
                              },
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Hapus Peternakan'),
                                    content: Text(
                                      'Hapus "${farm.name}"? Tindakan ini tidak bisa dibatalkan.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true && mounted) {
                                  final error = await FarmService.instance
                                      .deleteFarm(farm.id);
                                  if (!mounted) return;
                                  if (error != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(error),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    _loadFarms();
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FarmCard extends StatelessWidget {
  final FarmModel farm;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const _FarmCard({required this.farm, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FarmDashboardScreen(
              farm: Farm(
                id: farm.id,
                name: farm.name,
                location: farm.location ?? 'Lokasi belum diatur',
                period: farm.periode,
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.home_work_outlined,
                color: Color(0xFFFF6B00),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farm.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        farm.location ?? 'Lokasi belum diatur',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        farm.periode,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Color(0xFFCCCCCC),
                size: 20,
              ),
              onSelected: (value) {
                if (value == 'edit') onEdit?.call();
                if (value == 'delete') onDelete?.call();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Color(0xFF555555),
                      ),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
