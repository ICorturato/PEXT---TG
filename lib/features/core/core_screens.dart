import 'dart:async';

import 'package:flutter/material.dart';
import '../../app_routes.dart';
import '../../models/packaging_specification.dart';
import '../../widgets/pext_asset_icon.dart';
import '../../widgets/app_search_bar.dart';

const _blue = Color(0xFF053488);
const _canvas = Color(0xFFF6F8FB);
const _border = Color(0xFFE5E7EB);

class TermsDictionaryScreen extends StatefulWidget {
  final bool admin;
  const TermsDictionaryScreen({super.key, this.admin = false});
  @override
  State<TermsDictionaryScreen> createState() => _TermsDictionaryScreenState();
}

class _TermsDictionaryScreenState extends State<TermsDictionaryScreen> {
  String _query = '';
  static const _groups = <String, List<String>>{
    'A': [
      'Aditivo',
      'Aderência Intercamadas',
      'Anel de Ar',
      'Alimentador',
      'ABS (Acrilonitrila Butadieno Estireno)'
    ],
    'B': [
      'Barreira',
      'Bobina',
      'Bolha',
      'Bico de Extrusão',
      'Blenda Polimérica'
    ],
    'C': [
      'Coextrusão',
      'Cabeçote',
      'Camada Barreira',
      'Canal de Fluxo',
      'Cristalinidade'
    ],
    'D': [
      'Die',
      'Degasagem',
      'Delaminação',
      'Dosagem Gravimétrica',
      'Distribuidor de Fluxo'
    ],
  };

  @override
  Widget build(BuildContext context) {
    final groups = _groups.entries
        .map((entry) => MapEntry(
            entry.key,
            entry.value
                .where(
                    (term) => term.toLowerCase().contains(_query.toLowerCase()))
                .toList()))
        .where((entry) => entry.value.isNotEmpty)
        .toList();
    return _Shell(
        title: 'Dicionário de Termos',
        admin: widget.admin,
        returnToHome: true,
        action: widget.admin
            ? _BoxedHeaderAction(
                icon: Icons.add,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const CadastroTermoScreen())))
            : const _BoxedHeaderAction(icon: Icons.favorite_border),
        child: Column(children: [
          _TermsSearch(onChanged: (value) => setState(() => _query = value)),
          const SizedBox(height: 14),
          Expanded(
              child: groups.isEmpty
                  ? const _NoTermsFound()
                  : ListView(children: [
                      for (final entry in groups)
                        _TermsLetterGroup(
                            letter: entry.key,
                            terms: entry.value,
                            onTermTap: (term) => _detail(context, term))
                    ])),
        ]));
  }

  void _detail(BuildContext context, String term) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              DetalhesTermoScreen(term: term, admin: widget.admin)));
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
  final List<String> terms;
  final ValueChanged<String> onTermTap;
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
                                horizontal: 14, vertical: 11),
                            decoration: BoxDecoration(
                                border: index == terms.length - 1
                                    ? null
                                    : const Border(
                                        bottom: BorderSide(color: _border))),
                            child: Text(terms[index],
                                style: const TextStyle(fontSize: 16))))
                ])))
      ]));
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

class DetalhesTermoScreen extends StatelessWidget {
  final String term;
  final bool admin;
  const DetalhesTermoScreen(
      {super.key, required this.term, this.admin = false});

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Dicionário de Termos',
        admin: admin,
        action: admin
            ? null
            : const _BoxedHeaderAction(icon: Icons.favorite_border),
        child: ListView(children: [
          if (admin) ...[
            Row(children: [
              Expanded(
                  child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF8494E),
                          side: const BorderSide(color: Color(0xFFF8494E))),
                      onPressed: () {},
                      icon: const Icon(Icons.delete_outline, size: 17),
                      label: const Text('Excluir Conteúdo'))),
              const SizedBox(width: 8),
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  CadastroTermoScreen(initialTerm: term))),
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
                    Text(term,
                        style: const TextStyle(
                            color: _blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    const Text(
                        'Processo onde um material é forçado sob alta pressão através de um orifício ou molde, adquirindo o formato exato dessa abertura. É uma técnica contínua usada em diversos setores, desde a fabricação de perfis metálicos e plásticos até a produção de alimentos e massas.'),
                    const SizedBox(height: 22),
                    const Text('Como funciona?',
                        style: TextStyle(
                            color: _blue, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const Text(
                        'O polímero é aquecido, plastificado e empurrado por uma rosca sem-fim através de um cabeçote, formando filmes, perfis, tubos, entre outros.'),
                    const SizedBox(height: 22),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset('images/training_extrusion.png',
                            height: 158,
                            width: double.infinity,
                            fit: BoxFit.cover)),
                    const SizedBox(height: 22),
                    const Text('Termos Relacionados',
                        style: TextStyle(
                            color: _blue, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    Wrap(spacing: 8, children: const [
                      _TermChip('Rosca'),
                      _TermChip('Matriz'),
                      _TermChip('Filme')
                    ]),
                  ])),
        ]),
      );
}

class CadastroTermoScreen extends StatefulWidget {
  final String? initialTerm;
  const CadastroTermoScreen({super.key, this.initialTerm});

  @override
  State<CadastroTermoScreen> createState() => _CadastroTermoScreenState();
}

class _CadastroTermoScreenState extends State<CadastroTermoScreen> {
  late final TextEditingController _termController;
  final _explanationController = TextEditingController();
  final _howItWorksController = TextEditingController();
  final _relatedTerms = <String>['Matriz'];

  @override
  void initState() {
    super.initState();
    _termController = TextEditingController(text: widget.initialTerm ?? '');
  }

  @override
  void dispose() {
    _termController.dispose();
    _explanationController.dispose();
    _howItWorksController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _termController.clear();
    _explanationController.clear();
    _howItWorksController.clear();
    setState(() {
      _relatedTerms
        ..clear()
        ..add('Matriz');
    });
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
          _TermFormField('Como funciona',
              controller: _howItWorksController, lines: 5),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                  onPressed: () {}, child: const Text('ADICIONAR TÓPICO'))),
          const SizedBox(height: 16),
          const Text('Imagem',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const _TermImageAttachment(),
          const SizedBox(height: 8),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                  onPressed: () {},
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
                    onPressed: () => setState(() => _relatedTerms.add('Rosca')),
                    child: const Center(
                        child: Icon(Icons.add_circle_outline,
                            color: _blue, size: 20))))
          ]),
          const SizedBox(height: 20)
        ])),
        SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (_) => TermoSucessoDialog(onAddMore: _resetForm)),
                child: const Text('CADASTRAR')))
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
  const _TermImageAttachment();
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(10),
      decoration: _card(),
      child: const Row(children: [
        SizedBox(
            width: 42,
            height: 42,
            child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Color(0xFFF1F3F6),
                    borderRadius: BorderRadius.all(Radius.circular(8))))),
        SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('img.jpg',
              style: TextStyle(color: _blue, fontWeight: FontWeight.w600)),
          Text('JPG - 34 MB',
              style: TextStyle(fontSize: 10, color: Color(0xFF737D8C)))
        ])),
        PextAssetIcon(PextAssets.download, size: 24)
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
  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Treinamentos',
        admin: widget.admin,
        returnToHome: true,
        action: widget.admin
            ? IconButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TrainingEditorScreen())),
                icon: const Icon(Icons.add_circle_outline, color: _blue))
            : const Icon(Icons.favorite_border, color: _blue),
        child: Column(children: [
          _TabBar(
              labels: _filters,
              value: _filter,
              onChanged: (value) => setState(() => _filter = value)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: List.generate(7, (index) {
                final status = index % 4;
                return _TrainingTile(
                  status: status,
                  admin: widget.admin,
                  onTap: () => _openCourse(context, status),
                );
              }),
            ),
          ),
        ]),
      );

  void _openCourse(BuildContext context, int status) => showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Abrir treinamento'),
          content: const Text('O que você deseja acessar neste treinamento?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => TrainingDetailScreen(
                            admin: widget.admin, completed: status == 2)));
              },
              child: const Text('MÓDULOS'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => widget.admin
                            ? const AdminQuestionListScreen()
                            : const ExamScreen()));
              },
              child: const Text('AVALIAÇÃO'),
            ),
          ],
        ),
      );
}

