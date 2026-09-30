import 'package:flutter/material.dart';
import '../../app_routes.dart';
import '../../models/app_category.dart';
import '../../models/doubt_model.dart';
import '../../models/packaging_specification.dart';
import '../../services/api_client.dart';
import '../../widgets/pext_asset_icon.dart';
import '../../widgets/app_search_bar.dart';
import '../core/category_management_screen.dart';
import '../core/core_screens.dart';

const _blue = Color(0xFF053488);
const _canvas = Color(0xFFF6F8FB);
const _border = Color(0xFFE5E7EB);

class TroubleshootingListScreen extends StatefulWidget {
  final bool admin;
  const TroubleshootingListScreen({super.key, this.admin = false});
  @override
  State<TroubleshootingListScreen> createState() =>
      _TroubleshootingListScreenState();
}

class _TroubleshootingListScreenState extends State<TroubleshootingListScreen> {
  String _query = '';
  var _problems = const [
    ApiProblem(
        id: 'local-thickness',
        title: 'Variação na espessura',
        description:
            'O produto sai com espessura irregular ou fora do especificado',
        recommendedSolution: ''),
    ApiProblem(
        id: 'local-sealing',
        title: 'Falha de selagem',
        description: 'A embalagem não apresenta selagem uniforme',
        recommendedSolution: ''),
  ];

  @override
  void initState() {
    super.initState();
    _loadProblems();
  }

  Future<void> _loadProblems() async {
    try {
      final values = await ApiClient.instance.problems();
      if (mounted) setState(() => _problems = values);
    } catch (_) {/* The local list remains available if the API is offline. */}
  }

