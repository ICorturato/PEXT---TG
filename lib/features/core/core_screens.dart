import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../app_routes.dart';
import '../../models/app_category.dart';
import '../../models/content_model.dart';
import '../../models/doubt_model.dart';
import '../../models/packaging_specification.dart';
import '../../models/training_model.dart';
import '../../services/api_client.dart';
import '../../services/chat_service.dart';
import '../../services/content_service.dart';
import '../../services/doubt_service.dart';
import '../../services/favorites_service.dart';
import '../../services/file_download_service.dart';
import '../../services/training_service.dart';
import '../../widgets/pext_asset_icon.dart';
import '../../widgets/app_search_bar.dart';
import '../admin/admin_user_screens.dart';
import 'category_management_screen.dart';

const _blue = Color(0xFF053488);
const _canvas = Color(0xFFF6F8FB);
const _border = Color(0xFFE5E7EB);

typedef NovoTreinamentoScreen = TrainingEditorScreen;
typedef NovoModuloScreen = ModuleEditorScreen;
typedef QuestoesScreen = AdminQuestionListScreen;
typedef DetalhesTreinamentoScreen = TrainingDetailScreen;
typedef DetalhesModuloScreen = LessonDetailScreen;
typedef PackagingEditScreen = PackagingRegistrationScreen;

class _TermTopic {
  final String title;
  final String content;

  const _TermTopic({required this.title, required this.content});

  factory _TermTopic.fromJson(Object? value) {
    if (value is Map) {
      return _TermTopic(
          title: value['title']?.toString() ?? '',
          content: value['content']?.toString() ?? '');
    }
    // Terms saved before the title/body schema used a list of text strings.
    return _TermTopic(title: 'Como funciona', content: value?.toString() ?? '');
  }
}

class _TermTopicDraft {
  final title = TextEditingController();
  final content = TextEditingController();

  _TermTopicDraft({String titleText = '', String contentText = ''}) {
    title.text = titleText;
    content.text = contentText;
  }

  factory _TermTopicDraft.fromJson(Object? value) {
    final topic = _TermTopic.fromJson(value);
    return _TermTopicDraft(titleText: topic.title, contentText: topic.content);
  }

  bool get hasValue =>
      title.text.trim().isNotEmpty || content.text.trim().isNotEmpty;
  Map<String, String> toJson() =>
      {'title': title.text.trim(), 'content': content.text.trim()};

  void dispose() {
    title.dispose();
    content.dispose();
  }
}

class TermsDictionaryScreen extends StatefulWidget {
  final bool admin;
  const TermsDictionaryScreen({super.key, this.admin = false});
  @override
  State<TermsDictionaryScreen> createState() => _TermsDictionaryScreenState();
}

class _TermsDictionaryScreenState extends State<TermsDictionaryScreen> {
  String _query = '';
  var _terms = <ApiContent>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    try {
      final values = await ApiClient.instance.content('terms');
      values.sort((left, right) => left
          .text('term')
          .toLowerCase()
          .compareTo(right.text('term').toLowerCase()));
      if (mounted) setState(() => _terms = values);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<ApiContent>>{};
    for (final term in _terms.where((item) =>
        item.text('term').toLowerCase().contains(_query.toLowerCase()))) {
      final name = term.text('term');
      if (name.isNotEmpty) {
        groups.putIfAbsent(name[0].toUpperCase(), () => []).add(term);
      }
    }
    return _Shell(
        title: 'Dicionário de Termos',
        admin: widget.admin,
        returnToHome: true,
        action: widget.admin
            ? _BoxedHeaderAction(
                icon: Icons.add,
                onTap: () async {
                  final changed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                          builder: (_) => const CadastroTermoScreen()));
                  if (changed == true) _loadTerms();
                })
            : const _BoxedHeaderAction(icon: Icons.favorite_border),
        child: Column(children: [
          _TermsSearch(onChanged: (value) => setState(() => _query = value)),
          const SizedBox(height: 14),
          Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : groups.isEmpty
                      ? const _NoTermsFound()
                      : ListView(children: [
                          for (final entry in groups.entries)
                            _TermsLetterGroup(
                                letter: entry.key,
                                terms: entry.value,
                                onTermTap: (term) => _detail(context, term))
                        ])),
        ]));
  }

  Future<void> _detail(BuildContext context, ApiContent term) async {
    final changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) =>
                DetalhesTermoScreen(item: term, admin: widget.admin)));
    if (changed == true) _loadTerms();
  }
}

class _TermsSearch extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _TermsSearch({required this.onChanged});

  @override
  Widget build(BuildContext context) =>
      AppSearchBar(hint: 'Ex: Coextrusão', onChanged: onChanged);
}

class _TermsLetterGroup extends StatelessWidget {
  final String letter;
  final List<ApiContent> terms;
  final ValueChanged<ApiContent> onTermTap;
  const _TermsLetterGroup(
      {required this.letter, required this.terms, required this.onTermTap});

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 6),
            child: Text(letter,
                style: const TextStyle(
                    color: _blue, fontSize: 19, fontWeight: FontWeight.w500))),
        Container(
            decoration: _card(),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Column(children: [
                  for (var index = 0; index < terms.length; index++)
                    InkWell(
                        onTap: () => onTermTap(terms[index]),
                        child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                                border: index == terms.length - 1
                                    ? null
                                    : const Border(
                                        bottom: BorderSide(color: _border))),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(terms[index].text('term'),
                                      style: const TextStyle(fontSize: 16)),
                                ),
                                _TermFavoriteIconButton(termId: terms[index].id),
                              ],
                            )))
                ])))
      ]));
}

class _TermFavoriteIconButton extends StatelessWidget {
  final String termId;
  const _TermFavoriteIconButton({required this.termId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FavoritesService.instance,
      builder: (context, _) {
        final isFavorited = FavoritesService.instance.isFavorite(termId);
        return IconButton(
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: isFavorited ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
          ),
          onPressed: () async {
            final nowFav = await FavoritesService.instance.toggleFavorite(
              entityType: 'TERM',
              entityId: termId,
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(nowFav
                      ? 'Termo adicionado aos favoritos!'
                      : 'Removido dos favoritos.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          tooltip: 'Favoritar',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        );
      },
    );
  }
}

class _NoTermsFound extends StatelessWidget {
  const _NoTermsFound();
  @override
  Widget build(BuildContext context) => const Padding(
      padding: EdgeInsets.only(top: 4),
      child: Row(children: [
        Text('Nada encontrado! - ', style: TextStyle(color: _blue)),
        Text('Solicitar ao supervisor',
            style: TextStyle(
                decoration: TextDecoration.underline, color: Color(0xFF363C46)))
      ]));
}

class DetalhesTermoScreen extends StatefulWidget {
  final ApiContent item;
  final bool admin;
  const DetalhesTermoScreen(
      {super.key, required this.item, this.admin = false});

  @override
  State<DetalhesTermoScreen> createState() => _DetalhesTermoScreenState();
}

class _DetalhesTermoScreenState extends State<DetalhesTermoScreen> {
  ApiContent get item => widget.item;

  Future<void> _toggleFavorite() async {
    try {
      final nowFav = await FavoritesService.instance.toggleFavorite(
        entityType: 'TERM',
        entityId: widget.item.id,
        itemData: widget.item.data,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nowFav
                ? 'Termo adicionado aos favoritos!'
                : 'Termo removido dos favoritos.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar favorito: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: FavoritesService.instance,
        builder: (context, _) {
          final isFavorited = FavoritesService.instance.isFavorite(widget.item.id);
          return _Shell(
            title: 'Dicionário de Termos',
            admin: widget.admin,
            action: widget.admin
                ? null
                : _BoxedHeaderAction(
                    icon: isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? const Color(0xFFEF4444) : _blue,
                    onTap: _toggleFavorite,
                  ),
            child: ListView(children: [
          if (widget.admin) ...[
            Row(children: [
              Expanded(
                  child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF8494E),
                          side: const BorderSide(color: Color(0xFFF8494E))),
                      onPressed: () async {
                        await ApiClient.instance
                            .deleteContent('terms', widget.item.id);
                        if (context.mounted) Navigator.pop(context, true);
                      },
                      icon: const Icon(Icons.delete_outline, size: 17),
                      label: const Text('Excluir Conteúdo'))),
              const SizedBox(width: 8),
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: () async {
                        final changed = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                                builder: (_) =>
                                    CadastroTermoScreen(initialTerm: widget.item)));
                        if (changed == true && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                      icon: const PextAssetIcon(PextAssets.edit, size: 17),
                      label: const Text('Editar Conteúdo')))
            ]),
            const SizedBox(height: 16),
          ],
          Container(
              padding: const EdgeInsets.all(14),
              decoration: _card(),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.text('term'),
                        style: const TextStyle(
                            color: _blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Text(item.text('description')),
                    const SizedBox(height: 22),
                    ...((item.data['topics'] as List? ?? const [])
                        .map(_TermTopic.fromJson)
                        .where((topic) =>
                            topic.title.isNotEmpty || topic.content.isNotEmpty)
                        .expand((topic) => [
                              Text(topic.title,
                                  style: const TextStyle(
                                      color: _blue,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(topic.content),
                              const SizedBox(height: 22),
                            ])),
                    if (item.text('imagePath').isNotEmpty)
                      ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                              ApiClient.instance
                                  .mediaUrl(item.text('imagePath')),
                              height: 158,
                              width: double.infinity,
                              fit: BoxFit.cover)),
                    const SizedBox(height: 22),
                    const Text('Termos Relacionados',
                        style: TextStyle(
                            color: _blue, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    Wrap(
                        spacing: 8,
                        children: item
                            .strings('relatedTerms')
                            .map(_TermChip.new)
                            .toList()),
                  ])),
        ]),
      );
    });
}

class CadastroTermoScreen extends StatefulWidget {
  final ApiContent? initialTerm;
  const CadastroTermoScreen({super.key, this.initialTerm});

  @override
  State<CadastroTermoScreen> createState() => _CadastroTermoScreenState();
}

class _CadastroTermoScreenState extends State<CadastroTermoScreen> {
  late final TextEditingController _termController;
  final _explanationController = TextEditingController();
  final _topics = <_TermTopicDraft>[];
  final _relatedTerms = <String>[];
  var _availableTerms = <String>[];
  String? _categoryId;
  XFile? _image;
  Uint8List? _imageBytes;
  String? _imageError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.initialTerm;
    _termController = TextEditingController(text: item?.text('term') ?? '');
    _explanationController.text = item?.text('description') ?? '';
    _categoryId = item?.text('categoryId');
    _relatedTerms.addAll(item?.strings('relatedTerms') ?? const []);
    final topics = item?.data['topics'] as List? ?? const [];
    _topics.addAll(topics.isEmpty
        ? [_TermTopicDraft(titleText: 'Como funciona')]
        : topics.map(_TermTopicDraft.fromJson));
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    try {
      final values = await ApiClient.instance.content('terms');
      if (mounted) {
        setState(() => _availableTerms = values
            .map((item) => item.text('term'))
            .where((value) => value.isNotEmpty && value != _termController.text)
            .toList());
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _termController.dispose();
    _explanationController.dispose();
    for (final topic in _topics) {
      topic.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final extension = file.name.contains('.')
        ? file.name.substring(file.name.lastIndexOf('.')).toLowerCase()
        : '';
    const allowedExtensions = {'.png', '.jpg', '.jpeg'};
    if (!allowedExtensions.contains(extension) || bytes.isEmpty) {
      if (!mounted) return;
      setState(() {
        _image = null;
        _imageBytes = null;
        _imageError = bytes.isEmpty
            ? 'The selected image is empty. Choose another file.'
            : 'Select an image in PNG, JPG, or JPEG format.';
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_imageError!)));
      return;
    }
    if (!mounted) return;
    setState(() {
      _image = file;
      _imageBytes = bytes;
      _imageError = null;
    });
  }

  Future<void> _pickRelatedTerms() async {
    final selection = Set<String>.from(_relatedTerms);
    final values = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (_, setSheetState) => SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * .7,
            child: Column(children: [
              const ListTile(title: Text('Related terms')),
              Expanded(
                child: ListView(
                  children: _availableTerms
                      .map((term) => CheckboxListTile(
                            value: selection.contains(term),
                            title: Text(term),
                            onChanged: (checked) => setSheetState(() {
                              if (checked == true) {
                                selection.add(term);
                              } else {
                                selection.remove(term);
                              }
                            }),
                          ))
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.pop(sheetContext, selection.toList()),
                    child: const Text('Apply'),
                  ),
                ),
              )
            ]),
          ),
        ),
      ),
    );
    if (values != null) {
      setState(() {
        _relatedTerms
          ..clear()
          ..addAll(values);
      });
    }
  }

  Future<void> _save() async {
    if (_termController.text.trim().isEmpty ||
        _explanationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Term and explanation are required.')));
      return;
    }
    if (_imageError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_imageError!)));
      return;
    }
    setState(() => _saving = true);
    try {
      final imagePath = _image == null
          ? widget.initialTerm?.text('imagePath')
          : await ApiClient.instance.uploadImage(_image!);
      final values = <String, dynamic>{
        'term': _termController.text.trim(),
        'description': _explanationController.text.trim(),
        'topics': _topics
            .where((topic) => topic.hasValue)
            .map((topic) => topic.toJson())
            .toList(),
        'relatedTerms': _relatedTerms,
        'categoryId': _categoryId,
        'imagePath': imagePath,
      };
      if (widget.initialTerm == null) {
        await ApiClient.instance.createContent('terms', values);
      } else {
        await ApiClient.instance
            .updateContent('terms', widget.initialTerm!.id, values);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Dicionário de Termos',
      admin: true,
      child: Column(children: [
        Expanded(
            child: ListView(children: [
          _TermFormField('Termo:',
              controller: _termController,
              hint: 'Ex: Material irregular na matriz'),
          _TermFormField('Explicação',
              controller: _explanationController, lines: 5),
          ..._topics.asMap().entries.expand((entry) => [
                Row(children: [
                  Expanded(
                      child: _TermFormField('Título do tópico',
                          controller: entry.value.title,
                          hint: 'Ex: Como funciona')),
                  if (_topics.length > 1)
                    IconButton(
                        tooltip: 'Remove topic',
                        onPressed: () => setState(() {
                              entry.value.dispose();
                              _topics.removeAt(entry.key);
                            }),
                        icon: const Icon(Icons.delete_outline,
                            color: Color(0xFFD93838)))
                ]),
                _TermFormField('Conteúdo do tópico',
                    controller: entry.value.content, lines: 3),
              ]),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                  onPressed: () =>
                      setState(() => _topics.add(_TermTopicDraft())),
                  child: const Text('ADICIONAR TÓPICO'))),
          const SizedBox(height: 14),
          ScopedCategoryPicker(
              scope: CategoryScope.terms,
              value: _categoryId,
              onChanged: (value) => setState(() => _categoryId = value)),
          const SizedBox(height: 16),
          const Text('Imagem',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _TermImageAttachment(
              imageBytes: _imageBytes,
              imageUrl: widget.initialTerm?.text('imagePath'),
              imageName: _image?.name),
          const SizedBox(height: 8),
          if (_imageError != null)
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_imageError!,
                    style: const TextStyle(color: Color(0xFFD93838)))),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('ADICIONAR IMAGEM'))),
          const SizedBox(height: 16),
          const Text('Termos Relacionados',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 7),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ..._relatedTerms.map((term) => _RelatedTermChip(term)),
            SizedBox(
                width: 40,
                height: 36,
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    onPressed: _pickRelatedTerms,
                    child: const Center(
                        child: Icon(Icons.add_circle_outline,
                            color: _blue, size: 20))))
          ]),
          const SizedBox(height: 20)
        ])),
        SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'SAVING...' : 'CADASTRAR')))
      ]));
}

class _TermFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int lines;
  const _TermFormField(this.label,
      {required this.controller, this.hint, this.lines = 1});

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
            controller: controller,
            minLines: lines,
            maxLines: lines,
            decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: _border))))
      ]));
}

class _TermImageAttachment extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? imageUrl;
  final String? imageName;
  const _TermImageAttachment({this.imageBytes, this.imageUrl, this.imageName});

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(10),
      decoration: _card(),
      child: Row(children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
                width: 42,
                height: 42,
                child: imageBytes != null
                    ? Image.memory(imageBytes!, fit: BoxFit.cover)
                    : imageUrl?.isNotEmpty == true
                        ? Image.network(ApiClient.instance.mediaUrl(imageUrl),
                            fit: BoxFit.cover)
                        : const DecoratedBox(
                            decoration: BoxDecoration(color: Color(0xFFF1F3F6)),
                            child: Icon(Icons.image_outlined,
                                color: Color(0xFF737D8C))))),
        const SizedBox(width: 10),
        Expanded(
            child: imageBytes != null || imageUrl?.isNotEmpty == true
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(imageName ?? imageUrl!.split('/').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: _blue, fontWeight: FontWeight.w600)),
                        const Text('Imagem selecionada',
                            style: TextStyle(
                                fontSize: 10, color: Color(0xFF737D8C)))
                      ])
                : const Text('Nenhuma imagem selecionada',
                    style: TextStyle(color: Color(0xFF737D8C)))),
        const Icon(Icons.cloud_upload_outlined, color: _blue, size: 24)
      ]));
}

class _RelatedTermChip extends StatelessWidget {
  final String term;
  const _RelatedTermChip(this.term);
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(7)),
      child: Text(term));
}

class TermoSucessoDialog extends StatelessWidget {
  final VoidCallback onAddMore;
  const TermoSucessoDialog({super.key, required this.onAddMore});

  @override
  Widget build(BuildContext context) => Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF9AA3B0))),
      child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Termo adicionado com sucesso!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _blue, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: () {
                      onAddMore();
                      Navigator.pop(context);
                    },
                    child: const Text('Adicionar mais'))),
            const SizedBox(height: 8),
            SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                    onPressed: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                    child: const Text('Fechar')))
          ])));
}

class _TermChip extends StatelessWidget {
  final String text;
  const _TermChip(this.text);
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(4)),
      child: Text(text,
          style: const TextStyle(fontSize: 11, color: Color(0xFF363C46))));
}

class TrainingListScreen extends StatefulWidget {
  final bool admin;
  const TrainingListScreen({super.key, this.admin = false});
  @override
  State<TrainingListScreen> createState() => _TrainingListScreenState();
}

class _TrainingListScreenState extends State<TrainingListScreen> {
  int _filter = 0;
  final _filters = const ['Todos', 'Em Curso', 'Concluídos', 'Desistência'];
  final _trainingService = TrainingService.instance;

  @override
  void initState() {
    super.initState();
    _loadTrainings();
  }

  Future<void> _loadTrainings() async {
    await _trainingService.fetchTrainings();
  }

  int _computeTrainingStatus(TrainingModel training) {
    final isDropped = training.enrollmentStatus?.toUpperCase() == 'DROPPED' ||
        training.enrollmentStatus?.toLowerCase() == 'desistência';
    if (isDropped) return 1; // Desistência

    final isCompleted = training.areAllModulesCompleted ||
        (training.progressPercentage >= 1.0 && training.modules.isNotEmpty) ||
        training.enrollmentStatus?.toUpperCase() == 'COMPLETED';
    if (isCompleted) return 2; // Concluído

    final isInProgress = training.progressPercentage > 0.0 ||
        (training.isEnrolled && training.completedModuleCount > 0);
    if (isInProgress) return 0; // Em curso

    return 3; // Não iniciado
  }

  List<TrainingModel> _filterTrainings(List<TrainingModel> all) {
    if (_filter == 1) {
      return all.where((t) => _computeTrainingStatus(t) == 0).toList();
    } else if (_filter == 2) {
      return all.where((t) => _computeTrainingStatus(t) == 2).toList();
    } else if (_filter == 3) {
      return all.where((t) => _computeTrainingStatus(t) == 1).toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Treinamentos',
        admin: widget.admin,
        returnToHome: true,
        action: widget.admin
            ? IconButton(
                onPressed: () async {
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TrainingEditorScreen(),
                    ),
                  );
                  if (changed == true) _loadTrainings();
                },
                icon: const Icon(Icons.add_circle_outline, color: _blue),
              )
            : IconButton(
                onPressed: () => Navigator.pushNamed(context, PextRoutes.favorites),
                icon: const Icon(Icons.favorite_border, color: _blue),
                tooltip: 'Favoritos',
              ),
        child: Column(children: [
          _TabBar(
            labels: _filters,
            value: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListenableBuilder(
              listenable: _trainingService,
              builder: (context, _) {
                if (_trainingService.isLoading &&
                    _trainingService.trainings.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_trainingService.errorMessage != null &&
                    _trainingService.trainings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _trainingService.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: _loadTrainings,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                final allTrainings = _trainingService.trainings;
                final trainings = _filterTrainings(allTrainings);

                if (trainings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school_outlined,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          allTrainings.isEmpty
                              ? 'Nenhum treinamento cadastrado.'
                              : 'Nenhum treinamento encontrado para este filtro.',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (widget.admin) ...[
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: _blue,
                            ),
                            onPressed: () async {
                              final changed = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TrainingEditorScreen(),
                                ),
                              );
                              if (changed == true) _loadTrainings();
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Cadastrar Treinamento'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: trainings.length,
                  itemBuilder: (context, index) {
                    final training = trainings[index];
                    final status = _computeTrainingStatus(training);
                    final currentModule = training.nextIncompleteModule;
                    final currentModuleSubtitle = currentModule != null
                        ? 'Módulo ${currentModule.order} - ${currentModule.title}'
                        : 'Todos os módulos concluídos';

                    return _TrainingTile(
                      trainingId: training.id,
                      status: status,
                      admin: widget.admin,
                      title: training.title.isNotEmpty
                          ? training.title
                          : 'Treinamento',
                      moduleCount: training.modules.length,
                      questionCount: training.questionCount,
                      progress: training.progressPercentage,
                      currentModuleSubtitle: currentModuleSubtitle,
                      onTap: () => _openCourse(context, status, training),
                    );
                  },
                );
              },
            ),
          ),
        ]),
      );

  void _openCourse(
      BuildContext context, int status, TrainingModel training) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrainingDetailScreen(
          admin: widget.admin,
          completed: status == 2,
          training: training,
        ),
      ),
    ).then((val) {
      if (val == true) _loadTrainings();
    });
  }
}