class TrainingDetailScreen extends StatelessWidget {
  final bool admin;
  final bool completed;
  const TrainingDetailScreen(
      {super.key, required this.admin, this.completed = false});

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Processos de ...',
        admin: admin,
        fallbackRoute: PextRoutes.training,
        action: admin
            ? _BoxedHeaderAction(
                icon: Icons.edit_outlined,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TrainingEditorScreen())))
            : const _BoxedHeaderAction(icon: Icons.favorite_border),
        child: ListView(children: [
          const _CourseProgressCard(),
          const SizedBox(height: 18),
          const Text('Módulos do curso',
              style: TextStyle(
                  color: _blue, fontSize: 21, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(
              10,
              (index) => _CourseModule(
                  index: index + 1,
                  status: index < 5
                      ? 2
                      : index < 7
                          ? 1
                          : 0,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => LessonDetailScreen(admin: admin))))),
        ]),
      );
}

class _CourseProgressCard extends StatelessWidget {
  const _CourseProgressCard();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: _card(),
        child: Column(children: [
          Row(children: [
            const SizedBox(
                width: 84,
                height: 84,
                child: Stack(alignment: Alignment.center, children: [
                  Positioned.fill(
                      child: CircularProgressIndicator(
                          value: .5,
                          strokeWidth: 7,
                          color: _blue,
                          backgroundColor: _border)),
                  Text('50%', style: TextStyle(fontSize: 20))
                ])),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Você completou 5 de 10 módulos',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: const [
                    Expanded(
                        child: LinearProgressIndicator(
                            value: .5, color: _blue, minHeight: 8)),
                    SizedBox(width: 8),
                    Text('50%', style: TextStyle(color: _blue, fontSize: 17))
                  ]),
                  const SizedBox(height: 8),
                  const Text('Faltam 5 módulos para concluir',
                      style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                ])),
          ]),
          const SizedBox(height: 16),
          const Row(children: [
            Expanded(
                child: _CourseMetric(
                    Icons.menu_book_outlined, '10', 'Módulos', _blue)),
            SizedBox(width: 7),
            Expanded(
                child: _CourseMetric(Icons.check_circle_outline, '5',
                    'Concluídos', Color(0xFF22C55E))),
            SizedBox(width: 7),
            Expanded(
                child: _CourseMetric(
                    Icons.schedule, '2', 'Em andamento', Color(0xFFF59E0B))),
            SizedBox(width: 7),
            Expanded(
                child: _CourseMetric(Icons.lock_outline, '3', 'Não iniciado',
                    Color(0xFF6B7280))),
          ]),
        ]),
      );
}

class _CourseMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _CourseMetric(this.icon, this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(7),
      decoration: _card(),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 20),
        Text(value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        Text(label,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 7))
      ]));
}

class _CourseModule extends StatelessWidget {
  final int index;
  final int status;
  final VoidCallback onTap;
  const _CourseModule(
      {required this.index, required this.status, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final done = status == 2;
    final active = status == 1;
    final color = done
        ? const Color(0xFF22C55E)
        : active
            ? _blue
            : const Color(0xFF9CA3AF);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: _card(),
      child: ListTile(
        onTap: onTap,
        leading: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2)),
            child: done
                ? Icon(Icons.check, color: color)
                : Text('$index', style: TextStyle(color: color, fontSize: 18))),
        title: const Text('Fundamentos da Extrusão',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text(
            'Entenda os princípios básicos do processo de extrusão.',
            style: TextStyle(fontSize: 9)),
        trailing:
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _Pill(
              done
                  ? 'Concluído'
                  : active
                      ? 'Em curso'
                      : 'Não Iniciado',
              done
                  ? const Color(0xFF22C55E)
                  : active
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF9CA3AF)),
          Text(
              done
                  ? '100%'
                  : active
                      ? '50%'
                      : '0%',
              style: const TextStyle(color: _blue))
        ]),
      ),
    );
  }
}

