import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app_routes.dart';
import '../../models/resin_model.dart';
import '../../services/api_client.dart';
import '../../services/resin_service.dart';
import '../../widgets/pext_asset_icon.dart';

const _blue = Color(0xFF053488);
const _navy = Color(0xFF053488); // #053488 for titles and subtitles
const _red = Color(0xFFD93838);
const _green = Color(0xFF1B873F);
const _canvas = Color(0xFFF6F8FB);
const _border = Color(0xFFE5E7EB);

// Aliases matching prompt specifications
typedef ListaResinasScreen = ResinsListScreen;
typedef CadastroResinaScreen = ResinFormScreen;
typedef FormularioResinaScreen = ResinFormScreen;
typedef DetalhesResinaScreen = ResinDetailScreen;

String? _getAssetForApplication(String name, {String? customIcon}) {
  if (customIcon != null && customIcon.isNotEmpty) {
    switch (customIcon) {
      case 'car':
        return PextAssets.car;
      case 'box':
      case 'packaging':
        return PextAssets.packaging;
      case 'bottle':
      case 'jar':
        return PextAssets.jar;
      case 'clothes':
      case 'fiber':
        return PextAssets.fiber;
      case 'washer':
      case 'house_machines':
      case 'houseMachines':
        return PextAssets.houseMachines;
      case 'toy':
      case 'joys':
        return PextAssets.joys;
      case 'material':
        return PextAssets.material;
    }
  }

  final lower = name.toLowerCase();
  if (lower.contains('embalag') || lower.contains('filme') || lower.contains('sacol') || lower.contains('pouch')) {
    return PextAssets.packaging;
  }
  if (lower.contains('tampa') || lower.contains('fechament') || lower.contains('garraf') || lower.contains('frasco') || lower.contains('pote')) {
    return PextAssets.jar;
  }
  if (lower.contains('fibra') || lower.contains('têxtil') || lower.contains('textil') || lower.contains('tecido')) {
    return PextAssets.fiber;
  }
  if (lower.contains('auto') || lower.contains('veícul') || lower.contains('veicul') || lower.contains('carro') || lower.contains('peça') || lower.contains('peca')) {
    return PextAssets.car;
  }
  if (lower.contains('eletro') || lower.contains('utilidade') || lower.contains('casa') || lower.contains('lavadora')) {
    return PextAssets.houseMachines;
  }
  if (lower.contains('brinqued') || lower.contains('lazer') || lower.contains('infantil') || lower.contains('bens')) {
    return PextAssets.joys;
  }
  return null;
}

String? _getAssetForFlowStep(String iconName, String title, int order) {
  final lowerIcon = iconName.toLowerCase();
  switch (lowerIcon) {
    case 'material':
    case 'hub':
      return PextAssets.material;
    case 'polimerization':
    case 'polimerizacao':
    case 'reactor':
      return PextAssets.polimerization;
    case 'granulation':
    case 'granulacao':
    case 'grain':
      return PextAssets.granulation;
    case 'final_product':
    case 'finalproduct':
    case 'product':
      return PextAssets.finalProduct;
    case 'packaging':
      return PextAssets.packaging;
    case 'car':
      return PextAssets.car;
  }

  final lower = '$iconName $title'.toLowerCase();
  if (lower.contains('material') || lower.contains('matéria') || lower.contains('materia') || lower.contains('propen') || lower.contains('hub')) {
    return PextAssets.material;
  }
  if (lower.contains('polimeriz') || lower.contains('reator') || lower.contains('reactor')) {
    return PextAssets.polimerization;
  }
  if (lower.contains('granul') || lower.contains('grain') || lower.contains('grão') || lower.contains('grao')) {
    return PextAssets.granulation;
  }
  if (lower.contains('final') || lower.contains('produto') || lower.contains('product') || lower.contains('sacola') || lower.contains('acabado')) {
    return PextAssets.finalProduct;
  }

  if (order == 1) return PextAssets.material;
  if (order == 2) return PextAssets.polimerization;
  if (order == 3) return PextAssets.granulation;
  if (order == 4) return PextAssets.finalProduct;
  return null;
}


// ============================================================================
// 1. LIST SCREEN (ListaResinasScreen / ResinsListScreen)
// ============================================================================

class ResinsListScreen extends StatefulWidget {
  final bool admin;
  const ResinsListScreen({super.key, this.admin = false});

  @override
  State<ResinsListScreen> createState() => _ResinsListScreenState();
}