class TrainingDetailScreen extends StatefulWidget {
  final bool admin;
  final bool completed;
  final TrainingModel? training;
  final ApiContent? record;

  const TrainingDetailScreen({
    super.key,
    this.admin = false,
    this.completed = false,
    this.training,
    this.record,
  });

  @override
  State<TrainingDetailScreen> createState() => _TrainingDetailScreenState();
}

class _TrainingDetailScreenState extends State<TrainingDetailScreen> {
  TrainingModel? _training;
  late List<TrainingModule> _modules;
  bool _isFavorited = false;
  bool _isEnrolled = false;
  bool _enrolling = false;

  @override
  void initState() {
    super.initState();
    if (widget.training != null) {
      _training = widget.training;
    } else if (widget.record != null) {
      _training = TrainingModel.fromJson(widget.record!.data);
    }
    final bool isDropped = _training?.enrollmentStatus == 'DROPPED';
    final bool isDefault = _training?.isDefaultForAllUsers ?? true;
    _isEnrolled = !isDropped && (widget.completed || (_training?.isEnrolled ?? false) || isDefault);
    _modules = _training?.modules.isNotEmpty == true
        ? List<TrainingModule>.from(_training!.modules)
        : [
            const TrainingModule(
              id: 'm1',
              order: 1,
              title: 'Fundamentos da Extrusão',
              description: 'Entenda os princípios básicos do processo de extrusão.',
              isCompleted: true,
            ),
            const TrainingModule(
              id: 'm2',
              order: 2,
              title: 'Temperatura e Pressão',
              description: 'Controle de parâmetros térmicos na linha de produção.',
              isCompleted: false,
            ),
            const TrainingModule(
              id: 'm3',
              order: 3,
              title: 'Velocidade e Resfriamento',
              description: 'Calibração das banheiras de vácuo e puxador.',
              isCompleted: false,
            ),
          ];
    _reloadTraining();
  }

  Future<void> _toggleFavorite() async {
    if (_training == null) return;
    try {
      final nowFav = await FavoritesService.instance.toggleFavorite(
        entityType: 'TRAINING',
        entityId: _training!.id,
        itemData: _training!.toJson(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nowFav
                ? 'Treinamento adicionado aos favoritos!'
                : 'Removido dos favoritos.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _enroll() async {
    if (_training == null) return;
    setState(() => _enrolling = true);
    try {
      await ApiClient.instance.enrollTraining(_training!.id);
      if (mounted) {
        setState(() {
          _isEnrolled = true;
          _training = _training!.copyWith(isEnrolled: true, enrollmentStatus: 'EM_CURSO');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscrição confirmada! Treinamento iniciado.'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
        _reloadTraining();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao iniciar treinamento: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  Future<void> _unenroll() async {
    if (_training == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Matrícula',
            style: TextStyle(color: _blue, fontWeight: FontWeight.bold)),
        content: Text(
            'Deseja realmente cancelar sua matrícula em "${_training!.title}"? Seu progresso será preservado para caso retome futuramente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD93838)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancelar Matrícula'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _enrolling = true);
    try {
      await ApiClient.instance.unenrollTraining(_training!.id);
      if (mounted) {
        setState(() {
          _isEnrolled = false;
          _training = _training!.copyWith(isEnrolled: false, enrollmentStatus: 'DROPPED');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Matrícula cancelada com sucesso.'),
            backgroundColor: Color(0xFF6B7280),
          ),
        );
        _reloadTraining();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cancelar matrícula: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  Future<void> _reloadTraining() async {
    if (_training == null) return;
    try {
      final data = await ApiClient.instance.getTrainingDetail(_training!.id);
      if (!mounted) return;
      final updated = TrainingModel.fromJson(data);
      final bool isDropped = updated.enrollmentStatus == 'DROPPED';
      final bool isDefault = updated.isDefaultForAllUsers;
      setState(() {
        _training = updated;
        if (updated.modules.isNotEmpty) {
          _modules = List<TrainingModule>.from(updated.modules);
        }
        _isEnrolled = !isDropped && (widget.completed || updated.isEnrolled || isDefault);
      });
    } catch (_) {
      final found = TrainingService.instance.trainings
          .where((t) => t.id == _training!.id)
          .firstOrNull;
      if (found != null && mounted) {
        final bool isDropped = found.enrollmentStatus == 'DROPPED';
        final bool isDefault = found.isDefaultForAllUsers;
        setState(() {
          _training = found;
          if (found.modules.isNotEmpty) {
            _modules = List<TrainingModule>.from(found.modules);
          }
          _isEnrolled = !isDropped && (widget.completed || found.isEnrolled || isDefault);
        });
      }
    }
  }

  void _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _modules.removeAt(oldIndex);
      _modules.insert(newIndex, item);
      for (int i = 0; i < _modules.length; i++) {
        _modules[i] = _modules[i].copyWith(order: i + 1);
      }
      if (_training != null) {
        _training = _training!.copyWith(modules: _modules);
      }
    });

    if (_training != null) {
      try {
        await TrainingService.instance.updateTraining(_training!.id, _training!);
      } catch (e) {
        debugPrint('Error updating module order: $e');
      }
    }
  }

  Future<void> _deleteTraining() async {
    if (_training == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Treinamento',
            style: TextStyle(color: _blue, fontWeight: FontWeight.bold)),
        content: Text('Deseja realmente excluir "${_training!.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD93838),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await TrainingService.instance.deleteTraining(_training!.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _training?.title.isNotEmpty == true
        ? _training!.title
        : 'Detalhes do Treinamento';

    final isOptional = !(_training?.isDefaultForAllUsers ?? true);
    final isDropped = _training?.enrollmentStatus == 'DROPPED';
    final needsEnrollment = !widget.admin && (isOptional || isDropped) && !_isEnrolled;

    return _Shell(
      title: title,
      admin: widget.admin,
      fallbackRoute: PextRoutes.training,
      action: widget.admin
          ? Row(mainAxisSize: MainAxisSize.min, children: [
              _BoxedHeaderAction(
                icon: Icons.edit_outlined,
                onTap: () async {
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TrainingEditorScreen(initialModel: _training),
                    ),
                  );
                  if (changed == true && mounted) {
                    Navigator.pop(context, true);
                  }
                },
              ),
              if (_training != null)
                _BoxedHeaderAction(
                  icon: Icons.delete_outline,
                  onTap: _deleteTraining,
                ),
            ])
          : ListenableBuilder(
              listenable: FavoritesService.instance,
              builder: (context, _) {
                final isFav = _training != null &&
                    FavoritesService.instance.isFavorite(_training!.id);
                return _BoxedHeaderAction(
                  icon: isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? const Color(0xFFEF4444) : _blue,
                  onTap: _toggleFavorite,
                );
              },
            ),
      child: ListView(
        children: [
          if (needsEnrollment)
            _OptionalCourseBanner(
              onEnroll: _enroll,
              enrolling: _enrolling,
            )
          else if (!widget.admin)
            _CourseProgressCard(
              training: _training ??
                  TrainingModel(
                    id: 'demo',
                    title: title,
                    description: '',
                    modules: _modules,
                  ),
              onTakeAssessment: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExamScreen(training: _training),
                  ),
                ).then((_) => _reloadTraining());
              },
              onUnenroll: _unenroll,
            ),
          if (!widget.admin) const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Módulos do curso',
                style: TextStyle(
                  color: _blue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.admin)
                const Text(
                  'Arraste para reordenar',
                  style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.admin)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _modules.length,
              onReorder: _onReorder,
              itemBuilder: (ctx, index) {
                final module = _modules[index];
                return ReorderableDelayedDragStartListener(
                  key: ValueKey(module.id),
                  index: index,
                  child: _CourseModuleCard(
                    index: index + 1,
                    module: module,
                    admin: true,
                    trailing: const Icon(Icons.drag_handle, color: Color(0xFF9CA3AF)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonDetailScreen(
                          admin: widget.admin,
                          module: module,
                          training: _training,
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          else
            ..._modules.asMap().entries.map((entry) {
              final index = entry.key;
              final module = entry.value;
              final bool isPreviousCompleted = index == 0 ||
                  (_modules[index - 1].isCompleted || _modules[index - 1].isFullyCompleted);
              final bool isLocked = needsEnrollment || !isPreviousCompleted;

              return _CourseModuleCard(
                index: index + 1,
                module: module,
                admin: false,
                isLocked: isLocked,
                onTap: () {
                  if (isLocked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(needsEnrollment
                            ? 'Clique em "Matricular-se" para liberar o acesso às aulas.'
                            : 'Complete o módulo anterior para desbloquear este módulo.'),
                        backgroundColor: const Color(0xFFF59E0B),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonDetailScreen(
                        admin: widget.admin,
                        module: module,
                        training: _training,
                      ),
                    ),
                  ).then((val) {
                    if (val == true) {
                      _reloadTraining();
                    }
                  });
                },
              );
            }),
        ],
      ),
    );
  }
}

class _OptionalCourseBanner extends StatelessWidget {
  final VoidCallback onEnroll;
  final bool enrolling;

  const _OptionalCourseBanner({
    required this.onEnroll,
    required this.enrolling,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _blue.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school, color: _blue, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Matrícula no Treinamento',
                      style: TextStyle(
                        color: _blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Matricule-se para ter acesso às aulas, materiais e avaliações deste treinamento.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _blue,
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: enrolling ? null : onEnroll,
              icon: enrolling
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.school, size: 20),
              label: Text(
                enrolling ? 'Matriculando...' : 'Matricular-se',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseProgressCard extends StatelessWidget {
  final TrainingModel training;
  final VoidCallback? onTakeAssessment;
  final VoidCallback? onUnenroll;

  const _CourseProgressCard({
    required this.training,
    this.onTakeAssessment,
    this.onUnenroll,
  });

  @override
  Widget build(BuildContext context) {
    final total = training.modules.isNotEmpty ? training.modules.length : 1;
    final completed = training.completedModuleCount;
    final inProgress = training.inProgressModuleCount;
    final notStarted = training.notStartedModuleCount;
    final pct = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
    final pctStr = '${(pct * 100).toInt()}%';
    final remaining = (total - completed) > 0 ? (total - completed) : 0;
    final allDone = total > 0 && completed >= total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(children: [
        Row(children: [
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(alignment: Alignment.center, children: [
              Positioned.fill(
                child: CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 7,
                  color: allDone ? const Color(0xFF22C55E) : _blue,
                  backgroundColor: _border,
                ),
              ),
              Text(
                pctStr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: allDone ? const Color(0xFF22C55E) : _blue,
                ),
              ),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allDone
                      ? 'Parabéns! Todos os módulos foram concluídos'
                      : 'Você completou $completed de $total módulos',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _blue,
                  ),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        color: allDone ? const Color(0xFF22C55E) : _blue,
                        backgroundColor: _border,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    pctStr,
                    style: TextStyle(
                      color: allDone ? const Color(0xFF22C55E) : _blue,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(
                  allDone
                      ? 'Avaliação final desbloqueada!'
                      : 'Faltam $remaining módulos para concluir',
                  style: TextStyle(
                    fontSize: 11,
                    color: allDone ? const Color(0xFF16A34A) : const Color(0xFF6B7280),
                    fontWeight: allDone ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 16),
        // KPI row wrapped in IntrinsicHeight with CrossAxisAlignment.stretch for strict equal heights!
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _CourseMetric(
                  Icons.menu_book_outlined,
                  '$total',
                  'Módulos',
                  _blue,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _CourseMetric(
                  Icons.check_circle_outline,
                  '$completed',
                  'Concluídos',
                  const Color(0xFF22C55E),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _CourseMetric(
                  Icons.schedule,
                  '$inProgress',
                  'Em andamento',
                  const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _CourseMetric(
                  Icons.lock_outline,
                  '$notStarted',
                  'Não iniciado',
                  const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        if (allDone) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B4AA0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              onPressed: onTakeAssessment,
              icon: const Icon(Icons.assignment_turned_in, size: 20, color: Colors.white),
              label: const Text(
                'VER TESTE / REALIZAR AVALIAÇÃO',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
        if (onUnenroll != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD93838),
                side: const BorderSide(color: Color(0xFFD93838)),
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onUnenroll,
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text(
                'Cancelar Matrícula',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}


class _CourseMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _CourseMetric(this.icon, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: _card(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9, color: Color(0xFF4B5563)),
            ),
          ],
        ),
      );
}

class _CourseModuleCard extends StatelessWidget {
  final int index;
  final TrainingModule module;
  final bool admin;
  final bool isLocked;
  final Widget? trailing;
  final VoidCallback onTap;

  const _CourseModuleCard({
    required this.index,
    required this.module,
    this.admin = false,
    this.isLocked = false,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeGreen = Color(0xFF22C55E);
    final completed = module.isCompleted || module.isFullyCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: _card(),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: admin
                    ? _blue
                    : (isLocked
                        ? const Color(0xFF9CA3AF)
                        : (completed ? activeGreen : _blue)),
                width: 2,
              ),
            ),
            child: admin
                ? Text('$index',
                    style: const TextStyle(
                        color: _blue, fontWeight: FontWeight.bold, fontSize: 15))
                : (isLocked
                    ? const Icon(Icons.lock_outline,
                        color: Color(0xFF9CA3AF), size: 20)
                    : (completed
                        ? const Icon(Icons.check, color: activeGreen, size: 22)
                        : Text('$index',
                            style: const TextStyle(
                                color: _blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)))),
          ),
          title: Text(
            module.title.isNotEmpty ? module.title : 'Módulo $index',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isLocked ? const Color(0xFF6B7280) : _blue,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            module.description.isNotEmpty
                ? module.description
                : 'Conteúdo programático do módulo.',
            style: TextStyle(
              fontSize: 11,
              color: isLocked ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
          trailing: admin
              ? (trailing ?? const Icon(Icons.drag_handle, color: Color(0xFF9CA3AF)))
              : (isLocked
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, size: 12, color: Color(0xFF9CA3AF)),
                          SizedBox(width: 4),
                          Text(
                            'Bloqueado',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : (completed
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Concluído',
                                style: TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '100%',
                                style: TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Em curso',
                            style: TextStyle(
                              color: Color(0xFFD97706),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ))),
        ),
      ),
    );
  }
}

class _LessonVideoPlayer extends StatefulWidget {
  final String? videoUrl;
  final String fallbackAsset;

  const _LessonVideoPlayer({
    this.videoUrl,
    this.fallbackAsset = 'images/training_extrusion.png',
  });

  @override
  State<_LessonVideoPlayer> createState() => _LessonVideoPlayerState();
}

class _LessonVideoPlayerState extends State<_LessonVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() async {
    final url = widget.videoUrl;
    try {
      if (url != null && (url.startsWith('http://') || url.startsWith('https://'))) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      } else if (url != null && url.isNotEmpty) {
        final filePath = url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;
        final file = File(filePath);
        if (file.existsSync()) {
          _controller = VideoPlayerController.file(file);
        } else {
          _controller = VideoPlayerController.networkUrl(Uri.parse(
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          ));
        }
      } else {
        _controller = VideoPlayerController.networkUrl(Uri.parse(
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        ));
      }

      await _controller!.initialize();
      _controller!.addListener(_onControllerUpdate);
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  void _openFullscreen() {
    if (_controller == null || !_isInitialized) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      VideoProgressIndicator(
                        _controller!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: _blue,
                          bufferedColor: Colors.white54,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                          Text(
                            '${_formatDuration(_controller!.value.position)} / ${_formatDuration(_controller!.value.duration)}',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          IconButton(
                            icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || !_isInitialized || _controller == null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              widget.fallbackAsset,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          InkWell(
            onTap: _initVideo,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
            ),
          ),
        ],
      );
    }

    final duration = _controller!.value.duration;
    final position = _controller!.value.position;
    final isPlaying = _controller!.value.isPlaying;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio > 0 ? _controller!.value.aspectRatio : 16 / 9,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GestureDetector(
              onTap: () {
                setState(() => _showControls = !_showControls);
              },
              child: VideoPlayer(_controller!),
            ),
            if (_showControls || !isPlaying)
              Container(
                color: Colors.black.withOpacity(0.35),
                child: Center(
                  child: IconButton(
                    iconSize: 52,
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: Colors.white,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),
              ),
            if (_showControls || !isPlaying)
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      colors: const VideoProgressColors(
                        playedColor: Color(0xFF2563EB),
                        bufferedColor: Colors.white38,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_formatDuration(position)} / ${_formatDuration(duration)}',
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                        const Spacer(),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.fullscreen, color: Colors.white, size: 22),
                          onPressed: _openFullscreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LessonDetailScreen extends StatefulWidget {
  final bool admin;
  final TrainingModule? module;
  final TrainingModel? training;
  const LessonDetailScreen({
    super.key,
    this.admin = false,
    this.module,
    this.training,
  });
  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int tab = 0;
  late TrainingModule? _currentModule;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    _currentModule = widget.module;
  }

  Future<void> _completeModule() async {
    if (widget.training == null || _currentModule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Módulo concluído com sucesso!'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      Navigator.pop(context, true);
      return;
    }
    setState(() => _completing = true);
    try {
      await ApiClient.instance.completeTrainingModule(
        widget.training!.id,
        _currentModule!.id,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Módulo concluído com sucesso!'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao concluir módulo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  void _editContent() async {
    final updated = await Navigator.push<TrainingModule>(
      context,
      MaterialPageRoute(
        builder: (_) => ModuleEditorScreen(initialModule: _currentModule),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _currentModule = updated);
    }
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Conteúdo'),
        content: const Text('Tem certeza que deseja excluir o conteúdo deste módulo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD93838)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenTitle = widget.training?.title.isNotEmpty == true
        ? widget.training!.title
        : (_currentModule?.title.isNotEmpty == true
            ? _currentModule!.title
            : 'Processos de ...');

    return _Shell(
      title: screenTitle,
      admin: widget.admin,
      fallbackRoute: PextRoutes.training,
      action: widget.admin
          ? _BoxedHeaderAction(
              icon: Icons.edit_outlined,
              onTap: _editContent,
            )
          : const _BoxedHeaderAction(icon: Icons.favorite_border),
      child: Column(children: [
        _TabBar(
          labels: const ['Conteúdo', 'Documentação'],
          value: tab,
          onChanged: (value) => setState(() => tab = value),
        ),
        const SizedBox(height: 18),
        Expanded(child: tab == 0 ? _lessonContent() : _lessonDocuments()),
      ]),
    );
  }

  Widget _lessonContent() {
    final lessonTitle = _currentModule?.title.isNotEmpty == true
        ? _currentModule!.title
        : '1.1 - Introdução às Matérias-Primas';
    final lessonDescription = _currentModule?.description.isNotEmpty == true
        ? _currentModule!.description
        : 'Conheça os principais tipos de matérias-primas utilizadas na extrusão e suas características.';

    final videoList = _currentModule?.videos ?? const [];

    final allModules = widget.training?.modules ?? [];
    final currentIndex = allModules.indexWhere((m) => m.id == _currentModule?.id);
    final subsequentModules = currentIndex >= 0
        ? allModules.skip(currentIndex + 1).where((m) => !m.isCompleted).toList()
        : <TrainingModule>[];

    return ListView(children: [
      if (widget.admin)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  foregroundColor: const Color(0xFFD93838),
                  side: const BorderSide(color: Color(0xFFD93838)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFD93838)),
                label: const Text(
                  'Excluir Conteúdo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  foregroundColor: const Color(0xFF132B5C),
                  side: const BorderSide(color: Color(0xFF132B5C)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: _editContent,
                icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF132B5C)),
                label: const Text(
                  'Editar Conteúdo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ]),
        ),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: _card(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            lessonTitle,
            style: const TextStyle(
              color: _blue,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 14),
          _LessonVideoPlayer(
            videoUrl: videoList.isNotEmpty ? videoList.first.urlOrPath : null,
            fallbackAsset: 'images/training_extrusion.png',
          ),
          const SizedBox(height: 16),
          const Text(
            'Sobre esta aula',
            style: TextStyle(
              color: _blue,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(lessonDescription),
          if (videoList.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Vídeos da aula',
              style: TextStyle(
                color: _blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            ...videoList.map((v) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.play_circle_fill, color: _blue, size: 28),
                  title: Text(
                    v.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    v.duration,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                )),
          ],
          if (subsequentModules.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Próximos conteúdos',
              style: TextStyle(
                color: _blue,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 6),
            ...subsequentModules.map((m) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    m.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    m.videos.isNotEmpty ? '${m.videos.length} vídeo(s)' : 'Módulo seguinte',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  trailing: const Icon(Icons.play_circle_outline, color: Color(0xFF132B5C)),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonDetailScreen(
                          admin: widget.admin,
                          module: m,
                          training: widget.training,
                        ),
                      ),
                    );
                  },
                )),
          ],
          if (!widget.admin) ...[
            const SizedBox(height: 20),
            if (_currentModule?.isCompleted == true || _currentModule?.isFullyCompleted == true)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Módulo Concluído',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _completing ? null : _completeModule,
                  icon: _completing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: Text(
                    _completing ? 'Concluindo...' : 'CONCLUIR MÓDULO',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ]),
      ),
    ]);
  }

  Widget _lessonDocuments() {
    final docs = _currentModule?.documents ?? const [];

    return ListView(children: [
      const Text(
        'Materiais de Apoio',
        style: TextStyle(
          color: _blue,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      if (docs.isNotEmpty)
        ...docs.map((doc) => Container(
              margin: const EdgeInsets.only(bottom: 7),
              decoration: _card(),
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: _card(),
                  alignment: Alignment.center,
                  child: const PextAssetIcon(PextAssets.pdf, size: 27),
                ),
                title: Text(
                  doc.title,
                  style: const TextStyle(
                    color: _blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(doc.fileSize),
                trailing: IconButton(
                  icon: const PextAssetIcon(PextAssets.download, size: 24),
                  tooltip: 'Baixar material',
                  onPressed: () {
                    FileDownloadService.instance.downloadFile(
                      context,
                      url: doc.urlOrPath,
                      filename: doc.title,
                    );
                  },
                ),
              ),
            ))
      else
        Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.all(20),
          decoration: _card(),
          alignment: Alignment.center,
          child: const Text(
            'Nenhum documento anexado neste módulo.',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
        ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 44),
            foregroundColor: const Color(0xFF132B5C),
            side: const BorderSide(color: Color(0xFF132B5C)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          onPressed: () {},
          child: const Text('Ver todos os documentos'),
        ),
      ),
    ]);
  }
}

class TrainingCompletionScreen extends StatelessWidget {
  const TrainingCompletionScreen({super.key});
  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Conclusão Treinamento',
        child: ListView(children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _card(),
            child: Column(children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset('images/training_extrusion.png',
                      height: 190, width: double.infinity, fit: BoxFit.cover)),
              const SizedBox(height: 10),
              const _Pill('Concluído', Color(0xFF22C55E)),
              const Text('Treinamento\nTemperatura de Extrusão',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: _blue, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const LinearProgressIndicator(value: 1, color: _blue),
              const SizedBox(height: 55),
              const Text('Parabéns!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('Você concluiu todo o conteúdo deste módulo.'),
              const SizedBox(height: 18),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ExamScreen())),
                      child: const Text('FAZER AVALIAÇÃO'))),
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                      onPressed: () {}, child: const Text('REVER CONTEÚDO'))),
              const SizedBox(height: 30),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Resumo do Treinamento',
                      style: TextStyle(
                          color: _blue, fontWeight: FontWeight.bold))),
              Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                      border: Border.all(color: _border),
                      borderRadius: BorderRadius.circular(8)),
                  child: const ListTile(
                      leading: Icon(Icons.menu_book_outlined, color: _blue),
                      title: Text('Aulas Concluídas'),
                      trailing:
                          Text('12 de 12', style: TextStyle(color: _blue)))),
              Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                      border: Border.all(color: _border),
                      borderRadius: BorderRadius.circular(8)),
                  child: const ListTile(
                      leading: Icon(Icons.description_outlined, color: _blue),
                      title: Text('Documentos'),
                      trailing:
                          Text('5 arquivos', style: TextStyle(color: _blue)))),
            ]),
          ),
        ]),
      );
}

class ExamScreen extends StatefulWidget {
  final bool reviewMode;
  final TrainingModel? training;
  const ExamScreen({super.key, this.reviewMode = false, this.training});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late List<TrainingQuestion> _questions;
  int _currentIndex = 0;
  final Map<int, int> _answers = {};
  final Set<int> _marked = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.training != null && widget.training!.questions.isNotEmpty) {
      _questions = List.from(widget.training!.questions);
    } else {
      _questions = List.generate(
        30,
        (index) {
          final num = (index + 1).toString().padLeft(2, '0');
          return TrainingQuestion(
            id: 'mock_q_${index + 1}',
            order: index + 1,
            prompt: 'Questão $num: Selecione o parâmetro operacional correto para o processo de produção industrial.',
            type: 'SINGLE_CHOICE',
            alternatives: const [
              TrainingAlternative(id: 'a1', letter: 'A', text: 'Garantir a fusão adequada do material e sua fluidez.', isCorrect: true),
              TrainingAlternative(id: 'a2', letter: 'B', text: 'Reduzir o tempo de ciclo da linha de extrusão.', isCorrect: false),
              TrainingAlternative(id: 'a3', letter: 'C', text: 'Aumentar a tolerância térmica máxima.', isCorrect: false),
              TrainingAlternative(id: 'a4', letter: 'D', text: 'Diminuir os limites de segurança da máquina.', isCorrect: false),
            ],
          );
        },
      );
    }
  }

  Future<void> _submitAssessment() async {
    final unanswered = _questions.length - _answers.length;
    if (unanswered > 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Questões Pendentes',
              style: TextStyle(color: _blue, fontWeight: FontWeight.bold)),
          content: Text(
              'Você respondeu ${_answers.length} de ${_questions.length} questões. Deseja finalizar mesmo assim?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Continuar Avaliação'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _blue),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Finalizar'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _submitting = true);
    int correctCount = 0;
    for (int i = 0; i < _questions.length; i++) {
      final selectedAltIdx = _answers[i];
      if (selectedAltIdx != null &&
          selectedAltIdx < _questions[i].alternatives.length &&
          _questions[i].alternatives[selectedAltIdx].isCorrect) {
        correctCount++;
      }
    }
    final score = _questions.isNotEmpty
        ? ((correctCount * 100) / _questions.length).round()
        : 0;
    final passing = widget.training?.passingGrade ?? 70;
    final approved = score >= passing;

    try {
      if (widget.training != null) {
        await ApiClient.instance.submitAssessment(
          widget.training!.id,
          score: score,
          correctCount: correctCount,
          totalCount: _questions.length,
        );
      }
    } catch (e) {
      debugPrint('Error submitting assessment: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _ResultScreen(
          approved: approved,
          title: 'Resultado Avaliação',
          scorePercentage: score,
          correctCount: correctCount,
          totalCount: _questions.length,
          onPrimary: () => Navigator.pop(context, true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions.isNotEmpty && _currentIndex < _questions.length
        ? _questions[_currentIndex]
        : null;

    return _Shell(
      title: widget.training?.title.isNotEmpty == true
          ? 'Avaliação: ${widget.training!.title}'
          : 'Avaliação Treinamento',
      action: _BoxedHeaderAction(
        icon: Icons.menu,
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => _QuestionNavigator(
            questionsCount: _questions.length,
            answers: _answers,
            marked: _marked,
            currentIndex: _currentIndex,
            onSelect: (index) {
              setState(() => _currentIndex = index);
              Navigator.pop(context);
            },
            onFinish: () {
              Navigator.pop(context);
              _submitAssessment();
            },
          ),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _QuestionSteps(
          currentIndex: _currentIndex,
          totalCount: _questions.length,
        ),
        const SizedBox(height: 18),
        Expanded(
          child: currentQ != null
              ? ListView(children: [
                  Text(
                    currentQ.prompt,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 18),
                  ...currentQ.alternatives.asMap().entries.map((entry) {
                    final altIdx = entry.key;
                    final alt = entry.value;
                    final isSelected = _answers[_currentIndex] == altIdx;
                    return _AnswerCard(
                      letter: alt.letter.isNotEmpty ? alt.letter : 'ABCD'[altIdx % 4],
                      text: alt.text,
                      selected: isSelected,
                      correct: widget.reviewMode && alt.isCorrect,
                      wrong: widget.reviewMode && isSelected && !alt.isCorrect,
                      onTap: () => setState(() => _answers[_currentIndex] = altIdx),
                    );
                  }),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => setState(() {
                      if (_marked.contains(_currentIndex)) {
                        _marked.remove(_currentIndex);
                      } else {
                        _marked.add(_currentIndex);
                      }
                    }),
                    icon: Icon(
                      _marked.contains(_currentIndex)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: _marked.contains(_currentIndex)
                          ? const Color(0xFFF2C200)
                          : null,
                    ),
                    label: Text(_marked.contains(_currentIndex)
                        ? 'Marcada para revisar'
                        : 'Marcar para revisar depois'),
                  ),
                ])
              : const Center(child: Text('Nenhuma questão encontrada.')),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _currentIndex > 0
                  ? () => setState(() => _currentIndex--)
                  : null,
              child: const Text('Anterior'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _currentIndex == _questions.length - 1
                    ? const Color(0xFF16A34A)
                    : _blue,
              ),
              onPressed: _submitting
                  ? null
                  : (_currentIndex == _questions.length - 1
                      ? _submitAssessment
                      : () => setState(() => _currentIndex++)),
              child: Text(_submitting
                  ? 'Enviando...'
                  : (_currentIndex == _questions.length - 1
                      ? 'FINALIZAR TESTE'
                      : 'Próximo')),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _QuestionSteps extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  const _QuestionSteps({
    this.currentIndex = 0,
    this.totalCount = 30,
  });

  @override
  Widget build(BuildContext context) {
    final pct = totalCount > 0 ? ((currentIndex + 1) / totalCount) : 0.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Questão ${currentIndex + 1} de $totalCount',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _blue),
          ),
          Text(
            '${(pct * 100).toInt()}%',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _blue),
          ),
        ],
      ),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: pct,
          color: _blue,
          backgroundColor: _border,
          minHeight: 8,
        ),
      ),
    ]);
  }
}