class LessonDetailScreen extends StatefulWidget {
  final bool admin;
  const LessonDetailScreen({super.key, this.admin = false});
  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Processos de ...',
        admin: widget.admin,
        fallbackRoute: PextRoutes.training,
        action: widget.admin
            ? _BoxedHeaderAction(
                icon: Icons.edit_outlined,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ModuleEditorScreen())))
            : const _BoxedHeaderAction(icon: Icons.favorite_border),
        child: Column(children: [
          _TabBar(
              labels: const ['Conteúdo', 'Documentação'],
              value: tab,
              onChanged: (value) => setState(() => tab = value)),
          const SizedBox(height: 18),
          Expanded(child: tab == 0 ? _lessonContent() : _lessonDocuments()),
        ]),
      );

  Widget _lessonContent() => ListView(children: [
        if (widget.admin)
          Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                Expanded(
                    child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('EXCLUIR CONTEÚDO'))),
                const SizedBox(width: 8),
                Expanded(
                    child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ModuleEditorScreen())),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('EDITAR CONTEÚDO'))),
              ])),
        Container(
            padding: const EdgeInsets.all(14),
            decoration: _card(),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('1.1 - Introdução às Matérias-Primas',
                  style: TextStyle(
                      color: _blue, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 14),
              Stack(alignment: Alignment.center, children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('images/training_extrusion.png',
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover)),
                const Icon(Icons.play_circle_outline,
                    color: Colors.white, size: 52)
              ]),
              const SizedBox(height: 16),
              const Text('Sobre esta aula',
                  style: TextStyle(
                      color: _blue, fontWeight: FontWeight.bold, fontSize: 17)),
              const Text(
                  'Conheça os principais tipos de matérias-primas utilizadas na extrusão e suas características.'),
              const Divider(),
              const Text('Próximos conteúdos',
                  style: TextStyle(
                      color: _blue, fontWeight: FontWeight.bold, fontSize: 17)),
              ...[
                '1.2 - Tipos de Polímeros',
                '1.3 - Aditivos e Cargas',
                '1.4 - Armazenamento',
                '1.5 - Tipos de sla'
              ].map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item),
                  subtitle: const Text('10 min'),
                  trailing: const Icon(Icons.play_circle_outline)))
            ]))
      ]);
  Widget _lessonDocuments() => ListView(children: [
        const Text('Materiais de Apoio',
            style: TextStyle(
                color: _blue, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...List.generate(
            4,
            (_) => Container(
                margin: const EdgeInsets.only(bottom: 7),
                decoration: _card(),
                child: ListTile(
                    leading: Container(
                        width: 44,
                        height: 44,
                        decoration: _card(),
                        alignment: Alignment.center,
                        child: const PextAssetIcon(PextAssets.pdf, size: 27)),
                    title: const Text('Ficha Técnica ...',
                        style: TextStyle(
                            color: _blue, fontWeight: FontWeight.bold)),
                    subtitle: const Text('PDF - 1,2 MB'),
                    trailing:
                        const PextAssetIcon(PextAssets.download, size: 24)))),
        SizedBox(
            width: double.infinity,
            child: OutlinedButton(
                onPressed: () {},
                child: const Text('Ver todos os documentos'))),
      ]);
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
  const ExamScreen({super.key, this.reviewMode = false});
  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int? answer;
  bool review = false;
  bool marked = false;
  @override
  void initState() {
    super.initState();
    review = widget.reviewMode;
    answer = widget.reviewMode ? 0 : null;
  }

  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Avaliação Treinamento',
      action: _BoxedHeaderAction(
          icon: Icons.menu,
          onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const _QuestionNavigator())),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _QuestionSteps(),
        const SizedBox(height: 18),
        Expanded(
            child: ListView(children: [
          const Text(
              'Qual é a principal função da temperatura de extrusão no processo?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          ...[
            'Aumentar a resistência do Material',
            'Reduzir o tempo de ciclo',
            'Garantir a fusão adequada do material e sua fluidez',
            'Diminuir o custo do processo'
          ].asMap().entries.map((entry) => _AnswerCard(
              letter: 'ABCD'[entry.key],
              text: entry.value,
              selected: answer == entry.key,
              correct: review && entry.key == 2,
              wrong: review && answer == entry.key && entry.key != 2,
              onTap: () => setState(() => answer = entry.key))),
          OutlinedButton.icon(
              onPressed: () => setState(() => marked = !marked),
              icon: Icon(marked ? Icons.bookmark : Icons.bookmark_border,
                  color: marked ? const Color(0xFFF2C200) : null),
              label: Text(marked
                  ? 'Marcada para revisar'
                  : 'Marcar para revisar depois')),
        ])),
        Row(children: [
          Expanded(
              child: OutlinedButton(
                  onPressed: () {}, child: const Text('Anterior'))),
          Expanded(
              child: FilledButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FinalExamSummaryScreen())),
                  child: const Text('Próximo')))
        ])
      ]));
}

class _QuestionSteps extends StatelessWidget {
  const _QuestionSteps();
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Questão 3 de 20',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          for (final item in [1, 2, 3, 4, 5, 20])
            Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item == 3 ? _blue : Colors.white,
                    border: Border.all(color: _border)),
                child: Text('$item',
                    style: TextStyle(
                        color:
                            item == 3 ? Colors.white : const Color(0xFF374151),
                        fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 13),
        const LinearProgressIndicator(value: .23, color: _blue, minHeight: 8),
      ]);
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
  const _QuestionNavigator();
  @override
  Widget build(BuildContext context) => SafeArea(
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              const Expanded(
                  child: Text('Navegar entre questões',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 21, fontWeight: FontWeight.bold))),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close))
            ]),
            const SizedBox(height: 12),
            GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 4.2,
                children: [
                  _QuestionLegend(
                      color: Color(0xFF22C55E), label: 'Respondida'),
                  _QuestionLegend(color: _blue, label: 'Atual'),
                  _QuestionLegend(
                      color: Color(0xFF9CA3AF), label: 'Não respondida'),
                  _QuestionLegend(
                      color: Color(0xFFF2C200),
                      label: 'Marcada',
                      bookmark: true),
                ]),
            const SizedBox(height: 14),
            GridView.count(
                shrinkWrap: true,
                crossAxisCount: 5,
                childAspectRatio: 1.2,
                children: List.generate(20, (index) {
                  final active = index == 2;
                  final answered = index < 2;
                  final marked = index == 5 || index == 12;
                  final color = active
                      ? _blue
                      : answered
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF9CA3AF);
                  return Stack(children: [
                    Container(
                        margin: const EdgeInsets.all(5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: active || answered ? color : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color)),
                        child: Text('${index + 1}',
                            style: TextStyle(
                                color: active || answered
                                    ? Colors.white
                                    : const Color(0xFF374151),
                                fontWeight: FontWeight.bold))),
                    if (marked)
                      const Positioned(
                          top: 1,
                          right: 1,
                          child: Icon(Icons.bookmark,
                              color: Color(0xFFF2C200), size: 17)),
                  ]);
                })),
            const SizedBox(height: 16),
            SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FinalExamSummaryScreen())),
                    child: const Text('FINALIZAR TESTE'))),
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
        Icon(bookmark ? Icons.bookmark : Icons.circle, color: color, size: 13),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11))
      ]);
}

class FinalExamSummaryScreen extends StatelessWidget {
  const FinalExamSummaryScreen({super.key});
  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Avaliação Treinamento',
        action: _BoxedHeaderAction(
            icon: Icons.menu,
            onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const _QuestionNavigator())),
        child: ListView(children: [
          const Row(children: [
            Expanded(
                child: Text('Questão',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(
                child: Text('Sua resposta',
                    style: TextStyle(fontWeight: FontWeight.bold)))
          ]),
          const SizedBox(height: 8),
          ...List.generate(20, (index) {
            final incorrect = index == 6 || index == 8;
            final color =
                incorrect ? const Color(0xFFF44336) : const Color(0xFF22C55E);
            return Container(
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: _border))),
                child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: color,
                        child: Text('${index + 1}',
                            style: const TextStyle(color: Colors.white))),
                    title: const Center(
                        child: Text('A',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    trailing: Icon(incorrect ? Icons.close : Icons.check,
                        color: color)));
          }),
          const SizedBox(height: 24),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ExamScreen(reviewMode: true))),
                  child: const Text('REVISAR QUESTÃO'))),
          SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: () => _finishExam(context),
                  child: const Text('FINALIZAR TESTE'))),
        ]),
      );
}