  @override
  Widget build(BuildContext context) {
    final matches = _problems
        .where((problem) => '${problem.title} ${problem.description}'
            .toLowerCase()
            .contains(_query.toLowerCase()))
        .toList();
    return _TroubleScaffold(
        title: 'Problemas e Soluções',
        admin: widget.admin,
        returnToHome: true,
        action: widget.admin
            ? IconButton(
                tooltip: 'Cadastrar problema',
                onPressed: () async {
                  final changed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              TroubleshootingFormScreen(admin: widget.admin)));
                  if (changed == true) _loadProblems();
                },
                icon: const Icon(Icons.add_circle_outline, color: _blue))
            : null,
        child: Column(children: [
          AppSearchBar(
              hint: 'Ex: Bolhas',
              onChanged: (value) => setState(() => _query = value)),
          const SizedBox(height: 14),
          Expanded(
              child: ListView(children: [
            ...matches.map((problem) => _ProblemCard(
                  title: problem.title,
                  subtitle: problem.description,
                  onTap: () async {
                    final page = widget.admin
                        ? TroubleshootingFormScreen(
                            admin: widget.admin, initial: problem)
                        : PackagingSelectionScreen(
                            problem: problem.title, problemId: problem.id);
                    final changed = await Navigator.push<bool>(
                        context, MaterialPageRoute(builder: (_) => page));
                    if (changed == true && widget.admin) _loadProblems();
                  },
                )),
            if (!widget.admin)
              InkWell(
                onTap: () => _openSupportEscalation(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: _card(),
                  child: const Row(children: [
                    Icon(Icons.support_agent, color: _blue, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Não encontrou o seu problema?',
                              style: TextStyle(
                                  color: _blue, fontWeight: FontWeight.bold)),
                          Text(
                              'Entre em contato com um supervisor para receber auxílio',
                              style: TextStyle(fontSize: 11))
                        ])),
                    Icon(Icons.chevron_right, color: _blue),
                  ]),
                ),
              ),
          ])),
        ]));
  }

  Future<void> _openSupportEscalation(BuildContext context) async {
    final textController = TextEditingController();
    String selectedMachine = 'Extrusora Principal';
    bool sending = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.support_agent, color: _blue, size: 26),
                  SizedBox(width: 10),
                  Text(
                    'Suporte / Dúvida Operacional',
                    style: TextStyle(
                      color: _blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Descreva a ocorrência ou problema identificado. Este chamado será registrado imediatamente e encaminhado ao supervisor.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: selectedMachine,
                decoration: InputDecoration(
                  labelText: 'Máquina / Equipamento',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _border),
                  ),
                  filled: true,
                  fillColor: _canvas,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(value: 'Extrusora Principal', child: Text('Extrusora Principal')),
                  DropdownMenuItem(value: 'Extrusora Balão 01', child: Text('Extrusora Balão 01')),
                  DropdownMenuItem(value: 'Linha de Coextrusão 02', child: Text('Linha de Coextrusão 02')),
                  DropdownMenuItem(value: 'Misturador / Silo 03', child: Text('Misturador / Silo 03')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() => selectedMachine = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ex: Filme apresentando aspecto leitoso e estrias mesmo após ajuste térmico na zona 3...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _border),
                  ),
                  filled: true,
                  fillColor: _canvas,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: sending
                    ? null
                    : () async {
                        final question = textController.text.trim();
                        if (question.isEmpty) return;
                        setModalState(() => sending = true);
                        try {
                          final payload = await ApiClient.instance.createSupportTicket(
                            description: question,
                            machineId: selectedMachine,
                            processContext: 'Linha de Coextrusão',
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chamado encaminhado ao supervisor com sucesso!'),
                                backgroundColor: Color(0xFF22C55E),
                              ),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DoubtThreadScreen(
                                  doubt: DoubtModel.fromJson(payload),
                                  admin: false,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          setModalState(() => sending = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro ao enviar solicitação: $e'),
                                backgroundColor: const Color(0xFFEF4444),
                              ),
                            );
                          }
                        }
                      },
                icon: sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, size: 18),
                label: Text(
                  sending ? 'ENVIANDO...' : 'ENVIAR AO SUPERVISOR',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PackagingSelectionScreen extends StatefulWidget {
  final String problem;
  final String? problemId;
  const PackagingSelectionScreen(
      {super.key, required this.problem, this.problemId});

  @override
  State<PackagingSelectionScreen> createState() =>
      _PackagingSelectionScreenState();
}

class _PackagingSelectionScreenState extends State<PackagingSelectionScreen> {
  String _query = '';
  List<String> get _packages =>
      PackagingCatalog.items.map((item) => item.name).toList();

  @override
  void initState() {
    super.initState();
    _loadPackagings();
  }

  Future<void> _loadPackagings() async {
    try {
      final values = await ApiClient.instance.packagings();
      if (mounted && values.isNotEmpty)
        setState(() => PackagingCatalog.replace(values));
    } catch (_) {/* Offline fallback is retained for visual prototype work. */}
  }

  @override
  Widget build(BuildContext context) {
    final packages = _packages
        .where((item) => item.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return _TroubleScaffold(
        title: 'Problemas e Soluções',
        child: Column(children: [
          const _ProblemStepper(current: 1),
          const SizedBox(height: 26),
          const Align(
              alignment: Alignment.centerLeft,
              child: Text('Selecione a embalagem',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          const SizedBox(height: 10),
          _ProblemSearch(
              hint: 'Buscar embalagem...',
              onChanged: (value) => setState(() => _query = value)),
          const SizedBox(height: 18),
          Expanded(
              child: ListView.separated(
                  itemCount: packages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (context, index) => _PackagingCard(
                      name: packages[index],
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ChecklistScreen(
                                  problem: widget.problem,
                                  problemId: widget.problemId,
                                  packaging: packages[index]))))))
        ]));
  }
}

class ChecklistScreen extends StatefulWidget {
  final String problem;
  final String? problemId;
  final String packaging;
  const ChecklistScreen(
      {super.key,
      required this.problem,
      this.problemId,
      required this.packaging});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  late PackagingSpecification _specification;
  final Set<int> _verified = {};
  final Map<int, TextEditingController> _controllers = {};
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _specification = PackagingCatalog.byName(widget.packaging);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(int index) =>
      _controllers.putIfAbsent(index, TextEditingController.new);

  Future<void> _continueToSolutions() async {
    final measurements = Map<String, double>.fromEntries(List.generate(
        _specification.enabledVerifications.length,
        (index) => MapEntry(
            _specification.enabledVerifications.elementAt(index).name,
            double.tryParse(_controllerFor(index).text.replaceAll(',', '.')) ??
                0)));
    try {
      if (widget.problemId != null && _specification.id != null) {
        await ApiClient.instance.diagnose(
            problemId: widget.problemId!,
            packagingId: _specification.id!,
            inputValues: measurements);
      }
      if (!mounted) return;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SolutionsScreen(
                  problem: widget.problem,
                  packaging: _specification.name,
                  measurements: measurements)));
    } on ApiException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  void _changePackaging() => showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
          child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(18),
              children: PackagingCatalog.items
                  .map((item) => ListTile(
                      leading:
                          const PextAssetIcon(PextAssets.product, size: 26),
                      title: Text(item.name),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        setState(() {
                          _specification = item;
                          _verified.clear();
                          _expandedIndex = null;
                        });
                      }))
                  .toList())));

  @override
  Widget build(BuildContext context) => _TroubleScaffold(
      title: 'Problemas e Soluções',
      child: Column(children: [
        const _ProblemStepper(current: 2),
        const SizedBox(height: 24),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: _card(),
            child: Row(children: [
              Expanded(
                  child: Text('Embalagem selecionada: ${_specification.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              TextButton(
                  onPressed: _changePackaging,
                  child: const Text('Trocar',
                      style: TextStyle(
                          color: _blue, fontWeight: FontWeight.bold))),
            ])),
        const SizedBox(height: 20),
        const Align(
            alignment: Alignment.centerLeft,
            child: Text('Vamos verificar os pontos abaixo:',
                style: TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 14),
        Expanded(
            child: ListView(
                children: List.generate(
                    _specification.enabledVerifications.length, (index) {
          final parameter =
              _specification.enabledVerifications.elementAt(index);
          return _DynamicVerificationCard(
              parameter: parameter,
              controller: _controllerFor(index),
              expanded: _expandedIndex == index,
              verified: _verified.contains(index),
              onMeasurement: (_) => setState(() {}),
              onExpand: () => setState(() =>
                  _expandedIndex = _expandedIndex == index ? null : index),
              onVerify: () => setState(() {
                    _verified.add(index);
                    _expandedIndex = null;
                  }));
        }))),
        const SizedBox(height: 8),
        SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: _verified.length ==
                        _specification.enabledVerifications.length
                    ? _continueToSolutions
                    : null,
                child: const Text('PRÓXIMO')))
      ]));
}

