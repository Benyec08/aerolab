import 'package:flutter/material.dart';

import '../../data/entities/aircraft_entity.dart';
import '../../data/services/aircraft_service.dart';
import '../analysis/new_analysis_page.dart';
import 'aircraft_form_dialog.dart';

class AircraftHangarPage extends StatefulWidget {
  const AircraftHangarPage({super.key});

  @override
  State<AircraftHangarPage> createState() => _AircraftHangarPageState();
}

class _AircraftHangarPageState extends State<AircraftHangarPage> {
  final TextEditingController _searchController = TextEditingController();
  final AircraftService _aircraftService = AircraftService();

  String _selectedType = 'Tümü';
  String _selectedSort = 'En Yeni';

  List<AircraftEntity> _aircraftList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeHangar();
  }

  Future<void> _initializeHangar() async {
    try {
      await _aircraftService.ensureInitialAircraft();
      await _loadAircraft();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showMessage('Araç verileri yüklenemedi: $error');
    }
  }

  Future<void> _loadAircraft() async {
    final aircraft = _aircraftService.getAllAircraft();

    if (!mounted) {
      return;
    }

    setState(() {
      _aircraftList = aircraft;
      _isLoading = false;
    });
  }

  List<AircraftEntity> get _filteredAircraft {
    final searchText = _searchController.text.trim().toLowerCase();

    final result = _aircraftList.where((aircraft) {
      final name = aircraft.name.toLowerCase();
      final type = aircraft.type.toLowerCase();

      final matchesSearch =
          searchText.isEmpty ||
          name.contains(searchText) ||
          type.contains(searchText);

      final matchesType =
          _selectedType == 'Tümü' || aircraft.type == _selectedType;

      return matchesSearch && matchesType;
    }).toList();

    switch (_selectedSort) {
      case 'En Yeni':
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case 'En Eski':
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;

      case 'İsim A-Z':
        result.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;

      case 'İsim Z-A':
        result.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;

      case 'Ağırlık - Artan':
        result.sort((a, b) => a.weightKg.compareTo(b.weightKg));
        break;

      case 'Ağırlık - Azalan':
        result.sort((a, b) => b.weightKg.compareTo(a.weightKg));
        break;
    }

    return result;
  }

  int _countByType(String type) {
    return _aircraftList.where((aircraft) {
      return aircraft.type == type;
    }).length;
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
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AircraftFormDialog(),
    );

    if (!mounted || result == null) {
      return;
    }

    try {
      final aircraft = await _aircraftService.createAircraft(result);

      await _loadAircraft();

      _showMessage('${aircraft.name} araç kütüphanesine eklendi.');
    } catch (error) {
      _showMessage('Araç kaydedilemedi: $error');
    }
  }

  Future<void> _editAircraft(AircraftEntity aircraft) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AircraftFormDialog(aircraft: aircraft.toMap()),
    );

    if (!mounted || result == null) {
      return;
    }

    try {
      final editedAircraft = await _aircraftService.updateAircraft(
        currentAircraft: aircraft,
        formData: result,
      );

      await _loadAircraft();

      _showMessage('${editedAircraft.name} başarıyla güncellendi.');
    } catch (error) {
      _showMessage('Araç güncellenemedi: $error');
    }
  }

  Future<void> _duplicateAircraft(AircraftEntity aircraft) async {
    try {
      await _aircraftService.duplicateAircraft(aircraft);

      await _loadAircraft();

      _showMessage('${aircraft.name} başarıyla kopyalandı.');
    } catch (error) {
      _showMessage('Araç kopyalanamadı: $error');
    }
  }

  Future<void> _confirmDeleteAircraft(AircraftEntity aircraft) async {
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
            '${aircraft.name} adlı aracı silmek istediğinize '
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

    try {
      await _aircraftService.deleteAircraft(aircraft.id);
      await _loadAircraft();

      _showMessage('${aircraft.name} başarıyla silindi.');
    } catch (error) {
      _showMessage('Araç silinemedi: $error');
    }
  }

  void _openAircraft(AircraftEntity aircraft) {
    final engineeringAircraft = _aircraftService.toEngineeringModel(aircraft);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewAnalysisPage(initialAircraft: engineeringAircraft),
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
              onPressed: _isLoading ? null : _createNewAircraft,
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
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
                                      onDuplicate: () async {
                                        await _duplicateAircraft(aircraft);
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
  final AircraftEntity aircraft;
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
                          aircraft.name,
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
                      aircraft.type,
                      style: const TextStyle(
                        color: Color(0xFF0B3D91),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Divider(height: 28),
                  _AircraftInfoRow(
                    label: 'Ağırlık',
                    value: '${aircraft.weightKg} kg',
                  ),
                  _AircraftInfoRow(
                    label: 'Kanat Alanı',
                    value: '${aircraft.wingAreaM2} m²',
                  ),
                  _AircraftInfoRow(
                    label: 'Motor Gücü',
                    value: '${aircraft.motorPowerW} W',
                  ),
                  _AircraftInfoRow(
                    label: 'Batarya',
                    value: aircraft.batteryDescription.isEmpty
                        ? '${aircraft.batteryCellCount}S '
                              '${aircraft.batteryType}'
                        : aircraft.batteryDescription,
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