class _ResinsListScreenState extends State<ResinsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _selectedCategoryFilter;
  final _resinService = ResinService.instance;

  @override
  void initState() {
    super.initState();
    _loadResins();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadResins() async {
    await _resinService.fetchResins(query: _query);
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value);
    _resinService.fetchResins(query: _query);
  }

  void _navigateToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      PextRoutes.home,
      (route) => false,
      arguments: PextRouteArgs(admin: widget.admin),
    );
  }

  void _openFilterBottomSheet() {
    final categories = _resinService.categories;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtrar Resinas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _navy,
                      ),
                    ),
                    if (_selectedCategoryFilter != null)
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedCategoryFilter = null);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Limpar Filtro'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Categorias:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _blue,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Todas'),
                      selected: _selectedCategoryFilter == null,
                      selectedColor: const Color(0xFFEAF2FF),
                      checkmarkColor: _blue,
                      labelStyle: TextStyle(
                        color: _selectedCategoryFilter == null ? _blue : Colors.black87,
                        fontWeight: _selectedCategoryFilter == null ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        setState(() => _selectedCategoryFilter = null);
                        Navigator.pop(ctx);
                      },
                    ),
                    ...categories.map((cat) {
                      final selected = _selectedCategoryFilter == cat.id;
                      return FilterChip(
                        label: Text(cat.name),
                        selected: selected,
                        selectedColor: const Color(0xFFEAF2FF),
                        checkmarkColor: _blue,
                        labelStyle: TextStyle(
                          color: selected ? _blue : Colors.black87,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          setState(() => _selectedCategoryFilter = val ? cat.id : null);
                          Navigator.pop(ctx);
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _navigateToHome();
      },
      child: Scaffold(
        backgroundColor: _canvas,
        appBar: AppBar(
          backgroundColor: _canvas,
          surfaceTintColor: _canvas,
          leading: IconButton(
            tooltip: 'Voltar para Início',
            onPressed: _navigateToHome,
            icon: const Icon(Icons.arrow_back_ios_new, color: _blue, size: 19),
          ),
          centerTitle: true,
          title: const Text(
            'Resinas',
            style: TextStyle(
              color: _blue,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (widget.admin)
              _HeaderActionButton(
                icon: Icons.add,
                tooltip: 'Adicionar resina',
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ResinFormScreen(admin: true),
                    ),
                  );
                  if (result == true || mounted) {
                    _loadResins();
                  }
                },
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
          child: Column(
            children: [
              // Search & Filter Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: const InputDecoration(
                          hintText: 'Ex: Coextrusão',
                          hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12),
                            child: PextAssetIcon(PextAssets.search, size: 20),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  InkWell(
                    onTap: _openFilterBottomSheet,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: _cardDecoration(),
                      child: const Center(
                        child: PextAssetIcon(PextAssets.filter, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListenableBuilder(
                  listenable: _resinService,
                  builder: (context, _) {
                    if (_resinService.isLoading && _resinService.resins.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_resinService.errorMessage != null &&
                        _resinService.resins.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _resinService.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _loadResins,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      );
                    }

                    var resins = _resinService.resins;
                    if (_selectedCategoryFilter != null) {
                      resins = resins
                          .where((r) => r.categoryId == _selectedCategoryFilter)
                          .toList();
                    }

                    if (resins.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.inbox, size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            const Text(
                              'Nenhuma resina encontrada.',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            if (widget.admin) ...[
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: _blue,
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ResinFormScreen(admin: true),
                                  ),
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('Cadastrar Resina'),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _loadResins,
                      child: ListView.separated(
                        itemCount: resins.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 9),
                        itemBuilder: (context, index) {
                          final resin = resins[index];
                          return _ResinListCard(
                            resin: resin,
                            onTap: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ResinDetailScreen(
                                    resinId: resin.id,
                                    admin: widget.admin,
                                  ),
                                ),
                              );
                              if (updated == true && mounted) {
                                _loadResins();
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _ResinBottomBar(admin: widget.admin, selected: 2),
      ),
    );
  }
}

class _ResinListCard extends StatelessWidget {
  final ResinModel resin;
  final VoidCallback onTap;

  const _ResinListCard({
    required this.resin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final acronym = resin.acronym.isNotEmpty ? resin.acronym : 'RES';
    final boldTitle = resin.acronym.isNotEmpty ? resin.acronym : resin.name;
    final graySubtitle = resin.acronym.isNotEmpty && resin.name.isNotEmpty
        ? resin.name
        : (resin.description.isNotEmpty ? resin.description : 'Polietileno');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            // Square container showing STRICTLY THE ACRONYM (SIGLA), NEVER the photo!
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: Text(
                acronym.length > 4 ? acronym.substring(0, 4) : acronym,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    boldTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    graySubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _blue,
                    ),
                  ),
                ],
              ),
            ),
            // Trailing right chevron (>)
            const Icon(
              Icons.chevron_right,
              size: 24,
              color: _blue,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. DETAIL SCREEN (DetalhesResinaScreen / ResinDetailScreen)
// ============================================================================

class ResinDetailScreen extends StatefulWidget {
  final String resinId;
  final bool admin;
  final ResinModel? initialResin;

  const ResinDetailScreen({
    super.key,
    required this.resinId,
    this.admin = false,
    this.initialResin,
  });

  @override
  State<ResinDetailScreen> createState() => _ResinDetailScreenState();
}

class _ResinDetailScreenState extends State<ResinDetailScreen> {
  int _tab = 0;
  bool _loading = true;
  String? _error;
  ResinModel? _resin;

  final _tabs = const [
    'Visão Geral',
    'Características',
    'Propriedades',
    'Mais',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialResin != null) {
      _resin = widget.initialResin;
      _loading = false;
    } else {
      _fetchDetail();
    }
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final item = await ResinService.instance.getResinById(widget.resinId);
      if (mounted) {
        setState(() {
          _resin = item;
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

  Future<void> _toggleFavorite() async {
    if (_resin == null) return;
    final isFav = await ResinService.instance.toggleFavorite(_resin!.id);
    if (mounted) {
      setState(() {
        _resin = _resin!.copyWith(isFavorite: isFav);
      });
    }
  }

  Future<void> _editResin() async {
    if (_resin == null) return;
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResinFormScreen(
          admin: true,
          initialResin: _resin,
        ),
      ),
    );
    if (updated == true && mounted) {
      _fetchDetail();
    }
  }

  Future<void> _confirmDelete() async {
    if (_resin == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Conteúdo'),
        content: Text('Tem certeza que deseja excluir "${_resin!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ResinService.instance.deleteResin(_resin!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Resina excluída com sucesso.')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _resin != null
        ? '${_resin!.acronym.isNotEmpty ? _resin!.acronym : "Resina"} - ${_resin!.name}'
        : 'Detalhes da Resina';

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: _canvas,
        appBar: AppBar(
          backgroundColor: _canvas,
          surfaceTintColor: _canvas,
          leading: IconButton(
            tooltip: 'Voltar para Lista de Resinas',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: _blue, size: 19),
          ),
          centerTitle: true,
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _navy,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            // Favorite button REMOVED completely on admin screens!
            if (!widget.admin && _resin != null)
              IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _resin!.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _resin!.isFavorite ? Colors.red : _navy,
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _fetchDetail,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  )
                : _resin == null
                    ? const Center(child: Text('Resina não encontrada.'))
                    : Column(
                        children: [
                          // NAVIGATION TABS STRICTLY AT THE TOP OF THE SCREEN!
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            child: _TabsBar(
                              tabs: _tabs,
                              selected: _tab,
                              onChanged: (index) =>
                                  setState(() => _tab = index),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                              child: _buildDetailTabContent(_resin!),
                            ),
                          ),
                        ],
                      ),
        bottomNavigationBar: _ResinBottomBar(admin: widget.admin, selected: 2),
      ),
    );
  }

  Widget _buildDetailTabContent(ResinModel resin) {
    if (_tab == 0) {
      return _buildOverviewTab(resin);
    } else if (_tab == 1) {
      return _buildCharacteristicsTab(resin);
    } else if (_tab == 2) {
      return _buildPropertiesTab(resin);
    } else {
      return _buildMoreTab(resin);
    }
  }

  // --- TAB 0: VISÃO GERAL (Cover photo banner ONLY appears here!) ---
  Widget _buildOverviewTab(ResinModel resin) {
    final imageWidget = resin.imageUrl != null && resin.imageUrl!.isNotEmpty
        ? Image.network(
            ApiClient.instance.mediaUrl(resin.imageUrl),
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(
              'images/training_extrusion.png',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        : Image.asset(
            'images/training_extrusion.png',
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          );

    final acronym = resin.acronym.isNotEmpty ? resin.acronym : 'PP';
    // Nome do Material (instead of category)
    final materialName = resin.name.isNotEmpty ? resin.name : 'Termoplástico';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover Photo Banner ONLY on Visão Geral
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: imageWidget,
        ),
        const SizedBox(height: 14),

        // Badges: Green acronym square badge, Nome do Material chip, and stacked enlarged Edit/Delete buttons
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF48BB78),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      acronym,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Text(
                      materialName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF16A34A),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.admin) ...[
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _blue,
                      side: const BorderSide(color: _blue, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      minimumSize: const Size(165, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _editResin,
                    icon: const PextAssetIcon(PextAssets.edit, size: 18),
                    label: const Text(
                      'Editar Conteúdo',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _blue),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _red,
                      side: const BorderSide(color: _red, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      minimumSize: const Size(165, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _confirmDelete,
                    icon: const PextAssetIcon(PextAssets.trash, size: 18),
                    label: const Text(
                      'Excluir Conteúdo',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _red),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // Three white rounded metric cards side by side
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                iconAsset: PextAssets.density,
                label: 'Densidade',
                value: resin.densityMetricFormatted,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                iconAsset: PextAssets.temperature,
                label: 'Temp. de Fusão',
                value: resin.meltingPointMetricFormatted,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                iconAsset: PextAssets.mfi,
                label: 'MFI',
                value: resin.mfiMetricFormatted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // "Como Funciona?" section with dark blue title
        const Text(
          'Como Funciona?',
          style: TextStyle(
            color: _blue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          resin.description.isNotEmpty
              ? resin.description
              : 'O polipropileno (PP) é um termoplástico semicristalino produzido pela polimerização do propeno.',
          style: const TextStyle(fontSize: 13, color: _blue, height: 1.4),
        ),
        const SizedBox(height: 20),

        // "Processo de Produção:" compact flowchart with icons & admin manage button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Processo de Produção:',
                style: TextStyle(
                  color: _blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (widget.admin)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _blue,
                  side: const BorderSide(color: _blue),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () async {
                  final result = await Navigator.push<List<ProductionStep>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GerenciarEtapasFluxogramaScreen(
                        initialSteps: resin.productionProcess,
                      ),
                    ),
                  );
                  if (result != null && mounted) {
                    final updated = resin.copyWith(productionProcess: result);
                    await ResinService.instance.updateResin(resin.id, updated);
                    _fetchDetail();
                  }
                },
                icon: const PextAssetIcon(PextAssets.edit, size: 14),
                label: const Text('Gerenciar Etapas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _blue)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        _buildHorizontalFlowchart(resin.productionProcess),
        const SizedBox(height: 22),

        // "Para o que é utilizado?" 3-column grid & admin manage button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Para o que é utilizado?',
                    style: TextStyle(
                      color: _blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Devido às suas propriedades, o material é utilizado em diversos segmentos da indústria.',
                    style: TextStyle(fontSize: 12, color: _blue),
                  ),
                ],
              ),
            ),
            if (widget.admin)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _blue,
                  side: const BorderSide(color: _blue),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () async {
                  final result = await Navigator.push<List<String>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GerenciarAplicacoesScreen(
                        initialSelected: resin.applications,
                      ),
                    ),
                  );
                  if (result != null && mounted) {
                    final updated = resin.copyWith(applications: result);
                    await ResinService.instance.updateResin(resin.id, updated);
                    _fetchDetail();
                  }
                },
                icon: const PextAssetIcon(PextAssets.edit, size: 14),
                label: const Text('Gerenciar Aplicações', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _blue)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _buildApplicationsGrid(resin.applications),
      ],
    );
  }

  Widget _buildMetricCard({
    IconData? icon,
    String? iconAsset,
    required String label,
    required String value,
  }) {
    final iconWidget = iconAsset != null
        ? PextAssetIcon(iconAsset, size: 28)
        : Icon(icon ?? Icons.bubble_chart_outlined, size: 28, color: _blue);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: _blue,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _blue,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalFlowchart(List<ProductionStep> steps) {
    final list = steps.isNotEmpty
        ? (List<ProductionStep>.from(steps)..sort((a, b) => a.order.compareTo(b.order)))
        : [
            const ProductionStep(id: '1', order: 1, title: 'Matéria-Prima\n(Propeno)', iconName: 'hub'),
            const ProductionStep(id: '2', order: 2, title: 'Polimerização', iconName: 'reactor'),
            const ProductionStep(id: '3', order: 3, title: 'Granulação', iconName: 'grain'),
            const ProductionStep(id: '4', order: 4, title: 'Produto Final', iconName: 'product'),
          ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < list.length; i++) ...[
            Container(
              width: 84,
              height: 94,
              padding: const EdgeInsets.all(8),
              decoration: _cardDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIcon(list[i], size: 30, color: _blue),
                  const SizedBox(height: 6),
                  Text(
                    list[i].title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            if (i < list.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '→',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _blue,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepIcon(ProductionStep step, {required double size, required Color color}) {
    if (step.imageUrl != null && step.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          ApiClient.instance.mediaUrl(step.imageUrl),
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildFallbackFlowStepWidget(step, size: size, color: color),
        ),
      );
    }
    return _buildFallbackFlowStepWidget(step, size: size, color: color);
  }

  Widget _buildFallbackFlowStepWidget(ProductionStep step, {required double size, required Color color}) {
    final asset = _getAssetForFlowStep(step.iconName, step.title, step.order);
    if (asset != null) {
      return PextAssetIcon(asset, size: size);
    }
    return Icon(_getFlowStepIcon(step.iconName, step.order), size: size, color: color);
  }

  Widget _buildApplicationsGrid(List<String> applications) {
    final apps = applications.isNotEmpty
        ? applications
        : [
            'Embalagens',
            'Tampas e Fechamentos',
            'Fibras Têxteis',
            'Peças Automotivas',
            'Eletrodomésticos e utilidades',
            'Brinquedos e bens de consumo',
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 16) / 3;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: apps.map((app) {
            final meta = ApplicationCatalogService.get(app);
            Widget iconWidget;
            if (meta != null && meta.imageUrl != null && meta.imageUrl!.isNotEmpty) {
              iconWidget = ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  ApiClient.instance.mediaUrl(meta.imageUrl),
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _buildFallbackAppWidget(app, customIcon: meta.iconKey),
                ),
              );
            } else {
              iconWidget = _buildFallbackAppWidget(app, customIcon: meta?.iconKey);
            }

            return Container(
              width: itemWidth,
              height: 104,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              decoration: _cardDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconWidget,
                  const SizedBox(height: 8),
                  Text(
                    app,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _blue,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFallbackAppWidget(String app, {String? customIcon}) {
    final asset = _getAssetForApplication(app, customIcon: customIcon);
    if (asset != null) {
      return PextAssetIcon(asset, size: 32);
    }
    final icon = _getIconForApplication(app, customIcon: customIcon);
    return Icon(icon, color: _blue, size: 30);
  }

  // --- TAB 1: CARACTERÍSTICAS (NO BANNER! 3x3 Uniform Grid + Checkmark List) ---
  Widget _buildCharacteristicsTab(ResinModel resin) {
    final specs = [
      {'label': 'Densidade', 'val': resin.densityMetricFormatted, 'col': 0},
      {'label': 'Temp. de Fusão', 'val': resin.meltingPointMetricFormatted, 'col': 1},
      {'label': 'MFI', 'val': resin.mfiMetricFormatted, 'col': 2},
      {'label': 'HDT', 'val': _findDatum(resin, 'deflex') ?? '0,90 - 0,91 g/cm³', 'col': 0},
      {'label': 'Resistência à Tração', 'val': _findDatum(resin, 'tração') ?? '160 - 170°C', 'col': 1},
      {'label': 'EB', 'val': _findDatum(resin, 'alongamento') ?? '0,3 - 50 g/10 min', 'col': 2},
      {'label': 'Modulo de Elasticidade', 'val': _findDatum(resin, 'elasticidade') ?? '0,90 - 0,91 g/cm³', 'col': 0},
      {'label': 'Impacto Izod(23°C)', 'val': _findDatum(resin, 'izod') ?? '160 - 170°C', 'col': 1},
      {'label': 'Dureza Rockwell', 'val': _findDatum(resin, 'rockwell') ?? '0,3 - 50 g/10 min', 'col': 2},
    ];

    final mainChars = resin.mainCharacteristics.isNotEmpty
        ? resin.mainCharacteristics
        : [
            'Leve e resistente',
            'Boa resistência química',
            'Flexível e versátil',
            'Alta resistência à fadiga',
            'Baixo custo',
            'Reciclável',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dados técnicos',
          style: TextStyle(
            color: _blue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // 3-column strictly uniform grid: all boxes in every row have IDENTICAL height and width
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: specs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.88,
          ),
          itemBuilder: (context, index) {
            final s = specs[index];
            final col = s['col'] as int;
            final asset = col == 0
                ? PextAssets.density
                : col == 1
                    ? PextAssets.temperature
                    : PextAssets.mfi;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              decoration: _cardDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PextAssetIcon(asset, size: 26),
                  const SizedBox(height: 6),
                  Text(
                    s['label'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: _blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s['val'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _blue,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Principais características as vertical list with green checkmark (✔)
        const Text(
          'Principais características',
          style: TextStyle(
            color: _blue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mainChars.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    mainChars[index],
                    style: const TextStyle(
                      fontSize: 13,
                      color: _blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  String? _findDatum(ResinModel resin, String keyPart) {
    for (final d in resin.technicalData) {
      if (d.key.toLowerCase().contains(keyPart)) {
        return d.value.isNotEmpty ? d.value : null;
      }
    }
    return null;
  }

  // --- TAB 2: PROPRIEDADES (NO BANNER! Progress Bars + Observações Importantes) ---
  Widget _buildPropertiesTab(ResinModel resin) {
    final List<Map<String, dynamic>> propsToDisplay = [];

    if (resin.properties.isNotEmpty) {
      for (final rp in resin.properties) {
        final lvl = rp.level.trim();
        final lowerLvl = lvl.toLowerCase();
        final double val = switch (lowerLvl) {
          'alta' || 'alto' => 0.85,
          'baixa' || 'baixo' => 0.25,
          _ => 0.50,
        };
        propsToDisplay.add({
          'name': rp.name,
          'level': lvl.isNotEmpty ? lvl : 'Média',
          'val': val,
        });
      }
    } else {
      propsToDisplay.addAll([
        {'name': 'Resistência Química', 'level': 'Alta', 'val': 0.85},
        {'name': 'Resistência ao impacto', 'level': 'Média', 'val': 0.50},
        {'name': 'Rigidez', 'level': 'Alta', 'val': 0.85},
        {'name': 'Flexibilidade', 'level': 'Média', 'val': 0.50},
        {'name': 'Temperatura de uso contínuo', 'level': '80-100 °C', 'val': 0.35},
        {'name': 'Reciclabilidade', 'level': 'Alta', 'val': 0.85},
      ]);
    }

    final obsLines = resin.observations.isNotEmpty
        ? resin.observations.split('\n').where((l) => l.trim().isNotEmpty).toList()
        : [
            'Evitar contato prolongado com solventes aromáticos e clorados.',
            'Armazenar em local seco e protegido da luz solar direta.',
            'Para melhor performance, utilizar aditivos compatíveis com a aplicação.',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Propriedades principais',
          style: TextStyle(
            color: _blue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        ...propsToDisplay.map((p) {
          final name = p['name'] as String;
          final level = p['level'] as String;
          final val = (p['val'] as num).toDouble();

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: _blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: val,
                      color: _blue,
                      backgroundColor: const Color(0xFFE5E7EB),
                      minHeight: 7,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 55,
                  child: Text(
                    level,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _blue,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),

        // Observações importantes Info Card with prototype info icon
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  PextAssetIcon(PextAssets.info, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Observações importantes',
                    style: TextStyle(
                      color: _blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...obsLines.map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(Icons.circle, size: 6, color: _blue),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            line,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _blue,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 3: MAIS (NO BANNER! Documents, Videos) ---
  Widget _buildMoreTab(ResinModel resin) {
    final docs = resin.documents.isNotEmpty
        ? resin.documents
        : [
            const ResinDocument(id: '1', name: 'Ficha Técnica ...', fileSize: '1,2 MB', extension: 'PDF', urlOrPath: ''),
            const ResinDocument(id: '2', name: 'Ficha Técnica ...', fileSize: '1,2 MB', extension: 'PDF', urlOrPath: ''),
          ];

    final videos = resin.videos.isNotEmpty
        ? resin.videos
        : [
            const ResinVideo(id: '1', type: 'GALLERY', title: 'Processamento ....', duration: '03:20', urlOrPath: ''),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Documentos Relacionados',
          style: TextStyle(
            color: _blue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...docs.map((doc) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: _cardDecoration(),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border),
                    ),
                    alignment: Alignment.center,
                    child: const PextAssetIcon(PextAssets.pdf, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.name,
                          style: const TextStyle(
                            color: _blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${doc.extension} - ${doc.fileSize.isNotEmpty ? doc.fileSize : "1,2 MB"}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: _blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const PextAssetIcon(PextAssets.download, size: 22),
                    tooltip: 'Baixar',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Download de ${doc.name} iniciado...')),
                      );
                    },
                  ),
                ],
              ),
            )),
        const SizedBox(height: 20),

        const Text(
          'Video Relacionados',
          style: TextStyle(
            color: _blue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...videos.map((vid) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: _cardDecoration(),
              child: Row(
                children: [
                  Container(
                    width: 76,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const PextAssetIcon(PextAssets.videoWatch, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vid.title,
                          style: const TextStyle(
                            color: _blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vid.duration.isNotEmpty ? vid.duration : '03:20',
                          style: const TextStyle(
                            fontSize: 11,
                            color: _blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 22, color: _blue),
                ],
              ),
            )),
      ],
    );
  }
}

// ============================================================================
// DEDICATED MANAGEMENT FLOW 1: FLOWCHART STEPS WITH CUSTOM ICON SELECTION & IMAGE UPLOAD
// ============================================================================

class GerenciarEtapasFluxogramaScreen extends StatefulWidget {
  final List<ProductionStep> initialSteps;

  const GerenciarEtapasFluxogramaScreen({
    super.key,
    required this.initialSteps,
  });

  @override
  State<GerenciarEtapasFluxogramaScreen> createState() =>
      _GerenciarEtapasFluxogramaScreenState();
}

class _GerenciarEtapasFluxogramaScreenState
    extends State<GerenciarEtapasFluxogramaScreen> {
  late List<ProductionStep> _steps;

  final List<Map<String, dynamic>> _iconCatalog = [
    {'key': 'material', 'label': 'Matéria-Prima', 'asset': PextAssets.material},
    {'key': 'polimerization', 'label': 'Polimerização', 'asset': PextAssets.polimerization},
    {'key': 'granulation', 'label': 'Granulação', 'asset': PextAssets.granulation},
    {'key': 'final_product', 'label': 'Produto Final', 'asset': PextAssets.finalProduct},
    {'key': 'packaging', 'label': 'Embalagem', 'asset': PextAssets.packaging},
    {'key': 'car', 'label': 'Automotivo', 'asset': PextAssets.car},
    {'key': 'factory', 'label': 'Fábrica / Linha', 'icon': Icons.factory_outlined},
    {'key': 'science', 'label': 'Laboratório', 'icon': Icons.science_outlined},
    {'key': 'filter', 'label': 'Filtragem', 'icon': Icons.filter_alt_outlined},
    {'key': 'thermostat', 'label': 'Aquecimento', 'icon': Icons.thermostat_outlined},
    {'key': 'settings', 'label': 'Extrusão', 'icon': Icons.settings_suggest_outlined},
    {'key': 'water', 'label': 'Resfriamento', 'icon': Icons.water_drop_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _steps = List<ProductionStep>.from(widget.initialSteps);
  }

  void _addOrEditStep({ProductionStep? existing, int? index}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descController = TextEditingController(text: existing?.description ?? '');
    String selectedIcon = existing?.iconName ?? 'material';
    String? selectedImageUrl = existing?.imageUrl;

    final result = await showDialog<ProductionStep>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            existing == null ? 'Nova Etapa do Processo' : 'Editar Etapa',
            style: const TextStyle(color: _blue, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título da Etapa *',
                    hintText: 'Ex: Polimerização',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                    hintText: 'Detalhes da etapa...',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Escolher Ícone do Sistema:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _blue),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _iconCatalog.map((item) {
                    final isSel = selectedIcon == item['key'] && selectedImageUrl == null;
                    Widget iconWidget;
                    if (item['asset'] != null) {
                      iconWidget = PextAssetIcon(item['asset'] as String, size: 20);
                    } else {
                      iconWidget = Icon(
                        item['icon'] as IconData,
                        color: isSel ? _blue : _navy,
                        size: 18,
                      );
                    }

                    return InkWell(
                      onTap: () => setDialogState(() {
                        selectedIcon = item['key'] as String;
                        selectedImageUrl = null;
                      }),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFEAF2FF) : Colors.white,
                          border: Border.all(
                            color: isSel ? _blue : _border,
                            width: isSel ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            iconWidget,
                            const SizedBox(width: 5),
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSel ? _blue : _navy,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Ou carregar uma nova imagem/ícone:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _blue),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _blue,
                    side: const BorderSide(color: _blue),
                  ),
                  onPressed: () async {
                    try {
                      final picker = ImagePicker();
                      final file = await picker.pickImage(source: ImageSource.gallery);
                      if (file != null) {
                        final uploaded = await ApiClient.instance.uploadImage(file);
                        setDialogState(() {
                          selectedImageUrl = uploaded;
                        });
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Erro ao enviar imagem: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.add_photo_alternate, size: 18),
                  label: Text(selectedImageUrl != null ? 'Trocar Imagem' : 'Carregar Imagem da Galeria'),
                ),
                if (selectedImageUrl != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          ApiClient.instance.mediaUrl(selectedImageUrl),
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Imagem selecionada!', style: TextStyle(fontSize: 11, color: _green, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16, color: _red),
                        onPressed: () => setDialogState(() => selectedImageUrl = null),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _blue),
              onPressed: () {
                final t = titleController.text.trim();
                if (t.isEmpty) return;
                Navigator.pop(
                  ctx,
                  ProductionStep(
                    id: existing?.id ?? 'step_${DateTime.now().millisecondsSinceEpoch}',
                    order: existing?.order ?? (_steps.length + 1),
                    title: t,
                    description: descController.text.trim(),
                    iconName: selectedIcon,
                    imageUrl: selectedImageUrl,
                  ),
                );
              },
              child: Text(existing == null ? 'Adicionar' : 'Salvar'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (index != null) {
          _steps[index] = result;
        } else {
          _steps.add(result);
        }
        for (var i = 0; i < _steps.length; i++) {
          _steps[i] = _steps[i].copyWith(order: i + 1);
        }
      });
    }
  }

  void _confirmDeleteStep(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Etapa', style: TextStyle(color: _blue, fontWeight: FontWeight.bold)),
        content: Text('Deseja realmente excluir a etapa "${_steps[index].title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _red),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _steps.removeAt(index);
                for (var i = 0; i < _steps.length; i++) {
                  _steps[i] = _steps[i].copyWith(order: i + 1);
                }
              });
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepFallback(ProductionStep step) {
    final asset = _getAssetForFlowStep(step.iconName, step.title, step.order);
    if (asset != null) {
      return PextAssetIcon(asset, size: 24);
    }
    return Icon(_getFlowStepIcon(step.iconName, step.order), size: 24, color: _blue);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, _steps);
      },
      child: Scaffold(
        backgroundColor: _canvas,
        appBar: AppBar(
          backgroundColor: _canvas,
          surfaceTintColor: _canvas,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: _blue, size: 19),
            onPressed: () => Navigator.pop(context, _steps),
          ),
          title: const Text(
            'Gerenciar Fluxograma',
            style: TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Etapas Sequenciais:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: _blue, fontSize: 14),
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _blue,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => _addOrEditStep(),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Nova Etapa'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _steps.isEmpty
                    ? const Center(child: Text('Nenhuma etapa cadastrada no fluxograma.', style: TextStyle(color: _blue)))
                    : ReorderableListView.builder(
                        itemCount: _steps.length,
                        // ignore: deprecated_member_use
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = _steps.removeAt(oldIndex);
                            _steps.insert(newIndex, item);
                            for (var i = 0; i < _steps.length; i++) {
                              _steps[i] = _steps[i].copyWith(order: i + 1);
                            }
                          });
                        },
                        itemBuilder: (context, index) {
                          final step = _steps[index];
                          Widget iconItem;
                          if (step.imageUrl != null && step.imageUrl!.isNotEmpty) {
                            iconItem = ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                ApiClient.instance.mediaUrl(step.imageUrl),
                                width: 32,
                                height: 32,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => _buildStepFallback(step),
                              ),
                            );
                          } else {
                            iconItem = _buildStepFallback(step);
                          }

                          return Container(
                            key: ValueKey(step.id),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: _cardDecoration(),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: iconItem,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${step.order}. ${step.title.replaceAll('\n', ' ')}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _blue,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (step.description.isNotEmpty)
                                        Text(
                                          step.description,
                                          style: const TextStyle(
                                            color: _blue,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const PextAssetIcon(PextAssets.edit, size: 18),
                                  tooltip: 'Editar Etapa',
                                  onPressed: () => _addOrEditStep(existing: step, index: index),
                                ),
                                IconButton(
                                  icon: const PextAssetIcon(PextAssets.trash, size: 18),
                                  tooltip: 'Excluir Etapa',
                                  onPressed: () => _confirmDeleteStep(index),
                                ),
                                const Icon(Icons.drag_handle, color: Colors.grey),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _blue),
                  onPressed: () => Navigator.pop(context, _steps),
                  child: const Text(
                    'SALVAR E CONCLUIR',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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

// ============================================================================
// DEDICATED MANAGEMENT FLOW 2: APPLICATIONS WITH CUSTOM ICON & IMAGE REGISTRATION
// ============================================================================

class GerenciarAplicacoesScreen extends StatefulWidget {
  final List<String> initialSelected;

  const GerenciarAplicacoesScreen({
    super.key,
    required this.initialSelected,
  });

  @override
  State<GerenciarAplicacoesScreen> createState() =>
      _GerenciarAplicacoesScreenState();
}

class _GerenciarAplicacoesScreenState extends State<GerenciarAplicacoesScreen> {
  late Set<String> _selected;

  final List<String> _catalog = [
    'Embalagens',
    'Tampas e Fechamentos',
    'Fibras Têxteis',
    'Peças Automotivas',
    'Eletrodomésticos e utilidades',
    'Brinquedos e bens de consumo',
    'Tubos e Conexões',
    'Filmes Agrícolas',
    'Frascos e Garrafas',
    'Construção Civil',
  ];

  final List<Map<String, dynamic>> _appIconOptions = [
    {'key': 'packaging', 'label': 'Embalagens', 'asset': PextAssets.packaging},
    {'key': 'bottle', 'label': 'Tampas e Frascos', 'asset': PextAssets.jar},
    {'key': 'clothes', 'label': 'Fibras Têxteis', 'asset': PextAssets.fiber},
    {'key': 'car', 'label': 'Peças Automotivas', 'asset': PextAssets.car},
    {'key': 'washer', 'label': 'Eletrodomésticos', 'asset': PextAssets.houseMachines},
    {'key': 'toy', 'label': 'Brinquedos e Bens', 'asset': PextAssets.joys},
    {'key': 'material', 'label': 'Matéria-Prima / Resina', 'asset': PextAssets.material},
    {'key': 'pipe', 'label': 'Tubos / Encanamento', 'icon': Icons.plumbing_outlined},
    {'key': 'film', 'label': 'Filmes Agrícolas', 'icon': Icons.layers_outlined},
    {'key': 'med', 'label': 'Saúde / Medicina', 'icon': Icons.medical_services_outlined},
    {'key': 'tool', 'label': 'Construção Civil', 'icon': Icons.construction_outlined},
    {'key': 'furniture', 'label': 'Móveis / Utilidades', 'icon': Icons.chair_outlined},
    {'key': 'industry', 'label': 'Indústria Geral', 'icon': Icons.precision_manufacturing_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.initialSelected);
    for (final app in widget.initialSelected) {
      if (!_catalog.contains(app)) {
        _catalog.insert(0, app);
      }
    }
  }

  void _addOrEditApplication({String? existingName}) async {
    final existingMeta = existingName != null ? ApplicationCatalogService.get(existingName) : null;
    final textCtrl = TextEditingController(text: existingName ?? '');
    String selectedIconKey = existingMeta?.iconKey ?? 'packaging';
    String? selectedImageUrl = existingMeta?.imageUrl;

    final result = await showDialog<ApplicationMetadata>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            existingName == null ? 'Cadastrar Nova Aplicação' : 'Editar Aplicação',
            style: const TextStyle(color: _blue, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: textCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Aplicação *',
                    hintText: 'Ex: Painéis Solares',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Selecione um Ícone para esta Aplicação:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _blue),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _appIconOptions.map((item) {
                    final isSel = selectedIconKey == item['key'] && selectedImageUrl == null;
                    Widget iconWidget;
                    if (item['asset'] != null) {
                      iconWidget = PextAssetIcon(item['asset'] as String, size: 20);
                    } else {
                      iconWidget = Icon(item['icon'] as IconData, size: 18, color: isSel ? _blue : _navy);
                    }

                    return InkWell(
                      onTap: () => setDialogState(() {
                        selectedIconKey = item['key'] as String;
                        selectedImageUrl = null;
                      }),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFEAF2FF) : Colors.white,
                          border: Border.all(
                            color: isSel ? _blue : _border,
                            width: isSel ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            iconWidget,
                            const SizedBox(width: 5),
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSel ? _blue : _navy,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Ou carregar uma nova imagem/ícone:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _blue),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _blue,
                    side: const BorderSide(color: _blue),
                  ),
                  onPressed: () async {
                    try {
                      final picker = ImagePicker();
                      final file = await picker.pickImage(source: ImageSource.gallery);
                      if (file != null) {
                        final uploaded = await ApiClient.instance.uploadImage(file);
                        setDialogState(() {
                          selectedImageUrl = uploaded;
                        });
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Erro ao enviar imagem: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.add_photo_alternate, size: 18),
                  label: Text(selectedImageUrl != null ? 'Trocar Imagem' : 'Carregar Imagem da Galeria'),
                ),
                if (selectedImageUrl != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          ApiClient.instance.mediaUrl(selectedImageUrl),
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Imagem vinculada!', style: TextStyle(fontSize: 11, color: _green, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16, color: _red),
                        onPressed: () => setDialogState(() => selectedImageUrl = null),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _blue),
              onPressed: () {
                final t = textCtrl.text.trim();
                if (t.isEmpty) return;
                Navigator.pop(
                  ctx,
                  ApplicationMetadata(
                    title: t,
                    iconKey: selectedIconKey,
                    imageUrl: selectedImageUrl,
                  ),
                );
              },
              child: Text(existingName == null ? 'Cadastrar' : 'Salvar'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result.title.isNotEmpty) {
      final newTitle = result.title;
      ApplicationCatalogService.register(
        newTitle,
        iconKey: result.iconKey,
        imageUrl: result.imageUrl,
      );
      setState(() {
        if (existingName != null) {
          final idx = _catalog.indexOf(existingName);
          if (idx != -1) {
            _catalog[idx] = newTitle;
          }
          if (_selected.contains(existingName)) {
            _selected.remove(existingName);
            _selected.add(newTitle);
          }
        } else {
          if (!_catalog.contains(newTitle)) {
            _catalog.insert(0, newTitle);
          }
          _selected.add(newTitle);
        }
      });
    }
  }

  void _confirmDeleteApplication(String app) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Aplicação', style: TextStyle(color: _blue, fontWeight: FontWeight.bold)),
        content: Text('Deseja realmente excluir a aplicação "$app" do catálogo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _red),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _catalog.remove(app);
                _selected.remove(app);
              });
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAppItem(String app, String? customIcon) {
    final asset = _getAssetForApplication(app, customIcon: customIcon);
    if (asset != null) {
      return PextAssetIcon(asset, size: 24);
    }
    final icon = _getIconForApplication(app, customIcon: customIcon);
    return Icon(icon, color: _blue, size: 24);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, _selected.toList());
      },
      child: Scaffold(
        backgroundColor: _canvas,
        appBar: AppBar(
          backgroundColor: _canvas,
          surfaceTintColor: _canvas,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: _blue, size: 19),
            onPressed: () => Navigator.pop(context, _selected.toList()),
          ),
          title: const Text(
            'Gerenciar Aplicações',
            style: TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Catálogo de Aplicações:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: _blue, fontSize: 14),
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _blue,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => _addOrEditApplication(),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Cadastrar Nova'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _catalog.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final app = _catalog[index];
                    final isChecked = _selected.contains(app);
                    final meta = ApplicationCatalogService.get(app);

                    Widget iconWidget;
                    if (meta != null && meta.imageUrl != null && meta.imageUrl!.isNotEmpty) {
                      iconWidget = ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          ApiClient.instance.mediaUrl(meta.imageUrl),
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackAppItem(app, meta.iconKey),
                        ),
                      );
                    } else {
                      iconWidget = _buildFallbackAppItem(app, meta?.iconKey);
                    }

                    return Container(
                      decoration: _cardDecoration(),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isChecked,
                            activeColor: _blue,
                            visualDensity: VisualDensity.compact,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selected.add(app);
                                } else {
                                  _selected.remove(app);
                                }
                              });
                            },
                          ),
                          Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isChecked ? const Color(0xFFEAF2FF) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: iconWidget,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              app,
                              style: TextStyle(
                                color: _blue,
                                fontWeight: isChecked ? FontWeight.bold : FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const PextAssetIcon(PextAssets.edit, size: 18),
                            tooltip: 'Editar Aplicação',
                            onPressed: () => _addOrEditApplication(existingName: app),
                          ),
                          IconButton(
                            icon: const PextAssetIcon(PextAssets.trash, size: 18),
                            tooltip: 'Excluir Aplicação',
                            onPressed: () => _confirmDeleteApplication(app),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _blue),
                  onPressed: () => Navigator.pop(context, _selected.toList()),
                  child: const Text(
                    'SALVAR E CONCLUIR',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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

// ============================================================================
// 3. FORM SCREEN (CadastroResinaScreen / FormularioResinaScreen)
// ============================================================================

class ResinFormScreen extends StatefulWidget {
  final bool admin;
  final ResinModel? initialResin;

  const ResinFormScreen({
    super.key,
    this.admin = true,
    this.initialResin,
  });

  @override
  State<ResinFormScreen> createState() => _ResinFormScreenState();
}

class _ResinFormScreenState extends State<ResinFormScreen> {
  int _tab = 0;
  bool _saving = false;

  // Controllers for Visão Geral Tab
  late final TextEditingController _nameController;
  late final TextEditingController _technicalNameController;
  late final TextEditingController _acronymController;
  late final TextEditingController _descriptionController;

  // Category & Subcategory
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedSubcategory;

  Uint8List? _coverImageBytes;
  String? _coverImageFilename;
  String? _existingImageUrl;

  // Dynamic Flowchart Steps & Applications
  final List<ProductionStep> _flowSteps = [];
  final List<String> _applications = [];

  // Controllers for Características Tab (Standardized numeric fields)
  late final TextEditingController _densityController;
  late final TextEditingController _mfiController;
  late final TextEditingController _meltingTempController;
  late final TextEditingController _heatDeflectionController;
  late final TextEditingController _tensileStrengthController;
  late final TextEditingController _elongationController;
  late final TextEditingController _elasticModulusController;
  late final TextEditingController _izodImpactController;
  late final TextEditingController _rockwellHardnessController;

  // Principais Características list
  late final TextEditingController _mainCharInputController;
  final List<String> _mainCharacteristics = [];

  // Controllers for Propriedades Tab
  final Map<String, String> _propertyLevels = {
    'Rigidez': 'Média',
    'Resistência Química': 'Alta',
    'Resistência ao Impacto': 'Média',
    'Transparência': 'Baixa',
    'Processabilidade': 'Alta',
    'Reciclabilidade': 'Alta',
  };
  late final TextEditingController _observationsController;

  // Media for Mais Tab
  final List<ResinVideo> _videos = [];
  final List<ResinDocument> _documents = [];

  final _tabs = const [
    'Visão Geral',
    'Características',
    'Propriedades',
    'Mais',
  ];

  final List<String> _subcategoriesPreset = [
    'Virgem',
    'Reciclado Pós-Consumo (PCR)',
    'Reciclado Pós-Industrial (PIR)',
    'Composto',
    'Masterbatch',
    'Biopolímero',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    final init = widget.initialResin;

    // Tab 0
    _nameController = TextEditingController(text: init?.name ?? '');
    _technicalNameController = TextEditingController(text: init?.technicalName ?? '');
    _acronymController = TextEditingController(text: init?.acronym ?? '');
    _descriptionController = TextEditingController(text: init?.description ?? '');
    _selectedCategoryId = init?.categoryId;
    _selectedCategoryName = init?.categoryName;
    _selectedSubcategory = init?.subcategoryId ?? init?.subcategoryName;
    _existingImageUrl = init?.imageUrl;

    // Flow steps & applications
    if (init != null) {
      _flowSteps.addAll(init.productionProcess);
      _applications.addAll(init.applications);
    } else {
      _flowSteps.addAll([
        const ProductionStep(id: 'step_1', order: 1, title: 'Matéria-Prima\n(Propeno)', iconName: 'hub'),
        const ProductionStep(id: 'step_2', order: 2, title: 'Polimerização', iconName: 'reactor'),
        const ProductionStep(id: 'step_3', order: 3, title: 'Granulação', iconName: 'grain'),
        const ProductionStep(id: 'step_4', order: 4, title: 'Produto Final', iconName: 'product'),
      ]);
      _applications.addAll([
        'Embalagens',
        'Tampas e Fechamentos',
        'Fibras Têxteis',
        'Peças Automotivas',
        'Eletrodomésticos e utilidades',
        'Brinquedos e bens de consumo',
      ]);
    }

    // Tab 1: Characteristics
    _densityController = TextEditingController();
    _mfiController = TextEditingController();
    _meltingTempController = TextEditingController();
    _heatDeflectionController = TextEditingController();
    _tensileStrengthController = TextEditingController();
    _elongationController = TextEditingController();
    _elasticModulusController = TextEditingController();
    _izodImpactController = TextEditingController();
    _rockwellHardnessController = TextEditingController();
    _mainCharInputController = TextEditingController();

    if (init != null) {
      _populateCharacteristicsFromExisting(init);
    } else {
      _densityController.text = '0.90 - 0.91';
      _mfiController.text = '0.3 - 50';
      _meltingTempController.text = '160 - 170';
      _heatDeflectionController.text = '0.90 - 0.91';
      _tensileStrengthController.text = '160 - 170';
      _elongationController.text = '0.3 - 50';
      _elasticModulusController.text = '0.90 - 0.91';
      _izodImpactController.text = '160 - 170';
      _rockwellHardnessController.text = '0.3 - 50';
      _mainCharacteristics.addAll([
        'Leve e resistente',
        'Boa resistência química',
        'Flexível e versátil',
        'Alta resistência à fadiga',
        'Baixo custo',
        'Reciclável',
      ]);
    }

    // Tab 2: Properties
    _observationsController = TextEditingController(text: init?.observations ?? '');
    if (init != null) {
      for (final prop in init.properties) {
        _propertyLevels[prop.name] = prop.level;
      }
    }

    // Tab 3: More
    if (init != null) {
      _videos.addAll(init.videos);
      _documents.addAll(init.documents);
    }

    _loadCategories();
  }

  void _populateCharacteristicsFromExisting(ResinModel init) {
    for (final datum in init.technicalData) {
      final k = datum.key.toLowerCase();
      final v = datum.value.replaceAll(RegExp(r'[^0-9.,\-\s]'), '').trim();
      if (k.contains('densidade')) {
        _densityController.text = v.isNotEmpty ? v : datum.value;
      } else if (k.contains('mfi') || k.contains('flu')) {
        _mfiController.text = v.isNotEmpty ? v : datum.value;
      } else if (k.contains('deflex') || k.contains('hdt')) {
        _heatDeflectionController.text = v.isNotEmpty ? v : datum.value;
      } else if (k.contains('fus')) {
        _meltingTempController.text = v.isNotEmpty ? v : datum.value;
      } else if (k.contains('tração') || k.contains('tracao')) {
        _tensileStrengthController.text = v.isNotEmpty ? v : datum.value;
      } else if (k.contains('alongamento') || k.contains('ruptura') || k == 'eb') {
        _elongationController.text = v.isNotEmpty ? v : datum.value;
      } else if (k.contains('elasticidade') || k.contains('módulo') || k.contains('modulo')) {
        _elasticModulusController.text = v.isNotEmpty ? v : datum.value;
      } else if (k.contains('izod') || k.contains('impacto')) {
        _izodImpactController.text = v.isNotEmpty ? v : datum.value;
      } else if (k.contains('rockwell') || k.contains('dureza')) {
        _rockwellHardnessController.text = datum.value;
      }
    }
    _mainCharacteristics.addAll(init.mainCharacteristics);
  }

  Future<void> _loadCategories() async {
    final cats = await ResinService.instance.loadCategories();
    if (mounted && _selectedCategoryId == null && cats.isNotEmpty) {
      setState(() {
        _selectedCategoryId = cats.first.id;
        _selectedCategoryName = cats.first.name;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _technicalNameController.dispose();
    _acronymController.dispose();
    _descriptionController.dispose();

    _densityController.dispose();
    _mfiController.dispose();
    _meltingTempController.dispose();
    _heatDeflectionController.dispose();
    _tensileStrengthController.dispose();
    _elongationController.dispose();
    _elasticModulusController.dispose();
    _izodImpactController.dispose();
    _rockwellHardnessController.dispose();
    _mainCharInputController.dispose();

    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _coverImageBytes = bytes;
        _coverImageFilename = file.name;
      });
    }
  }

  Future<void> _openManageFlowSteps() async {
    final result = await Navigator.push<List<ProductionStep>>(
      context,
      MaterialPageRoute(
        builder: (_) => GerenciarEtapasFluxogramaScreen(
          initialSteps: _flowSteps,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _flowSteps
          ..clear()
          ..addAll(result);
      });
    }
  }

  Future<void> _openManageApplications() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => GerenciarAplicacoesScreen(
          initialSelected: _applications,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _applications
          ..clear()
          ..addAll(result);
      });
    }
  }

  void _addMainCharacteristic() {
    final text = _mainCharInputController.text.trim();
    if (text.isNotEmpty && !_mainCharacteristics.contains(text)) {
      setState(() {
        _mainCharacteristics.add(text);
        _mainCharInputController.clear();
      });
    }
  }

  Future<void> _pickDocument() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          final doc = await ResinService.instance.uploadDocument(
            bytes: bytes,
            filename: file.name,
          );
          setState(() => _documents.add(doc));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao anexar documento: $e')),
        );
      }
    }
  }

  Future<void> _openAddVideoDialog() async {
    final titleCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    final result = await showDialog<ResinVideo>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Adicionar Vídeo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título do Vídeo *',
                  hintText: 'Ex: Demonstração de Extrusão',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: durationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Duração (ex: 04:30)',
                  hintText: '04:30',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: urlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Link do Vídeo (YouTube ou URL)',
                  hintText: 'https://youtube.com/...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _blue),
            onPressed: () {
              final title = titleCtrl.text.trim();
              final url = urlCtrl.text.trim();
              if (title.isEmpty) return;
              if (!ctx.mounted) return;
              Navigator.pop(
                ctx,
                ResinVideo(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: 'YOUTUBE',
                  title: title,
                  duration: durationCtrl.text.trim(),
                  urlOrPath: url.isNotEmpty ? url : 'https://youtube.com',
                ),
              );
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() => _videos.add(result));
    }
  }

  List<TechnicalDatum> _buildTechnicalDataList() {
    final List<TechnicalDatum> list = [];

    void addIfFilled(String key, String val, String suffix) {
      final trimmed = val.trim();
      if (trimmed.isNotEmpty) {
        final formatted = trimmed.contains(suffix) ? trimmed : '$trimmed $suffix';
        list.add(TechnicalDatum(
          id: 'tech_${list.length + 1}',
          key: key,
          value: formatted.trim(),
        ));
      }
    }

    addIfFilled('Densidade:', _densityController.text, 'g/cm³');
    addIfFilled('Índice de Fluídez (MFI):', _mfiController.text, 'g/10 min');
    addIfFilled('Temperatura de Fusão:', _meltingTempController.text, '°C');
    addIfFilled('Temperatura de deflexão térmica:', _heatDeflectionController.text, '°C');
    addIfFilled('Resistência à Tração:', _tensileStrengthController.text, 'MPa');
    addIfFilled('Alongamento na ruptura:', _elongationController.text, '%');
    addIfFilled('Módulo de Elasticidade:', _elasticModulusController.text, 'MPa');
    addIfFilled('Impacto Izod (23°C):', _izodImpactController.text, 'kJ/m²');
    if (_rockwellHardnessController.text.trim().isNotEmpty) {
      list.add(TechnicalDatum(
        id: 'tech_${list.length + 1}',
        key: 'Dureza Rockwell:',
        value: _rockwellHardnessController.text.trim(),
      ));
    }

    return list;
  }

  Future<void> _saveResin() async {
    final name = _nameController.text.trim();
    final acronym = _acronymController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o Nome do Material.')),
      );
      setState(() => _tab = 0);
      return;
    }

    if (acronym.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a Sigla (Ex: PEBD, PP).')),
      );
      setState(() => _tab = 0);
      return;
    }

    setState(() => _saving = true);

    try {
      final propertiesList = _propertyLevels.entries
          .map((e) => ResinProperty(id: e.key, name: e.key, level: e.value))
          .toList();

      final techData = _buildTechnicalDataList();

      final resinModel = ResinModel(
        id: widget.initialResin?.id ?? '',
        name: name,
        technicalName: _technicalNameController.text.trim(),
        acronym: acronym,
        categoryId: _selectedCategoryId,
        categoryName: _selectedCategoryName,
        subcategoryId: _selectedSubcategory,
        subcategoryName: _selectedSubcategory,
        imageUrl: _existingImageUrl,
        description: _descriptionController.text.trim(),
        productionProcess: _flowSteps,
        applications: _applications,
        technicalData: techData,
        properties: propertiesList,
        observations: _observationsController.text.trim(),
        mainCharacteristics: _mainCharacteristics,
        videos: _videos,
        documents: _documents,
        isFavorite: widget.initialResin?.isFavorite ?? false,
      );

      if (widget.initialResin == null) {
        await ResinService.instance.createResin(
          resinModel,
          imageBytes: _coverImageBytes,
          imageFilename: _coverImageFilename,
        );
      } else {
        await ResinService.instance.updateResin(
          widget.initialResin!.id,
          resinModel,
          imageBytes: _coverImageBytes,
          imageFilename: _coverImageFilename,
        );
      }

      if (mounted) {
        setState(() => _saving = false);
        _showSuccessConfirmationModal();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar resina: $e')),
        );
      }
    }
  }

  void _showSuccessConfirmationModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF1B873F), size: 28),
            SizedBox(width: 10),
            Text(
              'Sucesso!',
              style: TextStyle(fontWeight: FontWeight.bold, color: _navy),
            ),
          ],
        ),
        content: const Text(
          'Resina adicionada com sucesso!',
          style: TextStyle(fontSize: 15, color: Color(0xFF374151)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (!dialogCtx.mounted) return;
              Navigator.pop(dialogCtx);
              setState(() {
                _nameController.clear();
                _technicalNameController.clear();
                _acronymController.clear();
                _descriptionController.clear();
                _densityController.clear();
                _mfiController.clear();
                _meltingTempController.clear();
                _heatDeflectionController.clear();
                _tensileStrengthController.clear();
                _elongationController.clear();
                _elasticModulusController.clear();
                _izodImpactController.clear();
                _rockwellHardnessController.clear();
                _mainCharInputController.clear();
                _mainCharacteristics.clear();
                _observationsController.clear();
                _coverImageBytes = null;
                _coverImageFilename = null;
                _tab = 0;
              });
            },
            child: const Text(
              'Adicionar mais',
              style: TextStyle(color: _blue, fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _blue),
            onPressed: () {
              if (!dialogCtx.mounted) return;
              Navigator.pop(dialogCtx);
              if (mounted) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.initialResin == null
        ? 'Cadastrar Resina'
        : 'Editar Resina';

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: _canvas,
        appBar: AppBar(
          backgroundColor: _canvas,
          surfaceTintColor: _canvas,
          leading: IconButton(
            tooltip: 'Voltar',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: _blue, size: 19),
          ),
          centerTitle: true,
          title: Text(
            title,
            style: const TextStyle(
              color: _blue,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
          child: Column(
            children: [
              _TabsBar(
                tabs: _tabs,
                selected: _tab,
                onChanged: (index) => setState(() => _tab = index),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildFormContent(),
                ),
              ),
              const SizedBox(height: 10),
              // Fixed full-width solid primary blue button labeled "CADASTRAR" at bottom of every tab
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _blue),
                  onPressed: _saving ? null : _saveResin,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.initialResin == null
                              ? 'CADASTRAR'
                              : 'SALVAR ALTERAÇÕES',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _ResinBottomBar(admin: widget.admin, selected: 2),
      ),
    );
  }

  Widget _buildFormContent() {
    if (_tab == 0) return _buildFormOverview();
    if (_tab == 1) return _buildFormCharacteristics();
    if (_tab == 2) return _buildFormProperties();
    return _buildFormMore();
  }

  // --- TAB 0: VISÃO GERAL ---
  Widget _buildFormOverview() {
    final categories = ResinService.instance.categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover Image Selector
        Center(
          child: InkWell(
            onTap: _pickCoverImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: _coverImageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(_coverImageBytes!, fit: BoxFit.cover),
                    )
                  : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            ApiClient.instance.mediaUrl(_existingImageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.add_photo_alternate, size: 40),
                            ),
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 36, color: _blue),
                            SizedBox(height: 6),
                            Text(
                              'Selecionar Foto de Capa',
                              style: TextStyle(
                                  color: _blue, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _formField(
          label: 'Nome do Material:',
          hint: 'Ex: Polietileno de Baixa Densidade',
          controller: _nameController,
        ),
        _formField(
          label: 'Nome técnico (opcional):',
          hint: 'Ex: Polietileno homopolímero linear',
          controller: _technicalNameController,
        ),
        _formField(
          label: 'Sigla:',
          hint: 'Ex: PEBD, PP, PEAD',
          controller: _acronymController,
        ),
        _formField(
          label: 'Descrição curta (multiline):',
          hint: 'Descreva a resina, características básicas e propriedades...',
          controller: _descriptionController,
          lines: 3,
        ),
        // Scoped Category Dropdown
        const Text(
          'Categoria:',
          style: TextStyle(
            color: _blue,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategoryId,
          items: categories.map((cat) {
            return DropdownMenuItem<String>(
              value: cat.id,
              child: Text(cat.name),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedCategoryId = val;
              final found = categories.where((c) => c.id == val);
              if (found.isNotEmpty) {
                _selectedCategoryName = found.first.name;
              }
            });
          },
          decoration: const InputDecoration(
            hintText: 'Selecione a categoria',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: _border),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Subcategory Dropdown (Optional)
        const Text(
          'Subcategoria (opcional):',
          style: TextStyle(
            color: _blue,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          initialValue: _subcategoriesPreset.contains(_selectedSubcategory)
              ? _selectedSubcategory
              : null,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Nenhuma subcategoria'),
            ),
            ..._subcategoriesPreset.map((sub) {
              return DropdownMenuItem<String>(
                value: sub,
                child: Text(sub),
              );
            }),
          ],
          onChanged: (val) {
            setState(() => _selectedSubcategory = val);
          },
          decoration: const InputDecoration(
            hintText: 'Selecione a subcategoria',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: _border),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Dedicated Flowchart Steps Management Flow Card (NO OVERFLOW: Row wrapped in Expanded)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fluxograma de Processos',
                          style: TextStyle(
                            color: _blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${_flowSteps.length} etapa(s) configurada(s)',
                          style: const TextStyle(fontSize: 12, color: _blue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _blue,
                      side: const BorderSide(color: _blue),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: _openManageFlowSteps,
                    icon: const PextAssetIcon(PextAssets.edit, size: 14),
                    label: const Text('Gerenciar Etapas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _blue)),
                  ),
                ],
              ),
              if (_flowSteps.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _flowSteps.map((s) => Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: const Color(0xFFEAF2FF),
                    avatar: Icon(_getFlowStepIcon(s.iconName, s.order), size: 16, color: _blue),
                    label: Text(s.title.replaceAll('\n', ' '), style: const TextStyle(fontSize: 11, color: _blue)),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Dedicated Applications Management Flow Card (NO OVERFLOW: Row wrapped in Expanded)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aplicações da Resina',
                          style: TextStyle(
                            color: _blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${_applications.length} aplicação(ões) selecionada(s)',
                          style: const TextStyle(fontSize: 12, color: _blue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _blue,
                      side: const BorderSide(color: _blue),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: _openManageApplications,
                    icon: const PextAssetIcon(PextAssets.edit, size: 14),
                    label: const Text('Gerenciar Aplicações', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _blue)),
                  ),
                ],
              ),
              if (_applications.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _applications.map((app) => Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: const Color(0xFFF0FDF4),
                    avatar: Icon(_getIconForApplication(app), size: 16, color: _green),
                    label: Text(app, style: const TextStyle(fontSize: 11, color: _green)),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // --- TAB 1: CARACTERÍSTICAS (Standardized specs + Checkmark List) ---
  Widget _buildFormCharacteristics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading('Especificações Técnicas:'),
        const SizedBox(height: 6),

        _standardNumericField(
          label: 'Densidade:',
          suffix: 'g/cm³',
          controller: _densityController,
        ),
        _standardNumericField(
          label: 'Índice de Fluídez (MFI):',
          suffix: 'g/10 min',
          controller: _mfiController,
        ),
        _standardNumericField(
          label: 'Temperatura de Fusão:',
          suffix: '°C',
          controller: _meltingTempController,
        ),
        _standardNumericField(
          label: 'Temperatura de deflexão térmica:',
          suffix: '°C',
          controller: _heatDeflectionController,
        ),
        _standardNumericField(
          label: 'Resistência à Tração:',
          suffix: 'MPa',
          controller: _tensileStrengthController,
        ),
        _standardNumericField(
          label: 'Alongamento na ruptura:',
          suffix: '%',
          controller: _elongationController,
        ),
        _standardNumericField(
          label: 'Módulo de Elasticidade:',
          suffix: 'MPa',
          controller: _elasticModulusController,
        ),
        _standardNumericField(
          label: 'Impacto Izod (23°C):',
          suffix: 'kJ/m²',
          controller: _izodImpactController,
        ),
        _standardNumericField(
          label: 'Dureza Rockwell:',
          suffix: '',
          controller: _rockwellHardnessController,
          hintText: 'Ex: Escala R ou R100',
        ),

        const SizedBox(height: 20),
        _sectionHeading('Principais Características:'),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _mainCharInputController,
                decoration: const InputDecoration(
                  hintText: 'Ex: Leve e resistente',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: _border),
                  ),
                ),
                onSubmitted: (_) => _addMainCharacteristic(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _blue),
              onPressed: _addMainCharacteristic,
              child: const Text('Adicionar'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Displayed as a clean list with green checkmark (✔) and delete button
        if (_mainCharacteristics.isEmpty)
          const Text(
            'Nenhuma característica adicionada.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _mainCharacteristics.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final item = _mainCharacteristics[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: _cardDecoration(),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _blue,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: _red, size: 18),
                      onPressed: () => setState(() => _mainCharacteristics.removeAt(index)),
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _standardNumericField({
    required String label,
    required String suffix,
    required TextEditingController controller,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _navy,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: suffix.isNotEmpty
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            decoration: InputDecoration(
              hintText: hintText ?? '0.0',
              filled: true,
              fillColor: Colors.white,
              suffixText: suffix.isNotEmpty ? suffix : null,
              suffixStyle: const TextStyle(
                color: _blue,
                fontWeight: FontWeight.bold,
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: _border),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: PROPRIEDADES ---
  Widget _buildFormProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading('Propriedades:'),
        const SizedBox(height: 10),
        ..._propertyLevels.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _navy,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 7,
                  child: Row(
                    children: ['Baixa', 'Média', 'Alta'].map((lvl) {
                      final active = entry.value == lvl;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 36),
                              foregroundColor: active ? _blue : Colors.black87,
                              side: BorderSide(
                                color: active ? _blue : _border,
                                width: active ? 1.5 : 1,
                              ),
                              backgroundColor: active
                                  ? const Color(0xFFEAF2FF)
                                  : Colors.white,
                            ),
                            onPressed: () {
                              setState(() => _propertyLevels[entry.key] = lvl);
                            },
                            child: Text(
                              lvl,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight:
                                    active ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        _sectionHeading('Observações:'),
        const SizedBox(height: 6),
        TextField(
          controller: _observationsController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Ex: Material irregular na matriz...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: _border),
            ),
          ),
        ),
      ],
    );
  }

  // --- TAB 3: MAIS ---
  Widget _buildFormMore() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading('Documentos:'),
        const SizedBox(height: 6),
        if (_documents.isEmpty)
          const Text(
            'Nenhum documento anexado.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          )
        else
          ..._documents.map((doc) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: _cardDecoration(),
                child: Row(
                  children: [
                    const PextAssetIcon(PextAssets.pdf, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.name,
                            style: const TextStyle(
                              color: _blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${doc.extension} • ${doc.fileSize}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: _blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: _red, size: 20),
                      onPressed: () =>
                          setState(() => _documents.remove(doc)),
                    ),
                  ],
                ),
              )),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _blue,
              side: const BorderSide(color: _blue),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _pickDocument,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Anexar Documento (PDF)'),
          ),
        ),
        const SizedBox(height: 24),

        _sectionHeading('Vídeos:'),
        const SizedBox(height: 6),
        if (_videos.isEmpty)
          const Text(
            'Nenhum vídeo anexado.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          )
        else
          ..._videos.map((vid) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: _cardDecoration(),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const PextAssetIcon(PextAssets.videoWatch, size: 26),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vid.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _blue,
                              fontSize: 13,
                            ),
                          ),
                          if (vid.duration.isNotEmpty)
                            Text(
                              vid.duration,
                              style: const TextStyle(
                                fontSize: 11,
                                color: _blue,
                              ),
                            ),
                          Text(
                            vid.urlOrPath,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: _blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: _red, size: 20),
                      onPressed: () => setState(() => _videos.remove(vid)),
                    ),
                  ],
                ),
              )),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _blue,
              side: const BorderSide(color: _blue),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _openAddVideoDialog,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Adicionar Vídeo'),
          ),
        ),
      ],
    );
  }

  Widget _formField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _blue,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            maxLines: lines,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: _border),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 4. SHARED UTILITIES & ICONS
// ============================================================================

IconData _getFlowStepIcon(String iconName, int order) {
  final lower = iconName.toLowerCase();
  if (lower.contains('hub') || lower.contains('molecul') || lower.contains('materia') || lower.contains('matéria') || lower.contains('propen')) {
    return Icons.hub_outlined;
  }
  if (lower.contains('reactor') || lower.contains('polimeriz') || lower.contains('reator') || lower.contains('tank')) {
    return Icons.propane_tank_outlined;
  }
  if (lower.contains('grain') || lower.contains('granul') || lower.contains('pellet') || lower.contains('grao')) {
    return Icons.grain_outlined;
  }
  if (lower.contains('product') || lower.contains('produto') || lower.contains('final') || lower.contains('bag') || lower.contains('sacola')) {
    return Icons.shopping_bag_outlined;
  }
  if (lower.contains('factory') || lower.contains('fabrica')) {
    return Icons.factory_outlined;
  }
  if (lower.contains('science') || lower.contains('quimic') || lower.contains('químic')) {
    return Icons.science_outlined;
  }
  if (lower.contains('filter') || lower.contains('filtr')) {
    return Icons.filter_alt_outlined;
  }
  if (lower.contains('thermostat') || lower.contains('heat') || lower.contains('term')) {
    return Icons.thermostat_outlined;
  }
  if (lower.contains('speed') || lower.contains('veloc')) {
    return Icons.speed_outlined;
  }
  if (lower.contains('settings') || lower.contains('extrus')) {
    return Icons.settings_suggest_outlined;
  }
  if (lower.contains('water') || lower.contains('agua') || lower.contains('água')) {
    return Icons.water_drop_outlined;
  }
  if (lower.contains('inventory') || lower.contains('caixa') || lower.contains('estoque')) {
    return Icons.inventory_2_outlined;
  }

  // Fallback defaults based on step order
  return switch (order) {
    1 => Icons.hub_outlined,
    2 => Icons.propane_tank_outlined,
    3 => Icons.grain_outlined,
    4 => Icons.shopping_bag_outlined,
    _ => Icons.factory_outlined,
  };
}

IconData _getIconForApplication(String name, {String? customIcon}) {
  if (customIcon != null && customIcon.isNotEmpty) {
    final mapped = _mapCustomIconKey(customIcon);
    if (mapped != null) return mapped;
  }

  final lower = name.toLowerCase();
  if (lower.contains('embalag') || lower.contains('filme') || lower.contains('sacol') || lower.contains('pouch')) {
    return Icons.inventory_2_outlined;
  }
  if (lower.contains('tampa') || lower.contains('fechament') || lower.contains('garraf')) {
    return Icons.radio_button_checked_rounded;
  }
  if (lower.contains('fibra') || lower.contains('têxtil') || lower.contains('textil') || lower.contains('tecido')) {
    return Icons.checkroom_outlined;
  }
  if (lower.contains('auto') || lower.contains('veícul') || lower.contains('carro') || lower.contains('peça')) {
    return Icons.directions_car_outlined;
  }
  if (lower.contains('eletro') || lower.contains('utilidade') || lower.contains('casa') || lower.contains('cozinha') || lower.contains('lavadora')) {
    return Icons.local_laundry_service_outlined;
  }
  if (lower.contains('brinqued') || lower.contains('lazer') || lower.contains('infantil') || lower.contains('bens')) {
    return Icons.toys_outlined;
  }
  if (lower.contains('tubo') || lower.contains('conex') || lower.contains('can') || lower.contains('constru')) {
    return Icons.plumbing_outlined;
  }
  if (lower.contains('hospital') || lower.contains('médic') || lower.contains('saúde')) {
    return Icons.medical_services_outlined;
  }
  if (lower.contains('solar') || lower.contains('energia') || lower.contains('painel')) {
    return Icons.solar_power_outlined;
  }
  return Icons.widgets_outlined;
}

IconData? _mapCustomIconKey(String key) {
  return switch (key) {
    'car' => Icons.directions_car_outlined,
    'box' => Icons.inventory_2_outlined,
    'bottle' => Icons.radio_button_checked_rounded,
    'clothes' => Icons.checkroom_outlined,
    'washer' => Icons.local_laundry_service_outlined,
    'toy' => Icons.toys_outlined,
    'pipe' => Icons.plumbing_outlined,
    'film' => Icons.layers_outlined,
    'med' => Icons.medical_services_outlined,
    'tool' => Icons.construction_outlined,
    'chip' => Icons.memory_outlined,
    'furniture' => Icons.chair_outlined,
    'food' => Icons.restaurant_outlined,
    'cosmetic' => Icons.spa_outlined,
    'shoe' => Icons.roller_skating_outlined,
    'industry' => Icons.precision_manufacturing_outlined,
    _ => null,
  };
}

class _TabsBar extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChanged;

  const _TabsBar({
    required this.tabs,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final isSelected = entry.key == selected;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(entry.key),
              child: Column(
                children: [
                  Text(
                    entry.value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? _blue : const Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 2,
                    width: double.infinity,
                    color: isSelected ? _blue : _border,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, size: 19, color: _blue),
      ),
    );
  }
}

Widget _sectionHeading(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: _blue,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border),
    );