Future<void> _finishExam(BuildContext context) => showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Visualizar resultado'),
        content: const Text(
            'Escolha a tela de resultado para a prévia da avaliação.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FailedResultScreen()));
            },
            child: const Text('TELA DE REPROVADO'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ApprovedResultScreen()));
            },
            child: const Text('TELA DE APROVADO'),
          ),
        ],
      ),
    );

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
  const _ResultScreen(
      {required this.approved, required this.title, required this.onPrimary});
  @override
  Widget build(BuildContext context) {
    final color = approved ? const Color(0xFF16C79A) : const Color(0xFFF44336);
    final tint = approved ? const Color(0xFFD7F5E5) : const Color(0xFFFFE0B1);
    return _Shell(
        title: title,
        child: ListView(children: [
          const SizedBox(height: 70),
          CircleAvatar(
              radius: 74,
              backgroundColor: color,
              child: Icon(approved ? Icons.check : Icons.close,
                  color: Colors.white, size: 84)),
          const SizedBox(height: 36),
          Text(approved ? 'Parabéns!' : 'Você não foi aprovado',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(approved ? 'Você foi aprovado!' : 'Continue estudando!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Color(0xFF6B7280))),
          const SizedBox(height: 26),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                  color: tint, borderRadius: BorderRadius.circular(18)),
              child: Row(children: [
                Expanded(
                    child: _ResultMetric(
                        'Acertos', approved ? '18 de 20' : '11 de 20', color)),
                Expanded(
                    child: _ResultMetric(
                        'Porcentagem', approved ? '90%' : '55%', color)),
                Expanded(
                    child: _ResultMetric(
                        'Situação', approved ? 'Aprovado' : 'Reprovado', color))
              ])),
          const SizedBox(height: 32),
          if (approved)
            const Text(
                'Ótimo trabalho! Você atingiu o resultado necessário para aprovação.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19))
          else ...[
            const Text(
                'Você precisa de pelo menos 70% de acertos para ser aprovado',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19)),
            const SizedBox(height: 20),
            const Text('Principais tópicos para revisar',
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
                        backgroundColor: Color(0xFFF44336),
                        child: Icon(Icons.close, color: Colors.white)),
                    title: Text(item),
                    trailing: const Text('2/5 acertos',
                        style: TextStyle(color: _blue))))),
          ],
          const SizedBox(height: 28),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                  onPressed: () {},
                  child: Text(approved ? 'REVER RESPOSTAS' : 'REVER MÓDULO'))),
          SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: onPrimary,
                  child:
                      Text(approved ? 'VOLTAR AOS MÓDULOS' : 'REFAZER TESTE'))),
        ]));
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
  const TrainingEditorScreen({super.key});
  @override
  State<TrainingEditorScreen> createState() => _TrainingEditorScreenState();
}

class _TrainingEditorScreenState extends State<TrainingEditorScreen> {
  int tab = 0;
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
                      ? _modules()
                      : _assessment()),
          SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: () => _saved(context),
                  child: const Text('CADASTRAR'))),
        ]),
      );

  Widget _overview() => ListView(children: const [
        _Field('Título do treinamento', hint: 'Ex: Processos de extrusão'),
        _Field('Descrição curta', lines: 4, hint: 'Descreva o treinamento'),
        _TrainingSelectField('Categoria'),
        _Field('Carga horária total (opcional)', hint: 'Ex: 4 horas'),
        _UploadDropZone('Imagem de capa')
      ]);
  Widget _modules() => ListView(children: [
        ...List.generate(
            2,
            (_) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: _card(),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(children: [
                      const ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.drag_indicator),
                          title: Text('Fundamentos da Extrusão'),
                          subtitle: Text(
                              'Entenda os princípios básicos do processo de extrusão.')),
                      Row(children: [
                        Expanded(
                            child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 36),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    foregroundColor: const Color(0xFF132B5C),
                                    side: const BorderSide(
                                        color: Color(0xFF132B5C)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ModuleEditorScreen())),
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Editar Módulo',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 36),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    foregroundColor: const Color(0xFFD93838),
                                    side: const BorderSide(
                                        color: Color(0xFFD93838)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                onPressed: () {},
                                icon:
                                    const Icon(Icons.delete_outline, size: 18),
                                label: const Text('Excluir Módulo',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600))))
                      ])
                    ])))),
        SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ModuleEditorScreen())),
                icon: const Icon(Icons.add),
                label: const Text('ADICIONAR MÓDULO'))),
      ]);
  Widget _assessment() => ListView(children: [
        const _Field('Quantidade de questões', hint: 'Ex: 35'),
        const Padding(
            padding: EdgeInsets.only(bottom: 13),
            child: Text('Mínimo: 30 | Máximo: 50',
                style: TextStyle(fontSize: 10, color: Colors.black54))),
        const _Field('Nota mínima para aprovação', hint: 'Ex: 70'),
        Container(
            decoration: _card(),
            child: ListTile(
                title: const Text('Gerenciar Questões',
                    style:
                        TextStyle(color: _blue, fontWeight: FontWeight.bold)),
                subtitle:
                    const Text('Cadastre e edite as questões da avaliação.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminQuestionListScreen()))))
      ]);
  void _saved(BuildContext context) => showDialog(
      context: context,
      builder: (_) => TrainingSuccessDialog(
          onAddMore: () {
            Navigator.pop(context);
            setState(() => tab = 0);
          },
          onClose: () =>
              Navigator.of(context).popUntil((route) => route.isFirst)));
}

class ModuleEditorScreen extends StatelessWidget {
  const ModuleEditorScreen({super.key});
  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Novo Módulo',
      admin: true,
      fallbackRoute: PextRoutes.training,
      child: ListView(children: [
        const _Field('Título do módulo', hint: 'Ex: Fundamentos da Extrusão'),
        const _Field('Descrição curta', hint: 'Descreva o módulo'),
        const _AttachmentPreview(
            title: 'Vídeos do módulo',
            item: 'Processamento ...',
            detail: '03:20',
            video: true),
        const _AttachmentPreview(
            title: 'Documentos',
            item: 'Ficha Técnica ...',
            detail: 'PDF - 1,2 MB'),
        const SizedBox(height: 18),
        SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CADASTRAR')))
      ]));
}

class AdminQuestionListScreen extends StatelessWidget {
  const AdminQuestionListScreen({super.key});
  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Questões',
        admin: true,
        fallbackRoute: PextRoutes.training,
        child: ListView(children: [
          _AddContentButton(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const QuestionTypeSelectorScreen()))),
          ...List.generate(
              10,
              (index) => Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: _card(),
                    child: ListTile(
                      leading: Text('${index + 1}.'),
                      title: const Text(
                          'Qual é a principal função da temperatura de extrusão no processo?'),
                      subtitle: const Text('Múltipla escolha'),
                      trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminQuestionEditorScreen()))),
                    ),
                  )),
          const SizedBox(height: 18),
          OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('FECHAR')),
        ]),
      );
}

class QuestionTypeSelectorScreen extends StatefulWidget {
  const QuestionTypeSelectorScreen({super.key});
  @override
  State<QuestionTypeSelectorScreen> createState() =>
      _QuestionTypeSelectorScreenState();
}

