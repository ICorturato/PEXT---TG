import 'package:flutter/material.dart';
import '../../widgets/pext_asset_icon.dart';

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
  final _terms = const [
    'Aditivo',
    'Aderência Intercamadas',
    'Anel de Ar',
    'Alimentador',
    'ABS (Acrilonitrila Butadieno Estireno)',
    'Barreira',
    'Bobina',
    'Bolha',
    'Bico de Extrusão',
    'Blenda Polimérica',
    'Coextrusão',
    'Cabeçote',
    'Camada Barreira',
    'Canal de Fluxo',
    'Cristalinidade',
    'Die',
    'Degasagem',
    'Delaminação',
    'Dosagem Gravimétrica',
    'Distribuidor de Fluxo',
    'Extrusão'
  ];
  @override
  Widget build(BuildContext context) {
    final items = _terms
        .where((term) => term.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return _Shell(
        title: widget.admin ? 'Termos' : 'Dicionário de Termos',
        action: widget.admin
            ? _BoxedHeaderAction(
                icon: Icons.add, onTap: () => _termDialog(context))
            : const _BoxedHeaderAction(icon: Icons.favorite_border),
        child: Column(children: [
          TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                  prefixIcon: PextAssetIcon(PextAssets.search, size: 21),
                  hintText: 'Ex: Coextrusão',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(13)),
                      borderSide: BorderSide(color: _border)))),
          const SizedBox(height: 14),
          Expanded(
              child: items.isEmpty
                  ? const _NoTermsFound()
                  : ListView(children: _grouped(items))),
        ]));
  }

  List<Widget> _grouped(List<String> items) {
    String letter = '';
    final children = <Widget>[];
    for (final term in items) {
      final initial = term[0].toUpperCase();
      if (initial != letter) {
        letter = initial;
        children.add(Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 0, 4),
            child: Text(letter,
                style: const TextStyle(
                    color: _blue, fontWeight: FontWeight.w600))));
      }
      children.add(InkWell(
          onTap: () => _detail(context, term),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: _border))),
              child: Row(children: [
                Expanded(child: Text(term)),
                Icon(widget.admin ? Icons.edit_outlined : Icons.chevron_right,
                    size: 18, color: _blue)
              ]))));
    }
    return children;
  }

  void _detail(BuildContext context, String term) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => TermInfoScreen(term: term)));
  void _termDialog(BuildContext context) => showDialog(
      context: context,
      builder: (_) => const _InfoDialog('Adicionar termo',
          'Formulário visual para cadastrar definição, operação e referências.'));
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

class TermInfoScreen extends StatelessWidget {
  final String term;
  const TermInfoScreen({super.key, required this.term});

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Dicionário de Termos',
        action: const _BoxedHeaderAction(icon: Icons.favorite_border),
        child: ListView(children: [
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ExamScreen()));
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
                          builder: (_) => const LessonDetailScreen())))),
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
      height: 62,
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
  const LessonDetailScreen({super.key});
  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Processos de ...',
        action: const _BoxedHeaderAction(icon: Icons.favorite_border),
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
                    leading:
                        Container(width: 44, height: 44, decoration: _card()),
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
              context: context, builder: (_) => const _QuestionNavigator())),
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
        ),
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
                context: context, builder: (_) => const _QuestionNavigator())),
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
      child: Column(children: [
        const Spacer(),
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
        const Spacer(),
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
        _Field('Título do treinamento'),
        _Field('Descrição curta', lines: 4),
        _Field('Categoria'),
        _Field('Carga horária total'),
        _EditorSection('Imagem de capa', Icons.cloud_upload_outlined)
      ]);
  Widget _modules() => ListView(children: [
        ...List.generate(
            2,
            (_) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: _card(),
                child: const ListTile(
                    leading: Icon(Icons.drag_indicator),
                    title: Text('Fundamentos da Extrusão'),
                    subtitle: Text(
                        'Entenda os princípios básicos do processo de extrusão.'),
                    trailing: Icon(Icons.delete_outline)))),
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
        const _Field('Quantidade de questões'),
        const _Field('Nota mínima para aprovação'),
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
      builder: (_) => AlertDialog(
              title: const Text('Treinamento adicionado com sucesso!'),
              actions: [
                FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('FECHAR'))
              ]));
}

class ModuleEditorScreen extends StatelessWidget {
  const ModuleEditorScreen({super.key});
  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Novo Módulo',
      admin: true,
      child: ListView(children: [
        const _Field('Título do módulo'),
        const _Field('Descrição curta'),
        const _EditorSection('Vídeos do módulo', Icons.video_library_outlined),
        const _EditorSection('Documentos', Icons.description_outlined),
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
        child: ListView(children: [
          SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminQuestionEditorScreen())),
                  icon: const Icon(Icons.add),
                  label: const Text('NOVA QUESTÃO'))),
          ...List.generate(
              8,
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
        ]),
      );
}