class _AnswerCard extends StatelessWidget {
  final String letter;
  final String text;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback onTap;
  const _AnswerCard(
      {required this.letter,
      required this.text,
      required this.selected,
      required this.correct,
      required this.wrong,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    final color = correct
        ? const Color(0xFF22C55E)
        : wrong
            ? const Color(0xFFF44336)
            : selected
                ? _blue
                : const Color(0xFF9CA3AF);
    return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: selected || correct || wrong ? color : _border,
                        width: 1.5)),
                child: Row(children: [
                  Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected || correct || wrong
                              ? color
                              : Colors.white,
                          border: Border.all(color: color, width: 1.5)),
                      child: Text(letter,
                          style: TextStyle(
                              color: selected || correct || wrong
                                  ? Colors.white
                                  : color,
                              fontWeight: FontWeight.bold,
                              fontSize: 18))),
                  const SizedBox(width: 18),
                  Expanded(
                      child: Text(text,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)))
                ]))));
  }
}

class _QuestionNavigator extends StatelessWidget {
  final int questionsCount;
  final Map<int, int> answers;
  final Set<int> marked;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onFinish;

  const _QuestionNavigator({
    this.questionsCount = 30,
    this.answers = const {},
    this.marked = const {},
    this.currentIndex = 0,
    required this.onSelect,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              const Expanded(
                  child: Text('Navegar entre questões',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close))
            ]),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _QuestionLegend(color: Color(0xFF22C55E), label: 'Respondida'),
                _QuestionLegend(color: _blue, label: 'Atual'),
                _QuestionLegend(color: Color(0xFF9CA3AF), label: 'Pendente'),
                _QuestionLegend(color: Color(0xFFF2C200), label: 'Marcada', bookmark: true),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 6,
              childAspectRatio: 1.1,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: List.generate(questionsCount, (index) {
                final active = index == currentIndex;
                final answered = answers.containsKey(index);
                final isMarked = marked.contains(index);
                final color = active
                    ? _blue
                    : answered
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF9CA3AF);
                return InkWell(
                  onTap: () => onSelect(index),
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(children: [
                    Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: active || answered ? color : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color, width: 1.5)),
                        child: Text('${index + 1}',
                            style: TextStyle(
                                color: active || answered
                                    ? Colors.white
                                    : const Color(0xFF374151),
                                fontWeight: FontWeight.bold))),
                    if (isMarked)
                      const Positioned(
                          top: 2,
                          right: 2,
                          child: Icon(Icons.bookmark,
                              color: Color(0xFFF2C200), size: 14)),
                  ]),
                );
              }),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _blue),
                onPressed: onFinish,
                child: const Text('FINALIZAR TESTE'),
              ),
            ),
          ]),
        )),
      );
}

class _QuestionLegend extends StatelessWidget {
  final Color color;
  final String label;
  final bool bookmark;
  const _QuestionLegend(
      {required this.color, required this.label, this.bookmark = false});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(bookmark ? Icons.bookmark : Icons.circle, color: color, size: 12),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10))
      ]);
}

class FinalExamSummaryScreen extends StatelessWidget {
  const FinalExamSummaryScreen({super.key});
  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Avaliação Treinamento',
        child: ListView(children: [
          const SizedBox(height: 20),
          const Text('Resumo da Avaliação',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('VOLTAR'))),
        ]),
      );
}

class ApprovedResultScreen extends StatelessWidget {
  const ApprovedResultScreen({super.key});
  @override
  Widget build(BuildContext context) => _ResultScreen(
      approved: true,
      title: 'Resultado Avaliação',
      onPrimary: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const TrainingDetailScreen(admin: false))));
}

class FailedResultScreen extends StatelessWidget {
  const FailedResultScreen({super.key});
  @override
  Widget build(BuildContext context) => _ResultScreen(
      approved: false,
      title: 'Resultado Avaliação',
      onPrimary: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const RetakeExamScreen())));
}

class _ResultScreen extends StatelessWidget {
  final bool approved;
  final String title;
  final VoidCallback onPrimary;
  final int? scorePercentage;
  final int? correctCount;
  final int? totalCount;

  const _ResultScreen({
    required this.approved,
    required this.title,
    required this.onPrimary,
    this.scorePercentage,
    this.correctCount,
    this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final color = approved ? const Color(0xFF16C79A) : const Color(0xFFF44336);
    final tint = approved ? const Color(0xFFD7F5E5) : const Color(0xFFFFE0B1);
    final acertosStr = (correctCount != null && totalCount != null)
        ? '$correctCount de $totalCount'
        : (approved ? '28 de 30' : '15 de 30');
    final pctStr = scorePercentage != null
        ? '$scorePercentage%'
        : (approved ? '93%' : '50%');

    return _Shell(
        title: title,
        child: ListView(children: [
          const SizedBox(height: 50),
          CircleAvatar(
              radius: 64,
              backgroundColor: color,
              child: Icon(approved ? Icons.check : Icons.close,
                  color: Colors.white, size: 74)),
          const SizedBox(height: 28),
          Text(approved ? 'Parabéns!' : 'Você não foi aprovado',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(approved ? 'Você foi aprovado!' : 'Continue estudando!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Color(0xFF6B7280))),
          const SizedBox(height: 24),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                  color: tint, borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Expanded(
                    child: _ResultMetric('Acertos', acertosStr, color)),
                Expanded(
                    child: _ResultMetric('Porcentagem', pctStr, color)),
                Expanded(
                    child: _ResultMetric(
                        'Situação', approved ? 'Aprovado' : 'Reprovado', color))
              ])),
          const SizedBox(height: 28),
          if (approved)
            const Text(
                'Ótimo trabalho! Você atingiu o resultado necessário para aprovação.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16))
          else ...[
            const Text(
                'Você precisa de pelo menos 70% de acertos para ser aprovado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Principais tópicos para revisar:',
                style: TextStyle(color: _blue, fontWeight: FontWeight.bold)),
            ...[
              'Temperatura do Material',
              'Parâmetros do processo',
              'Tipos de polímeros'
            ].map((item) => Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: _card(),
                child: ListTile(
                    leading: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFFF44336),
                        child: Icon(Icons.close, color: Colors.white, size: 16)),
                    title: Text(item, style: const TextStyle(fontSize: 13)),
                    trailing: const Text('Revisar',
                        style: TextStyle(color: _blue, fontWeight: FontWeight.bold))))),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: approved ? const Color(0xFF16C79A) : _blue,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onPrimary,
              child: Text(approved ? 'CONCLUIR' : 'VOLTAR AO TREINAMENTO'),
            ),
          ),
        ]),
      );
  }
}

class _ResultMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ResultMetric(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold))
      ]);
}

class RetakeExamScreen extends StatelessWidget {
  const RetakeExamScreen({super.key});
  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Refazer Avaliação',
      child: ListView(children: [
        const SizedBox(height: 54),
        const CircleAvatar(
            radius: 82,
            backgroundColor: Color(0xFFFFD9A9),
            child: Icon(Icons.refresh, color: Colors.black, size: 94)),
        const SizedBox(height: 36),
        const Text('Refazer avaliação?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        const Text(
            'Você pode refazer o teste mais duas vezes!\nRevise até estar preparado.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 19, color: Color(0xFF6B7280))),
        const SizedBox(height: 28),
        Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: const Color(0xFFFFD9A9),
                borderRadius: BorderRadius.circular(18)),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Recomendamos revisar o conteúdo antes',
                      style: TextStyle(
                          color: Color(0xFFFF7A00),
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text('• Novas perguntas poderão ser exibidas',
                      style: TextStyle(
                          color: Color(0xFFFF7A00),
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text('• Sua última pontuação será substituída',
                      style: TextStyle(
                          color: Color(0xFFFF7A00),
                          fontWeight: FontWeight.bold))
                ])),
        const SizedBox(height: 54),
        SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ExamScreen())),
                child: const Text('REFAZER TESTE'))),
        SizedBox(
            width: double.infinity,
            child: OutlinedButton(
                onPressed: () {}, child: const Text('REVER MÓDULO'))),
        const SizedBox(height: 6),
      ]));
}

class TrainingEditorScreen extends StatefulWidget {
  final ApiContent? initial;
  final TrainingModel? initialModel;
  const TrainingEditorScreen({super.key, this.initial, this.initialModel});
  @override
  State<TrainingEditorScreen> createState() => _TrainingEditorScreenState();
}

class _TrainingEditorScreenState extends State<TrainingEditorScreen> {
  int tab = 0;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _hoursController;
  late final TextEditingController _passingGradeController;
  String? _categoryId;
  XFile? _thumbnail;
  Uint8List? _thumbnailBytes;
  String? _existingThumbnailUrl;
  List<TrainingModule> _modules = [];
  List<TrainingQuestion> _questions = [];
  bool _isDefaultForAllUsers = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final model = widget.initialModel;
    final record = widget.initial;
    _isDefaultForAllUsers = model?.isDefaultForAllUsers ?? (record?.data['isDefaultForAllUsers'] == true);
    _titleController = TextEditingController(text: model?.title ?? record?.text('title') ?? '');
    _descriptionController =
        TextEditingController(text: model?.description ?? record?.text('description') ?? '');
    _hoursController =
        TextEditingController(text: model?.workload ?? record?.text('totalSteps') ?? '');
    _passingGradeController = TextEditingController(
      text: model != null ? model.passingGrade.toString() : (record?.intVal('passingGrade') ?? 70).toString(),
    );
    _categoryId = model?.categoryId ?? record?.text('categoryId');
    _existingThumbnailUrl = model?.thumbnailUrl ?? record?.text('thumbnailUrl') ?? record?.text('imageUrl');