class SolutionsScreen extends StatelessWidget {
  final String problem;
  final String packaging;
  final Map<String, double> measurements;
  const SolutionsScreen(
      {super.key,
      required this.problem,
      required this.packaging,
      required this.measurements});

  @override
  Widget build(BuildContext context) => _TroubleScaffold(
      title: 'Problemas e Soluções',
      child: Column(children: [
        const _ProblemStepper(current: 3),
        const SizedBox(height: 24),
        Text('Embalagem: $packaging',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
            'Com base nas verificações, estas são as causas\nprováveis e as soluções recomendadas:',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        Expanded(child: ListView(children: _solutions())),
        SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('PROBLEMA SOLUCIONADO'))),
        const SizedBox(height: 8),
        SizedBox(
            width: double.infinity,
            child: OutlinedButton(
                onPressed: () => _showSupervisorModal(context,
                    problem: problem,
                    packaging: packaging,
                    measurements: measurements),
                child: const Text('NÃO CONSEGUI RESOLVER')))
      ]));

  List<Widget> _solutions() {
    final specification = PackagingCatalog.byName(packaging);
    final recommendations = <Widget>[
      _RecommendedSolutionCard('Guia de solução recomendado',
          'Orientação geral para $problem.', _problemGuide(problem)),
    ];
    for (final parameter in specification.enabledVerifications) {
      final measurement = measurements[parameter.name] ?? 0;
      if (measurement < parameter.min || measurement > parameter.max) {
        final above = measurement > parameter.max;
        recommendations.add(_RecommendedSolutionCard(
            '${parameter.name} ${above ? 'muito alta' : 'muito baixa'}',
            '${parameter.name} medida em $measurement ${parameter.unit}; a faixa recomendada é de ${parameter.min} a ${parameter.max} ${parameter.unit}.',
            '${above ? 'Reduza' : 'Aumente'} gradualmente o ajuste até ficar dentro da faixa recomendada.'));
      }
    }
    if (recommendations.length == 1) {
      recommendations.add(const _RecommendedSolutionCard(
          'Parâmetros dentro da faixa',
          'As medições verificadas estão dentro dos limites recomendados.',
          'Monitore o processo e verifique componentes mecânicos caso o problema persista.'));
    }
    return recommendations;
  }
}

String _problemGuide(String problem) {
  const guides = {
    'Variação na espessura':
        'Ajuste a velocidade da linha gradualmente e confirme a estabilidade da matriz.',
    'Falha de selagem':
        'Verifique a temperatura, pressão e tempo de contato da selagem.',
    'Rugosidade no filme':
        'Inspecione a matriz, a alimentação e a condição do material antes de retomar a produção.',
    'Bolhas no material':
        'Verifique a secagem do material e a estabilidade da temperatura do cilindro.',
  };
  return guides[problem] ??
      'Siga o procedimento operacional e acione o supervisor se a condição persistir.';
}

