import 'package:flutter/material.dart';
import '../../widgets/pext_asset_icon.dart';

const _blue = Color(0xFF053488);
const _canvas = Color(0xFFF6F8FB);
const _border = Color(0xFFE5E7EB);

class TroubleshootingListScreen extends StatefulWidget {
  final bool admin;
  const TroubleshootingListScreen({super.key, this.admin = false});
  @override State<TroubleshootingListScreen> createState() => _TroubleshootingListScreenState();
}

class _TroubleshootingListScreenState extends State<TroubleshootingListScreen> {
  String _query = '';
  final _problems = const [
    ('Variação na espessura', 'O produto sai com espessura irregular ou fora do especificado'),
    ('Falha de selagem', 'A embalagem não apresenta selagem uniforme'),
    ('Rugosidade no filme', 'A superfície apresenta aspereza ou marcas'),
    ('Bolhas no material', 'Formação de bolhas durante o processo de extrusão'),
  ];
  @override Widget build(BuildContext context) {
    final matches = _problems.where((problem) => '${problem.$1} ${problem.$2}'.toLowerCase().contains(_query.toLowerCase())).toList();
    return _TroubleScaffold(title: 'Problemas e Soluções', action: widget.admin ? IconButton(tooltip: 'Cadastrar problema', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TroubleshootingFormScreen())), icon: const Icon(Icons.add_circle_outline, color: _blue)) : null, child: Column(children: [
      TextField(onChanged: (value) => setState(() => _query = value), decoration: const InputDecoration(prefixIcon: PextAssetIcon(PextAssets.search, size: 21), hintText: 'Ex: Bolhas', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(11)), borderSide: BorderSide.none))),
      const SizedBox(height: 14),
      Expanded(child: ListView(children: [
        ...matches.map((problem) => _ProblemCard(
              title: problem.$1,
              subtitle: problem.$2,
              onTap: () {
                final page = widget.admin ? const TroubleshootingFormScreen() : TroubleshootingWizardScreen(problem: problem.$1);
                Navigator.push(context, MaterialPageRoute(builder: (_) => page));
              },
            )),
        if (!widget.admin)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(14),
            decoration: _card(),
            child: const Row(children: [Icon(Icons.support_agent, color: _blue), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Não encontrou o seu problema?', style: TextStyle(color: _blue, fontWeight: FontWeight.bold)), Text('Entre em contato com um supervisor para receber auxílio', style: TextStyle(fontSize: 11))]))]),
          ),
      ])),
    ]));
  }
}

class TroubleshootingWizardScreen extends StatefulWidget {
  final String problem;
  const TroubleshootingWizardScreen({super.key, required this.problem});
  @override State<TroubleshootingWizardScreen> createState() => _TroubleshootingWizardScreenState();
}
class _TroubleshootingWizardScreenState extends State<TroubleshootingWizardScreen> {
  int _step = 1; String _packaging = 'KitKat 45 g'; final Set<int> _checked = {};
  @override Widget build(BuildContext context) => _TroubleScaffold(title: 'Problemas e Soluções', child: Column(children: [
    _StepIndicator(current: _step), const SizedBox(height: 7), Text(_step == 1 ? 'Selecione a embalagem' : _step == 2 ? 'Verifique as possíveis causas' : 'Solução apresentada', style: const TextStyle(color: _blue, fontWeight: FontWeight.bold)), const SizedBox(height: 18),
    Expanded(child: SingleChildScrollView(child: _body())), const SizedBox(height: 12), _buttons(), const SizedBox(height: 8),
  ]));
  Widget _body() {
    if (_step == 1) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Qual embalagem está apresentando o problema?', style: TextStyle(fontSize: 14)), const SizedBox(height: 12), ...['KitKat 45 g', 'Chocolate 90 g', 'Biscoito recheado 120 g'].map((name) => RadioListTile<String>(contentPadding: const EdgeInsets.symmetric(horizontal: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: _border)), tileColor: Colors.white, value: name, groupValue: _packaging, activeColor: _blue, title: Text(name, style: const TextStyle(color: _blue, fontWeight: FontWeight.w600)), subtitle: const Text('Estrutura coextrudada', style: TextStyle(fontSize: 10)), onChanged: (value) => setState(() => _packaging = value!))), const SizedBox(height: 16), const Text('Problema identificado', style: TextStyle(color: _blue, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(widget.problem)]);
    if (_step == 2) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Embalagem selecionada: $_packaging', style: const TextStyle(color: _blue, fontWeight: FontWeight.bold)), const SizedBox(height: 16), const Text('Vamos verificar os pontos abaixo:', style: TextStyle(fontSize: 14)), const SizedBox(height: 10), ...List.generate(_checks.length, (index) => _VerificationCard(title: _checks[index].$1, hint: _checks[index].$2, checked: _checked.contains(index), onChanged: (checked) => setState(() { if (checked) { _checked.add(index); } else { _checked.remove(index); } }))),]);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Embalagem: $_packaging', style: const TextStyle(color: _blue, fontWeight: FontWeight.bold)), const SizedBox(height: 7), Text('Abaixo estão as causas prováveis para: ${widget.problem}'), const SizedBox(height: 16), const _SolutionCard('Temperatura fora da faixa', 'A temperatura da zona de fusão pode estar abaixo do recomendado.', 'Verifique a faixa da resina e ajuste gradualmente os controladores.'), const _SolutionCard('Pressão de extrusão instável', 'Oscilações na pressão podem causar irregularidades no filme.', 'Inspecione filtros, rosca e estabilidade de alimentação.'), const SizedBox(height: 12), OutlinedButton.icon(onPressed: _askSupervisor, icon: const Icon(Icons.support_agent), label: const Text('Solicitar ajuda do supervisor'))]);
  }
  Widget _buttons() => Row(children: [if (_step > 1) Expanded(child: OutlinedButton(onPressed: () => setState(() => _step--), child: const Text('VOLTAR'))), if (_step > 1) const SizedBox(width: 10), Expanded(child: FilledButton(onPressed: _step == 3 ? () => Navigator.pop(context) : () => setState(() => _step++), child: Text(_step == 3 ? 'FINALIZAR' : 'CONTINUAR')))]);
  void _askSupervisor() => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Solicitação enviada'), content: const Text('Um supervisor será notificado para ajudar com este problema.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))]));
}