    if (model != null && model.modules.isNotEmpty) {
      _modules = List.from(model.modules);
    } else if (record != null && record.data['modules'] is List) {
      _modules = (record.data['modules'] as List)
          .map((e) => TrainingModule.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else {
      _modules = [
        const TrainingModule(
          id: 'mod_1',
          order: 1,
          title: 'Fundamentos da Extrusão',
          description: 'Entenda os princípios básicos do processo de extrusão.',
        ),
        const TrainingModule(
          id: 'mod_2',
          order: 2,
          title: 'Fundamentos da Extrusão',
          description: 'Entenda os princípios básicos do processo de extrusão.',
        ),
      ];
    }

    if (model != null && model.questions.isNotEmpty) {
      _questions = List.from(model.questions);
    } else if (record != null && record.data['questions'] is List) {
      _questions = (record.data['questions'] as List)
          .map((e) => TrainingQuestion.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else {
      _questions = List.generate(
        29,
        (index) {
          final num = (index + 1).toString().padLeft(2, '0');
          return TrainingQuestion(
            id: 'mock_q_${index + 1}',
            order: index + 1,
            prompt: 'Questão $num: Selecione o parâmetro operacional correto.',
            type: 'SINGLE_CHOICE',
            alternatives: const [
              TrainingAlternative(id: 'a1', letter: 'A', text: 'Parâmetro padrão de calibração', isCorrect: true),
              TrainingAlternative(id: 'a2', letter: 'B', text: 'Variação alternativa de processo', isCorrect: false),
              TrainingAlternative(id: 'a3', letter: 'C', text: 'Tolerância secundária admissível', isCorrect: false),
              TrainingAlternative(id: 'a4', letter: 'D', text: 'Limite de segurança operacional', isCorrect: false),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    _passingGradeController.dispose();
    super.dispose();
  }

  bool get _isQuestionCountValid => _questions.length >= 30 && _questions.length <= 50;

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Novo treinamento',
        admin: true,
        fallbackRoute: PextRoutes.training,
        child: Column(children: [
          _TabBar(
              labels: const ['Visão Geral', 'Módulos', 'Avaliação'],
              value: tab,
              onChanged: (value) => setState(() => tab = value)),
          const SizedBox(height: 18),
          Expanded(
              child: tab == 0
                  ? _overview()
                  : tab == 1
                      ? _modulesView()
                      : _assessment()),
          SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: (_saving || !_isQuestionCountValid) ? null : _save,
                  child:
                      Text(widget.initial == null && widget.initialModel == null ? 'CADASTRAR' : 'SALVAR'))),
        ]),
      );

  Widget _overview() => ListView(children: [
        _Field('Título do treinamento',
            controller: _titleController, hint: 'Ex: Processos de extrusão'),
        _Field('Descrição curta',
            controller: _descriptionController,
            lines: 4,
            hint: 'Descreva o treinamento'),
        ScopedCategoryPicker(
            scope: CategoryScope.training,
            value: _categoryId,
            onChanged: (value) => setState(() => _categoryId = value)),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: _card(),
          child: Material(
            color: Colors.transparent,
            child: SwitchListTile(
              title: const Text('Treinamento Obrigatório / Padrão',
                  style: TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text(
                  'Inscrever automaticamente todos os usuários do sistema neste treinamento.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              value: _isDefaultForAllUsers,
              activeColor: _blue,
              onChanged: (val) => setState(() => _isDefaultForAllUsers = val),
            ),
          ),
        ),
        _Field('Carga horária total (opcional)',
            controller: _hoursController, hint: 'Ex: 4 horas'),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Imagem de capa',
            style: TextStyle(color: _blue, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
            onTap: _pickThumbnail,
            borderRadius: BorderRadius.circular(12),
            child: _thumbnailBytes != null
                ? Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _thumbnailBytes!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      IconButton(
                        icon: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 14,
                          child: Icon(Icons.close, size: 16, color: Colors.black),
                        ),
                        onPressed: () => setState(() {
                          _thumbnail = null;
                          _thumbnailBytes = null;
                        }),
                      ),
                    ],
                  )
                : (_existingThumbnailUrl != null && _existingThumbnailUrl!.isNotEmpty
                    ? Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              ApiClient.instance.resolveMediaUrl(_existingThumbnailUrl!),
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const _UploadDropZone('Imagem de capa'),
                            ),
                          ),
                          IconButton(
                            icon: const CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 14,
                              child: Icon(Icons.close, size: 16, color: Colors.black),
                            ),
                            onPressed: () => setState(() {
                              _existingThumbnailUrl = null;
                            }),
                          ),
                        ],
                      )
                    : const _UploadDropZone('Imagem de capa'))),
        const SizedBox(height: 12),
      ]);

  Widget _modulesView() => ListView(children: [
        ..._modules.asMap().entries.map((entry) {
          final i = entry.key;
          final mod = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: _card(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.drag_indicator, color: Color(0xFF6B7280)),
                    title: Text(
                      mod.title.isNotEmpty ? mod.title : 'Fundamentos da Extrusão',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _blue,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      mod.description.isNotEmpty
                          ? mod.description
                          : 'Entenda os princípios básicos do processo de extrusão.',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 38),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            foregroundColor: const Color(0xFF132B5C),
                            side: const BorderSide(color: Color(0xFF132B5C)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final updated = await Navigator.push<TrainingModule>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ModuleEditorScreen(initialModule: mod),
                              ),
                            );
                            if (updated != null) {
                              setState(() => _modules[i] = updated);
                            }
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text(
                            'Editar Módulo',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 38),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            foregroundColor: const Color(0xFFD93838),
                            side: const BorderSide(color: Color(0xFFD93838)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            setState(() => _modules.removeAt(i));
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text(
                            'Excluir Módulo',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 44),
              foregroundColor: const Color(0xFF132B5C),
              side: const BorderSide(color: Color(0xFF132B5C)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            onPressed: () async {
              final newMod = await Navigator.push<TrainingModule>(
                context,
                MaterialPageRoute(
                  builder: (_) => const ModuleEditorScreen(),
                ),
              );
              if (newMod != null) {
                setState(() => _modules.add(newMod));
              }
            },
            icon: const Icon(Icons.add),
            label: const Text(
              '+ ADICIONAR MÓDULO',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ]);

  Widget _assessment() => ListView(children: [
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: _card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quantidade de questões',
                style: TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '${_questions.length}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _isQuestionCountValid ? const Color(0xFF16A34A) : const Color(0xFFD93838),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'questões cadastradas',
                    style: TextStyle(
                      fontSize: 13,
                      color: _isQuestionCountValid ? const Color(0xFF374151) : const Color(0xFFD93838),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Mínimo: 30 | Máximo: 50 questões',
                style: TextStyle(
                  fontSize: 11,
                  color: _isQuestionCountValid ? const Color(0xFF6B7280) : const Color(0xFFD93838),
                  fontWeight: _isQuestionCountValid ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        _Field(
          'Nota mínima para aprovação',
          controller: _passingGradeController,
          hint: 'Ex: 70',
          keyboardType: TextInputType.number,
        ),
        Container(
          decoration: _card(),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              title: const Text(
                'Gerenciar Questões',
                style: TextStyle(color: _blue, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                _questions.isEmpty
                    ? 'Cadastre e edite as questões da avaliação.'
                    : '${_questions.length} questões cadastradas.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final updated = await Navigator.push<List<TrainingQuestion>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminQuestionListScreen(
                      initialQuestions: _questions,
                      trainingTitle: _titleController.text.trim().isNotEmpty
                          ? _titleController.text.trim()
                          : 'Novo Treinamento',
                    ),
                  ),
                );
                if (updated != null) {
                  setState(() {
                    _questions = updated;
                  });
                }
              },
            ),
          ),
        ),
      ]);

  Future<void> _pickThumbnail() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (mounted) {
      setState(() {
        _thumbnail = image;
        _thumbnailBytes = bytes;
      });
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe o título do treinamento.')),
      );
      return;
    }

    if (!_isQuestionCountValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A avaliação deve conter entre 30 e 50 questões cadastradas.'),
          backgroundColor: Color(0xFFD93838),
        ),
      );
      return;
    }

    final pGrade = int.tryParse(_passingGradeController.text.trim()) ?? 70;
    setState(() => _saving = true);

    try {
      String? finalThumbnailUrl = _existingThumbnailUrl;
      if (_thumbnail != null) {
        finalThumbnailUrl = await ApiClient.instance.uploadImage(_thumbnail!);
      } else if (_thumbnailBytes != null) {
        finalThumbnailUrl = await ApiClient.instance.uploadMediaBytes(
          bytes: _thumbnailBytes!,
          filename: 'training_cover.jpg',
          contentType: 'image/jpeg',
        );
      }

      final trainingToSave = TrainingModel(
        id: widget.initialModel?.id ?? widget.initial?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _categoryId,
        workload: _hoursController.text.trim(),
        thumbnailUrl: finalThumbnailUrl,
        passingGrade: pGrade,
        questionCount: _questions.length,
        modules: _modules,
        questions: _questions,
        totalSteps: _modules.length,
        isDefaultForAllUsers: _isDefaultForAllUsers,
      );

      if (widget.initialModel == null && widget.initial == null) {
        await TrainingService.instance.createTraining(trainingToSave);
      } else {
        final id = widget.initialModel?.id ?? widget.initial!.id;
        await TrainingService.instance.updateTraining(id, trainingToSave);
      }

      await TrainingService.instance.fetchTrainings();

      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar treinamento: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class ModuleEditorScreen extends StatefulWidget {
  final TrainingModule? initialModule;
  const ModuleEditorScreen({super.key, this.initialModule});

  @override
  State<ModuleEditorScreen> createState() => _ModuleEditorScreenState();
}

class _ModuleEditorScreenState extends State<ModuleEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late List<TrainingVideo> _videos;
  late List<TrainingDocument> _documents;

  @override
  void initState() {
    super.initState();
    final mod = widget.initialModule;
    _titleController = TextEditingController(text: mod?.title ?? '');
    _descriptionController = TextEditingController(text: mod?.description ?? '');
    _videos = mod != null && mod.videos.isNotEmpty
        ? List.from(mod.videos)
        : [];
    _documents = mod != null && mod.documents.isNotEmpty
        ? List.from(mod.documents)
        : [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addVideo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Adicionar Vídeo',
                style: TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.video_library_outlined, color: _blue),
                ),
                title: const Text('Selecionar da Galeria / Arquivos (.mp4, .mov)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Carregar arquivo do dispositivo', style: TextStyle(fontSize: 12)),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  final result = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['mp4', 'mov'],
                  );
                  if (result.isNotEmpty) {
                    final file = result.first;
                    setState(() {
                      _videos.add(TrainingVideo(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: file.name,
                        duration: 'Vídeo local',
                        urlOrPath: file.path ?? '',
                      ));
                    });
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.link, color: _blue),
                ),
                title: const Text('Inserir Link de Vídeo Externo (URL)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('YouTube, Vimeo ou link direto', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _showExternalVideoUrlDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExternalVideoUrlDialog() {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '05:00');

    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Vídeo Externo',
          style: TextStyle(color: _blue, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Título do vídeo', hintText: 'Ex: Aula 1 - Extrusão'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(labelText: 'URL do vídeo', hintText: 'https://...'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: durationCtrl,
              decoration: const InputDecoration(labelText: 'Duração estimada', hintText: 'Ex: 05:00'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              final url = urlCtrl.text.trim();
              if (title.isNotEmpty && url.isNotEmpty) {
                setState(() {
                  _videos.add(TrainingVideo(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: title,
                    duration: durationCtrl.text.trim().isNotEmpty ? durationCtrl.text.trim() : '05:00',
                    urlOrPath: url,
                  ));
                });
                Navigator.pop(dlgCtx);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _addDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );
    if (result.isEmpty) return;
    final file = result.first;
    final bytes = file.lengthSync() ?? (await file.length()) ?? 0;
    final sizeInMb = (bytes / (1024 * 1024)).toStringAsFixed(1);
    final ext = (file.extension ?? 'pdf').toUpperCase();

    setState(() {
      _documents.add(TrainingDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: file.name,
        fileSize: '$ext - $sizeInMb MB',
        extension: ext,
        urlOrPath: file.path ?? '',
      ));
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe o título do módulo.')),
      );
      return;
    }
    final mod = TrainingModule(
      id: widget.initialModule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      order: widget.initialModule?.order ?? 1,
      title: title,
      description: _descriptionController.text.trim(),
      videos: _videos,
      documents: _documents,
      isCompleted: widget.initialModule?.isCompleted ?? false,
    );
    Navigator.pop(context, mod);
  }

  @override
  Widget build(BuildContext context) => _Shell(
    title: widget.initialModule == null ? 'Novo Módulo' : 'Editar Módulo',
    admin: true,
    fallbackRoute: PextRoutes.training,
    child: ListView(
      children: [
        _Field('Título do módulo', controller: _titleController, hint: 'Ex: Fundamentos da Extrusão'),
        _Field('Descrição curta', controller: _descriptionController, lines: 4, hint: 'Descreva o módulo'),
        
        // Vídeos do módulo
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Vídeos do módulo',
            style: TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        ..._videos.asMap().entries.map((entry) {
          final idx = entry.key;
          final vid = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: _card(),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: _blue, size: 28),
              ),
              title: Text(
                vid.title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: _blue, fontSize: 14),
              ),
              subtitle: Text(
                vid.duration,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF4B5563)),
                onPressed: () => setState(() => _videos.removeAt(idx)),
              ),
            ),
          );
        }),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 42),
              foregroundColor: const Color(0xFF132B5C),
              side: const BorderSide(color: Color(0xFF132B5C)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
            ),
            onPressed: _addVideo,
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('ADICIONAR', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),

        // Documentos
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Documentos',
            style: TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        ..._documents.asMap().entries.map((entry) {
          final idx = entry.key;
          final doc = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: _card(),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: _card(),
                alignment: Alignment.center,
                child: const PextAssetIcon(PextAssets.pdf, size: 26),
              ),
              title: Text(
                doc.title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: _blue, fontSize: 14),
              ),
              subtitle: Text(
                doc.fileSize,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF4B5563)),
                onPressed: () => setState(() => _documents.removeAt(idx)),
              ),
            ),
          );
        }),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 42),
              foregroundColor: const Color(0xFF132B5C),
              side: const BorderSide(color: Color(0xFF132B5C)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
            ),
            onPressed: _addDocument,
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('ADICIONAR', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _save,
            child: Text(widget.initialModule == null ? 'CADASTRAR' : 'SALVAR'),
          ),
        ),
      ],
    ),
  );
}

class AdminQuestionListScreen extends StatefulWidget {
  final List<TrainingQuestion> initialQuestions;
  final String? trainingTitle;
  const AdminQuestionListScreen({
    super.key,
    this.initialQuestions = const [],
    this.trainingTitle,
  });

  @override
  State<AdminQuestionListScreen> createState() => _AdminQuestionListScreenState();
}

class _AdminQuestionListScreenState extends State<AdminQuestionListScreen> {
  late List<TrainingQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _questions = widget.initialQuestions.isNotEmpty
        ? List.from(widget.initialQuestions)
        : List.generate(
            10,
            (index) => TrainingQuestion(
              id: 'q_$index',
              order: index + 1,
              prompt: 'Qual é a principal função da temperatura de extrusão no processo?',
              type: 'MULTIPLE_CHOICE',
              alternatives: [
                const TrainingAlternative(id: 'a1', letter: 'A', text: 'Alternativa da questão', isCorrect: true),
                const TrainingAlternative(id: 'a2', letter: 'B', text: 'Alternativa da questão', isCorrect: false),
                const TrainingAlternative(id: 'a3', letter: 'C', text: 'Alternativa da questão', isCorrect: false),
                const TrainingAlternative(id: 'a4', letter: 'D', text: 'Alternativa da questão', isCorrect: false),
              ],
            ),
          );
  }

  String _formatType(String type) {
    switch (type) {
      case 'SINGLE_CHOICE':
        return 'Resposta única';
      case 'TRUE_FALSE':
        return 'Verdadeiro ou Falso';
      case 'MULTIPLE_CHOICE':
      default:
        return 'Múltipla escolha';
    }
  }

  void _addQuestion() async {
    final newQuestion = await Navigator.push<TrainingQuestion>(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionTypeSelectorScreen(trainingTitle: widget.trainingTitle),
      ),
    );
    if (newQuestion != null && mounted) {
      setState(() => _questions.add(newQuestion));
    }
  }

  void _editQuestion(int index) async {
    final q = _questions[index];
    int qType = 0;
    if (q.type == 'TRUE_FALSE') qType = 1;
    if (q.type == 'MULTIPLE_CHOICE') qType = 2;

    final updated = await Navigator.push<TrainingQuestion>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminQuestionEditorScreen(
          initialType: qType,
          initialQuestion: q,
          trainingTitle: widget.trainingTitle,
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _questions[index] = updated);
    }
  }

  @override
  Widget build(BuildContext context) => _Shell(
    title: 'Questões',
    admin: true,
    fallbackRoute: PextRoutes.training,
    child: ListView(
      children: [
        _AddContentButton(onTap: _addQuestion),
        const SizedBox(height: 10),
        ..._questions.asMap().entries.map((entry) {
          final index = entry.key;
          final q = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: _card(),
            child: ListTile(
              leading: Text(
                '${index + 1}.',
                style: const TextStyle(fontWeight: FontWeight.bold, color: _blue, fontSize: 15),
              ),
              title: Text(
                q.prompt,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                _formatType(q.type),
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF132B5C)),
                    onPressed: () => _editQuestion(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFD93838)),
                    onPressed: () => setState(() => _questions.removeAt(index)),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context, _questions),
            child: const Text('SALVAR QUESTÕES'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context, _questions),
            child: const Text('FECHAR'),
          ),
        ),
      ],
    ),
  );
}

class QuestionTypeSelectorScreen extends StatefulWidget {
  final String? trainingTitle;
  const QuestionTypeSelectorScreen({super.key, this.trainingTitle});

  @override
  State<QuestionTypeSelectorScreen> createState() =>
      _QuestionTypeSelectorScreenState();
}