void _showSupervisorModal(BuildContext context,
    {required String problem,
    required String packaging,
    required Map<String, double> measurements}) {
  final specification = PackagingCatalog.byName(packaging);
  final parametersList = <Map<String, String>>[];
  for (final param in specification.enabledVerifications) {
    final measured = measurements[param.name] ?? 0;
    final target = '${param.min} - ${param.max} ${param.unit}';
    final mid = (param.min + param.max) / 2;
    final diff = measured - mid;
    final deviation = diff >= 0
        ? '+${diff.toStringAsFixed(1)} ${param.unit}'
        : '${diff.toStringAsFixed(1)} ${param.unit}';
    parametersList.add({
      'parameterName': param.name,
      'target': target,
      'measuredValue': '$measured ${param.unit}',
      'deviation': deviation,
    });
  }

  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(22, 18, 8, 0),
      title: Row(children: [
        const Expanded(
          child: Text(
            'Não conseguiu resolver?',
            style: TextStyle(
              color: _blue,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Fechar',
          onPressed: () => Navigator.pop(dialogContext),
          icon: const Icon(Icons.close),
        ),
      ]),
      content: const Text(
        'O supervisor receberá o problema, a embalagem e as medições registradas para análise.',
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final payload = await ApiClient.instance.createSupportTicket(
                  description: 'Problema reportado: $problem na embalagem $packaging',
                  machineId: 'Linha de Coextrusão',
                  processContext: 'Diagnóstico de Embalagem',
                  verificationData: {
                    'packagingId': packaging,
                    'parameters': parametersList,
                  },
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Solicitação enviada ao supervisor: $problem ($packaging).'),
                      backgroundColor: const Color(0xFF22C55E),
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoubtThreadScreen(
                        doubt: DoubtModel.fromJson(payload),
                        admin: false,
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao enviar chamado ao supervisor: $e'),
                      backgroundColor: const Color(0xFFEF4444),
                    ),
                  );
                }
              }
            },
            child: const Text('SOLICITAR SUPERVISOR'),
          ),
        ),
      ],
    ),
  );
}

class _ProblemSearch extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const _ProblemSearch({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) =>
      AppSearchBar(hint: hint, onChanged: onChanged);
}

class _ProblemStepper extends StatelessWidget {
  final int current;
  const _ProblemStepper({required this.current});

  @override
  Widget build(BuildContext context) => Row(
          children: List.generate(5, (index) {
        if (index.isOdd) {
          return Expanded(child: Container(height: 2, color: _border));
        }
        final step = index ~/ 2 + 1;
        final active = step == current;
        return CircleAvatar(
            radius: 15,
            backgroundColor: active ? _blue : const Color(0xFFE5E7EB),
            child: Text('$step',
                style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF363C46),
                    fontWeight: FontWeight.bold)));
      }));
}

class _PackagingCard extends StatelessWidget {
  final String name;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _PackagingCard({required this.name, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: _card(),
          child: Row(children: [
            const _PackageIcon(),
            const SizedBox(width: 12),
            Expanded(
                child: Text(name,
                    style: const TextStyle(
                        color: _blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold))),
            if (trailing != null) trailing!
          ])));
}

class _PackageIcon extends StatelessWidget {
  const _PackageIcon();
  @override
  Widget build(BuildContext context) => Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF8A8F98)),
          borderRadius: BorderRadius.circular(12)),
      child: const PextAssetIcon(PextAssets.product, size: 28));
}

class _DynamicVerificationCard extends StatelessWidget {
  final PackagingParameter parameter;
  final TextEditingController controller;
  final bool expanded;
  final bool verified;
  final ValueChanged<String> onMeasurement;
  final VoidCallback onExpand;
  final VoidCallback onVerify;
  const _DynamicVerificationCard(
      {required this.parameter,
      required this.controller,
      required this.expanded,
      required this.verified,
      required this.onMeasurement,
      required this.onExpand,
      required this.onVerify});