class AdminQuestionEditorScreen extends StatefulWidget {
  const AdminQuestionEditorScreen({super.key});
  @override
  State<AdminQuestionEditorScreen> createState() =>
      _AdminQuestionEditorScreenState();
}

class _AdminQuestionEditorScreenState extends State<AdminQuestionEditorScreen> {
  int type = 0;
  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Questões',
      admin: true,
      child: Column(children: [
        _TabBar(
            labels: const ['Resposta única', 'Verdadeiro/Falso', 'Múltipla'],
            value: type,
            onChanged: (value) => setState(() => type = value)),
        const SizedBox(height: 16),
        Expanded(
            child: ListView(children: [
          const _Field('Enunciado da questão', lines: 4),
          const _EditorSection(
              'Imagem (opcional)', Icons.cloud_upload_outlined),
          const Text('Alternativas',
              style: TextStyle(color: _blue, fontWeight: FontWeight.bold)),
          ...List.generate(
              type == 1 ? 2 : 4,
              (index) => Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: _card(),
                  child: ListTile(
                      leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(type == 1
                              ? (index == 0 ? 'V' : 'F')
                              : 'ABCD'[index])),
                      title: const Text('Alternativa da questão'),
                      trailing: const Icon(Icons.edit_outlined)))),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('ADICIONAR ALTERNATIVA')))
        ])),
        SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('SALVAR QUESTÃO'))),
      ]));
}

class ChatAssistantScreen extends StatelessWidget {
  final bool admin;
  const ChatAssistantScreen({super.key, this.admin = false});
  @override
  Widget build(BuildContext context) => _Shell(
      title: admin ? 'Suporte administrativo' : 'Assistente IA',
      child: Column(children: [
        Expanded(
            child: ListView(children: [
          if (admin)
            const _ChatBubble(
                'Solicitação de Igor: avaliar pressão para embalagem KitKat.',
                true),
          const _ChatBubble(
              'Olá! Como posso ajudar na sua operação hoje?', false),
          const _ChatBubble('Qual a faixa de temperatura para PEBD?', true),
          const _ChatBubble(
              'Consulte primeiro a ficha técnica. Se a dúvida exigir ajuste específico de linha, posso abrir uma solicitação para o supervisor.',
              false)
        ])),
        Container(
            height: 48,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(15)),
            child: Row(children: [
              const Expanded(
                  child: TextField(
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 13),
                          hintText: 'Faça sua pergunta',
                          hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                          border: InputBorder.none))),
              Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                      color: _blue,
                      borderRadius:
                          BorderRadius.horizontal(right: Radius.circular(14))),
                  child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: PextAssetIcon(PextAssets.send, size: 25))),
            ])),
      ]));
}

class PackagingListScreen extends StatefulWidget {
  const PackagingListScreen({super.key});
  @override
  State<PackagingListScreen> createState() => _PackagingListScreenState();
}

class _PackagingListScreenState extends State<PackagingListScreen> {
  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Embalagens',
        action: IconButton(
            onPressed: () => showDialog(
                context: context,
                builder: (_) => const _InfoDialog('Cadastrar embalagem',
                    'Formulário visual para nome, estrutura, materiais e documentação.')),
            icon: const Icon(Icons.add_box_outlined, color: _blue)),
        child: Column(children: [
          const TextField(
              decoration: InputDecoration(
                  prefixIcon: PextAssetIcon(PextAssets.search, size: 21),
                  hintText: 'Buscar embalagem...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(13)),
                      borderSide: BorderSide.none))),
          const SizedBox(height: 14),
          ...['RAP10', 'Macarrão', 'KitKat'].map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: _card(),
              child: ListTile(
                leading: const PextAssetIcon(PextAssets.product, size: 26),
                title: Text(item,
                    style: const TextStyle(
                        color: _blue, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.chevron_right, color: _blue),
                onTap: () => showDialog(
                    context: context,
                    builder: (_) => _InfoDialog(item,
                        'Especificações, estruturas, resinas e documentação da embalagem.')),
              ),
            ),
          ),
        ]),
      );
}