class _QuestionTypeSelectorScreenState
    extends State<QuestionTypeSelectorScreen> {
  int selected = 0;
  static const types = [
    ('Resposta Única', 'Apenas uma alternativa.', Icons.radio_button_checked),
    ('Verdadeiro ou Falso', 'Defina o que é verdadeiro ou falso.', Icons.compare_arrows),
    ('Múltipla Escolha', 'Pode conter mais de uma alternativa correta.', Icons.checklist),
  ];

  @override
  Widget build(BuildContext context) => _Shell(
    title: 'Questões',
    admin: true,
    fallbackRoute: PextRoutes.training,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.trainingTitle ?? 'Título do Treinamento',
          style: const TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView.builder(
            itemCount: types.length,
            itemBuilder: (_, index) {
              final item = types[index];
              final isSel = selected == index;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSel ? _blue : _border,
                    width: isSel ? 1.5 : 1.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onTap: () => setState(() => selected = index),
                    leading: Icon(
                      isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSel ? _blue : const Color(0xFF6B7280),
                      size: 24,
                    ),
                    title: Text(
                      item.$1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isSel ? _blue : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      item.$2,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    trailing: Icon(item.$3, color: _blue, size: 24),
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  foregroundColor: const Color(0xFF132B5C),
                  side: const BorderSide(color: Color(0xFF132B5C)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('ANTERIOR', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  backgroundColor: const Color(0xFF415285),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () async {
                  final created = await Navigator.push<TrainingQuestion>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminQuestionEditorScreen(
                        initialType: selected,
                        trainingTitle: widget.trainingTitle,
                      ),
                    ),
                  );
                  if (created != null && mounted) {
                    Navigator.pop(context, created);
                  }
                },
                child: const Text('PRÓXIMO', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}

class AdminQuestionEditorScreen extends StatefulWidget {
  final int initialType;
  final TrainingQuestion? initialQuestion;
  final String? trainingTitle;
  final bool returnToList;
  const AdminQuestionEditorScreen({
    super.key,
    this.initialType = 0,
    this.initialQuestion,
    this.trainingTitle,
    this.returnToList = false,
  });

  @override
  State<AdminQuestionEditorScreen> createState() =>
      _AdminQuestionEditorScreenState();
}

class _AdminQuestionEditorScreenState
    extends State<AdminQuestionEditorScreen> {
  late int type;
  late final TextEditingController _promptController;
  final List<String> _alternatives = [];
  final Set<int> _correct = {};
  XFile? _imageFile;
  Uint8List? _imageBytes;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    type = widget.initialType;
    final q = widget.initialQuestion;
    _promptController = TextEditingController(text: q?.prompt ?? '');
    _existingImageUrl = q?.imageUrl;

    if (q != null && q.alternatives.isNotEmpty) {
      for (int i = 0; i < q.alternatives.length; i++) {
        _alternatives.add(q.alternatives[i].text);
        if (q.alternatives[i].isCorrect) {
          _correct.add(i);
        }
      }
    } else {
      if (type == 1) {
        _alternatives.addAll(['Verdadeiro', 'Falso']);
        _correct.add(0);
      } else {
        _alternatives.addAll([
          'Alternativa da questão',
          'Alternativa da questão',
        ]);
        _correct.add(0);
      }
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;
    final bytes = await img.readAsBytes();
    if (mounted) {
      setState(() {
        _imageFile = img;
        _imageBytes = bytes;
      });
    }
  }

  void _editAlternative(int? index) {
    final controller = TextEditingController(
      text: index == null ? '' : _alternatives[index],
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alternativa',
              style: TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Ex: Resposta aqui'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final value = controller.text.trim();
                  if (value.isNotEmpty) {
                    setState(() {
                      if (index == null) {
                        _alternatives.add(value);
                      } else {
                        _alternatives[index] = value;
                      }
                    });
                  }
                  Navigator.pop(sheetContext);
                },
                child: Text(index == null ? 'ADICIONAR' : 'SALVAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveQuestion() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe o enunciado da questão.')),
      );
      return;
    }

    if (_alternatives.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos uma alternativa.')),
      );
      return;
    }

    if (_correct.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a alternativa correta.')),
      );
      return;
    }

    String typeStr = 'SINGLE_CHOICE';
    if (type == 1) typeStr = 'TRUE_FALSE';
    if (type == 2) typeStr = 'MULTIPLE_CHOICE';

    String? imageUrl = _existingImageUrl;
    if (_imageFile != null) {
      imageUrl = await ApiClient.instance.uploadImage(_imageFile!);
    } else if (_imageBytes != null) {
      imageUrl = await ApiClient.instance.uploadMediaBytes(
        bytes: _imageBytes!,
        filename: 'question_image.jpg',
        contentType: 'image/jpeg',
      );
    }

    const letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    final alts = <TrainingAlternative>[];
    for (int i = 0; i < _alternatives.length; i++) {
      String letter = type == 1 ? (i == 0 ? 'V' : 'F') : (i < letters.length ? letters[i] : '$i');
      alts.add(TrainingAlternative(
        id: 'alt_$i',
        letter: letter,
        text: _alternatives[i],
        isCorrect: _correct.contains(i),
      ));
    }

    final question = TrainingQuestion(
      id: widget.initialQuestion?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      order: widget.initialQuestion?.order ?? 1,
      prompt: prompt,
      type: typeStr,
      imageUrl: imageUrl,
      alternatives: alts,
    );

    Navigator.pop(context, question);
  }

  @override
  Widget build(BuildContext context) => _Shell(
    title: 'Questões',
    admin: true,
    fallbackRoute: PextRoutes.training,
    child: Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              _Field(
                'Enunciado da questão',
                controller: _promptController,
                lines: 4,
                hint: 'Ex: Material irregular na matriz',
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Imagem (opcional)',
                  style: TextStyle(color: _blue, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(12),
                child: _imageBytes != null
                    ? Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _imageBytes!,
                              height: 135,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          IconButton(
                            icon: const CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 14,
                              child: Icon(Icons.close, size: 16, color: Colors.black),
                            ),
                            onPressed: () => setState(() {
                              _imageFile = null;
                              _imageBytes = null;
                            }),
                          ),
                        ],
                      )
                    : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty
                        ? Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  ApiClient.instance.resolveMediaUrl(_existingImageUrl!),
                                  height: 135,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const _UploadDropZone('Clique para enviar a imagem'),
                                ),
                              ),
                              IconButton(
                                icon: const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 14,
                                  child: Icon(Icons.close, size: 16, color: Colors.black),
                                ),
                                onPressed: () => setState(() => _existingImageUrl = null),
                              ),
                            ],
                          )
                        : const _UploadDropZone('Clique para enviar a imagem')),
              ),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Alternativas',
                  style: TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 6),
              ...List.generate(
                _alternatives.length,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: _card(),
                  child: ListTile(
                    leading: Text(
                      type == 1 ? (index == 0 ? 'V' : 'F') : 'ABCD'[index % 4],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _blue,
                        fontSize: 16,
                      ),
                    ),
                    title: Text(_alternatives[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (type == 2)
                          Checkbox(
                            value: _correct.contains(index),
                            activeColor: _blue,
                            onChanged: (value) => setState(() {
                              if (value == true) {
                                _correct.add(index);
                              } else {
                                _correct.remove(index);
                              }
                            }),
                          )
                        else
                          Radio<int>(
                            value: index,
                            groupValue: _correct.isEmpty ? null : _correct.first,
                            activeColor: _blue,
                            onChanged: (value) => setState(() {
                              _correct
                                ..clear()
                                ..add(value!);
                            }),
                          ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Color(0xFF132B5C), size: 20),
                          onPressed: () => _editAlternative(index),
                        ),
                        if (type != 1 && _alternatives.length > 2)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFD93838), size: 20),
                            onPressed: () => setState(() {
                              _alternatives.removeAt(index);
                              _correct.remove(index);
                            }),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (type != 1)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        foregroundColor: const Color(0xFF132B5C),
                        side: const BorderSide(color: Color(0xFF132B5C)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      ),
                      onPressed: () => _editAlternative(null),
                      icon: const Icon(Icons.add),
                      label: const Text('ADICIONAR ALTERNATIVA', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  foregroundColor: const Color(0xFF132B5C),
                  side: const BorderSide(color: Color(0xFF132B5C)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('ANTERIOR', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  backgroundColor: const Color(0xFF415285),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: _saveQuestion,
                child: const Text('PRÓXIMO', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}

class ChatAssistantScreen extends StatefulWidget {
  final bool admin;
  const ChatAssistantScreen({super.key, this.admin = false});

  @override
  State<ChatAssistantScreen> createState() => _ChatAssistantScreenState();
}

class _ChatAssistantScreenState extends State<ChatAssistantScreen> {
  int _tab = 0;
  int _userTab = 0;
  final _chatKey = GlobalKey<_AssistantChatTabState>();

  @override
  void initState() {
    super.initState();
    ChatService.instance.fetchSessions();
  }

  Future<void> _confirmClearChat(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Limpar conversa',
            style: TextStyle(color: _blue, fontWeight: FontWeight.bold)),
        content: const Text('Deseja limpar todo o histórico desta conversa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD93838)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _chatKey.currentState?.clearConversation();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.admin) {
      return _Shell(
        title: 'Assistente IA',
        admin: false,
        action: _userTab == 0
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BoxedHeaderAction(
                    icon: Icons.add_comment_outlined,
                    onTap: () {
                      _chatKey.currentState?.startNewSession();
                    },
                  ),
                  _BoxedHeaderAction(
                    icon: Icons.delete_sweep_outlined,
                    onTap: () => _confirmClearChat(context),
                  ),
                ],
              )
            : _BoxedHeaderAction(
                icon: Icons.delete_sweep_outlined,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Limpar histórico',
                          style: TextStyle(color: _blue, fontWeight: FontWeight.bold)),
                      content:
                          const Text('Deseja excluir todo o histórico de conversas?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFD93838)),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Excluir tudo'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ChatService.instance.clearAllSessions();
                  }
                },
              ),
        child: Column(
          children: [
            _TabBar(
              labels: const ['Chat', 'Histórico'],
              value: _userTab,
              onChanged: (value) => setState(() => _userTab = value),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: IndexedStack(
                index: _userTab,
                children: [
                  _AssistantChatTab(key: _chatKey, isAdmin: false),
                  _UserChatHistoryTab(
                    onSelectSession: (session) {
                      _chatKey.currentState?.loadSession(session);
                      setState(() => _userTab = 0);
                    },
                    onNewChat: () {
                      _chatKey.currentState?.startNewSession();
                      setState(() => _userTab = 0);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _Shell(
        title: 'Assistente IA',
        admin: true,
        action: _tab == 3
            ? _BoxedHeaderAction(
                icon: Icons.add,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const CadastroConteudoScreen())))
            : (_tab == 0
                ? _BoxedHeaderAction(
                    icon: Icons.delete_sweep_outlined,
                    onTap: () => _confirmClearChat(context))
                : null),
        child: Column(children: [
          _TabBar(
              labels: const ['Chat', 'Histórico', 'Dúvidas', 'Conteúdo'],
              value: _tab,
              onChanged: (value) => setState(() => _tab = value)),
          const SizedBox(height: 14),
          Expanded(
              child: IndexedStack(index: _tab, children: [
            _AssistantChatTab(key: _chatKey, isAdmin: true),
            _UserChatHistoryTab(
              onSelectSession: (session) {
                _chatKey.currentState?.loadSession(session);
                setState(() => _tab = 0);
              },
              onNewChat: () {
                _chatKey.currentState?.startNewSession();
                setState(() => _tab = 0);
              },
            ),
            const _DuvidasTabView(),
            const _ConteudoTabView(),
          ]))
        ]));
  }
}

class _UserChatHistoryTab extends StatelessWidget {
  final ValueChanged<ChatSession> onSelectSession;
  final VoidCallback onNewChat;

  const _UserChatHistoryTab({
    required this.onSelectSession,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ChatService.instance,
      builder: (context, _) {
        final sessions = ChatService.instance.sessions;
        if (sessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.forum_outlined, color: _blue, size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nenhum histórico disponível',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _blue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Suas conversas com o assistente IA aparecerão aqui.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: _blue),
                  onPressed: onNewChat,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Iniciar nova conversa'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: onNewChat,
                  icon: const Icon(Icons.add_comment_outlined, size: 18),
                  label: const Text(
                    'NOVA CONVERSA',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  final formattedDate =
                      '${session.updatedAt.day.toString().padLeft(2, '0')}/${session.updatedAt.month.toString().padLeft(2, '0')}/${session.updatedAt.year} ${session.updatedAt.hour.toString().padLeft(2, '0')}:${session.updatedAt.minute.toString().padLeft(2, '0')}';

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onSelectSession(session),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: _card(),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.chat_bubble_outline,
                                color: _blue, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        session.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: _blue,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  session.lastMessageSnippet.isNotEmpty
                                      ? session.lastMessageSnippet
                                      : '${session.messages.length} mensagens',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Color(0xFF9CA3AF), size: 20),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Excluir conversa',
                                      style: TextStyle(
                                          color: _blue,
                                          fontWeight: FontWeight.bold)),
                                  content:
                                      Text('Deseja excluir "${session.title}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFD93838)),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Excluir'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ChatService.instance
                                    .deleteSession(session.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AssistantMessage {
  final String text;
  final bool mine;
  final bool isAdmin;
  final String? adminName;
  final bool canEscalate;
  final bool isLoading;
  final bool isSystemNotification;

  const _AssistantMessage({
    required this.text,
    required this.mine,
    this.isAdmin = false,
    this.adminName,
    this.canEscalate = false,
    this.isLoading = false,
    this.isSystemNotification = false,
  });
}

class _AssistantChatTab extends StatefulWidget {
  final bool isAdmin;
  const _AssistantChatTab({super.key, this.isAdmin = false});

  @override
  State<_AssistantChatTab> createState() => _AssistantChatTabState();
}

class _AssistantChatTabState extends State<_AssistantChatTab> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;
  bool _hasOpenEscalation = false;
  String _sessionId = '';
  String _sessionTitle = '';

  final _messages = <_AssistantMessage>[
    const _AssistantMessage(
        text: 'Como posso ajudar na sua operação hoje?', mine: false),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void loadSession(ChatSession session) {
    setState(() {
      _sessionId = session.id;
      _sessionTitle = session.title;
      _messages.clear();
      for (final m in session.messages) {
        _messages.add(_AssistantMessage(
          text: m['text']?.toString() ?? '',
          mine: m['mine'] == true,
          canEscalate: m['canEscalate'] == true,
          isAdmin: m['isAdmin'] == true,
          adminName: m['adminName']?.toString(),
        ));
      }
      if (_messages.isEmpty) {
        _messages.add(const _AssistantMessage(
          text: 'Como posso ajudar na sua operação hoje?',
          mine: false,
        ));
      }
      _hasOpenEscalation = false;
    });
    _scrollToBottom();
  }

  void startNewSession() {
    setState(() {
      _sessionId = '';
      _sessionTitle = '';
      _messages.clear();
      _messages.add(const _AssistantMessage(
        text: 'Como posso ajudar na sua operação hoje?',
        mine: false,
      ));
      _hasOpenEscalation = false;
    });
    _scrollToBottom();
  }

  void clearConversation() {
    if (_sessionId.isNotEmpty) {
      ChatService.instance.deleteSession(_sessionId);
    }
    startNewSession();
  }

  void _saveCurrentSession(String lastAnswer) {
    if (_sessionId.isEmpty) {
      _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    }
    final session = ChatSession(
      id: _sessionId,
      title: _sessionTitle.isNotEmpty ? _sessionTitle : 'Conversa com IA',
      lastMessageSnippet: lastAnswer.length > 60
          ? '${lastAnswer.substring(0, 60)}...'
          : lastAnswer,
      updatedAt: DateTime.now(),
      messages: _messages
          .where((m) => !m.isLoading && !m.isSystemNotification)
          .map((m) => {
                'text': m.text,
                'mine': m.mine,
                'canEscalate': m.canEscalate,
                'isAdmin': m.isAdmin,
                'adminName': m.adminName,
              })
          .toList(),
    );
    ChatService.instance.saveSession(session);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    if (_sessionId.isEmpty && !widget.isAdmin) {
      _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
      _sessionTitle = text.length > 35 ? '${text.substring(0, 35)}...' : text;
    }

    final history = _messages
        .where((m) => !m.isLoading && !m.isSystemNotification)
        .map((m) => {
              'role': m.mine ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();

    setState(() {
      _messages.add(_AssistantMessage(text: text, mine: true));
      _messages.add(const _AssistantMessage(
          text: '',
          mine: false,
          isLoading: true));
      _sending = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response =
          await ChatService.instance.sendMessage(text, history: history);
      final answer = response['answer']?.toString() ??
          'Como posso ajudar você em relação à sua dúvida?';
      final canEscalate = response['canEscalate'] == true;

      if (!mounted) return;
      setState(() {
        _messages.removeLast(); // remove loading message
        _messages.add(_AssistantMessage(
          text: answer,
          mine: false,
          canEscalate: canEscalate,
        ));
        _sending = false;
      });
      _saveCurrentSession(answer);
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.removeLast();
        _messages.add(const _AssistantMessage(
          text:
              'Desculpe, ocorreu uma instabilidade na conexão com o assistente. Por favor, tente novamente.',
          mine: false,
          canEscalate: true,
        ));
        _sending = false;
      });
      _saveCurrentSession('Desculpe, ocorreu uma instabilidade na conexão.');
      _scrollToBottom();
    }
  }

  Future<void> _escalateToAdmin(String query) async {
    try {
      await DoubtService.instance.createDoubt(query);
      if (!mounted) return;
      setState(() {
        _hasOpenEscalation = true;
        _messages.add(const _AssistantMessage(
          text:
              'Sua dúvida foi encaminhada para a equipe de administração! Você pode acompanhar e receber respostas na aba "Dúvidas".',
          mine: false,
          isSystemNotification: true,
        ));
      });
      _scrollToBottom();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Dúvida encaminhada com sucesso para o Administrador!'),
        backgroundColor: Color(0xFF20BF64),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao encaminhar dúvida: $e'),
        backgroundColor: const Color(0xFFF8494E),
      ));
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: _messages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final msg = _messages[index];
              return Column(
                crossAxisAlignment: msg.mine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (msg.isAdmin)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 12,
                            backgroundImage:
                                AssetImage('images/profile_igor.png'),
                          ),
                          const SizedBox(width: 6),
                          const _StatusBadge(
                            label: 'ADM',
                            color: _blue,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              msg.adminName ?? 'Administrador PEXT',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (msg.isLoading)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 270),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4E7EC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: _blue),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Digitando resposta...',
                              style: TextStyle(
                                color: Color(0xFF363C46),
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    _ChatBubble(msg.text, msg.mine),
                  if (msg.canEscalate && !widget.isAdmin)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: _hasOpenEscalation
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFFE5E7EB)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      size: 15, color: Color(0xFF16A34A)),
                                  SizedBox(width: 5),
                                  Text(
                                    'Dúvida enviada ao ADM',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF4B5563),
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            )
                          : OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFD93838),
                                side:
                                    const BorderSide(color: Color(0xFFD93838)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                              ),
                              icon: const Icon(Icons.help_outline, size: 16),
                              label: const Text(
                                'Abrir dúvida para o ADM',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                              onPressed: () {
                                final lastUserMsg = _messages
                                    .lastWhere((m) => m.mine,
                                        orElse: () => _AssistantMessage(
                                            text: msg.text, mine: true))
                                    .text;
                                _escalateToAdmin(lastUserMsg);
                              },
                            ),
                    ),
                ],
              );
            },
          ),
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 14),
                  hintText: 'Faça sua pergunta',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _sending ? null : _send,
              child: Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(11),
                decoration: const BoxDecoration(
                  color: _blue,
                  borderRadius:
                      BorderRadius.horizontal(right: Radius.circular(14)),
                ),
                child: const PextAssetIcon(PextAssets.send, size: 24),
              ),
            )
          ]),
        ),
      ]);
}

class _DuvidasTabView extends StatefulWidget {
  const _DuvidasTabView();

  @override
  State<_DuvidasTabView> createState() => _DuvidasTabViewState();
}

class _DuvidasTabViewState extends State<_DuvidasTabView> {
  int _filter = 0;

  @override
  void initState() {
    super.initState();
    DoubtService.instance.fetchDoubts();
  }

  List<DoubtModel> _defaultSeedDoubts() => const [
        DoubtModel(
          id: 'seed-1',
          userId: 'u1',
          userName: 'Igor Teixeira Corturato',
          userAvatarUrl: 'images/profile_igor.png',
          question:
              'O que pode fazer o material sair da matriz de forma irregular',
          status: 'RESPONDIDO',
          createdAt: '08/08/2026',
          messages: [
            DoubtMessage(
              id: 'm1',
              senderId: 'u1',
              senderName: 'Igor Teixeira Corturato',
              senderRole: 'USER',
              text:
                  'O que pode fazer o material sair da matriz de forma irregular',
              createdAt: '08/08/2026 - 10:00',
            ),
            DoubtMessage(
              id: 'm2',
              senderId: 'admin1',
              senderName: 'Administrador PEXT',
              senderRole: 'ADMIN',
              text:
                  'Geralmente ocorre por variação de temperatura nas zonas do cabeçote ou obstrução parcial dos lábios da matriz. Verifique o perfil térmico e realize limpeza se necessário.',
              createdAt: '08/08/2026 - 10:15',
            ),
          ],
        ),
        DoubtModel(
          id: 'seed-2',
          userId: 'u1',
          userName: 'Igor Teixeira Corturato',
          userAvatarUrl: 'images/profile_igor.png',
          question:
              'O que pode fazer o material sair da matriz de forma irregular',
          status: 'RESPONDIDO',
          createdAt: '08/08/2026',
          messages: [
            DoubtMessage(
              id: 'm3',
              senderId: 'u1',
              senderName: 'Igor Teixeira Corturato',
              senderRole: 'USER',
              text:
                  'O que pode fazer o material sair da matriz de forma irregular',
              createdAt: '08/08/2026 - 11:20',
            ),
          ],
        ),
        DoubtModel(
          id: 'seed-3',
          userId: 'u1',
          userName: 'Igor Teixeira Corturato',
          userAvatarUrl: 'images/profile_igor.png',
          question:
              'O que pode fazer o material sair da matriz de forma irregular',
          status: 'NAO_RESPONDIDO',
          createdAt: '08/08/2026',
          messages: [
            DoubtMessage(
              id: 'm4',
              senderId: 'u1',
              senderName: 'Igor Teixeira Corturato',
              senderRole: 'USER',
              text:
                  'O que pode fazer o material sair da matriz de forma irregular',
              createdAt: '08/08/2026 - 14:00',
            ),
          ],
        ),
        DoubtModel(
          id: 'seed-4',
          userId: 'u1',
          userName: 'Igor Teixeira Corturato',
          userAvatarUrl: 'images/profile_igor.png',
          question:
              'O que pode fazer o material sair da matriz de forma irregular',
          status: 'NAO_RESPONDIDO',
          createdAt: '08/08/2026',
        ),
      ];

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(
        listenable: DoubtService.instance,
        builder: (context, _) {
          final allDoubts = DoubtService.instance.doubts.isNotEmpty
              ? DoubtService.instance.doubts
              : _defaultSeedDoubts();

          final shown = allDoubts.where((d) {
            if (_filter == 1) return d.isAnswered;
            if (_filter == 2) return !d.isAnswered;
            return true;
          }).toList();

          return Column(children: [
            _FilterRow(
              labels: const ['Todos', 'Respondido', 'Não respondida'],
              value: _filter,
              onChanged: (value) => setState(() => _filter = value),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: shown.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final doubt = shown[index];
                  return _QuestionCard(
                    doubt: doubt,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DoubtThreadScreen(doubt: doubt),
                        ),
                      );
                      setState(() {});
                    },
                  );
                },
              ),
            ),
          ]);
        },
      );
}

class _QuestionCard extends StatelessWidget {
  final DoubtModel doubt;
  final VoidCallback? onTap;

  const _QuestionCard({required this.doubt, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color =
        doubt.isAnswered ? const Color(0xFF20BF64) : const Color(0xFFF8494E);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _card(),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('images/profile_igor.png'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${doubt.userName} - ${doubt.createdAt.contains('T') ? doubt.createdAt.split('T').first : doubt.createdAt}',
                        style:
                            const TextStyle(fontSize: 9, color: Color(0xFF737D8C)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (doubt.machineId != null && doubt.machineId!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _blue.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          '[${doubt.machineId}]',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: _blue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  doubt.question,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 9),
                _StatusBadge(
                  label: doubt.isAnswered ? 'RESPONDIDA' : 'ABERTA',
                  color: color,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 25),
            child: Icon(Icons.chevron_right, color: Color(0xFF26313D)),
          ),
        ]),
      ),
    );
  }
}

class DoubtThreadScreen extends StatefulWidget {
  final DoubtModel doubt;
  final bool admin;
  const DoubtThreadScreen({super.key, required this.doubt, this.admin = false});

  @override
  State<DoubtThreadScreen> createState() => _DoubtThreadScreenState();
}