  @override
  Widget build(BuildContext context) {
    final measurement = double.tryParse(controller.text.replaceAll(',', '.'));
    final status = measurement == null
        ? null
        : measurement < parameter.min
            ? 'Abaixo do recomendado'
            : measurement > parameter.max
                ? 'Acima do recomendado'
                : 'Dentro da faixa recomendada';
    final statusColor = status == 'Dentro da faixa recomendada'
        ? const Color(0xFF1CBF66)
        : const Color(0xFFD93838);
    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: _card(),
        child: Column(children: [
          ListTile(
              onTap: onExpand,
              leading: verified
                  ? const Icon(Icons.check_circle, color: Color(0xFF1CBF66))
                  : const Icon(Icons.tune, color: _blue),
              title: Text(parameter.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(verified ? 'Verificado' : 'Não verificado',
                  style: TextStyle(
                      color: verified ? const Color(0xFF1CBF66) : Colors.grey,
                      fontSize: 12)),
              trailing: Icon(
                  expanded ? Icons.keyboard_arrow_up : Icons.chevron_right)),
          if (expanded) ...[
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'A faixa recomendada é de ${parameter.min} ${parameter.unit} a ${parameter.max} ${parameter.unit}.',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 10),
                      TextField(
                          controller: controller,
                          onChanged: onMeasurement,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                              labelText: 'Valor medido',
                              suffixText: parameter.unit,
                              filled: true,
                              fillColor: Colors.white,
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))))),
                      if (status != null) ...[
                        const SizedBox(height: 10),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(status,
                                style: TextStyle(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold))),
                      ],
                      const SizedBox(height: 10),
                      SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                              onPressed: measurement == null ? null : onVerify,
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('MARCAR COMO VERIFICADO')))
                    ]))
          ]
        ]));
  }
}

class _VerifiedChecklistCard extends StatelessWidget {
  final String title;
  const _VerifiedChecklistCard(this.title);
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(11),
      decoration: _card(),
      child: Row(children: [
        const _PackageIcon(),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(color: _blue, fontWeight: FontWeight.bold)),
          const Text('Verificado', style: TextStyle(color: Color(0xFF22C55E)))
        ])),
        const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFF18BF8A),
            child: Icon(Icons.check, color: Colors.white, size: 18))
      ]));
}

class _TemperatureChecklistCard extends StatelessWidget {
  final bool expanded;
  final int selected;
  final VoidCallback onTap;
  final ValueChanged<int> onAnswer;
  const _TemperatureChecklistCard(
      {required this.expanded,
      required this.selected,
      required this.onTap,
      required this.onAnswer});
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: _card(),
      child: Column(children: [
        InkWell(
            onTap: onTap,
            child: Padding(
                padding: const EdgeInsets.all(11),
                child: Row(children: [
                  const _PackageIcon(),
                  const SizedBox(width: 12),
                  const Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('Temperatura',
                            style: TextStyle(
                                color: _blue, fontWeight: FontWeight.bold)),
                        Text('Não verificado')
                      ])),
                  Icon(expanded ? Icons.expand_less : Icons.chevron_right,
                      size: 28)
                ]))),
        if (expanded) ...[
          const Divider(height: 1, color: _border),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 14, 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        'A temperatura do cilindro está dentro da faixa recomendada para RAP10',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...const [
                      ('Muito baixa', 'Abaixo do recomendado (< 160°C)'),
                      ('Dentro da faixa recomendada', 'Entre 160°C e 190°C'),
                      ('Muito Alta', 'Acima do recomendado (> 190°C)'),
                      ('Não sei informar', ''),
                    ].asMap().entries.map((entry) => RadioListTile<int>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: _blue,
                        value: entry.key,
                        groupValue: selected,
                        onChanged: (value) => onAnswer(value!),
                        title: Text(entry.value.$1,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: entry.value.$2.isEmpty
                            ? null
                            : Text(entry.value.$2,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))))
                  ]))
        ]
      ]));
}

class _DefaultChecklistCard extends StatelessWidget {
  final String title;
  const _DefaultChecklistCard(this.title);
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(11),
      decoration: _card(),
      child: Row(children: [
        const _PackageIcon(),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(color: _blue, fontWeight: FontWeight.bold)),
          const Text('Não verificado')
        ])),
        const Icon(Icons.chevron_right, size: 28)
      ]));
}

class _RecommendedSolutionCard extends StatelessWidget {
  final String title;
  final String cause;
  final String solution;
  const _RecommendedSolutionCard(this.title, this.cause, this.solution);
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _card(),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _PackageIcon(),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(color: _blue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 7),
          const Text('Causa provável'),
          Text(cause, style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 7),
          const Text('Solução recomendada:'),
          Text(solution, style: const TextStyle(fontSize: 11))
        ]))
      ]));
}

class TroubleshootingWizardScreen extends StatefulWidget {
  final String problem;
  const TroubleshootingWizardScreen({super.key, required this.problem});
  @override
  State<TroubleshootingWizardScreen> createState() =>
      _TroubleshootingWizardScreenState();
}

