import 'package:flutter/material.dart';

import '../analysis/new_analysis_page.dart';
import 'aircraft_form_dialog.dart';

class AircraftHangarPage extends StatefulWidget {
  const AircraftHangarPage({super.key});

  @override
  State<AircraftHangarPage> createState() => _AircraftHangarPageState();
}

class _AircraftHangarPageState extends State<AircraftHangarPage> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedType = 'Tümü';
  String _selectedSort = 'En Yeni';

  final List<Map<String, dynamic>> _aircraftList = [
    {
      'name': 'F16 Prototype',
      'type': 'Sabit Kanat',
      'weight': 2.35,
      'wingArea': 0.46,
      'wingSpan': 1.40,
      'motorCount': 1,
      'motorPower': 1200.0,
      'propellerDiameter': 14.0,
      'battery': '6S LiPo',
      'batteryType': 'LiPo',
      'batteryVoltage': 22.2,
      'batteryCapacity': 5000.0,
      'batteryCellCount': 6,
      'created': DateTime(2026, 7, 8),
    },
    {
      'name': 'UAV-X Drone',
      'type': 'Drone',
      'weight': 1.20,
      'wingArea': 0.00,
      'wingSpan': 0.00,
      'motorCount': 4,
      'motorPower': 800.0,
      'propellerDiameter': 10.0,
      'battery': '4S LiPo',
      'batteryType': 'LiPo',
      'batteryVoltage': 14.8,
      'batteryCapacity': 5200.0,
      'batteryCellCount': 4,
      'created': DateTime(2026, 7, 9),
    },
    {
      'name': 'VTOL Alpha',
      'type': 'VTOL',
      'weight': 3.10,
      'wingArea': 0.55,
      'wingSpan': 1.80,
      'motorCount': 4,
      'motorPower': 1600.0,
      'propellerDiameter': 12.0,
      'battery': '6S Li-Ion',
      'batteryType': 'Li-Ion',
      'batteryVoltage': 21.6,
      'batteryCapacity': 10000.0,
      'batteryCellCount': 6,
      'created': DateTime(2026, 7, 10),
    },
  ];

  List<Map<String, dynamic>> get _filteredAircraft {
    final searchText = _searchController.text.trim().toLowerCase();

    final result = _aircraftList.where((aircraft) {
      final name = aircraft['name'].toString().toLowerCase();
      final type = aircraft['type'].toString();

      final matchesSearch =
          searchText.isEmpty ||
          name.contains(searchText) ||
          type.toLowerCase().contains(searchText);

      final matchesType = _selectedType == 'Tümü' || type == _selectedType;

      return matchesSearch && matchesType;
    }).toList();

    switch (_selectedSort) {
      case 'En Yeni':
        result.sort(
          (a, b) =>
              (b['created'] as DateTime).compareTo(a['created'] as DateTime),
        );
        break;
      case 'En Eski':
        result.sort(
          (a, b) =>
              (a['created'] as DateTime).compareTo(b['created'] as DateTime),
        );
        break;
      case 'İsim A-Z':
        result.sort(
          (a, b) => a['name'].toString().toLowerCase().compareTo(
            b['name'].toString().toLowerCase(),
          ),
        );
        break;
      case 'İsim Z-A':
        result.sort(
          (a, b) => b['name'].toString().toLowerCase().compareTo(
            a['name'].toString().toLowerCase(),
          ),
        );
        break;
      case 'Ağırlık - Artan':
        result.sort(
          (a, b) => (a['weight'] as num).compareTo(b['weight'] as num),
        );
        break;
      case 'Ağırlık - Azalan':
        result.sort(
          (a, b) => (b['weight'] as num).compareTo(a['weight'] as num),
        );
        break;
    }

    return result;
  }

  int _countByType(String type) {
    return _aircraftList.where((aircraft) => aircraft['type'] == type).length;
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  Future<void> _createNewAircraft() async {
    final newAircraft = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AircraftFormDialog(),
    );

    if (!mounted || newAircraft == null) {
      return;
    }

    setState(() {
      _aircraftList.add(newAircraft);
    });

    _showMessage('${newAircraft['name']} araç kütüphanesine eklendi.');
  }

  Future<void> _editAircraft(Map<String, dynamic> aircraft) async {
    final editedAircraft = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          AircraftFormDialog(aircraft: Map<String, dynamic>.from(aircraft)),
    );

    if (!mounted || editedAircraft == null) {
      return;
    }

    final aircraftIndex = _aircraftList.indexOf(aircraft);

    if (aircraftIndex == -1) {
      _showMessage('Düzenlenecek araç bulunamadı.');
      return;
    }

    setState(() {
      _aircraftList[aircraftIndex] = editedAircraft;
    });

    _showMessage('${editedAircraft['name']} başarıyla güncellendi.');
  }

  String _createCopyName(String originalName) {
    final baseName = '$originalName Kopya';

    if (!_aircraftList.any((aircraft) => aircraft['name'] == baseName)) {
      return baseName;
    }

    int copyNumber = 2;

    while (_aircraftList.any(
      (aircraft) => aircraft['name'] == '$baseName $copyNumber',
    )) {
      copyNumber++;
    }

    return '$baseName $copyNumber';
  }

  void _duplicateAircraft(Map<String, dynamic> aircraft) {
    final copiedAircraft = Map<String, dynamic>.from(aircraft);

    copiedAircraft['name'] = _createCopyName(aircraft['name'].toString());
    copiedAircraft['created'] = DateTime.now();

    setState(() {
      _aircraftList.add(copiedAircraft);
    });

    _showMessage('${aircraft['name']} başarıyla kopyalandı.');
  }

  Future<void> _confirmDeleteAircraft(Map<String, dynamic> aircraft) async {
    final aircraftName = aircraft['name'].toString();

    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text('Aracı Sil'),
            ],
          ),
          content: Text(
            '$aircraftName adlı aracı silmek istediğinize '
            'emin misiniz?\n\nBu işlem geri alınamaz.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('İptal'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Sil'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldDelete != true) {
      return;
    }

    setState(() {
      _aircraftList.remove(aircraft);
    });

    _showMessage('$aircraftName başarıyla silindi.');
  }

  void _openAircraft(Map<String, dynamic> aircraft) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewAnalysisPage(
          initialAircraft: Map<String, dynamic>.from(aircraft),
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedType = 'Tümü';
      _selectedSort = 'En Yeni';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAircraft = _filteredAircraft;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Araç Kütüphanesi'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: _createNewAircraft,
              icon: const Icon(Icons.add),
              label: const Text('Yeni Araç'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HangarHeader(),
                  const SizedBox(height: 24),
                  _buildControls(),
                  const SizedBox(height: 20),
                  _buildStats(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: filteredAircraft.isEmpty
                        ? _EmptyState(
                            hasAircraft: _aircraftList.isNotEmpty,
                            onClearFilters: _clearFilters,
                            onCreateAircraft: _createNewAircraft,
                          )
                        : GridView.builder(
                            itemCount: filteredAircraft.length,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 380,
                                  mainAxisExtent: 350,
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing: 20,
                                ),
                            itemBuilder: (context, index) {
                              final aircraft = filteredAircraft[index];

                              return _AircraftCard(
                                aircraft: aircraft,
                                onOpen: () {
                                  _openAircraft(aircraft);
                                },
                                onEdit: () async {
                                  await _editAircraft(aircraft);
                                },
                                onDuplicate: () {
                                  _duplicateAircraft(aircraft);
                                },
                                onDelete: () async {
                                  await _confirmDeleteAircraft(aircraft);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 760;

        final searchField = TextField(
          controller: _searchController,
          onChanged: (_) {
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Araç adı veya türü ara...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Aramayı temizle',
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );

        final typeDropdown = _HangarDropdown(
          label: 'Araç Türü',
          icon: Icons.filter_alt_outlined,
          value: _selectedType,
          items: const ['Tümü', 'Sabit Kanat', 'Drone', 'VTOL', 'Helikopter'],
          onChanged: (value) {
            setState(() {
              _selectedType = value;
            });
          },
        );

        final sortDropdown = _HangarDropdown(
          label: 'Sıralama',
          icon: Icons.sort,
          value: _selectedSort,
          items: const [
            'En Yeni',
            'En Eski',
            'İsim A-Z',
            'İsim Z-A',
            'Ağırlık - Artan',
            'Ağırlık - Azalan',
          ],
          onChanged: (value) {
            setState(() {
              _selectedSort = value;
            });
          },
        );

        if (isNarrow) {
          return Column(
            children: [
              searchField,
              const SizedBox(height: 12),
              typeDropdown,
              const SizedBox(height: 12),
              sortDropdown,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: searchField),
            const SizedBox(width: 14),
            SizedBox(width: 210, child: typeDropdown),
            const SizedBox(width: 14),
            SizedBox(width: 220, child: sortDropdown),
          ],
        );
      },
    );
  }

  Widget _buildStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columnCount;

        if (constraints.maxWidth >= 900) {
          columnCount = 4;
        } else if (constraints.maxWidth >= 520) {
          columnCount = 2;
        } else {
          columnCount = 1;
        }

        const spacing = 14.0;

        final cardWidth =
            (constraints.maxWidth - (spacing * (columnCount - 1))) /
            columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: _HangarStatCard(
                title: 'Toplam Araç',
                value: _aircraftList.length.toString(),
                icon: Icons.flight,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _HangarStatCard(
                title: 'Sabit Kanat',
                value: _countByType('Sabit Kanat').toString(),
                icon: Icons.airplanemode_active,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _HangarStatCard(
                title: 'Drone',
                value: _countByType('Drone').toString(),
                icon: Icons.precision_manufacturing,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _HangarStatCard(
                title: 'VTOL',
                value: _countByType('VTOL').toString(),
                icon: Icons.vertical_align_top,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HangarHeader extends StatelessWidget {
  const _HangarHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Araç Kütüphanesi',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF102A43),
          ),
        ),
        SizedBox(height: 7),
        Text(
          'Hava araçlarınızı yönetin, filtreleyin ve analiz için hazırlayın.',
          style: TextStyle(fontSize: 15, color: Color(0xFF627D98)),
        ),
      ],
    );
  }
}

class _HangarDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _HangarDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }
}

class _HangarStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _HangarStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0B3D91).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF0B3D91)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF102A43),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF627D98)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AircraftCard extends StatefulWidget {
  final Map<String, dynamic> aircraft;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _AircraftCard({
    required this.aircraft,
    required this.onOpen,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  State<_AircraftCard> createState() => _AircraftCardState();
}

class _AircraftCardState extends State<_AircraftCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final aircraft = widget.aircraft;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: AnimatedScale(
        scale: _isHovered ? 1.015 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.12 : 0.06),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: _isHovered
                    ? const Color(0xFF0B3D91)
                    : const Color(0xFFD9E2EC),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          aircraft['name'].toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF102A43),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.flight_takeoff,
                        color: Color(0xFF0B3D91),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B3D91).withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      aircraft['type'].toString(),
                      style: const TextStyle(
                        color: Color(0xFF0B3D91),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Divider(height: 28),
                  _AircraftInfoRow(
                    label: 'Ağırlık',
                    value: '${aircraft['weight']} kg',
                  ),
                  _AircraftInfoRow(
                    label: 'Kanat Alanı',
                    value: '${aircraft['wingArea']} m²',
                  ),
                  _AircraftInfoRow(
                    label: 'Motor Gücü',
                    value: '${aircraft['motorPower']} W',
                  ),
                  _AircraftInfoRow(
                    label: 'Batarya',
                    value: aircraft['battery'].toString(),
                  ),
                  const Spacer(),
                  _AircraftActions(
                    onOpen: widget.onOpen,
                    onEdit: widget.onEdit,
                    onDuplicate: widget.onDuplicate,
                    onDelete: widget.onDelete,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AircraftActions extends StatelessWidget {
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _AircraftActions({
    required this.onOpen,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new, size: 17),
                label: const Text('Aç'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('Düzenle'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDuplicate,
                icon: const Icon(Icons.copy_outlined, size: 17),
                label: const Text('Kopyala'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 17),
                label: const Text('Sil'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AircraftInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _AircraftInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF627D98)),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF243B53),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasAircraft;
  final VoidCallback onClearFilters;
  final VoidCallback onCreateAircraft;

  const _EmptyState({
    required this.hasAircraft,
    required this.onClearFilters,
    required this.onCreateAircraft,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasAircraft ? Icons.search_off : Icons.airplanemode_inactive,
              size: 78,
              color: const Color(0xFF9FB3C8),
            ),
            const SizedBox(height: 18),
            Text(
              hasAircraft ? 'Araç Bulunamadı' : 'Henüz Kayıtlı Araç Yok',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF102A43),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              hasAircraft
                  ? 'Arama veya filtreleme ölçütlerine uygun bir araç bulunamadı.'
                  : 'İlk mühendislik aracınızı oluşturarak kütüphanenizi hazırlayın.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF627D98), height: 1.4),
            ),
            const SizedBox(height: 20),
            if (hasAircraft)
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Filtreleri Temizle'),
              )
            else
              FilledButton.icon(
                onPressed: onCreateAircraft,
                icon: const Icon(Icons.add),
                label: const Text('Yeni Araç'),
              ),
          ],
        ),
      ),
    );
  }
}