class _DoubtThreadScreenState extends State<DoubtThreadScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late DoubtModel _doubt;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _doubt = widget.doubt;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _controller.clear();

    try {
      final msg = await DoubtService.instance.replyDoubt(_doubt.id, text);
      if (!mounted) return;
      setState(() {
        _doubt = _doubt.copyWith(
          status: 'RESPONDIDO',
          messages: List<DoubtMessage>.from(_doubt.messages)..add(msg),
        );
        _sending = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (_) {
      // Local fallback
      if (!mounted) return;
      final localMsg = DoubtMessage(
        id: UniqueKey().toString(),
        senderId: 'admin',
        senderName: 'Administrador PEXT',
        senderRole: 'ADMIN',
        text: text,
        createdAt: 'Agora',
      );
      setState(() {
        _doubt = _doubt.copyWith(
          status: 'RESPONDIDO',
          messages: List<DoubtMessage>.from(_doubt.messages)..add(localMsg),
        );
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Assistente IA',
        admin: widget.admin,
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: _card(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('images/profile_igor.png'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_doubt.userName} - ${_doubt.createdAt}',
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF737D8C)),
                      ),
                      const SizedBox(height: 6),
                      if (_doubt.verificationData != null &&
                          _doubt.verificationData!.isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.rule_outlined,
                                      size: 14, color: _blue),
                                  SizedBox(width: 4),
                                  Text(
                                    'Parâmetros de Verificação',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: _blue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ...(_doubt.verificationData!.entries.map((entry) {
                                final val = entry.value;
                                if (val is Map) {
                                  final pName =
                                      val['parameterName'] ?? entry.key;
                                  final target = val['target'] ?? '-';
                                  final measured =
                                      val['measuredValue'] ?? '-';
                                  final dev = val['deviation'] ?? '-';
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 1),
                                    child: Text(
                                      '$pName: Alvo=$target | Lido=$measured | Desvio=$dev',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF334155),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }
                                return Text(
                                  '${entry.key}: ${entry.value}',
                                  style: const TextStyle(
                                      fontSize: 10, color: Color(0xFF334155)),
                                );
                              })),
                            ],
                          ),
                        ),
                      ],
                      Text(
                        _doubt.question,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      _StatusBadge(
                        label:
                            _doubt.isAnswered ? 'RESPONDIDA' : 'ABERTA',
                        color: _doubt.isAnswered
                            ? const Color(0xFF20BF64)
                            : const Color(0xFFF8494E),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              itemCount: _doubt.messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final message = _doubt.messages[index];
                if (message.isAdmin) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD0DCEE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const CircleAvatar(
                            radius: 14,
                            backgroundImage:
                                AssetImage('images/profile_igor.png'),
                          ),
                          const SizedBox(width: 8),
                          const _StatusBadge(label: 'ADM', color: _blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              message.senderName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _blue),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            message.createdAt,
                            style: const TextStyle(
                                fontSize: 9, color: Color(0xFF737D8C)),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Text(
                          message.text,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF1F2937)),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: _card(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(
                            message.senderName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          message.createdAt,
                          style: const TextStyle(
                              fontSize: 9, color: Color(0xFF737D8C)),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      Text(
                        message.text,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF374151)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _sendReply(),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 14),
                    hintText: 'Responder como Administrador...',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _sending ? null : _sendReply,
                child: Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(11),
                  decoration: const BoxDecoration(
                    color: _blue,
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(14)),
                  ),
                  child: const PextAssetIcon(PextAssets.send, size: 24),
                ),
              ),
            ]),
          ),
        ]),
      );
}

class _ConteudoTabView extends StatefulWidget {
  const _ConteudoTabView();

  @override
  State<_ConteudoTabView> createState() => _ConteudoTabViewState();
}

class _ConteudoTabViewState extends State<_ConteudoTabView> {
  int _filter = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    ContentService.instance.fetchContents();
  }

  List<ContentModel> _defaultSeedContents() => [
        ContentModel(
          id: 'seed-content-1',
          title: 'Material irregular na matriz',
          text:
              'Quando identificado material irregular na matriz, realizar a inspeção da peça e verificar se a ocorrência compromete o padrão de qualidade estabelecido. Caso seja constatada irregularidade, separar a peça e encaminhá-la para avaliação.',
          categoryName: 'Extrusão',
          documentName: 'Ficha Técnica.pdf',
          documentSize: 'PDF - 1,2 MB',
          authorName: 'André',
          status: 'ATIVO',
          createdAt: '01/08/2026 - 09:33',
          updatedAt: '03/07/2026 - 11:35',
          history: const [
            ContentAuditEntry(
              id: 'h1',
              authorName: 'André',
              action: 'CREATE',
              date: '01/08/2026 - 09:33',
              title: 'André criou este conteúdo.',
              description: 'Conteúdo inicial adicionado.',
            ),
            ContentAuditEntry(
              id: 'h2',
              authorName: 'Maria',
              action: 'UPDATE',
              date: '02/08/2026 - 09:43',
              title: 'Maria editou o conteúdo',
              description: 'Alterações:\n- Inclusão de Documento',
              previousContent: {
                'title': 'Material irregular na matriz',
                'text':
                    'Quando identificado material irregular na matriz, realizar a inspeção da peça e verificar se a ocorrência compromete o padrão de qualidade estabelecido. Caso seja constatada irregularidade, separar a peça e encaminhá-la para avaliação.',
                'date': '02/08/2026 - 09:40',
                'documentName': null,
              },
            ),
            ContentAuditEntry(
              id: 'h3',
              authorName: 'Jorge',
              action: 'UPDATE',
              date: '05/08/2026 - 09:43',
              title: 'Jorge editou o conteúdo',
              description: 'Alterações:\n- Removeu um documento',
              previousContent: {
                'title': 'Material irregular na matriz',
                'text':
                    'Quando identificado material irregular na matriz, a peça deve ser imediatamente segregada e registrada como não conforme. A ocorrência deve ser avaliada conforme o padrão de qualidade vigente.',
                'date': '05/08/2026 - 09:35',
                'documentName': 'Ficha Técnica.pdf',
              },
            ),
          ],
        ),
        ContentModel(
          id: 'seed-content-2',
          title: 'Material irregular na matriz',
          text:
              'Quando identificado material irregular na matriz, realizar a inspeção da peça e verificar se a ocorrência compromete o padrão de qualidade estabelecido.',
          categoryName: 'Extrusão',
          authorName: 'André',
          status: 'ATIVO',
          createdAt: '01/08/2026',
          updatedAt: '03/07/2026 - 11:35',
        ),
        ContentModel(
          id: 'seed-content-3',
          title: 'Material irregular na matriz',
          text:
              'Quando identificado material irregular na matriz, realizar a inspeção da peça e verificar se a ocorrência compromete o padrão de qualidade estabelecido.',
          categoryName: 'Extrusão',
          authorName: 'André',
          status: 'ATIVO',
          createdAt: '01/08/2026',
          updatedAt: '03/07/2026 - 11:35',
        ),
        ContentModel(
          id: 'seed-content-4',
          title: 'Material irregular na matriz',
          text:
              'Quando identificado material irregular na matriz, realizar a inspeção da peça e verificar se a ocorrência compromete o padrão de qualidade estabelecido.',
          categoryName: 'Extrusão',
          authorName: 'André',
          status: 'EXCLUIDO',
          createdAt: '01/08/2026',
          updatedAt: '03/07/2026 - 11:35',
        ),
      ];

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(
        listenable: ContentService.instance,
        builder: (context, _) {
          final allContents = ContentService.instance.contents.isNotEmpty
              ? ContentService.instance.contents
              : _defaultSeedContents();

          final shown = allContents.where((c) {
            final matchesFilter = switch (_filter) {
              1 => c.isActive,
              2 => !c.isActive,
              _ => true,
            };
            final matchesQuery = _query.isEmpty ||
                c.title.toLowerCase().contains(_query.toLowerCase()) ||
                c.text.toLowerCase().contains(_query.toLowerCase());
            return matchesFilter && matchesQuery;
          }).toList();

          return Column(children: [
            _FilterRow(
              labels: const ['Todos', 'Ativos', 'Inativos / Histórico'],
              value: _filter,
              onChanged: (value) => setState(() => _filter = value),
            ),
            const SizedBox(height: 12),
            AppSearchBar(
              hint: 'Ex: Bolhas',
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: shown.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final item = shown[index];
                  return _ContentCard(
                    content: item,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetalhesConteudoScreen(content: item),
                        ),
                      );
                      setState(() {});
                    },
                  );
                },
              ),
            ),
          ]);
        },
      );
}

class _ContentCard extends StatelessWidget {
  final ContentModel content;
  final VoidCallback? onTap;

  const _ContentCard({required this.content, this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          decoration: _card(),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Última alteração: ${content.updatedAt.contains('T') ? content.updatedAt.split('T').first : content.updatedAt}',
                    style:
                        const TextStyle(fontSize: 9, color: Color(0xFF737D8C)),
                  ),
                  Text(
                    'Autor: ${content.authorName}',
                    style:
                        const TextStyle(fontSize: 9, color: Color(0xFF737D8C)),
                  ),
                  const SizedBox(height: 9),
                  _StatusBadge(
                    label: content.isActive ? 'Ativo' : 'Inativo / Excluído',
                    color: content.isActive
                        ? const Color(0xFF20BF64)
                        : const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF26313D)),
          ]),
        ),
      );
}

class _FilterRow extends StatelessWidget {
  final List<String> labels;
  final int value;
  final ValueChanged<int> onChanged;

  const _FilterRow(
      {required this.labels, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(
        children: labels.asMap().entries.map((entry) {
          final color = entry.key == 1
              ? const Color(0xFF20BF64)
              : entry.key == 2
                  ? const Color(0xFF6B7280)
                  : const Color(0xFF737D8C);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  right: entry.key == labels.length - 1 ? 0 : 8),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 30),
                  side: BorderSide(
                      color: entry.key == value ? color : const Color(0xFFD1D5DB)),
                  padding: EdgeInsets.zero,
                  foregroundColor: color,
                  backgroundColor: entry.key == value
                      ? color.withOpacity(0.08)
                      : Colors.transparent,
                ),
                onPressed: () => onChanged(entry.key),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: entry.key == value
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(5),
          color: color.withOpacity(0.08),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class CadastroConteudoScreen extends StatefulWidget {
  final ContentModel? initial;
  const CadastroConteudoScreen({super.key, this.initial});

  @override
  State<CadastroConteudoScreen> createState() => _CadastroConteudoScreenState();
}

class _CadastroConteudoScreenState extends State<CadastroConteudoScreen> {
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  String? _categoryId;
  String? _documentName;
  String? _documentSize;
  String? _documentUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _titleController.text = widget.initial!.title;
      _textController.text = widget.initial!.text;
      _categoryId = widget.initial!.categoryId;
      _documentName = widget.initial!.documentName;
      _documentSize = widget.initial!.documentSize;
      _documentUrl = widget.initial!.documentUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final text = _textController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o tema do conteúdo.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      if (widget.initial == null) {
        await ContentService.instance.createContent(
          title: title,
          text: text,
          categoryId: _categoryId,
          documentName: _documentName,
          documentSize: _documentSize,
          documentUrl: _documentUrl,
        );
      } else {
        await ContentService.instance.updateContent(
          widget.initial!.id,
          title: title,
          text: text,
          categoryId: _categoryId,
          documentName: _documentName,
          documentSize: _documentSize,
          documentUrl: _documentUrl,
          changeNote: 'Edição de conteúdo técnico realizada',
        );
      }

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => const ConteudoSucessoDialog(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc'],
    );
    if (result.isEmpty) return;
    final file = result.first;
    final bytes = file.lengthSync() ?? (await file.length()) ?? 0;
    final sizeInMb = (bytes / (1024 * 1024)).toStringAsFixed(1);
    final ext = (file.extension ?? 'pdf').toUpperCase();

    setState(() {
      _documentName = file.name;
      _documentSize = '$ext - $sizeInMb MB';
      _documentUrl = file.path ?? '/uploads/${file.name}';
    });
  }

  void _removeDocument() {
    setState(() {
      _documentName = null;
      _documentSize = null;
      _documentUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) => _Shell(
        title: widget.initial == null ? 'NOVO CONTEÚDO' : 'EDITAR CONTEÚDO',
        admin: true,
        child: Column(children: [
          Expanded(
            child: ListView(children: [
              _ContentFormField(
                'Digite o tema',
                hint: 'Ex: Material irregular na matriz',
                controller: _titleController,
              ),
              _ContentFormField(
                'Conteúdo',
                lines: 5,
                controller: _textController,
              ),
              const Text(
                'Categoria',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              ScopedCategoryPicker(
                scope: CategoryScope.content,
                value: _categoryId,
                onChanged: (val) => setState(() => _categoryId = val),
              ),
              const SizedBox(height: 14),
              const Text(
                'Anexar Documentação',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (_documentName != null) ...[
                _DocumentAttachment(
                  fileName: _documentName!,
                  fileSize: _documentSize ?? 'PDF - 1,2 MB',
                  onDelete: _removeDocument,
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addDocument,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('ADICIONAR DOCUMENTO'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    foregroundColor: _blue,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ]),
          ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF384D7A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: _saving ? null : _submit,
              child: Text(
                widget.initial == null ? 'CADASTRAR' : 'SALVAR ALTERAÇÕES',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ]),
      );
}

class _ContentFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final int lines;
  final TextEditingController? controller;

  const _ContentFormField(
    this.label, {
    this.hint,
    this.lines = 1,
    this.controller,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            minLines: lines,
            maxLines: lines,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: _border),
              ),
            ),
          )
        ]),
      );
}

class _DocumentAttachment extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final VoidCallback? onDelete;

  const _DocumentAttachment({
    this.fileName = 'Ficha Técnica.pdf',
    this.fileSize = 'PDF - 1,2 MB',
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: _card(),
        child: Row(children: [
          const PextAssetIcon(PextAssets.pdf, size: 31),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                      color: _blue, fontWeight: FontWeight.w600),
                ),
                Text(
                  fileSize,
                  style:
                      const TextStyle(fontSize: 10, color: Color(0xFF737D8C)),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Color(0xFFF8494E), size: 22),
              onPressed: onDelete,
            )
          else
            const PextAssetIcon(PextAssets.download, size: 24),
        ]),
      );
}

class ConteudoSucessoDialog extends StatelessWidget {
  const ConteudoSucessoDialog({super.key});

  @override
  Widget build(BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF9AA3B0))),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
              'Conteúdo salvo com sucesso!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _blue, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continuar editando'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Fechar'),
              ),
            ),
          ]),
        ),
      );
}

class DetalhesConteudoScreen extends StatelessWidget {
  final ContentModel? content;

  const DetalhesConteudoScreen({super.key, this.content});

  ContentModel get _current =>
      content ??
      const ContentModel(
        id: 'seed-content-1',
        title: 'Material irregular na matriz',
        text:
            'Quando identificado material irregular na matriz, realizar a inspeção da peça e verificar se a ocorrência compromete o padrão de qualidade estabelecido. Caso seja constatada irregularidade, separar a peça e encaminhá-la para avaliação.',
        categoryName: 'Extrusão',
        documentName: 'Ficha Técnica.pdf',
        documentSize: 'PDF - 1,2 MB',
        authorName: 'André',
        status: 'ATIVO',
        createdAt: '01/08/2026 - 09:33',
        updatedAt: '03/07/2026 - 11:35',
        history: [
          ContentAuditEntry(
            id: 'h1',
            authorName: 'André',
            action: 'CREATE',
            date: '01/08/2026 - 09:33',
            title: 'André criou este conteúdo.',
            description: 'Conteúdo inicial adicionado.',
          ),
          ContentAuditEntry(
            id: 'h2',
            authorName: 'Maria',
            action: 'UPDATE',
            date: '02/08/2026 - 09:43',
            title: 'Maria editou o conteúdo',
            description: 'Alterações:\n- Inclusão de Documento',
            previousContent: {
              'title': 'Material irregular na matriz',
              'text':
                  'Quando identificado material irregular na matriz, realizar a inspeção da peça e verificar se a ocorrência compromete o padrão de qualidade estabelecido. Caso seja constatada irregularidade, separar a peça e encaminhá-la para avaliação.',
              'date': '02/08/2026 - 09:40',
              'documentName': null,
            },
          ),
          ContentAuditEntry(
            id: 'h3',
            authorName: 'Jorge',
            action: 'UPDATE',
            date: '05/08/2026 - 09:43',
            title: 'Jorge editou o conteúdo',
            description: 'Alterações:\n- Removeu um documento',
            previousContent: {
              'title': 'Material irregular na matriz',
              'text':
                  'Quando identificado material irregular na matriz, a peça deve ser imediatamente segregada e registrada como não conforme. A ocorrência deve ser avaliada conforme o padrão de qualidade vigente.',
              'date': '05/08/2026 - 09:35',
              'documentName': 'Ficha Técnica.pdf',
            },
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final item = _current;
    return _Shell(
      title: 'Assistente IA',
      admin: true,
      child: ListView(children: [
        _buildContentSummary(item),
        const SizedBox(height: 12),
        if (item.documentName != null && item.documentName!.trim().isNotEmpty)
          _DocumentAttachment(
            fileName: item.documentName!,
            fileSize: item.documentSize ?? 'PDF',
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: _card(),
            child: const Row(
              children: [
                Icon(Icons.insert_drive_file_outlined, color: Color(0xFF9AA4B4), size: 24),
                SizedBox(width: 10),
                Text(
                  'Nenhum documento anexado',
                  style: TextStyle(color: Color(0xFF737D8C), fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: item.isActive
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CadastroConteudoScreen(initial: item),
                        ),
                      )
                  : null,
              icon: const PextAssetIcon(PextAssets.edit, size: 17),
              label: Text(item.isActive ? 'Editar Conteúdo' : 'Edição Bloqueada'),
              style: OutlinedButton.styleFrom(
                foregroundColor: item.isActive ? const Color(0xFF132B5C) : const Color(0xFF9AA4B4),
                side: BorderSide(color: item.isActive ? const Color(0xFF132B5C) : const Color(0xFFD1D5DB)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (item.isActive) ...[
            const SizedBox(width: 9),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF8494E),
                  side: const BorderSide(color: Color(0xFFF8494E)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Excluir Conteúdo'),
                      content: const Text(
                          'Tem certeza que deseja desativar este conteúdo?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFF8494E)),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Desativar'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ContentService.instance.deleteContent(item.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Excluir Conteúdo'),
              ),
            ),
          ] else ...[
            const SizedBox(width: 9),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF9AA4B4),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: null,
                icon: const Icon(Icons.block, size: 18),
                label: const Text('Desativado'),
              ),
            ),
          ],
        ]),
        const SizedBox(height: 18),
        const Text(
          'Histórico de alteração',
          style: TextStyle(
              color: _blue, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (item.history.isNotEmpty)
          ...(() {
            final orderedHistory = List<ContentAuditEntry>.from(item.history);
            orderedHistory.sort((a, b) {
              if (a.action == 'CREATE' && b.action != 'CREATE') return -1;
              if (b.action == 'CREATE' && a.action != 'CREATE') return 1;
              return 0;
            });
            return orderedHistory;
          })().map((entry) {
            final isCreate = entry.action == 'CREATE';
            final isDelete = entry.action == 'DELETE';
            final color = isCreate
                ? const Color(0xFF20BF64)
                : isDelete
                    ? const Color(0xFFF8494E)
                    : _blue;
            final icon = isCreate
                ? Icons.add
                : isDelete
                    ? Icons.delete_outline
                    : Icons.edit_outlined;

            return _HistoryEvent(
              color: color,
              icon: icon,
              date: entry.date,
              title: entry.title,
              text: entry.description,
              onVersion: entry.previousContent != null
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ComparacaoVersoesConteudoScreen(
                            currentContent: item,
                            previousSnapshot: entry.previousContent,
                            author: entry.authorName,
                            date: entry.date,
                          ),
                        ),
                      )
                  : null,
            );
          })
        else ...[
          _HistoryEvent(
            color: const Color(0xFF20BF64),
            icon: Icons.add,
            date: '01/08/2026 - 09:33',
            title: '${item.authorName} criou este conteúdo.',
            text: 'Conteúdo inicial adicionado.',
          ),
        ],
      ]),
    );
  }

  Widget _buildContentSummary(ContentModel item) => Container(
        padding: const EdgeInsets.all(14),
        decoration: _card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 7),
            Text(
              'Última alteração: ${item.updatedAt}',
              style: const TextStyle(fontSize: 10, color: Color(0xFF737D8C)),
            ),
            Text(
              'Autor: ${item.authorName}',
              style: const TextStyle(fontSize: 10, color: Color(0xFF737D8C)),
            ),
            const SizedBox(height: 10),
            _StatusBadge(
              label: item.isActive ? 'Ativo' : 'Inativo / Excluído',
              color: item.isActive
                  ? const Color(0xFF20BF64)
                  : const Color(0xFF6B7280),
            ),
          ],
        ),
      );
}

class _HistoryEvent extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String date, title, text;
  final VoidCallback? onVersion;

  const _HistoryEvent({
    required this.color,
    required this.icon,
    required this.date,
    required this.title,
    required this.text,
    this.onVersion,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: _card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style:
                        const TextStyle(fontSize: 9, color: Color(0xFF737D8C)),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style:
                        const TextStyle(fontSize: 10, color: Color(0xFF737D8C)),
                  ),
                  if (onVersion != null)
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(top: 5),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: onVersion,
                      child: const Text(
                        'Ver conteúdo anterior.',
                        style: TextStyle(fontSize: 10, color: _blue),
                      ),
                    )
                ],
              ),
            ),
          )
        ]),
      );
}

class ComparacaoVersoesConteudoScreen extends StatelessWidget {
  final ContentModel? currentContent;
  final Map<String, dynamic>? previousSnapshot;
  final String? author;
  final String? date;