class _TroubleshootingWizardScreenState
    extends State<TroubleshootingWizardScreen> {
  int _step = 1;
  String _packaging = 'KitKat 45 g';
  final Set<int> _checked = {};
  @override
  Widget build(BuildContext context) => _TroubleScaffold(
      title: 'Problemas e Soluções',
      child: Column(children: [
        _StepIndicator(current: _step),
        const SizedBox(height: 7),
        Text(
            _step == 1
                ? 'Selecione a embalagem'
                : _step == 2
                    ? 'Verifique as possíveis causas'
                    : 'Solução apresentada',
            style: const TextStyle(color: _blue, fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        Expanded(child: SingleChildScrollView(child: _body())),
        const SizedBox(height: 12),
        _buttons(),
        const SizedBox(height: 8),
      ]));
  Widget _body() {
    if (_step == 1)
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Qual embalagem está apresentando o problema?',
            style: TextStyle(fontSize: 14)),
        const SizedBox(height: 12),
        ...[
          'KitKat 45 g',
          'Chocolate 90 g',
          'Biscoito recheado 120 g'
        ].map((name) => RadioListTile<String>(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: _border)),
            tileColor: Colors.white,
            value: name,
            groupValue: _packaging,
            activeColor: _blue,
            title: Text(name,
                style:
                    const TextStyle(color: _blue, fontWeight: FontWeight.w600)),
            subtitle: const Text('Estrutura coextrudada',
                style: TextStyle(fontSize: 10)),
            onChanged: (value) => setState(() => _packaging = value!))),
        const SizedBox(height: 16),
        const Text('Problema identificado',
            style: TextStyle(color: _blue, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(widget.problem)
      ]);
    if (_step == 2)
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Embalagem selecionada: $_packaging',
            style: const TextStyle(color: _blue, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('Vamos verificar os pontos abaixo:',
            style: TextStyle(fontSize: 14)),
        const SizedBox(height: 10),
        ...List.generate(
            _checks.length,
            (index) => _VerificationCard(
                title: _checks[index].$1,
                hint: _checks[index].$2,
                checked: _checked.contains(index),
                onChanged: (checked) => setState(() {
                      if (checked) {
                        _checked.add(index);
                      } else {
                        _checked.remove(index);
                      }
                    }))),
      ]);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Embalagem: $_packaging',
          style: const TextStyle(color: _blue, fontWeight: FontWeight.bold)),
      const SizedBox(height: 7),
      Text('Abaixo estão as causas prováveis para: ${widget.problem}'),
      const SizedBox(height: 16),
      const _SolutionCard(
          'Temperatura fora da faixa',
          'A temperatura da zona de fusão pode estar abaixo do recomendado.',
          'Verifique a faixa da resina e ajuste gradualmente os controladores.'),
      const _SolutionCard(
          'Pressão de extrusão instável',
          'Oscilações na pressão podem causar irregularidades no filme.',
          'Inspecione filtros, rosca e estabilidade de alimentação.'),
      const SizedBox(height: 12),
      OutlinedButton.icon(
          onPressed: _askSupervisor,
          icon: const Icon(Icons.support_agent),
          label: const Text('Solicitar ajuda do supervisor'))
    ]);
  }

  Widget _buttons() => Row(children: [
        if (_step > 1)
          Expanded(
              child: OutlinedButton(
                  onPressed: () => setState(() => _step--),
                  child: const Text('VOLTAR'))),
        if (_step > 1) const SizedBox(width: 10),
        Expanded(
            child: FilledButton(
                onPressed: _step == 3
                    ? () => Navigator.pop(context)
                    : () => setState(() => _step++),
                child: Text(_step == 3 ? 'FINALIZAR' : 'CONTINUAR')))
      ]);
  void _askSupervisor() => showDialog(
      context: context,
      builder: (_) => AlertDialog(
              title: const Text('Solicitação enviada'),
              content: const Text(
                  'Um supervisor será notificado para ajudar com este problema.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fechar'))
              ]));
}

const _checks = [
  ('Temperatura da zona de fusão', 'Informe a temperatura atual'),
  ('Pressão de extrusão', 'Está dentro da faixa especificada?'),
  ('Velocidade da linha', 'Confirme a velocidade configurada')
];

class TroubleshootingFormScreen extends StatefulWidget {
  final bool admin;
  final ApiProblem? initial;
  const TroubleshootingFormScreen(
      {super.key, this.admin = false, this.initial});
  @override
  State<TroubleshootingFormScreen> createState() =>
      _TroubleshootingFormScreenState();
}