class _QuestionTypeSelectorScreenState
    extends State<QuestionTypeSelectorScreen> {
  int selected = 0;
  static const types = [
    ('Resposta Única', 'Apenas uma alternativa.'),
    ('Verdadeiro ou Falso', 'Defina o que é verdadeiro ou falso.'),
    ('Múltipla Escolha', 'Pode conter mais de uma alternativa correta.'),
  ];

  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Questões',
      admin: true,
      fallbackRoute: PextRoutes.training,
      child: Column(children: [
        const Align(
            alignment: Alignment.centerLeft,
            child: Text('Título do Treinamento',
                style: TextStyle(color: _blue, fontWeight: FontWeight.bold))),
        const SizedBox(height: 14),
        Expanded(
            child: ListView.builder(
                itemCount: types.length,
                itemBuilder: (_, index) {
                  final item = types[index];
                  return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: _card(),
                      child: RadioListTile<int>(
                          value: index,
                          groupValue: selected,
                          onChanged: (value) =>
                              setState(() => selected = value!),
                          title: Text(item.$1,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(item.$2),
                          secondary: Icon(
                              index == 0
                                  ? Icons.radio_button_checked
                                  : index == 1
                                      ? Icons.rule
                                      : Icons.checklist,
                              color: _blue)));
                })),
        Row(children: [
          Expanded(
              child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ANTERIOR'))),
          const SizedBox(width: 4),
          Expanded(
              child: FilledButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AdminQuestionEditorScreen(
                              initialType: selected, returnToList: true))),
                  child: const Text('PRÓXIMO')))
        ])
      ]));
}

class AdminQuestionEditorScreen extends StatefulWidget {
  final int initialType;
  final bool returnToList;
  const AdminQuestionEditorScreen(
      {super.key, this.initialType = 0, this.returnToList = false});
  @override
  State<AdminQuestionEditorScreen> createState() =>
      _AdminQuestionEditorScreenState();
}

class _AdminQuestionEditorScreenState extends State<AdminQuestionEditorScreen> {
  late int type;
  final List<String> _alternatives =
      List.filled(4, 'Alternativa da questão', growable: true);
  final Set<int> _correct = {0};

  @override
  void initState() {
    super.initState();
    type = widget.initialType;
    if (type == 1) {
      _alternatives
        ..clear()
        ..addAll(['Verdadeiro', 'Falso']);
    }
  }

  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Questões',
      admin: true,
      fallbackRoute: PextRoutes.training,
      child: Column(children: [
        Expanded(
            child: ListView(children: [
          const _Field('Enunciado da questão',
              lines: 4, hint: 'Ex: Material irregular na matriz'),
          const _UploadDropZone('Imagem (opcional)'),
          const Text('Alternativas',
              style: TextStyle(color: _blue, fontWeight: FontWeight.bold)),
          ...List.generate(
              _alternatives.length,
              (index) => Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: _card(),
                  child: ListTile(
                      leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(type == 1
                              ? (index == 0 ? 'V' : 'F')
                              : 'ABCD'[index])),
                      title: Text(_alternatives[index]),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        if (type == 2)
                          Checkbox(
                              value: _correct.contains(index),
                              onChanged: (value) => setState(() {
                                    if (value!) {
                                      _correct.add(index);
                                    } else {
                                      _correct.remove(index);
                                    }
                                  }))
                        else
                          Radio<int>(
                              value: index,
                              groupValue: _correct.first,
                              onChanged: (value) => setState(() {
                                    _correct
                                      ..clear()
                                      ..add(value!);
                                  })),
                        IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _editAlternative(index)),
                        IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                setState(() => _alternatives.removeAt(index)))
                      ])))),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                  onPressed: () => _editAlternative(null),
                  icon: const Icon(Icons.add),
                  label: const Text('ADICIONAR ALTERNATIVA')))
        ])),
        Row(children: [
          Expanded(
              child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ANTERIOR'))),
          const SizedBox(width: 4),
          Expanded(
              child: FilledButton(
                  onPressed: _saveQuestion, child: const Text('PRÓXIMO')))
        ]),
      ]));

  void _editAlternative(int? index) {
    final controller =
        TextEditingController(text: index == null ? '' : _alternatives[index]);
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => Padding(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alternativa',
                      style:
                          TextStyle(color: _blue, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: 'Ex:')),
                  const SizedBox(height: 16),
                  SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                          onPressed: () {
                            final value = controller.text.trim();
                            if (value.isNotEmpty) {
                              setState(() => index == null
                                  ? _alternatives.add(value)
                                  : _alternatives[index] = value);
                            }
                            Navigator.pop(sheetContext);
                          },
                          child: Text(index == null ? 'ADICIONAR' : 'SALVAR')))
                ])));
  }

  void _saveQuestion() {
    final navigator = Navigator.of(context);
    navigator.pop();
    if (widget.returnToList) navigator.pop();
  }
}

class ChatAssistantScreen extends StatefulWidget {
  final bool admin;
  const ChatAssistantScreen({super.key, this.admin = false});

  @override
  State<ChatAssistantScreen> createState() => _ChatAssistantScreenState();
}

class _ChatAssistantScreenState extends State<ChatAssistantScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    if (!widget.admin) {
      return _Shell(
          title: 'Assistente IA',
          admin: false,
          child: const _AssistantChatTab());
    }

    return _Shell(
        title: 'Assistente IA',
        admin: true,
        action: _tab == 2
            ? _BoxedHeaderAction(
                icon: Icons.add,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const CadastroConteudoScreen())))
            : null,
        child: Column(children: [
          _TabBar(
              labels: const ['Chat', 'Dúvidas', 'Conteúdo'],
              value: _tab,
              onChanged: (value) => setState(() => _tab = value)),
          const SizedBox(height: 14),
          Expanded(
              child: IndexedStack(index: _tab, children: const [
            _AssistantChatTab(),
            _DuvidasTabView(),
            _ConteudoTabView(),
          ]))
        ]));
  }
}

class _AssistantChatTab extends StatefulWidget {
  const _AssistantChatTab();

  @override
  State<_AssistantChatTab> createState() => _AssistantChatTabState();
}

class _AssistantChatTabState extends State<_AssistantChatTab> {
  final _controller = TextEditingController();
  final _messages = <_AssistantMessage>[
    const _AssistantMessage('Como posso ajudar na sua operação hoje?', false),
    const _AssistantMessage('Qual a faixa de temperatura para PEBD?', true),
    const _AssistantMessage(
        'Consulte a ficha técnica. Para um ajuste específico de linha, posso encaminhar a solicitação para o supervisor.',
        false),
  ];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add(_AssistantMessage(text, true)));
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Expanded(
            child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: _messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) =>
                    _ChatBubble(_messages[index].text, _messages[index].mine))),
        Container(
            height: 50,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Expanded(
                  child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 14),
                          hintText: 'Faça sua pergunta',
                          hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                          border: InputBorder.none))),
              InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _send,
                  child: Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(11),
                      decoration: const BoxDecoration(
                          color: _blue,
                          borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(14))),
                      child: const PextAssetIcon(PextAssets.send, size: 24)))
            ]))
      ]);
}