  const ComparacaoVersoesConteudoScreen({
    super.key,
    this.currentContent,
    this.previousSnapshot,
    this.author,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    final title = currentContent?.title ?? 'Material irregular na matriz';
    final changeDate = date ?? '05/08/2026 - 09:35';
    final changeAuthor = author ?? 'Maria';
    final prevText = previousSnapshot?['text']?.toString() ??
        'Quando identificado material irregular na matriz, realizar a inspeção da peça e verificar se a ocorrência compromete o padrão de qualidade estabelecido. Caso seja constatada irregularidade, separar a peça e encaminhá-la para avaliação.';
    final currentText = currentContent?.text ??
        'Quando identificado material irregular na matriz, a peça deve ser imediatamente segregada e registrada como não conforme. A ocorrência deve ser avaliada conforme o padrão de qualidade vigente.';
    final prevDoc = previousSnapshot?['documentName']?.toString();
    final hasPrevDoc = prevDoc != null && prevDoc.trim().isNotEmpty;
    final curDoc = currentContent?.documentName;
    final hasCurDoc = curDoc != null && curDoc.trim().isNotEmpty;
    final bool isUnchanged = (hasPrevDoc && hasCurDoc && prevDoc == curDoc) || (!hasPrevDoc && !hasCurDoc);

    return _Shell(
      title: 'Assistente IA',
      admin: true,
      child: ListView(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Conteúdo: $title',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                'Alteração em: $changeDate',
                style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 3),
              Text(
                'Alterado por: $changeAuthor',
                style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Comparação de versões',
          style: TextStyle(
              color: _blue, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: _card(),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _VersionColumn(
                    date: 'Versão de ${previousSnapshot?['date'] ?? '02/08/2026 - 9:40'}',
                    text: prevText,
                  ),
                ),
                Expanded(
                  child: _VersionColumn(
                    date: 'Versão de $changeDate',
                    text: currentText,
                    isCurrent: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Anexos:',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: _card(),
          child: Row(children: [
            Expanded(
              child: _AttachmentVersion(
                label: 'Versão anterior',
                documentName: hasPrevDoc ? prevDoc! : 'Nenhum documento anexado',
                color: hasPrevDoc ? const Color(0xFFF0F4FA) : const Color(0xFFFFE9E9),
                status: hasPrevDoc ? 'Anterior' : 'Nenhum',
                statusColor: hasPrevDoc ? _blue : const Color(0xFFF8494E),
                url: previousSnapshot?['documentUrl']?.toString(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _AttachmentVersion(
                label: 'Versão atual',
                documentName: hasCurDoc ? curDoc! : 'Nenhum documento anexado',
                color: isUnchanged
                    ? const Color(0xFFF0F4FA)
                    : (hasCurDoc ? const Color(0xFFD6F9D9) : const Color(0xFFFFE9E9)),
                status: isUnchanged
                    ? 'Arquivo mantido (sem alteração)'
                    : (hasCurDoc ? 'Adicionado' : 'Removido'),
                statusColor: isUnchanged
                    ? const Color(0xFF6B7280)
                    : (hasCurDoc ? const Color(0xFF20BF64) : const Color(0xFFF8494E)),
                url: currentContent?.documentUrl,
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _VersionColumn extends StatelessWidget {
  final String date, text;
  final bool isCurrent;

  const _VersionColumn({
    required this.date,
    required this.text,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 215),
        decoration: BoxDecoration(
          border: isCurrent
              ? null
              : const Border(right: BorderSide(color: _border)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(9),
            color: const Color(0xFFE9EDF3),
            child: Text(
              date,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 9, color: Color(0xFF737D8C), height: 1.35),
            ),
          ),
        ]),
      );
}

class _AttachmentVersion extends StatelessWidget {
  final String label, status, documentName;
  final Color color, statusColor;
  final String? url;

  const _AttachmentVersion({
    required this.label,
    required this.documentName,
    required this.color,
    required this.status,
    required this.statusColor,
    this.url,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(9),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const PextAssetIcon(PextAssets.pdf, size: 24),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    documentName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 8),
                  ),
                ),
                if (documentName != 'Nenhum documento anexado')
                  IconButton(
                    icon: const Icon(Icons.download_rounded, size: 16, color: _blue),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    tooltip: 'Baixar arquivo',
                    onPressed: () {
                      FileDownloadService.instance.downloadFile(
                        context,
                        url: url ?? documentName,
                        filename: documentName,
                      );
                    },
                  ),
              ]),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: _StatusBadge(label: status, color: statusColor),
              )
            ]),
          )
        ]),
      );
}

class PackagingListScreen extends StatefulWidget {
  final bool admin;
  const PackagingListScreen({super.key, this.admin = false});
  @override
  State<PackagingListScreen> createState() => _PackagingListScreenState();
}

class _PackagingListScreenState extends State<PackagingListScreen> {
  String _query = '';
  var _items = <String>['RAP10', 'Macarrão', 'KitKat'];

  @override
  void initState() {
    super.initState();
    _loadPackagings();
  }

  Future<void> _loadPackagings() async {
    try {
      final values = await ApiClient.instance.packagings();
      if (mounted)
        setState(() {
          PackagingCatalog.replace(values);
          _items = values.map((item) => item.name).toList(growable: true);
        });
    } catch (_) {/* The local catalog remains available when offline. */}
  }

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Embalagens',
        admin: widget.admin,
        returnToHome: true,
        action: _BoxedHeaderAction(
            icon: Icons.add,
            onTap: () async {
              final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                      builder: (_) =>
                          PackagingRegistrationScreen(admin: widget.admin)));
              if (changed == true) _loadPackagings();
            }),
        child: Column(children: [
          AppSearchBar(
              hint: 'Buscar embalagem...',
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase())),
          const SizedBox(height: 14),
          ..._items.where((item) => item.toLowerCase().contains(_query)).map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: _card(),
                  child: ListTile(
                    leading: const PextAssetIcon(PextAssets.product, size: 26),
                    title: Text(item,
                        style: const TextStyle(
                            color: _blue, fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.chevron_right, color: _blue),
                    onTap: () async {
                      final changed = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                              builder: (_) => PackagingDetailScreen(
                                  admin: widget.admin, packagingName: item)));
                      if (changed == true) _loadPackagings();
                    },
                  ),
                ),
              ),
        ]),
      );
}

class PackagingRegistrationScreen extends StatefulWidget {
  final bool admin;
  final PackagingSpecification? initial;
  const PackagingRegistrationScreen(
      {super.key, required this.admin, this.initial});

  @override
  State<PackagingRegistrationScreen> createState() =>
      _PackagingRegistrationScreenState();
}

class _PackagingRegistrationScreenState
    extends State<PackagingRegistrationScreen> {
  int _tab = 0;
  late List<String> _materials;
  late PackagingSpecification _specification;
  late List<PackagingParameter> _parameters;
  late List<PackagingParameter> _extraParameters;
  late List<TextEditingController> _materialControllers;
  late List<TextEditingController> _minimumControllers;
  late List<TextEditingController> _maximumControllers;
  final _nameController = TextEditingController();
  String? _categoryId;
  String _category = 'Filme plástico';
  XFile? _image;
  Uint8List? _imageBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _materials = List<String>.from(['1518MM', 'FLEXUS 9212', 'HF2208S3'],
        growable: true);
    _specification = widget.initial ?? PackagingCatalog.byName('RAP10');
    _nameController.text = _specification.name;
    _categoryId = _specification.categoryId;
    _category =
        _specification.categoryName ?? _specification.category ?? _category;
    _parameters = List<PackagingParameter>.from(_specification.parameters);
    _extraParameters =
        List<PackagingParameter>.from(_specification.extraParameters);
    _materialControllers = List<TextEditingController>.generate(
        _materials.length, (_) => TextEditingController(),
        growable: true);
    _minimumControllers = _parameters
        .map((parameter) => TextEditingController(text: '${parameter.min}'))
        .toList(growable: true);
    _maximumControllers = _parameters
        .map((parameter) => TextEditingController(text: '${parameter.max}'))
        .toList(growable: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _materialControllers) {
      controller.dispose();
    }
    for (final controller in _minimumControllers) {
      controller.dispose();
    }
    for (final controller in _maximumControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _reset() => setState(() {
        _tab = 0;
        _materials = <String>[];
        _specification = PackagingCatalog.byName('RAP10');
        _categoryId = _specification.categoryId;
        _category = _specification.categoryName ??
            _specification.category ??
            'Filme plástico';
        _parameters = _specification.parameters;
        _extraParameters = _specification.extraParameters;
        for (final controller in _materialControllers) {
          controller.dispose();
        }
        for (final controller in _minimumControllers) {
          controller.dispose();
        }
        for (final controller in _maximumControllers) {
          controller.dispose();
        }
        _materialControllers = <TextEditingController>[];
        _minimumControllers = _parameters
            .map((parameter) => TextEditingController(text: '${parameter.min}'))
            .toList(growable: true);
        _maximumControllers = _parameters
            .map((parameter) => TextEditingController(text: '${parameter.max}'))
            .toList(growable: true);
      });

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (mounted)
      setState(() {
        _image = file;
        _imageBytes = bytes;
      });
  }

  Future<void> _save() async {
    for (var index = 0; index < _parameters.length; index++) {
      _parameters[index].min = double.tryParse(
              _minimumControllers[index].text.replaceAll(',', '.')) ??
          _parameters[index].min;
      _parameters[index].max = double.tryParse(
              _maximumControllers[index].text.replaceAll(',', '.')) ??
          _parameters[index].max;
    }
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Packaging name is required.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final imageUrl = _image == null
          ? widget.initial?.imageUrl
          : await ApiClient.instance.uploadImage(_image!);
      final draft = PackagingSpecification(
          id: widget.initial?.id,
          name: name,
          category: _category,
          categoryId: _categoryId,
          categoryName: _category,
          imageUrl: imageUrl,
          parameters: _parameters,
          extraParameters: _extraParameters);
      final created = widget.initial?.id == null
          ? await ApiClient.instance.createPackaging(draft,
              category: _category, categoryId: _categoryId, imageUrl: imageUrl)
          : await ApiClient.instance.updatePackaging(widget.initial!.id!, draft,
              category: _category, categoryId: _categoryId, imageUrl: imageUrl);
      PackagingCatalog.replace([...PackagingCatalog.items, created]);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
      return;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (!mounted) return;
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFF9CA5B1), width: 1.5)),
            title: const Text('Embalagem adicionada com sucesso!',
                textAlign: TextAlign.center,
                style: TextStyle(color: _blue, fontWeight: FontWeight.bold)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _reset();
                      },
                      child: const Text('Adicionar mais'))),
              const SizedBox(height: 10),
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Fechar'))),
            ])));
  }

  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Embalagens',
      admin: widget.admin,
      child: Column(children: [
        _TabBar(
            labels: const ['Visão Geral', 'Verificações'],
            value: _tab,
            onChanged: (value) => setState(() => _tab = value)),
        const SizedBox(height: 18),
        Expanded(child: _body()),
        SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(widget.initial == null ? 'CADASTRAR' : 'SALVAR',
                    style: TextStyle(fontWeight: FontWeight.bold)))),
      ]));

  Widget _body() {
    switch (_tab) {
      case 0:
        return ListView(children: [
          const Text('Nome da Embalagem',
              style: TextStyle(
                  color: _blue, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                  hintText: 'Ex: RAP10',
                  filled: true,
                  fillColor: Colors.white)),
          const SizedBox(height: 13),
          const Text('Categoria',
              style: TextStyle(
                  color: _blue, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          ScopedCategoryPicker(
            scope: CategoryScope.packaging,
            value: _categoryId ?? _category,
            onChanged: (val) => setState(() => _categoryId = val),
          ),
          const SizedBox(height: 13),
          InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(12),
              child: _imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(_imageBytes!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover))
                  : widget.initial?.imageUrl?.isNotEmpty == true
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                              ApiClient.instance
                                  .mediaUrl(widget.initial!.imageUrl!),
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover))
                      : const _UploadDropZone('Imagem da Embalagem')),
        ]);
      case 1:
        return ListView(children: [
          const Text('Verificações Fixas',
              style: TextStyle(
                  color: _blue, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._parameters.asMap().entries.map((entry) => _PackagingThresholdRow(
              parameter: entry.value,
              minimumController: _minimumControllers[entry.key],
              maximumController: _maximumControllers[entry.key],
              onEnabledChanged: (enabled) =>
                  setState(() => entry.value.enabled = enabled))),
          const SizedBox(height: 18),
          const Text('Verificações Extras / Personalizadas',
              style: TextStyle(
                  color: _blue, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._extraParameters.map((parameter) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: _card(),
              child: ListTile(
                  title: Text(parameter.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      '${parameter.min} a ${parameter.max} ${parameter.unit}'),
                  trailing: IconButton(
                      tooltip: 'Excluir verificação',
                      onPressed: () =>
                          setState(() => _extraParameters.remove(parameter)),
                      icon: const Icon(Icons.delete_outline,
                          color: Color(0xFFD93838)))))),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                  onPressed: _showAddExtraVerification,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Adicionar Verificação Extra'))),
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  void _showAddExtraVerification() {
    final name = TextEditingController();
    final minimum = TextEditingController();
    final maximum = TextEditingController();
    String selectedUnit = '°C';
    const predefinedUnits = [
      '°C',
      'bar',
      'm/min',
      'mm',
      'g/cm³',
      'g/10 min',
      'MPa',
      '%',
      'kJ/m²',
    ];

    showDialog<void>(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFD0DCEE), width: 1.5),
          ),
          title: const Text(
            'Adicionar Verificação',
            style: TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nome do parâmetro',
                    style: TextStyle(color: _blue, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    hintText: 'Ex: Espessura da Parede',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Unidade de Medida',
                    style: TextStyle(color: _blue, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: selectedUnit,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: predefinedUnits
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDlgState(() => selectedUnit = val);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Valor Mínimo',
                              style: TextStyle(color: _blue, fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: minimum,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '0.0',
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Valor Máximo',
                              style: TextStyle(color: _blue, fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: maximum,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '10.0',
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx),
              child: const Text('CANCELAR'),
            ),
            FilledButton(
              onPressed: () {
                final min = double.tryParse(minimum.text.replaceAll(',', '.'));
                final max = double.tryParse(maximum.text.replaceAll(',', '.'));
                if (name.text.trim().isEmpty || min == null || max == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preencha todos os campos corretamente.')),
                  );
                  return;
                }
                setState(() => _extraParameters.add(PackagingParameter(
                      name: name.text.trim(),
                      unit: selectedUnit,
                      min: min,
                      max: max,
                      isCustom: true,
                    )));
                Navigator.pop(dlgCtx);
              },
              child: const Text('ADICIONAR'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackagingInputRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onDelete;
  const _PackagingInputRow(
      {required this.label, required this.controller, required this.onDelete});

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600))),
        const SizedBox(width: 12),
        SizedBox(
            width: 130,
            height: 48,
            child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    suffixText: '%',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: _border))))),
        IconButton(
            tooltip: 'Excluir $label',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Color(0xFFD93838))),
      ]));
}

class _PackagingThresholdRow extends StatelessWidget {
  final PackagingParameter parameter;
  final TextEditingController minimumController;
  final TextEditingController maximumController;
  final ValueChanged<bool> onEnabledChanged;
  const _PackagingThresholdRow(
      {required this.parameter,
      required this.minimumController,
      required this.maximumController,
      required this.onEnabledChanged});

  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _card(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text('${parameter.name} (${parameter.unit})',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600))),
          Switch(value: parameter.enabled, onChanged: onEnabledChanged)
        ]),
        const SizedBox(height: 10),
        Opacity(
            opacity: parameter.enabled ? 1 : .45,
            child: IgnorePointer(
                ignoring: !parameter.enabled,
                child: Row(children: [
                  Expanded(
                      child: _ThresholdInput(
                          label: 'Min',
                          unit: parameter.unit,
                          controller: minimumController)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _ThresholdInput(
                          label: 'Max',
                          unit: parameter.unit,
                          controller: maximumController)),
                ])))
      ]));
}

class _ThresholdInput extends StatelessWidget {
  final String label, unit;
  final TextEditingController controller;
  const _ThresholdInput(
      {required this.label, required this.unit, required this.controller});
  @override
  Widget build(BuildContext context) => TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: _border))));
}

class _PackagingAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _PackagingAddButton({required this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          child: const Icon(Icons.add_circle_outline, color: _blue, size: 28)));
}

class PackagingDetailScreen extends StatelessWidget {
  final bool admin;
  final String packagingName;
  const PackagingDetailScreen(
      {super.key, required this.admin, required this.packagingName});

  @override
  Widget build(BuildContext context) {
    final specification = PackagingCatalog.byName(packagingName);
    return _Shell(
        title: packagingName,
        admin: admin,
        child: ListView(children: [
          Container(
              height: 185,
              decoration: _card(),
              child: specification.imageUrl?.isNotEmpty == true
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                          ApiClient.instance.mediaUrl(specification.imageUrl!),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                              child: PextAssetIcon(PextAssets.product, size: 88))))
                  : const Center(
                      child: PextAssetIcon(PextAssets.product, size: 88))),
          if (admin) ...[
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: () async {
                        final changed = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                                builder: (_) => PackagingRegistrationScreen(
                                    admin: admin, initial: specification)));
                        if (changed == true && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar Embalagem',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          foregroundColor: const Color(0xFF132B5C),
                          side: const BorderSide(color: Color(0xFF132B5C)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))))),
              const SizedBox(width: 8),
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: () async {
                        if (specification.id != null) {
                          await ApiClient.instance
                              .deletePackaging(specification.id!);
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Excluir Embalagem',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          foregroundColor: const Color(0xFFD93838),
                          side: const BorderSide(color: Color(0xFFD93838)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))))),
            ]),
          ],
          const SizedBox(height: 20),
          const Text('Composição',
              style: TextStyle(
                  color: _blue, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const _PackagingDetailsCard(items: [
            ('1518MM', '40%'),
            ('FLEXUS 9212', '30%'),
            ('HF2208S3', '30%'),
          ]),
          const SizedBox(height: 20),
          const Text('Parâmetros de Produção',
              style: TextStyle(
                  color: _blue, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _PackagingDetailsCard(
              items: specification.parameters
                  .map((parameter) => (
                        parameter.name,
                        '${parameter.min} a ${parameter.max} ${parameter.unit}'
                      ))
                  .toList()),
        ]));
  }
}

class _PackagingDetailsCard extends StatelessWidget {
  final List<(String, String)> items;
  const _PackagingDetailsCard({required this.items});

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: _card(),
      child: Column(
          children: items
              .map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    Expanded(
                        child: Text(item.$1,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600))),
                    Text(item.$2,
                        style: const TextStyle(
                            color: _blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ])))
              .toList()));
}

class UserProfileScreen extends StatefulWidget {
  final bool admin;
  const UserProfileScreen({super.key, this.admin = false});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int _tab = 0;
  bool _editing = false;
  late bool _isAdmin;
  String _name = 'Igor';
  String _email = 'igorurato@gmail.com';
  String _cargo = 'Produção';
  String? _avatarUrl;
  bool _avatarUploading = false;

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.admin || ApiClient.instance.session.isAdmin;
    _name = ApiClient.instance.session.name ?? (_isAdmin ? 'André' : 'Igor');
    _email = ApiClient.instance.session.email ??
        (_isAdmin ? 'admin@pext.local' : 'igorurato@gmail.com');
    _cargo = ApiClient.instance.session.cargo ??
        (_isAdmin ? 'Administrador' : 'Produção');
    _avatarUrl = ApiClient.instance.session.avatarUrl;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await ApiClient.instance.getMyProfile();
      if (!mounted) return;
      if (res['user'] is Map) {
        final u = Map<String, dynamic>.from(res['user'] as Map);
        setState(() {
          _name = u['name']?.toString() ?? _name;
          _email = u['email']?.toString() ?? _email;
          _cargo = u['cargo']?.toString() ?? _cargo;
          _avatarUrl = u['avatarUrl']?.toString() ?? _avatarUrl;
          if (u['role'] == 'ADMIN') _isAdmin = true;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() => _avatarUploading = true);
      final newUrl = await ApiClient.instance.uploadProfileAvatar(picked);
      if (!mounted) return;
      setState(() {
        _avatarUrl = newUrl;
        _avatarUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto de perfil atualizada com sucesso!'),
          backgroundColor: Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _avatarUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar foto: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _openUserRegistrationModal() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _UserRegistrationModal(),
    );
    if (result != null && mounted) {
      final name = result['name']?.toString() ?? 'Usuário';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuário "$name" cadastrado com sucesso!'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    }
  }

  void _logout() =>
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);

  @override
  Widget build(BuildContext context) => _Shell(
      title: _tab == 1 ? 'Perfil - Edição' : 'Perfil',
      admin: _isAdmin,
      returnToHome: true,
      child: Column(children: [
        _ProfileIdentity(
          editing: _editing,
          name: _name,
          avatarUrl: _avatarUrl,
          loading: _avatarUploading,
          onAvatarTap: _pickAndUploadAvatar,
        ),
        const SizedBox(height: 14),
        _TabBar(
            labels: const ['Dados', 'Segurança'],
            value: _tab,
            onChanged: (value) => setState(() {
                  _tab = value;
                  if (value == 1) _editing = false;
                })),
        const SizedBox(height: 16),
        Expanded(
            child: _tab == 0
                ? DadosTabView(
                    editing: _editing,
                    admin: _isAdmin,
                    name: _name,
                    email: _email,
                    cargo: _cargo,
                    onEdit: () => setState(() => _editing = true),
                    onSave: () => setState(() => _editing = false),
                    onLogout: _logout,
                    onRegisterUser: _openUserRegistrationModal,
                  )
                : const SegurancaTabView())
      ]));
}

class _ProfileIdentity extends StatelessWidget {
  final bool editing;
  final String name;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final bool loading;

  const _ProfileIdentity({
    required this.editing,
    required this.name,
    this.avatarUrl,
    this.onAvatarTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) => Column(children: [
        Stack(clipBehavior: Clip.none, children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _border, width: 2),
                    color: Colors.white),
                clipBehavior: Clip.antiAlias,
                child: loading
                    ? const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    : (avatarUrl != null && avatarUrl!.isNotEmpty)
                        ? Image.network(
                            ApiClient.instance.resolveMediaUrl(avatarUrl!),
                            key: ValueKey(avatarUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'images/profile_igor.png',
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset('images/profile_igor.png',
                            fit: BoxFit.cover)),
          ),
          Positioned(
              right: 2,
              bottom: 2,
              child: GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _blue, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ]),
                    child: const Icon(Icons.camera_alt_outlined,
                        color: _blue, size: 20)),
              ))
        ]),
        const SizedBox(height: 8),
        Text(name,
            style: const TextStyle(
                color: _blue, fontSize: 26, fontWeight: FontWeight.bold))
      ]);
}