const _checks = [('Temperatura da zona de fusão', 'Informe a temperatura atual'), ('Pressão de extrusão', 'Está dentro da faixa especificada?'), ('Velocidade da linha', 'Confirme a velocidade configurada')];

class TroubleshootingFormScreen extends StatefulWidget { const TroubleshootingFormScreen({super.key}); @override State<TroubleshootingFormScreen> createState() => _TroubleshootingFormScreenState(); }
class _TroubleshootingFormScreenState extends State<TroubleshootingFormScreen> {
  int _tab = 0; final _checks = <String>['Temperatura da zona de fusão', 'Pressão de extrusão'];
  @override Widget build(BuildContext context) => _TroubleScaffold(title: 'Cadastrar problema', child: Column(children: [
    _Tabs(selected: _tab, onChanged: (value) => setState(() => _tab = value)), const SizedBox(height: 16), Expanded(child: SingleChildScrollView(child: _tab == 0 ? _general() : _verifications())), FilledButton(onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Problema cadastrado'), content: const Text('O conteúdo foi salvo no protótipo.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))])), child: const Text('CADASTRAR')), const SizedBox(height: 8),
  ]));
  Widget _general() => const Column(children: [_Field('Nome do problema'), _Field('Descrição do problema', lines: 4), _Field('Causa provável', lines: 3), _Field('Solução recomendada', lines: 4)]);
  Widget _verifications() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Verificações cadastradas', style: TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 10), ..._checks.asMap().entries.map((entry) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: _card(), child: Row(children: [const Icon(Icons.drag_indicator, color: Color(0xFF7A8290)), const SizedBox(width: 8), Expanded(child: Text(entry.value)), IconButton(onPressed: () => setState(() => _checks.removeAt(entry.key)), icon: const Icon(Icons.delete_outline))]))), OutlinedButton.icon(onPressed: () async { final item = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const VerificationFormScreen())); if (item != null) setState(() => _checks.add(item)); }, icon: const Icon(Icons.add), label: const Text('Adicionar verificação'))]);
}

class VerificationFormScreen extends StatefulWidget { const VerificationFormScreen({super.key}); @override State<VerificationFormScreen> createState() => _VerificationFormScreenState(); }
class _VerificationFormScreenState extends State<VerificationFormScreen> {
  int _kind = 0;
  @override Widget build(BuildContext context) => _TroubleScaffold(title: 'Nova verificação', child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('Tipo de verificação', style: TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 12), _RadioTile(icon: Icons.straighten_outlined, title: 'Faixa numérica', description: 'O usuário informa um valor dentro de um intervalo.', selected: _kind == 0, onTap: () => setState(() => _kind = 0)), _RadioTile(icon: Icons.thumb_up_alt_outlined, title: 'Sim ou não', description: 'O usuário confirma se a condição foi atendida.', selected: _kind == 1, onTap: () => setState(() => _kind = 1)), const SizedBox(height: 8), const _Field('Pergunta de verificação'), if (_kind == 0) const Row(children: [Expanded(child: _Field('Mínimo')), SizedBox(width: 10), Expanded(child: _Field('Máximo'))]), const Spacer(), FilledButton(onPressed: () => Navigator.pop(context, _kind == 0 ? 'Temperatura da zona de fusão' : 'Confirmar condição'), child: const Text('ADICIONAR')), const SizedBox(height: 8)]));
}