class _AssistantMessage {
  final String text;
  final bool mine;
  const _AssistantMessage(this.text, this.mine);
}

class _DuvidasTabView extends StatefulWidget {
  const _DuvidasTabView();

  @override
  State<_DuvidasTabView> createState() => _DuvidasTabViewState();
}

class _DuvidasTabViewState extends State<_DuvidasTabView> {
  int _filter = 0;
  final _items = const [true, true, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    final shown = _filter == 0
        ? _items
        : _items.where((answered) => answered == (_filter == 1)).toList();
    return Column(children: [
      _FilterRow(
          labels: const ['Todos', 'Respondido', 'Não respondida'],
          value: _filter,
          onChanged: (value) => setState(() => _filter = value)),
      const SizedBox(height: 12),
      Expanded(
          child: ListView.separated(
              itemCount: shown.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) => _QuestionCard(answered: shown[index])))
    ]);
  }
}

class _QuestionCard extends StatelessWidget {
  final bool answered;
  const _QuestionCard({required this.answered});

  @override
  Widget build(BuildContext context) {
    final color = answered ? const Color(0xFF20BF64) : const Color(0xFFF8494E);
    return Container(
        padding: const EdgeInsets.all(12),
        decoration: _card(),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage('images/profile_igor.png')),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Igor Teixeira Corturato - 08/08/2026',
                    style: TextStyle(fontSize: 9, color: Color(0xFF737D8C))),
                const SizedBox(height: 6),
                const Text(
                    'O que pode fazer o material sair da matriz de forma irregular',
                    style: TextStyle(
                        fontSize: 14,
                        height: 1.12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 9),
                _StatusBadge(
                    label: answered ? 'Respondido' : 'Não respondida',
                    color: color)
              ])),
          const Padding(
              padding: EdgeInsets.only(top: 25),
              child: Icon(Icons.chevron_right, color: Color(0xFF26313D)))
        ]));
  }
}

class _ConteudoTabView extends StatefulWidget {
  const _ConteudoTabView();

  @override
  State<_ConteudoTabView> createState() => _ConteudoTabViewState();
}

class _ConteudoTabViewState extends State<_ConteudoTabView> {
  int _filter = 0;
  String _query = '';
  final _items = const [true, true, true, true, false, false, true];

  @override
  Widget build(BuildContext context) {
    final shown = _items
        .where((active) =>
            (_filter == 0 || active == (_filter == 1)) &&
            'Material irregular na matriz'
                .toLowerCase()
                .contains(_query.toLowerCase()))
        .toList();
    return Column(children: [
      _FilterRow(
          labels: const ['Todos', 'Ativos', 'Excluídas'],
          value: _filter,
          onChanged: (value) => setState(() => _filter = value)),
      const SizedBox(height: 12),
      AppSearchBar(
          hint: 'Ex: Bolhas',
          onChanged: (value) => setState(() => _query = value)),
      const SizedBox(height: 12),
      Expanded(
          child: ListView.separated(
              itemCount: shown.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) => _ContentCard(active: shown[index])))
    ]);
  }
}

class _ContentCard extends StatelessWidget {
  final bool active;
  const _ContentCard({required this.active});
  @override
  Widget build(BuildContext context) => InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DetalhesConteudoScreen())),
      child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          decoration: _card(),
          child: Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Material irregular na matriz',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  const Text('Última alteração: 03/07/2026 - 11:35',
                      style: TextStyle(fontSize: 9, color: Color(0xFF737D8C))),
                  const Text('Autor: André',
                      style: TextStyle(fontSize: 9, color: Color(0xFF737D8C))),
                  const SizedBox(height: 9),
                  _StatusBadge(
                      label: active ? 'Ativo' : 'Excluídas',
                      color: active
                          ? const Color(0xFF20BF64)
                          : const Color(0xFFF8494E))
                ])),
            const Icon(Icons.chevron_right, color: Color(0xFF26313D))
          ])));
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
                ? const Color(0xFFF8494E)
                : const Color(0xFF737D8C);
        return Expanded(
            child: Padding(
                padding: EdgeInsets.only(
                    right: entry.key == labels.length - 1 ? 0 : 8),
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 30),
                        side: BorderSide(color: color),
                        padding: EdgeInsets.zero,
                        foregroundColor: color),
                    onPressed: () => onChanged(entry.key),
                    child: Text(entry.value,
                        style: const TextStyle(fontSize: 9)))));
      }).toList());
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
      constraints: const BoxConstraints(minWidth: 78),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(5)),
      child: Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w600)));
}

class CadastroConteudoScreen extends StatelessWidget {
  const CadastroConteudoScreen({super.key});

  @override
  Widget build(BuildContext context) => _Shell(
      title: 'NOVO CONTEÚDO',
      admin: true,
      child: Column(children: [
        Expanded(
            child: ListView(children: [
          const _ContentFormField('Digite o tema',
              hint: 'Ex: Material irregular na matriz'),
          const _ContentFormField('Conteúdo', lines: 5),
          const _ContentFormField('Categoria'),
          const Text('Anexar Documentação',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const _DocumentAttachment(),
          const SizedBox(height: 8),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('ADICIONAR DOCUMENTO'))),
          const SizedBox(height: 20),
        ])),
        SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const ConteudoSucessoDialog()),
                child: const Text('CADASTRAR')))
      ]));
}

class _ContentFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final int lines;
  const _ContentFormField(this.label, {this.hint, this.lines = 1});

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
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

class _DocumentAttachment extends StatelessWidget {
  const _DocumentAttachment();
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(10),
      decoration: _card(),
      child: const Row(children: [
        PextAssetIcon(PextAssets.pdf, size: 31),
        SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Ficha Técnica.pdf',
              style: TextStyle(color: _blue, fontWeight: FontWeight.w600)),
          Text('PDF - 1,2 MB',
              style: TextStyle(fontSize: 10, color: Color(0xFF737D8C)))
        ])),
        PextAssetIcon(PextAssets.download, size: 24)
      ]));
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
            const Text('Conteúdo adicionado com sucesso!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _blue, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: () => Navigator.pop(context),
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

class DetalhesConteudoScreen extends StatelessWidget {
  const DetalhesConteudoScreen({super.key});
  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Assistente IA',
      admin: true,
      child: ListView(children: [
        _contentSummary(),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
              child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const PextAssetIcon(PextAssets.edit, size: 17),
                  label: const Text('Editar Conteúdo'))),
          const SizedBox(width: 9),
          Expanded(
              child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF8494E),
                      side: const BorderSide(color: Color(0xFFF8494E))),
                  onPressed: () {},
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Excluir Conteúdo')))
        ]),
        const SizedBox(height: 18),
        const Text('Histórico de alteração',
            style: TextStyle(
                color: _blue, fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _HistoryEvent(
            color: const Color(0xFF20BF64),
            icon: Icons.add,
            date: '01/08/2026 - 09:33',
            title: 'André criou este conteúdo.',
            text: 'Conteúdo inicial adicionado.'),
        _HistoryEvent(
            color: _blue,
            icon: Icons.edit_outlined,
            date: '02/08/2026 - 09:43',
            title: 'Maria editou o conteúdo',
            text: 'Alterações:\n- Inclusão de Documento',
            onVersion: () => _openComparison(context)),
        _HistoryEvent(
            color: _blue,
            icon: Icons.edit_outlined,
            date: '05/08/2026 - 09:43',
            title: 'Jorge editou o conteúdo',
            text: 'Alterações:\n- Removeu um documento',
            onVersion: () => _openComparison(context)),
        _HistoryEvent(
            color: const Color(0xFFF8494E),
            icon: Icons.delete_outline,
            date: '18/08/2026 - 09:43',
            title: 'Pedro excluiu este conteúdo',
            text: 'Motivo:\n- Informação desatualizada',
            onVersion: () => _openComparison(context)),
      ]));
}