class DadosTabView extends StatelessWidget {
  final bool editing;
  final bool admin;
  final String name;
  final String email;
  final String cargo;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onLogout;
  final VoidCallback? onRegisterUser;

  const DadosTabView({
    super.key,
    required this.editing,
    this.admin = false,
    this.name = 'Igor',
    this.email = 'igorurato@gmail.com',
    this.cargo = 'Produção',
    required this.onEdit,
    required this.onSave,
    required this.onLogout,
    this.onRegisterUser,
  });

  @override
  Widget build(BuildContext context) {
    final fields = [
      ('CPF', '123.***.***-45'),
      ('Data Nascimento', '30/03/2005'),
      ('E-mail', email.isNotEmpty ? email : 'igorurato@gmail.com'),
      ('Telefone', '(17) 8922-4002'),
      ('Endereço', 'Rua Jorge Meneguel, 1948, Vila Velha'),
      ('Cidade', 'Fernandópolis'),
      ('Função', cargo.isNotEmpty ? cargo : 'Produção'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ...fields.map((field) =>
            _ProfileField(label: field.$1, value: field.$2, editable: editing)),
        const SizedBox(height: 5),
        if (editing)
          FilledButton(onPressed: onSave, child: const Text('SALVAR ALTERAÇÃO'))
        else ...[
          OutlinedButton(onPressed: onEdit, child: const Text('EDITAR DADOS')),
          const SizedBox(height: 8),
          OutlinedButton(
              onPressed: onLogout,
              style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626))),
              child: const Text('SAIR'))
        ]
      ]),
    );
  }
}

class _UserRegistrationModal extends StatefulWidget {
  const _UserRegistrationModal();

  @override
  State<_UserRegistrationModal> createState() => _UserRegistrationModalState();
}

class _UserRegistrationModalState extends State<_UserRegistrationModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cargoController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final user = await ApiClient.instance.createUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        cargo: _cargoController.text.trim().isNotEmpty
            ? _cargoController.text.trim()
            : null,
        role: 'USER',
      );
      if (!mounted) return;
      Navigator.of(context).pop(user);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              e is ApiException ? e.message : 'Erro ao cadastrar usuário: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.person_add_alt_1, color: _blue, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Cadastrar Novo Usuário',
                      style: TextStyle(
                        color: _blue,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Preencha os dados do colaborador para acesso ao sistema.',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo',
                    hintText: 'Ex: Carlos Silva',
                    prefixIcon: Icon(Icons.person_outline, color: _blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: _border),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail de acesso',
                    hintText: 'Ex: carlos.silva@pext.local',
                    prefixIcon: Icon(Icons.email_outlined, color: _blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: _border),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Informe um e-mail válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Senha inicial',
                    hintText: 'Mínimo 6 caracteres',
                    prefixIcon: const Icon(Icons.lock_outline, color: _blue),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: _border),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) {
                      return 'A senha deve ter no mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _cargoController,
                  decoration: const InputDecoration(
                    labelText: 'Cargo / Função',
                    hintText: 'Ex: Operador de Extrusão, Produção',
                    prefixIcon: Icon(Icons.work_outline, color: _blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: _border),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: _blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'CADASTRAR USUÁRIO',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SegurancaTabView extends StatefulWidget {
  const SegurancaTabView({super.key});

  @override
  State<SegurancaTabView> createState() => _SegurancaTabViewState();
}

class _SegurancaTabViewState extends State<SegurancaTabView> {
  Timer? _timer;
  int _seconds = 34;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds == 0) {
        _timer?.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('Dados pessoais',
            style: TextStyle(
                color: _blue, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const _ProfileField(
            label: 'Nova Senha', value: '123.***.***-45', editable: true),
        const _ProfileField(
            label: 'Repita Nova Senha', value: '30/03/2005', editable: true),
        const SizedBox(height: 8),
        const Text('Código de verificação',
            style: TextStyle(
                color: _blue, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const _OtpFields(),
        const SizedBox(height: 12),
        Text(
            _seconds == 0
                ? 'Reenviar código'
                : 'Reenviar código em 00:${_seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(color: _blue, fontWeight: FontWeight.bold)),
        const SizedBox(height: 28),
        FilledButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alteração salva com sucesso.'))),
            child: const Text('SALVAR ALTERAÇÃO'))
      ]));
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final bool editable;
  const _ProfileField(
      {required this.label, required this.value, required this.editable});

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: _blue, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        TextFormField(
            initialValue: value,
            readOnly: !editable,
            obscureText: label.contains('Senha'),
            style: TextStyle(
                color: editable
                    ? const Color(0xFF363C46)
                    : const Color(0xFF9AA4B4)),
            decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(11)),
                    borderSide: BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(11)),
                    borderSide: BorderSide(color: _blue))))
      ]));
}

class _OtpFields extends StatelessWidget {
  const _OtpFields();
  @override
  Widget build(BuildContext context) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
          6,
          (index) => SizedBox(
              width: 36,
              height: 42,
              child: TextFormField(
                  maxLength: 1,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                          borderSide: BorderSide(color: _border)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
                          borderSide: BorderSide(color: _blue)))))));
}

class _Shell extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  final bool admin;
  final bool returnToHome;
  final bool boxedBack;
  final String? fallbackRoute;
  const _Shell(
      {required this.title,
      required this.child,
      this.action,
      this.admin = false,
      this.returnToHome = false,
      this.boxedBack = false,
      this.fallbackRoute});

  int get _selected {
    if ({
      'Treinamentos',
      'Processo de extrusão',
      'Processos de ...',
      'Conclusão Treinamento',
      'Avaliação Treinamento',
      'Resultado Avaliação',
      'Refazer Avaliação',
      'Novo treinamento',
      'Novo Módulo',
      'Questões'
    }.contains(title)) return 0;
    if (title == 'Assistente IA' || title == 'Suporte administrativo') return 3;
    if (title == 'Perfil' || title == 'Perfil - Edição') return 4;
    return 2;
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        _safeBack(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: _canvas,
        appBar: AppBar(
            backgroundColor: _canvas,
            surfaceTintColor: _canvas,
            centerTitle: true,
            leadingWidth: boxedBack ? 58 : null,
            leading: boxedBack
                ? Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: _border),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(color: Color(0x11000000), blurRadius: 3)
                            ]),
                        child: IconButton(
                            onPressed: () => _safeBack(context),
                            icon: const Icon(Icons.arrow_back_ios_new,
                                color: Colors.black, size: 19))))
                : IconButton(
                    onPressed: () => _safeBack(context),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: _blue, size: 19)),
            title: Text(title,
                style: const TextStyle(
                    color: _blue, fontWeight: FontWeight.w600, fontSize: 18)),
            actions: [if (action != null) action!, const SizedBox(width: 5)]),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(28, 6, 28, 18), child: child),
        bottomNavigationBar: _CoreBottomBar(selected: _selected, admin: admin),
      ));

  void _safeBack(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    _goToRoot(context, fallbackRoute ?? PextRoutes.home, admin: admin);
  }
}

class _CoreBottomBar extends StatelessWidget {
  final int selected;
  final bool admin;
  const _CoreBottomBar({required this.selected, this.admin = false});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: _border)),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
        child: SafeArea(
            top: false,
            child: Row(children: [
              _CoreNavItem(
                  asset: PextAssets.education,
                  activeAsset: PextAssets.educationActive,
                  label: 'Treinamento',
                  active: selected == 0,
                  onTap: () =>
                      _goToRoot(context, PextRoutes.training, admin: admin)),
              _CoreNavItem(
                  asset: admin ? PextAssets.dashboard : PextAssets.heart,
                  activeAsset: admin
                      ? PextAssets.dashboardActive
                      : PextAssets.heartActive,
                  label: admin ? 'Dashboard' : 'Favoritos',
                  active: selected == 1,
                  onTap: () => _goToRoot(context,
                      admin ? PextRoutes.dashboard : PextRoutes.favorites,
                      admin: admin)),
              _CoreNavItem(
                  asset: PextAssets.home,
                  activeAsset: PextAssets.homeActive,
                  label: 'Home',
                  active: selected == 2,
                  onTap: () =>
                      _goToRoot(context, PextRoutes.home, admin: admin)),
              _CoreNavItem(
                  asset: PextAssets.chat,
                  activeAsset: PextAssets.chatActive,
                  label: 'Chat',
                  active: selected == 3,
                  onTap: () =>
                      _goToRoot(context, PextRoutes.chat, admin: admin)),
              _CoreNavItem(
                  asset: PextAssets.profile,
                  activeAsset: PextAssets.profileActive,
                  label: 'Perfil',
                  active: selected == 4,
                  onTap: () =>
                      _goToRoot(context, PextRoutes.profile, admin: admin)),
            ])),
      );
}

void _goToRoot(BuildContext context, String route, {bool admin = false}) =>
    Navigator.of(context).pushNamedAndRemoveUntil(
        route, (currentRoute) => false,
        arguments: PextRouteArgs(admin: admin));

class _CoreNavItem extends StatelessWidget {
  final String asset, activeAsset, label;
  final bool active;
  final VoidCallback onTap;
  const _CoreNavItem(
      {required this.asset,
      required this.activeAsset,
      required this.label,
      required this.active,
      required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
      child: InkWell(
          onTap: onTap,
          child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 4),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                PextAssetIcon(active ? activeAsset : asset, size: 31),
                Text(label,
                    style: TextStyle(
                        fontSize: 10,
                        color: active ? _blue : const Color(0xFF26313D),
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.normal))
              ]))));
}

class _BoxedHeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  const _BoxedHeaderAction({required this.icon, this.onTap, this.color});
  @override
  Widget build(BuildContext context) => Container(
      width: 31,
      height: 31,
      margin: const EdgeInsets.only(right: 7),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(6)),
      child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: onTap,
          icon: Icon(icon, size: 19, color: color ?? _blue)));
}

class _TabBar extends StatelessWidget {
  final List<String> labels;
  final int value;
  final ValueChanged<int> onChanged;
  const _TabBar(
      {required this.labels, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(
      children: labels
          .asMap()
          .entries
          .map((entry) => Expanded(
              child: InkWell(
                  onTap: () => onChanged(entry.key),
                  child: Column(children: [
                    Text(entry.value,
                        style: TextStyle(
                            fontSize: 11,
                            color: entry.key == value
                                ? _blue
                                : const Color(0xFF7A8290),
                            fontWeight: entry.key == value
                                ? FontWeight.bold
                                : FontWeight.normal)),
                    const SizedBox(height: 7),
                    Container(
                        height: 1.5,
                        color: entry.key == value ? _blue : _border)
                  ]))))
          .toList());
}

class _TrainingFavoriteIconButton extends StatelessWidget {
  final String trainingId;
  const _TrainingFavoriteIconButton({required this.trainingId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FavoritesService.instance,
      builder: (context, _) {
        final isFavorited = FavoritesService.instance.isFavorite(trainingId);
        return IconButton(
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: isFavorited ? const Color(0xFFEF4444) : const Color(0xFF9CA3AF),
          ),
          onPressed: () async {
            final nowFav = await FavoritesService.instance.toggleFavorite(
              entityType: 'TRAINING',
              entityId: trainingId,
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(nowFav
                      ? 'Treinamento adicionado aos favoritos!'
                      : 'Removido dos favoritos.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          tooltip: 'Favoritar',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        );
      },
    );
  }
}

class _TrainingTile extends StatelessWidget {
  final String? trainingId;
  final int status;
  final bool admin;
  final VoidCallback onTap;
  final String? title;
  final int? moduleCount;
  final int? questionCount;
  final double? progress;
  final String? currentModuleSubtitle;

  const _TrainingTile({
    this.trainingId,
    required this.status,
    required this.admin,
    required this.onTap,
    this.title,
    this.moduleCount,
    this.questionCount,
    this.progress,
    this.currentModuleSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final labels = const ['Em curso', 'Desistência', 'Concluído', 'Não iniciado'];
    final colors = const [
      Color(0xFFF0A000),
      Color(0xFFF04444),
      Color(0xFF1AB65C),
      Color(0xFF6B7280),
    ];
    final safeStatus = (status >= 0 && status < labels.length) ? status : 3;

    final double progVal;
    if (progress != null) {
      progVal = progress!.clamp(0.0, 1.0);
    } else {
      progVal = safeStatus == 2 ? 1.0 : (safeStatus == 0 ? 0.7 : 0.0);
    }
    final int progPercent = (progVal * 100).toInt();

    return InkWell(
        onTap: onTap,
        child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: _card(),
            child: Row(children: [
              Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE6EBF2),
                      borderRadius: BorderRadius.circular(9)),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.asset('images/training_extrusion.png',
                          fit: BoxFit.cover))),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Expanded(
                          child: Text(title ?? 'Processo de extrusão',
                              style: const TextStyle(
                                  color: _blue, fontWeight: FontWeight.bold))),
                      if (!admin && trainingId != null)
                        _TrainingFavoriteIconButton(trainingId: trainingId!),
                      if (!admin) _Pill(labels[safeStatus], colors[safeStatus])
                    ]),
                    Text(
                        admin
                            ? '${moduleCount ?? 10} Módulos  •  ${questionCount ?? 20} Questões'
                            : (currentModuleSubtitle ?? 'Módulo 2 - Temperatura e pressão'),
                        style: const TextStyle(fontSize: 8)),
                    if (!admin) ...[
                      const SizedBox(height: 7),
                      Row(children: [
                        Expanded(
                            child: LinearProgressIndicator(
                                value: progVal,
                                color: _blue,
                                backgroundColor: _border,
                                minHeight: 5)),
                        const SizedBox(width: 5),
                        Text('$progPercent%',
                            style: const TextStyle(fontSize: 10, color: _blue))
                      ]),
                    ],
                    if (!admin && safeStatus == 1)
                      const _TrainingContextBanner(
                        asset: PextAssets.tryAgain,
                        color: Color(0xFFF04444),
                        text: 'Você parou de estudar. Retome de onde parou.',
                      ),
                    if (!admin && safeStatus == 2)
                      const _TrainingContextBanner(
                        asset: PextAssets.approved,
                        color: Color(0xFF1AB65C),
                        text:
                            'Aprovado - Você acertou 18 de 20 questões (90%).',
                      ),
                    if (!admin && safeStatus == 3)
                      const _TrainingContextBanner(
                        asset: PextAssets.warning,
                        color: Color(0xFF6B7280),
                        iconBackground: Color(0xFF9CA3AF),
                        text:
                            'Treinamento disponível. Inicie para começar sua capacitação.',
                      ),
                  ])),
              const Icon(
                Icons.chevron_right,
                color: _blue,
                size: 20,
              ),
            ])));
  }
}

class _TrainingContextBanner extends StatelessWidget {
  final String asset;
  final Color color;
  final String text;
  final Color? iconBackground;
  const _TrainingContextBanner(
      {required this.asset,
      required this.color,
      required this.text,
      this.iconBackground});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 7),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(7)),
        child: Row(children: [
          iconBackground == null
              ? PextAssetIcon(asset, size: 13)
              : CircleAvatar(
                  radius: 7,
                  backgroundColor: iconBackground,
                  child: PextAssetIcon(asset, size: 11)),
          const SizedBox(width: 4),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 7, fontWeight: FontWeight.w600)))
        ]),
      );
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)));
}

class _ModuleTile extends StatelessWidget {
  final int index;
  final String title;
  final bool done;
  final VoidCallback onTap;
  const _ModuleTile(
      {required this.index,
      required this.title,
      required this.done,
      required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: _card(),
      child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
              backgroundColor: done ? _blue : _border,
              child: Text('$index',
                  style: TextStyle(color: done ? Colors.white : _blue))),
          title: Text(title,
              style:
                  const TextStyle(color: _blue, fontWeight: FontWeight.w600)),
          subtitle: Text(done ? 'Concluído' : 'Não iniciado',
              style: const TextStyle(fontSize: 10)),
          trailing: Icon(done ? Icons.check_circle : Icons.play_circle_outline,
              color: done ? const Color(0xFF1AB65C) : _blue)));
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool mine;
  const _ChatBubble(this.text, this.mine);
  @override
  Widget build(BuildContext context) => Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
          constraints: const BoxConstraints(maxWidth: 270),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: mine ? _blue : const Color(0xFFE4E7EC),
              borderRadius: BorderRadius.circular(16)),
          child: Text(text,
              style: TextStyle(
                  fontSize: 12,
                  color: mine ? Colors.white : const Color(0xFF2D3542)))));
}

class _EditorSection extends StatelessWidget {
  final String title;
  final IconData icon;
  const _EditorSection(this.title, this.icon);
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _card(),
      child: ListTile(
          leading: Icon(icon, color: _blue),
          title: Text(title,
              style:
                  const TextStyle(color: _blue, fontWeight: FontWeight.bold)),
          subtitle: const Text('Adicionar e organizar conteúdo',
              style: TextStyle(fontSize: 11)),
          trailing: const Icon(Icons.chevron_right, color: _blue)));
}

class _Field extends StatelessWidget {
  final String label;
  final int lines;
  final String? value;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  const _Field(this.label,
      {this.lines = 1,
      this.value,
      this.hint,
      this.controller,
      this.keyboardType,
      this.onChanged});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: _blue, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        TextField(
            maxLines: lines,
            controller: controller ??
                (value == null ? null : TextEditingController(text: value)),
            readOnly: value != null && controller == null,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
                hintText: value == null ? (hint ?? 'Preencha $label') : null,
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: _border))))
      ]));
}

class _TrainingSelectField extends StatelessWidget {
  final String label;
  const _TrainingSelectField(this.label);

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: _blue, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            decoration: _card(),
            child: const Row(children: [
              Expanded(
                  child: Text('Selecione uma categoria',
                      style: TextStyle(color: Colors.black54))),
              Icon(Icons.keyboard_arrow_down)
            ]))
      ]));
}

class _UploadDropZone extends StatelessWidget {
  final String title;
  const _UploadDropZone(this.title);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                color: _blue, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Container(
            height: 135,
            decoration: BoxDecoration(
                border: Border.all(color: _border, width: 2),
                borderRadius: BorderRadius.circular(12)),
            child: const Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.cloud_upload_outlined,
                  size: 38, color: Colors.blueGrey),
              SizedBox(height: 6),
              Text('Clique para enviar a imagem',
                  style: TextStyle(color: Colors.blueGrey))
            ])))
      ]));
}

class _AttachmentPreview extends StatelessWidget {
  final String title, item, detail;
  final bool video;
  const _AttachmentPreview(
      {required this.title,
      required this.item,
      required this.detail,
      this.video = false});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                color: _blue, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: _card(),
            child: ListTile(
                leading: Container(
                    width: 58,
                    height: 46,
                    decoration: BoxDecoration(
                        color: video ? Colors.black12 : Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(
                        video
                            ? Icons.play_circle_outline
                            : Icons.picture_as_pdf_outlined,
                        color: _blue)),
                title: Text(item,
                    style: const TextStyle(
                        color: _blue, fontWeight: FontWeight.bold)),
                subtitle: Text(detail),
                trailing: const Icon(Icons.close))),
        _AddContentButton(onTap: () {})
      ]);
}

class _AddContentButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddContentButton({required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('ADICIONAR')));
}

class TrainingSuccessDialog extends StatelessWidget {
  final VoidCallback onAddMore;
  final VoidCallback onClose;
  const TrainingSuccessDialog(
      {super.key, required this.onAddMore, required this.onClose});
  @override
  Widget build(BuildContext context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Treinamento adicionado com sucesso!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _blue, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: onAddMore, child: const Text('Adicionar mais'))),
            const SizedBox(height: 8),
            SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                    onPressed: onClose, child: const Text('Fechar')))
          ])));
}

class _StepText extends StatelessWidget {
  final String text;
  const _StepText(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(color: _blue, fontWeight: FontWeight.bold));
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  const _PrimaryButton(this.text);
  @override
  Widget build(BuildContext context) =>
      FilledButton(onPressed: () {}, child: Text(text));
}

class _InfoDialog extends StatelessWidget {
  final String title, body;
  const _InfoDialog(this.title, this.body);
  @override
  Widget build(BuildContext context) => AlertDialog(
          title: Text(title, style: const TextStyle(color: _blue)),
          content: Text(body),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'))
          ]);
}

BoxDecoration _card() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(11),
    border: Border.all(color: _border));