// ============================================================================
// 5. NAVIGATION BOTTOM BAR
// ============================================================================

class _ResinBottomBar extends StatelessWidget {
  final bool admin;
  final int selected;

  const _ResinBottomBar({required this.admin, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _ResinNavItem(
              asset: PextAssets.education,
              activeAsset: PextAssets.educationActive,
              text: 'Treinamento',
              active: selected == 0,
              onTap: () => _goToRoot(context, PextRoutes.training, admin: admin),
            ),
            _ResinNavItem(
              asset: admin ? PextAssets.dashboard : PextAssets.heart,
              activeAsset:
                  admin ? PextAssets.dashboardActive : PextAssets.heartActive,
              text: admin ? 'Dashboard' : 'Favoritos',
              active: selected == 1,
              onTap: () => _goToRoot(
                context,
                admin ? PextRoutes.dashboard : PextRoutes.favorites,
                admin: admin,
              ),
            ),
            _ResinNavItem(
              asset: PextAssets.home,
              activeAsset: PextAssets.homeActive,
              text: 'Home',
              active: selected == 2,
              onTap: () => _goToRoot(context, PextRoutes.home, admin: admin),
            ),
            _ResinNavItem(
              asset: PextAssets.chat,
              activeAsset: PextAssets.chatActive,
              text: 'Chat',
              active: selected == 3,
              onTap: () => _goToRoot(context, PextRoutes.chat, admin: admin),
            ),
            _ResinNavItem(
              asset: PextAssets.profile,
              activeAsset: PextAssets.profileActive,
              text: 'Perfil',
              active: selected == 4,
              onTap: () => _goToRoot(context, PextRoutes.profile, admin: admin),
            ),
          ],
        ),
      ),
    );
  }

  void _goToRoot(BuildContext context, String route, {bool admin = false}) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      route,
      (currentRoute) => false,
      arguments: PextRouteArgs(admin: admin),
    );
  }
}

class _ResinNavItem extends StatelessWidget {
  final String asset, activeAsset, text;
  final bool active;
  final VoidCallback onTap;

  const _ResinNavItem({
    required this.asset,
    required this.activeAsset,
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PextAssetIcon(active ? activeAsset : asset, size: 28),
              Text(
                text,
                style: TextStyle(
                  fontSize: 10,
                  color: active ? _blue : const Color(0xFF363C46),
                  fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