void _openComparison(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const ComparacaoVersoesConteudoScreen()));

Widget _contentSummary() => Container(
    padding: const EdgeInsets.all(14),
    decoration: _card(),
    child:
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Material irregular na matriz',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      SizedBox(height: 7),
      Text('Última alteração: 03/07/2026 - 11:35',
          style: TextStyle(fontSize: 10, color: Color(0xFF737D8C))),
      Text('Autor: André',
          style: TextStyle(fontSize: 10, color: Color(0xFF737D8C))),
      SizedBox(height: 10),
      _StatusBadge(label: 'Ativo', color: Color(0xFF20BF64))
    ]));

class _HistoryEvent extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String date, title, text;
  final VoidCallback? onVersion;
  const _HistoryEvent(
      {required this.color,
      required this.icon,
      required this.date,
      required this.title,
      required this.text,
      this.onVersion});

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20)),
        const SizedBox(width: 9),
        Expanded(
            child: Container(
                padding: const EdgeInsets.all(12),
                decoration: _card(),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(date,
                          style: const TextStyle(
                              fontSize: 9, color: Color(0xFF737D8C))),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(text,
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF737D8C))),
                      if (onVersion != null)
                        TextButton(
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.only(top: 5)),
                            onPressed: onVersion,
                            child: const Text('Ver conteúdo anterior.',
                                style: TextStyle(fontSize: 10)))
                    ])))
      ]));
}

class ComparacaoVersoesConteudoScreen extends StatelessWidget {
  const ComparacaoVersoesConteudoScreen({super.key});
  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Assistente IA',
      admin: true,
      child: ListView(children: [
        Container(
            padding: const EdgeInsets.all(14),
            decoration: _card(),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Conteúdo: Material irregular na matriz',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  Text('Alteração em: 05/08/2026 - 09:35'),
                  SizedBox(height: 3),
                  Text('Alterado por: Maria')
                ])),
        const SizedBox(height: 16),
        const Text('Comparação de versões',
            style: TextStyle(
                color: _blue, fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _comparisonCard(),
        const SizedBox(height: 16),
        const Text('Anexos:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        _attachmentsComparison()
      ]));
}

Widget _comparisonCard() => Container(
    decoration: _card(),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
      Expanded(
          child: _VersionColumn(
              date: 'Versão de 02/08/2026 - 9:40',
              text:
                  'Quando identificado material irregular na matriz, realizar a inspeção da peça e verificar se a ocorrência compromete o padrão de qualidade estabelecido. Caso seja constatada irregularidade, separar a peça e encaminhá-la para avaliação.')),
      Expanded(
          child: _VersionColumn(
              date: 'Versão de 05/08/2026 - 9:35',
              text:
                  'Quando identificado material irregular na matriz, a peça deve ser imediatamente segregada e registrada como não conforme. A ocorrência deve ser avaliada conforme o padrão de qualidade vigente.')),
    ]));

class _VersionColumn extends StatelessWidget {
  final String date, text;
  const _VersionColumn({required this.date, required this.text});
  @override
  Widget build(BuildContext context) => Container(
      constraints: const BoxConstraints(minHeight: 215),
      decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: _border))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(9),
            color: const Color(0xFFE9EDF3),
            child: Text(date,
                style:
                    const TextStyle(fontSize: 9, fontWeight: FontWeight.w600))),
        Padding(
            padding: const EdgeInsets.all(10),
            child: Text(text,
                style: const TextStyle(fontSize: 9, color: Color(0xFF737D8C))))
      ]));
}

Widget _attachmentsComparison() => Container(
    decoration: _card(),
    child: Row(children: const [
      Expanded(
          child: _AttachmentVersion(
              label: 'Versão anterior',
              color: Color(0xFFFFE9E9),
              status: 'Removido',
              statusColor: Color(0xFFF8494E))),
      Expanded(
          child: _AttachmentVersion(
              label: 'Versão atual',
              color: Color(0xFFD6F9D9),
              status: 'Adicionado',
              statusColor: Color(0xFF20BF64))),
    ]));

class _AttachmentVersion extends StatelessWidget {
  final String label, status;
  final Color color, statusColor;
  const _AttachmentVersion(
      {required this.label,
      required this.color,
      required this.status,
      required this.statusColor});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(9),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
            padding: const EdgeInsets.all(8),
            color: color,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                PextAssetIcon(PextAssets.pdf, size: 24),
                SizedBox(width: 5),
                Expanded(
                    child: Text('Documentação 2025.pdf',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 8)))
              ]),
              const SizedBox(height: 6),
              Align(
                  alignment: Alignment.centerRight,
                  child: _StatusBadge(label: status, color: statusColor))
            ]))
      ]));
}

class PackagingListScreen extends StatefulWidget {
  final bool admin;
  const PackagingListScreen({super.key, this.admin = false});
  @override
  State<PackagingListScreen> createState() => _PackagingListScreenState();
}

class _PackagingListScreenState extends State<PackagingListScreen> {
  String _query = '';
  static const _items = ['RAP10', 'Macarrão', 'KitKat'];

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Embalagens',
        admin: widget.admin,
        returnToHome: true,
        action: _BoxedHeaderAction(
            icon: Icons.add,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    PackagingRegistrationScreen(admin: widget.admin)))),
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
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PackagingDetailScreen(
                            admin: widget.admin, packagingName: item))),
                  ),
                ),
              ),
        ]),
      );
}

class PackagingRegistrationScreen extends StatefulWidget {
  final bool admin;
  const PackagingRegistrationScreen({super.key, required this.admin});

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