class _TroubleScaffold extends StatelessWidget { final String title; final Widget child; final Widget? action; const _TroubleScaffold({required this.title, required this.child, this.action}); @override Widget build(BuildContext context) => Scaffold(backgroundColor: _canvas, appBar: AppBar(backgroundColor: _canvas, surfaceTintColor: _canvas, centerTitle: true, leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, color: _blue, size: 19)), title: Text(title, style: const TextStyle(color: _blue, fontWeight: FontWeight.w600, fontSize: 18)), actions: [if (action != null) action!, const SizedBox(width: 5)]), body: Padding(padding: const EdgeInsets.fromLTRB(28, 6, 28, 18), child: child), bottomNavigationBar: const _TroubleBottomBar()); }
class _TroubleBottomBar extends StatelessWidget { const _TroubleBottomBar(); @override Widget build(BuildContext context) => Container(decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: _border)), borderRadius: BorderRadius.vertical(top: Radius.circular(12))), child: SafeArea(top: false, child: Row(children: const [_TroubleNav(PextAssets.education, 'Treinamento'), _TroubleNav(PextAssets.heart, 'Favoritos'), _TroubleNav(PextAssets.home, 'Home'), _TroubleNav(PextAssets.chat, 'Chat'), _TroubleNav(PextAssets.profile, 'Perfil')]))); }
class _TroubleNav extends StatelessWidget { final String asset, text; const _TroubleNav(this.asset, this.text); @override Widget build(BuildContext context) => Expanded(child: Padding(padding: const EdgeInsets.only(top: 6, bottom: 4), child: Column(mainAxisSize: MainAxisSize.min, children: [PextAssetIcon(asset, size: 31), Text(text, style: const TextStyle(fontSize: 10, color: Color(0xFF363C46)))]))); }
class _ProblemCard extends StatelessWidget { final String title, subtitle; final VoidCallback onTap; const _ProblemCard({required this.title, required this.subtitle, required this.onTap}); @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(11), child: Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(13), decoration: _card(), child: Row(children: [const PextAssetIcon(PextAssets.problem, size: 26), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _blue, fontWeight: FontWeight.bold)), Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF687080)))])), const Icon(Icons.chevron_right, color: _blue)]))); }
class _StepIndicator extends StatelessWidget { final int current; const _StepIndicator({required this.current}); @override Widget build(BuildContext context) => Row(children: List.generate(5, (index) { if (index.isOdd) return Expanded(child: Container(height: 2, color: index ~/ 2 < current ? _blue : _border)); final number = index ~/ 2 + 1; final active = number <= current; return Container(width: 30, height: 30, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? _blue : _canvas, border: Border.all(color: active ? _blue : _border)), child: Text('$number', style: TextStyle(color: active ? Colors.white : const Color(0xFF7A8290), fontWeight: FontWeight.bold))); })); }
class _VerificationCard extends StatelessWidget { final String title, hint; final bool checked; final ValueChanged<bool> onChanged; const _VerificationCard({required this.title, required this.hint, required this.checked, required this.onChanged}); @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(13), decoration: _card(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(title, style: const TextStyle(color: _blue, fontWeight: FontWeight.bold))), Checkbox(value: checked, activeColor: _blue, onChanged: (value) => onChanged(value ?? false))]), Text(hint, style: const TextStyle(fontSize: 11)), const SizedBox(height: 9), TextField(decoration: const InputDecoration(hintText: 'Digite a informação', isDense: true, filled: true, fillColor: _canvas, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: _border))))])); }
class _SolutionCard extends StatelessWidget { final String title, cause, solution; const _SolutionCard(this.title, this.cause, this.solution); @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: _card(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _blue, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('Causa provável', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), Text(cause, style: const TextStyle(fontSize: 12)), const SizedBox(height: 8), const Text('Solução recomendada', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), Text(solution, style: const TextStyle(fontSize: 12))])); }
class _Tabs extends StatelessWidget { final int selected; final ValueChanged<int> onChanged; const _Tabs({required this.selected, required this.onChanged}); @override Widget build(BuildContext context) => Row(children: ['Visão geral', 'Verificações'].asMap().entries.map((entry) => Expanded(child: InkWell(onTap: () => onChanged(entry.key), child: Column(children: [Text(entry.value, style: TextStyle(fontSize: 13, color: entry.key == selected ? _blue : const Color(0xFF7A8290), fontWeight: entry.key == selected ? FontWeight.bold : FontWeight.normal)), const SizedBox(height: 8), Container(height: 2, color: entry.key == selected ? _blue : _border)])))).toList()); }
class _RadioTile extends StatelessWidget { final IconData icon; final String title, description; final bool selected; final VoidCallback onTap; const _RadioTile({required this.icon, required this.title, required this.description, required this.selected, required this.onTap}); @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(11), child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(13), decoration: _card(active: selected), child: Row(children: [Icon(icon, color: _blue), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _blue, fontWeight: FontWeight.bold)), Text(description, style: const TextStyle(fontSize: 11))])), Radio<bool>(value: true, groupValue: selected, activeColor: _blue, onChanged: (_) => onTap())]))); }
class _Field extends StatelessWidget { final String label; final int lines; const _Field(this.label, {this.lines = 1}); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: _blue, fontWeight: FontWeight.w600, fontSize: 13)), const SizedBox(height: 5), TextField(maxLines: lines, decoration: InputDecoration(hintText: 'Preencha $label', filled: true, fillColor: Colors.white, border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: _border))))])); }
BoxDecoration _card({bool active = false}) => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11), border: Border.all(color: active ? _blue : _border, width: active ? 1.4 : 1));