class _TroubleshootingFormScreenState extends State<TroubleshootingFormScreen> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _solution;
  String? _categoryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initial?.title ?? '');
    _description =
        TextEditingController(text: widget.initial?.description ?? '');
    _solution =
        TextEditingController(text: widget.initial?.recommendedSolution ?? '');
    _categoryId = widget.initial?.categoryId;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _solution.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _description.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final values = {
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'categoryId': _categoryId,
        'recommendedSolution': _solution.text.trim(),
      };
      if (widget.initial == null) {
        await ApiClient.instance.createContent('problems', values);
      } else {
        await ApiClient.instance
            .updateContent('problems', widget.initial!.id, values);
      }
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (widget.initial == null) return;
    try {
      await ApiClient.instance.deleteContent('problems', widget.initial!.id);
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) => _TroubleScaffold(
      title: 'Cadastrar problema',
      admin: widget.admin,
      action: widget.initial == null
          ? null
          : IconButton(
              tooltip: 'Delete problem',
              icon: const Icon(Icons.delete_outline, color: Color(0xFFD93838)),
              onPressed: _delete),
      child: Column(children: [
        Expanded(child: SingleChildScrollView(child: _general())),
        SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(widget.initial == null ? 'CADASTRAR' : 'SALVAR'))),
        const SizedBox(height: 8),
      ]));
  Widget _general() => Column(children: [
        _Field('Título do Problema', controller: _title),
        _Field('Descrição / Sintomas', controller: _description, lines: 4),
        ScopedCategoryPicker(
            scope: CategoryScope.problem,
            value: _categoryId,
            onChanged: (value) => setState(() => _categoryId = value)),
        const SizedBox(height: 12),
        _Field('Guia de Solução Recomendada', controller: _solution, lines: 5)
      ]);
}

class VerificationFormScreen extends StatefulWidget {
  const VerificationFormScreen({super.key});
  @override
  State<VerificationFormScreen> createState() => _VerificationFormScreenState();
}

class _VerificationFormScreenState extends State<VerificationFormScreen> {
  int _kind = 0;
  @override
  Widget build(BuildContext context) => _TroubleScaffold(
      title: 'Nova verificação',
      child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Tipo de verificação',
                style: TextStyle(
                    color: _blue, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _RadioTile(
                icon: Icons.straighten_outlined,
                title: 'Faixa numérica',
                description:
                    'O usuário informa um valor dentro de um intervalo.',
                selected: _kind == 0,
                onTap: () => setState(() => _kind = 0)),
            _RadioTile(
                icon: Icons.thumb_up_alt_outlined,
                title: 'Sim ou não',
                description: 'O usuário confirma se a condição foi atendida.',
                selected: _kind == 1,
                onTap: () => setState(() => _kind = 1)),
            const SizedBox(height: 8),
            const _Field('Pergunta de verificação'),
            if (_kind == 0)
              const Row(children: [
                Expanded(child: _Field('Mínimo')),
                SizedBox(width: 10),
                Expanded(child: _Field('Máximo'))
              ]),
            const SizedBox(height: 28),
            FilledButton(
                onPressed: () => Navigator.pop(
                    context,
                    _kind == 0
                        ? 'Temperatura da zona de fusão'
                        : 'Confirmar condição'),
                child: const Text('ADICIONAR')),
            const SizedBox(height: 8)
          ])));
}

class _TroubleScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  final bool admin;
  final bool returnToHome;
  const _TroubleScaffold(
      {required this.title,
      required this.child,
      this.action,
      this.admin = false,
      this.returnToHome = false});
  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        if (!returnToHome) return true;
        _goToRoot(context, PextRoutes.home, admin: admin);
        return false;
      },
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: _canvas,
          appBar: AppBar(
              backgroundColor: _canvas,
              surfaceTintColor: _canvas,
              centerTitle: true,
              leading: IconButton(
                  onPressed: () => returnToHome
                      ? _goToRoot(context, PextRoutes.home, admin: admin)
                      : Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: _blue, size: 19)),
              title: Text(title,
                  style: const TextStyle(
                      color: _blue, fontWeight: FontWeight.w600, fontSize: 18)),
              actions: [if (action != null) action!, const SizedBox(width: 5)]),
          body: Padding(
              padding: const EdgeInsets.fromLTRB(28, 6, 28, 18), child: child),
          bottomNavigationBar: _TroubleBottomBar(admin: admin)));
}

