import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/app_category.dart';
import '../../services/api_client.dart';
import '../../widgets/pext_asset_icon.dart';

const _blue = Color(0xFF053488);
const _border = Color(0xFFE5E7EB);

String? _getAssetForIconKey(String key) {
  switch (key) {
    case 'material':
      return PextAssets.material;
    case 'polimerization':
      return PextAssets.polimerization;
    case 'granulation':
      return PextAssets.granulation;
    case 'final_product':
      return PextAssets.finalProduct;
    case 'packaging':
      return PextAssets.packaging;
    case 'car':
      return PextAssets.car;
    case 'density':
      return PextAssets.density;
    case 'temperature':
    case 'high_temperature':
      return PextAssets.temperature;
    case 'mfi':
      return PextAssets.mfi;
    case 'fiber':
      return PextAssets.fiber;
    case 'jar':
      return PextAssets.jar;
    case 'joys':
      return PextAssets.joys;
    case 'house_machines':
      return PextAssets.houseMachines;
    case 'pipes':
    case 'tubos':
      return PextAssets.pipes;
    case 'lab':
    case 'quimica':
      return PextAssets.lab;
    case 'factory':
    case 'industry':
    case 'industrial':
    case 'industrial_geral':
      return PextAssets.factory;
    case 'furniture':
    case 'moveis':
      return PextAssets.furniture;
    case 'construction':
    case 'construcao':
    case 'construcao_civil':
      return PextAssets.construction;
    case 'health':
    case 'saude':
    case 'medical':
      return PextAssets.health;
    case 'agricultural_films':
    case 'filmes_agricolas':
      return PextAssets.agriculturalFilms;
    case 'filtration':
    case 'filter':
    case 'filtragem':
      return PextAssets.filtration;
    case 'cooling':
    case 'resfriamento':
      return PextAssets.cooling;
    case 'extrusion':
    case 'extrusao':
      return PextAssets.extrusion;
    default:
      return null;
  }
}

Widget buildCategoryIcon(AppCategory category, {double size = 20}) {
  if (category.imageUrl != null && category.imageUrl!.isNotEmpty) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        ApiClient.instance.mediaUrl(category.imageUrl),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.category_outlined, size: size, color: _blue),
      ),
    );
  }
  if (category.iconKey != null && category.iconKey!.isNotEmpty) {
    final asset = _getAssetForIconKey(category.iconKey!);
    if (asset != null) {
      return PextAssetIcon(asset, size: size);
    }
  }
  return Icon(Icons.school_outlined, size: size, color: _blue);
}

class ScopedCategoryPicker extends StatefulWidget {
  final CategoryScope scope;
  final String? value;
  final ValueChanged<String?> onChanged;

  const ScopedCategoryPicker({
    super.key,
    required this.scope,
    required this.value,
    required this.onChanged,
  });

  @override
  State<ScopedCategoryPicker> createState() => _ScopedCategoryPickerState();
}

class _ScopedCategoryPickerState extends State<ScopedCategoryPicker> {
  var _items = <AppCategory>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final values = await ApiClient.instance.categories(widget.scope);
      if (mounted) setState(() => _items = values);
    } catch (e) {
      debugPrint('Error loading categories in picker: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? matchedId;
    if (widget.value != null && widget.value!.isNotEmpty) {
      final exact = _items.where((item) => item.id == widget.value);
      if (exact.isNotEmpty) {
        matchedId = exact.first.id;
      } else {
        final byName = _items.where((item) =>
            item.name.trim().toLowerCase() ==
            widget.value!.trim().toLowerCase());
        if (byName.isNotEmpty) {
          matchedId = byName.first.id;
        }
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            key: ValueKey('${matchedId}_${_items.length}'),
            value: matchedId,
            isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: _border),
                ),
              ),
              hint: Text(
                _loading ? 'Carregando categorias...' : 'Selecione a categoria',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              items: _items.map((item) {
                return DropdownMenuItem(
                  value: item.id,
                  child: Row(
                    children: [
                      buildCategoryIcon(item, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _loading ? null : widget.onChanged,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              tooltip: 'Manage categories',
              color: _blue,
              icon: const Icon(Icons.settings_outlined, size: 22),
              onPressed: () async {
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CategoryManagementScreen(scope: widget.scope),
                  ),
                );
                if (!mounted) return;
                await _load();
              },
            ),
          ),
        ],
      );
  }
}