  @override
  void initState() {
    super.initState();
    _materials = List<String>.from(['1518MM', 'FLEXUS 9212', 'HF2208S3'],
        growable: true);
    _specification = PackagingCatalog.byName('RAP10');
    _parameters = _specification.parameters;
    _extraParameters = _specification.extraParameters;
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

  void _save() {
    for (var index = 0; index < _parameters.length; index++) {
      _parameters[index].min = double.tryParse(
              _minimumControllers[index].text.replaceAll(',', '.')) ??
          _parameters[index].min;
      _parameters[index].max = double.tryParse(
              _maximumControllers[index].text.replaceAll(',', '.')) ??
          _parameters[index].max;
    }
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
                        Navigator.of(context).pop();
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
                onPressed: _save,
                child: const Text('CADASTRAR',
                    style: TextStyle(fontWeight: FontWeight.bold)))),
      ]));

  Widget _body() {
    switch (_tab) {
      case 0:
        return ListView(children: const [
          _Field('Nome da Embalagem', hint: 'Ex: RAP10'),
          _TrainingSelectField('Categoria'),
          _UploadDropZone('Imagem da Embalagem'),
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
    final unit = TextEditingController();
    final minimum = TextEditingController();
    final maximum = TextEditingController();
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => Padding(
            padding: EdgeInsets.fromLTRB(
                18, 18, 18, MediaQuery.viewInsetsOf(sheetContext).bottom + 18),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Nova verificação extra',
                  style: TextStyle(
                      color: _blue, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              TextField(
                  controller: name,
                  decoration:
                      const InputDecoration(labelText: 'Nome do parâmetro')),
              TextField(
                  controller: unit,
                  decoration: const InputDecoration(labelText: 'Unidade')),
              TextField(
                  controller: minimum,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Valor mínimo')),
              TextField(
                  controller: maximum,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Valor máximo')),
              const SizedBox(height: 14),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: () {
                        final min =
                            double.tryParse(minimum.text.replaceAll(',', '.'));
                        final max =
                            double.tryParse(maximum.text.replaceAll(',', '.'));
                        if (name.text.trim().isEmpty ||
                            unit.text.trim().isEmpty ||
                            min == null ||
                            max == null) return;
                        setState(() => _extraParameters.add(PackagingParameter(
                            name: name.text.trim(),
                            unit: unit.text.trim(),
                            min: min,
                            max: max,
                            isCustom: true)));
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('ADICIONAR')))
            ])));
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
              child: const Center(
                  child: PextAssetIcon(PextAssets.product, size: 88))),
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
          if (admin) ...[
            const SizedBox(height: 22),
            Row(children: [
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  PackagingRegistrationScreen(admin: admin))),
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
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Embalagem excluída com sucesso.')));
                        Navigator.of(context).pop();
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

  void _logout() =>
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);

  @override
  Widget build(BuildContext context) => _Shell(
      title: _tab == 1 ? 'Perfil - Edição' : 'Perfil',
      admin: widget.admin,
      returnToHome: true,
      child: Column(children: [
        _ProfileIdentity(
            editing: _editing, name: widget.admin ? 'André' : 'Igor'),
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
                    onEdit: () => setState(() => _editing = true),
                    onSave: () => setState(() => _editing = false),
                    onLogout: _logout)
                : const SegurancaTabView())
      ]));
}

class _ProfileIdentity extends StatelessWidget {
  final bool editing;
  final String name;
  const _ProfileIdentity({required this.editing, required this.name});

  @override
  Widget build(BuildContext context) => Column(children: [
        Stack(clipBehavior: Clip.none, children: [
          Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _border, width: 2)),
              clipBehavior: Clip.antiAlias,
              child: Image.asset('images/profile_igor.png', fit: BoxFit.cover)),
          if (editing)
            Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _blue, width: 1.5),
                        borderRadius: BorderRadius.circular(7)),
                    child: const Icon(Icons.edit_outlined,
                        color: _blue, size: 19)))
        ]),
        const SizedBox(height: 8),
        Text(name,
            style: const TextStyle(
                color: _blue, fontSize: 26, fontWeight: FontWeight.bold))
      ]);
}

class DadosTabView extends StatelessWidget {
  final bool editing;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onLogout;
  const DadosTabView(
      {super.key,
      required this.editing,
      required this.onEdit,
      required this.onSave,
      required this.onLogout});

  static const _fields = [
    ('CPF', '123.***.***-45'),
    ('Data Nascimento', '30/03/2005'),
    ('E-mail', 'igorurato@gmail.com'),
    ('Telefone', '(17) 8922-4002'),
    ('Endereço', 'Rua Jorge Meneguel, 1948, Vila Velha'),
    ('Cidade', 'Fernandópolis'),
    ('Função', 'Produção'),
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ..._fields.map((field) =>
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
      ]));
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
  const _BoxedHeaderAction({required this.icon, this.onTap});
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
          icon: Icon(icon, size: 19, color: _blue)));
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

class _TrainingTile extends StatelessWidget {
  final int status;
  final bool admin;
  final VoidCallback onTap;
  const _TrainingTile(
      {required this.status, required this.admin, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final labels = ['Em curso', 'Desistência', 'Concluído', 'Concluído'];
    final colors = [
      const Color(0xFFF0A000),
      const Color(0xFFF04444),
      const Color(0xFF1AB65C),
      const Color(0xFF1AB65C),
    ];
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
                      const Expanded(
                          child: Text('Processo de extrusão',
                              style: TextStyle(
                                  color: _blue, fontWeight: FontWeight.bold))),
                      if (!admin) _Pill(labels[status], colors[status])
                    ]),
                    Text(
                        admin
                            ? '10 Módulos  •  20 Questões'
                            : 'Módulo 2 - Temperatura e pressão',
                        style: const TextStyle(fontSize: 8)),
                    if (!admin) ...[
                      const SizedBox(height: 7),
                      Row(children: [
                        Expanded(
                            child: LinearProgressIndicator(
                                value: status >= 2
                                    ? 1
                                    : status == 1
                                        ? 0
                                        : .7,
                                color: _blue,
                                backgroundColor: _border,
                                minHeight: 5)),
                        const SizedBox(width: 5),
                        Text(
                            status >= 2
                                ? '100%'
                                : status == 1
                                    ? '0%'
                                    : '70%',
                            style: const TextStyle(fontSize: 10, color: _blue))
                      ]),
                    ],
                    if (!admin && status == 1)
                      const _TrainingContextBanner(
                        asset: PextAssets.tryAgain,
                        color: Color(0xFFF04444),
                        text: 'Você parou de estudar. Retome de onde parou.',
                      ),
                    if (!admin && status == 2)
                      const _TrainingContextBanner(
                        asset: PextAssets.approved,
                        color: Color(0xFF1AB65C),
                        text:
                            'Aprovado - Você acertou 18 de 20 questões (90%).',
                      ),
                    if (!admin && status == 3)
                      const _TrainingContextBanner(
                        asset: PextAssets.warning,
                        color: Color(0xFFF0A000),
                        iconBackground: Color(0xFFF59E0B),
                        text:
                            'Reprovado - Você acertou 11 de 20 questões (55%).',
                      ),
                  ])),
              Icon(
                  admin
                      ? Icons.chevron_right
                      : status == 2
                          ? Icons.favorite
                          : Icons.favorite_border,
                  color: _blue,
                  size: 20)
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
  const _Field(this.label, {this.lines = 1, this.value, this.hint});
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
            controller:
                value == null ? null : TextEditingController(text: value),
            readOnly: value != null,
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