class UserProfileScreen extends StatefulWidget {
  final bool admin;
  const UserProfileScreen({super.key, this.admin = false});
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Perfil',
      child: Column(children: [
        const CircleAvatar(
            radius: 62,
            backgroundColor: Colors.white,
            child: Padding(
                padding: EdgeInsets.all(20),
                child: PextAssetIcon(PextAssets.profileActive, size: 84))),
        const SizedBox(height: 10),
        Text(widget.admin ? 'André' : 'Igor',
            style: const TextStyle(
                color: _blue, fontSize: 23, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _TabBar(
            labels: const ['Dados', 'Segurança'],
            value: _tab,
            onChanged: (value) => setState(() => _tab = value)),
        const SizedBox(height: 16),
        Expanded(
            child: SingleChildScrollView(
                child: _tab == 0
                    ? Column(children: const [
                        _Field('CPF', value: '123.***.***-45'),
                        _Field('Data de nascimento', value: '30/03/2005'),
                        _Field('E-mail', value: 'igor@pext.com.br'),
                        _Field('Telefone', value: '(17) 99999-9999'),
                        _Field('Endereço', value: 'Rua Jorge Meneguel, 1948'),
                        _Field('Cidade', value: 'Fernandópolis'),
                        _Field('Função', value: 'Produção')
                      ])
                    : Column(children: const [
                        _Field('Senha atual', value: '••••••••'),
                        _Field('Nova senha', value: '••••••••'),
                        _Field('Confirmar nova senha', value: '••••••••')
                      ]))),
        OutlinedButton(
            onPressed: () {},
            child: Text(_tab == 0 ? 'EDITAR DADOS' : 'ALTERAR SENHA'))
      ]));
}

class _Shell extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  final bool admin;
  const _Shell(
      {required this.title,
      required this.child,
      this.action,
      this.admin = false});

  int get _selected {
    if ({
      'Treinamentos',
      'Processo de extrusão',
      'Processos de ...',
      'Conclusão Treinamento',
      'Avaliação Treinamento',
      'Resultado Avaliação',
      'Refazer Avaliação'
    }.contains(title)) return 0;
    if (title == 'Assistente IA' || title == 'Suporte administrativo') return 3;
    if (title == 'Perfil') return 4;
    return 2;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _canvas,
        appBar: AppBar(
            backgroundColor: _canvas,
            surfaceTintColor: _canvas,
            centerTitle: true,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: _blue, size: 19)),
            title: Text(title,
                style: const TextStyle(
                    color: _blue, fontWeight: FontWeight.w600, fontSize: 18)),
            actions: [if (action != null) action!, const SizedBox(width: 5)]),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(28, 6, 28, 18), child: child),
        bottomNavigationBar: _CoreBottomBar(selected: _selected, admin: admin),
      );
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
                      _replaceWith(context, TrainingListScreen(admin: admin))),
              _CoreNavItem(
                  asset: admin ? PextAssets.dashboard : PextAssets.heart,
                  activeAsset: admin
                      ? PextAssets.dashboardActive
                      : PextAssets.heartActive,
                  label: admin ? 'Dashboard' : 'Favoritos',
                  active: selected == 1,
                  onTap: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst)),
              _CoreNavItem(
                  asset: PextAssets.home,
                  activeAsset: PextAssets.homeActive,
                  label: 'Home',
                  active: selected == 2,
                  onTap: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst)),
              _CoreNavItem(
                  asset: PextAssets.chat,
                  activeAsset: PextAssets.chatActive,
                  label: 'Chat',
                  active: selected == 3,
                  onTap: () =>
                      _replaceWith(context, ChatAssistantScreen(admin: admin))),
              _CoreNavItem(
                  asset: PextAssets.profile,
                  activeAsset: PextAssets.profileActive,
                  label: 'Perfil',
                  active: selected == 4,
                  onTap: () =>
                      _replaceWith(context, UserProfileScreen(admin: admin))),
            ])),
      );

  void _replaceWith(BuildContext context, Widget page) =>
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => page),
        (route) => false,
      );
}

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
                      _Pill(labels[status], colors[status])
                    ]),
                    const Text('Módulo 2 - Temperatura e pressão',
                        style: TextStyle(fontSize: 8)),
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
                    if (status == 1)
                      const _TrainingContextBanner(
                        icon: Icons.restart_alt,
                        color: Color(0xFFF04444),
                        text: 'Você parou de estudar. Retome de onde parou.',
                      ),
                    if (status == 2)
                      const _TrainingContextBanner(
                        icon: Icons.star,
                        color: Color(0xFF1AB65C),
                        text:
                            'Aprovado - Você acertou 18 de 20 questões (90%).',
                      ),
                    if (status == 3)
                      const _TrainingContextBanner(
                        icon: Icons.warning_amber_rounded,
                        color: Color(0xFFF0A000),
                        text:
                            'Reprovado - Você acertou 11 de 20 questões (55%).',
                      ),
                  ])),
              Icon(status == 2 ? Icons.favorite : Icons.favorite_border,
                  color: _blue, size: 20)
            ])));
  }
}

class _TrainingContextBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _TrainingContextBanner(
      {required this.icon, required this.color, required this.text});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 7),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(7)),
        child: Row(children: [
          Icon(icon, color: color, size: 13),
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
  const _Field(this.label, {this.lines = 1, this.value});
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
                hintText: value == null ? 'Preencha $label' : null,
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: _border))))
      ]));
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