class CategoryManagementScreen extends StatefulWidget {
  final CategoryScope scope;
  const CategoryManagementScreen({super.key, required this.scope});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  var _items = <AppCategory>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final values = await ApiClient.instance.categories(widget.scope);
      if (mounted) setState(() => _items = values);
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _edit([AppCategory? item]) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _CategoryEditDialog(
        title: item == null
            ? 'Nova Categoria'
            : 'Editar Categoria',
        initialName: item?.name ?? '',
        initialIconKey: item?.iconKey,
        initialImageUrl: item?.imageUrl,
      ),
    );
    if (!mounted || result == null) return;
    final name = result['name'] as String? ?? '';
    final iconKey = result['iconKey'] as String?;
    final imageUrl = result['imageUrl'] as String?;
    if (name.isEmpty) return;

    try {
      if (item == null) {
        await ApiClient.instance.createCategory(
          name,
          widget.scope,
          imageUrl: imageUrl,
          iconKey: iconKey,
        );
      } else {
        await ApiClient.instance.updateCategory(
          item.id,
          name,
          imageUrl: imageUrl,
          iconKey: iconKey,
        );
      }
      await _load();
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  Future<void> _delete(AppCategory item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir categoria'),
        content: Text('Deseja realmente excluir "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ApiClient.instance.deleteCategory(item.id);
      await _load();
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Categorias de ${widget.scope.label}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: const Color(0xFFF6F8FB),
          foregroundColor: _blue,
          centerTitle: true,
        ),
        backgroundColor: const Color(0xFFF6F8FB),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _edit(),
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma categoria encontrada.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final item = _items[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _border),
                        ),
                        child: ListTile(
                          leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: buildCategoryIcon(item, size: 22),
                            ),
                          title: Text(
                            item.name,
                            style: const TextStyle(
                              color: _blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            widget.scope.label,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          trailing: Wrap(
                            spacing: 0,
                            children: [
                              IconButton(
                                tooltip: 'Editar categoria',
                                onPressed: () => _edit(item),
                                icon: const Icon(Icons.edit_outlined, color: _blue),
                              ),
                              IconButton(
                                tooltip: 'Excluir categoria',
                                onPressed: () => _delete(item),
                                icon: const Icon(Icons.delete_outline,
                                    color: Color(0xFFEF4444)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      );
}

class _CategoryEditDialog extends StatefulWidget {
  final String title;
  final String initialName;
  final String? initialIconKey;
  final String? initialImageUrl;

  const _CategoryEditDialog({
    required this.title,
    required this.initialName,
    this.initialIconKey,
    this.initialImageUrl,
  });

  @override
  State<_CategoryEditDialog> createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends State<_CategoryEditDialog> {
  late final TextEditingController _controller;
  String? _selectedIconKey;
  String? _selectedImageUrl;
  bool _uploading = false;

  final List<Map<String, dynamic>> _catalogIcons = [
    {'key': 'material', 'label': 'Matéria-Prima', 'asset': PextAssets.material},
    {'key': 'polimerization', 'label': 'Polimerização', 'asset': PextAssets.polimerization},
    {'key': 'granulation', 'label': 'Granulação', 'asset': PextAssets.granulation},
    {'key': 'final_product', 'label': 'Produto Final', 'asset': PextAssets.finalProduct},
    {'key': 'packaging', 'label': 'Embalagem', 'asset': PextAssets.packaging},
    {'key': 'car', 'label': 'Automotivo', 'asset': PextAssets.car},
    {'key': 'density', 'label': 'Densidade', 'asset': PextAssets.density},
    {'key': 'temperature', 'label': 'Temperatura', 'asset': PextAssets.temperature},
    {'key': 'mfi', 'label': 'Fluidez (MFI)', 'asset': PextAssets.mfi},
    {'key': 'fiber', 'label': 'Fibras', 'asset': PextAssets.fiber},
    {'key': 'jar', 'label': 'Frascos', 'asset': PextAssets.jar},
    {'key': 'joys', 'label': 'Brinquedos', 'asset': PextAssets.joys},
    {'key': 'house_machines', 'label': 'Eletros', 'asset': PextAssets.houseMachines},
    {'key': 'pipes', 'label': 'Tubos', 'asset': PextAssets.pipes},
    {'key': 'lab', 'label': 'Laboratório/Química', 'asset': PextAssets.lab},
    {'key': 'factory', 'label': 'Industrial Geral', 'asset': PextAssets.factory},
    {'key': 'furniture', 'label': 'Móveis', 'asset': PextAssets.furniture},
    {'key': 'construction', 'label': 'Construção Civil', 'asset': PextAssets.construction},
    {'key': 'health', 'label': 'Saúde', 'asset': PextAssets.health},
    {'key': 'agricultural_films', 'label': 'Filmes Agrícolas', 'asset': PextAssets.agriculturalFilms},
    {'key': 'extrusion', 'label': 'Extrusão', 'asset': PextAssets.extrusion},
    {'key': 'filtration', 'label': 'Filtragem', 'asset': PextAssets.filtration},
    {'key': 'cooling', 'label': 'Resfriamento', 'asset': PextAssets.cooling},
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _selectedIconKey = widget.initialIconKey;
    _selectedImageUrl = widget.initialImageUrl;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() => _uploading = true);
        final url = await ApiClient.instance.uploadImage(file);
        if (mounted) {
          setState(() {
            _selectedImageUrl = url;
            _selectedIconKey = null;
            _uploading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar ícone: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          widget.title,
          style: const TextStyle(color: _blue, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nome da Categoria *',
                  hintText: 'Ex: Processos, Extrusão...',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Escolha um Ícone do Sistema:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: _blue,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _catalogIcons.map((item) {
                  final isSel = _selectedIconKey == item['key'] &&
                      _selectedImageUrl == null;
                  return InkWell(
                    onTap: () => setState(() {
                      _selectedIconKey = item['key'] as String;
                      _selectedImageUrl = null;
                    }),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
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
                          PextAssetIcon(item['asset'] as String, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: isSel ? _blue : const Color(0xFF132B5C),
                              fontWeight: isSel
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ou envie uma imagem/ícone:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: _blue,
                ),
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _blue,
                  side: const BorderSide(color: _blue),
                ),
                onPressed: _uploading ? null : _pickImage,
                icon: _uploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate, size: 18),
                label: Text(_selectedImageUrl != null
                    ? 'Trocar Imagem'
                    : 'Carregar Imagem da Galeria'),
              ),
              if (_selectedImageUrl != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        ApiClient.instance.mediaUrl(_selectedImageUrl),
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Imagem carregada com sucesso!',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF16A34A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.red),
                      onPressed: () => setState(() => _selectedImageUrl = null),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _blue),
            onPressed: () {
              final name = _controller.text.trim();
              if (name.isEmpty) return;
              Navigator.of(context).pop({
                'name': name,
                'iconKey': _selectedIconKey,
                'imageUrl': _selectedImageUrl,
              });
            },
            child: const Text('Salvar'),
          ),
        ],
      );
}