class _TroubleBottomBar extends StatelessWidget {
  final bool admin;
  const _TroubleBottomBar({required this.admin});
  @override
  Widget build(BuildContext context) => Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _border)),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      child: SafeArea(
          top: false,
          child: Row(children: [
            _TroubleNav(PextAssets.education, 'Treinamento',
                () => _goToRoot(context, PextRoutes.training, admin: admin)),
            _TroubleNav(
                admin ? PextAssets.dashboard : PextAssets.heart,
                admin ? 'Dashboard' : 'Favoritos',
                () => _goToRoot(context,
                    admin ? PextRoutes.dashboard : PextRoutes.favorites,
                    admin: admin)),
            _TroubleNav(PextAssets.home, 'Home',
                () => _goToRoot(context, PextRoutes.home, admin: admin)),
            _TroubleNav(PextAssets.chat, 'Chat',
                () => _goToRoot(context, PextRoutes.chat, admin: admin)),
            _TroubleNav(PextAssets.profile, 'Perfil',
                () => _goToRoot(context, PextRoutes.profile, admin: admin))
          ])));
}

class _TroubleNav extends StatelessWidget {
  final String asset, text;
  final VoidCallback onTap;
  const _TroubleNav(this.asset, this.text, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(
      child: InkWell(
          onTap: onTap,
          child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 4),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                PextAssetIcon(asset, size: 31),
                Text(text,
                    style:
                        const TextStyle(fontSize: 10, color: Color(0xFF363C46)))
              ]))));
}

void _goToRoot(BuildContext context, String route, {bool admin = false}) =>
    Navigator.of(context).pushNamedAndRemoveUntil(
        route, (currentRoute) => false,
        arguments: PextRouteArgs(admin: admin));

class _ProblemCard extends StatelessWidget {
  final String title, subtitle;
  final VoidCallback onTap;
  const _ProblemCard(
      {required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(13),
          decoration: _card(),
          child: Row(children: [
            const PextAssetIcon(PextAssets.problem, size: 26),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(
                          color: _blue, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF687080)))
                ])),
            const Icon(Icons.chevron_right, color: _blue)
          ])));
}

class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});
  @override
  Widget build(BuildContext context) => Row(
          children: List.generate(5, (index) {
        if (index.isOdd)
          return Expanded(
              child: Container(
                  height: 2, color: index ~/ 2 < current ? _blue : _border));
        final number = index ~/ 2 + 1;
        final active = number <= current;
        return Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? _blue : _canvas,
                border: Border.all(color: active ? _blue : _border)),
            child: Text('$number',
                style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF7A8290),
                    fontWeight: FontWeight.bold)));
      }));
}

class _VerificationCard extends StatelessWidget {
  final String title, hint;
  final bool checked;
  final ValueChanged<bool> onChanged;
  const _VerificationCard(
      {required this.title,
      required this.hint,
      required this.checked,
      required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: _card(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: _blue, fontWeight: FontWeight.bold))),
          Checkbox(
              value: checked,
              activeColor: _blue,
              onChanged: (value) => onChanged(value ?? false))
        ]),
        Text(hint, style: const TextStyle(fontSize: 11)),
        const SizedBox(height: 9),
        TextField(
            decoration: const InputDecoration(
                hintText: 'Digite a informação',
                isDense: true,
                filled: true,
                fillColor: _canvas,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: _border))))
      ]));
}

class _SolutionCard extends StatelessWidget {
  final String title, cause, solution;
  const _SolutionCard(this.title, this.cause, this.solution);
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _card(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(color: _blue, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Causa provável',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        Text(cause, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        const Text('Solução recomendada',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        Text(solution, style: const TextStyle(fontSize: 12))
      ]));
}



class _RadioTile extends StatelessWidget {
  final IconData icon;
  final String title, description;
  final bool selected;
  final VoidCallback onTap;
  const _RadioTile(
      {required this.icon,
      required this.title,
      required this.description,
      required this.selected,
      required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(13),
          decoration: _card(active: selected),
          child: Row(children: [
            Icon(icon, color: _blue),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(
                          color: _blue, fontWeight: FontWeight.bold)),
                  Text(description, style: const TextStyle(fontSize: 11))
                ])),
            Radio<bool>(
                value: true,
                groupValue: selected,
                activeColor: _blue,
                onChanged: (_) => onTap())
          ])));
}

class _Field extends StatelessWidget {
  final String label;
  final int lines;
  final TextEditingController? controller;
  const _Field(this.label, {this.lines = 1, this.controller});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: _blue, fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 5),
        TextField(
            controller: controller,
            maxLines: lines,
            decoration: InputDecoration(
                hintText: 'Preencha $label',
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: _border))))
      ]));
}

BoxDecoration _card({bool active = false}) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(11),
    border:
        Border.all(color: active ? _blue : _border, width: active ? 1.4 : 1));
