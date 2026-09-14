import 'package:flutter/material.dart';
import '../../widgets/pext_asset_icon.dart';

const _blue = Color(0xFF053488);
const _canvas = Color(0xFFF6F8FB);
const _border = Color(0xFFE5E7EB);

class TermsDictionaryScreen extends StatefulWidget { final bool admin; const TermsDictionaryScreen({super.key, this.admin = false}); @override State<TermsDictionaryScreen> createState() => _TermsDictionaryScreenState(); }
class _TermsDictionaryScreenState extends State<TermsDictionaryScreen> {
  String _query = '';
  final _terms = const ['Aditivo', 'Aderência Intercamadas', 'Anel de Ar', 'Alimentador', 'ABS (Acrilonitrila Butadieno Estireno)', 'Barreira', 'Bobina', 'Bolha', 'Bico de Extrusão', 'Blenda Polimérica', 'Coextrusão', 'Cabeçote', 'Camada Barreira', 'Canal de Fluxo', 'Cristalinidade', 'Die', 'Degasagem', 'Delaminação', 'Dosagem Gravimétrica', 'Distribuidor de Fluxo', 'Extrusão'];
  @override
  Widget build(BuildContext context) {
    final items = _terms.where((term) => term.toLowerCase().contains(_query.toLowerCase())).toList();
    return _Shell(title: widget.admin ? 'Termos' : 'Dicionário de Termos', action: widget.admin ? IconButton(onPressed: () => _termDialog(context), icon: const Icon(Icons.add_circle_outline, color: _blue)) : const Icon(Icons.favorite_border, color: _blue), child: Column(children: [
      TextField(onChanged: (value) => setState(() => _query = value), decoration: const InputDecoration(prefixIcon: PextAssetIcon(PextAssets.search, size: 21), hintText: 'Ex: Coextrusão', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(13)), borderSide: BorderSide(color: _border)))),
      const SizedBox(height: 14),
      Expanded(child: items.isEmpty ? const _NoTermsFound() : ListView(children: _grouped(items))),
    ]));
  }
  List<Widget> _grouped(List<String> items) { String letter = ''; final children = <Widget>[]; for (final term in items) { final initial = term[0].toUpperCase(); if (initial != letter) { letter = initial; children.add(Padding(padding: const EdgeInsets.fromLTRB(10, 12, 0, 4), child: Text(letter, style: const TextStyle(color: _blue, fontWeight: FontWeight.w600)))); } children.add(InkWell(onTap: () => _detail(context, term), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: _border))), child: Row(children: [Expanded(child: Text(term)), Icon(widget.admin ? Icons.edit_outlined : Icons.chevron_right, size: 18, color: _blue)])))); } return children; }
  void _detail(BuildContext context, String term) => Navigator.push(context, MaterialPageRoute(builder: (_) => TermInfoScreen(term: term)));
  void _termDialog(BuildContext context) => showDialog(context: context, builder: (_) => const _InfoDialog('Adicionar termo', 'Formulário visual para cadastrar definição, operação e referências.'));
}

class _NoTermsFound extends StatelessWidget {
  const _NoTermsFound();
  @override
  Widget build(BuildContext context) => const Padding(padding: EdgeInsets.only(top: 4), child: Row(children: [Text('Nada encontrado! - ', style: TextStyle(color: _blue)), Text('Solicitar ao supervisor', style: TextStyle(decoration: TextDecoration.underline, color: Color(0xFF363C46)))]));
}

class TermInfoScreen extends StatelessWidget {
  final String term;
  const TermInfoScreen({super.key, required this.term});

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Dicionário de Termos',
        action: const Icon(Icons.favorite_border, color: _blue),
        child: ListView(children: [
          Container(padding: const EdgeInsets.all(14), decoration: _card(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(term, style: const TextStyle(color: _blue, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Text('Processo onde um material é forçado sob alta pressão através de um orifício ou molde, adquirindo o formato exato dessa abertura. É uma técnica contínua usada em diversos setores, desde a fabricação de perfis metálicos e plásticos até a produção de alimentos e massas.'),
            const SizedBox(height: 22),
            const Text('Como funciona?', style: TextStyle(color: _blue, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('O polímero é aquecido, plastificado e empurrado por uma rosca sem-fim através de um cabeçote, formando filmes, perfis, tubos, entre outros.'),
            const SizedBox(height: 22),
            const Text('Termos Relacionados', style: TextStyle(color: _blue, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Wrap(spacing: 8, children: const [_TermChip('Rosca'), _TermChip('Matriz'), _TermChip('Filme')]),
          ])),
        ]),
      );
}

class _TermChip extends StatelessWidget { final String text; const _TermChip(this.text); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(4)), child: Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF363C46)))); }

class TrainingListScreen extends StatefulWidget { final bool admin; const TrainingListScreen({super.key, this.admin = false}); @override State<TrainingListScreen> createState() => _TrainingListScreenState(); }
class _TrainingListScreenState extends State<TrainingListScreen> {
  int _filter = 0; final _filters = const ['Todos', 'Em Curso', 'Concluídos', 'Desistência'];
  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Treinamentos',
        action: widget.admin ? IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingEditorScreen())), icon: const Icon(Icons.add_circle_outline, color: _blue)) : const Icon(Icons.favorite_border, color: _blue),
        child: Column(children: [
          _TabBar(labels: _filters, value: _filter, onChanged: (value) => setState(() => _filter = value)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: List.generate(7, (index) {
                final status = index % 3;
                return _TrainingTile(
                  status: status,
                  admin: widget.admin,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrainingDetailScreen(admin: widget.admin, completed: status == 2))),
                );
              }),
            ),
          ),
        ]),
      );
}

class TrainingDetailScreen extends StatefulWidget { final bool admin, completed; const TrainingDetailScreen({super.key, required this.admin, this.completed = false}); @override State<TrainingDetailScreen> createState() => _TrainingDetailScreenState(); }
class _TrainingDetailScreenState extends State<TrainingDetailScreen> {
  @override Widget build(BuildContext context) => _Shell(title: 'Processo de extrusão', action: widget.admin ? IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingEditorScreen())), icon: const Icon(Icons.edit_outlined, color: _blue)) : null, child: ListView(children: [Container(height: 130, decoration: _card(), child: const Center(child: Icon(Icons.precision_manufacturing_outlined, size: 58, color: _blue))), const SizedBox(height: 12), const Text('Conheça as etapas, parâmetros e cuidados do processo de extrusão.', style: TextStyle(fontSize: 13)), const SizedBox(height: 18), const Text('Módulos', style: TextStyle(color: _blue, fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...['Fundamentos da coextrusão', 'Temperatura e pressão', 'Controle de qualidade'].asMap().entries.map((entry) => _ModuleTile(index: entry.key + 1, title: entry.value, done: widget.completed || entry.key == 0, onTap: () {})), const SizedBox(height: 14), const Text('Avaliação final', style: TextStyle(color: _blue, fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Container(padding: const EdgeInsets.all(14), decoration: _card(), child: Row(children: [const Icon(Icons.fact_check_outlined, color: _blue), const SizedBox(width: 10), const Expanded(child: Text('30 questões selecionadas dinamicamente', style: TextStyle(fontSize: 12))), FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamScreen())), child: Text(widget.completed ? 'REFAZER' : 'INICIAR', style: const TextStyle(fontSize: 11)))]))]));
}

class ExamScreen extends StatefulWidget { const ExamScreen({super.key}); @override State<ExamScreen> createState() => _ExamScreenState(); }
class _ExamScreenState extends State<ExamScreen> { int _question = 1; int? _answer; @override Widget build(BuildContext context) => _Shell(title: 'Avaliação', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_StepText('Questão $_question de 30'), const SizedBox(height: 12), LinearProgressIndicator(value: _question / 30, color: _blue, backgroundColor: _border, minHeight: 7), const SizedBox(height: 24), const Text('Qual parâmetro deve ser verificado primeiro ao identificar variação na espessura do filme?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)), const SizedBox(height: 18), ...['Temperatura das zonas de aquecimento', 'Cor do material', 'Quantidade de embalagens no estoque', 'Data de fabricação da bobina'].asMap().entries.map((entry) => RadioListTile<int>(value: entry.key, groupValue: _answer, activeColor: _blue, title: Text(entry.value, style: const TextStyle(fontSize: 13)), onChanged: (value) => setState(() => _answer = value))), const Spacer(), Row(children: [OutlinedButton(onPressed: _question > 1 ? () => setState(() => _question--) : null, child: const Text('VOLTAR')), const Spacer(), FilledButton(onPressed: () { if (_question == 30) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ExamResultScreen())); } else { setState(() { _question++; _answer = null; }); } }, child: const Text('PRÓXIMA'))]), const SizedBox(height: 8)])); }
class ExamResultScreen extends StatelessWidget { const ExamResultScreen({super.key}); @override Widget build(BuildContext context) => _Shell(title: 'Resultado da avaliação', child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.workspace_premium, color: Color(0xFF1AB65C), size: 82), const SizedBox(height: 14), const Text('Parabéns, você foi aprovado!', style: TextStyle(color: _blue, fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('Você acertou 26 de 30 questões.'), const SizedBox(height: 26), FilledButton(onPressed: () => showDialog(context: context, builder: (_) => const _InfoDialog('Gabarito detalhado', 'Tela visual de respostas corretas, incorretas e justificativas técnicas.')), child: const Text('VER GABARITO'))]))); }

class TrainingEditorScreen extends StatelessWidget { const TrainingEditorScreen({super.key}); @override Widget build(BuildContext context) => _Shell(title: 'Novo treinamento', child: ListView(children: const [_Field('Nome do treinamento'), _Field('Descrição', lines: 4), _Field('Percentual mínimo de aprovação'), _EditorSection('Módulos', Icons.menu_book_outlined), _EditorSection('Banco de questões', Icons.quiz_outlined), SizedBox(height: 10), _PrimaryButton('CADASTRAR') ])); }

class ChatAssistantScreen extends StatelessWidget {
  final bool admin;
  const ChatAssistantScreen({super.key, this.admin = false});
  @override
  Widget build(BuildContext context) => _Shell(title: admin ? 'Suporte administrativo' : 'Assistente IA', child: Column(children: [
        Expanded(child: ListView(children: [if (admin) const _ChatBubble('Solicitação de Igor: avaliar pressão para embalagem KitKat.', true), const _ChatBubble('Olá! Como posso ajudar na sua operação hoje?', false), const _ChatBubble('Qual a faixa de temperatura para PEBD?', true), const _ChatBubble('Consulte primeiro a ficha técnica. Se a dúvida exigir ajuste específico de linha, posso abrir uma solicitação para o supervisor.', false)])),
        Container(height: 42, decoration: BoxDecoration(color: Colors.white, border: Border.all(color: _border), borderRadius: BorderRadius.circular(15)), child: Row(children: [
          const Expanded(child: TextField(decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 13), hintText: 'Faça sua pergunta', hintStyle: TextStyle(color: Color(0xFF9CA3AF)), border: InputBorder.none))),
          Container(width: 38, height: 38, margin: const EdgeInsets.all(1), decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(9)), child: const Padding(padding: EdgeInsets.all(7), child: PextAssetIcon(PextAssets.send, size: 21))),
        ])),
      ]));
}

class PackagingListScreen extends StatefulWidget { const PackagingListScreen({super.key}); @override State<PackagingListScreen> createState() => _PackagingListScreenState(); }
class _PackagingListScreenState extends State<PackagingListScreen> {
  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Embalagens',
        action: IconButton(onPressed: () => showDialog(context: context, builder: (_) => const _InfoDialog('Cadastrar embalagem', 'Formulário visual para nome, estrutura, materiais e documentação.')), icon: const Icon(Icons.add_box_outlined, color: _blue)),
        child: Column(children: [
          const TextField(decoration: InputDecoration(prefixIcon: PextAssetIcon(PextAssets.search, size: 21), hintText: 'Buscar embalagem...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(13)), borderSide: BorderSide.none))),
          const SizedBox(height: 14),
          ...['RAP10', 'Macarrão', 'KitKat'].map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: _card(),
              child: ListTile(
                leading: const PextAssetIcon(PextAssets.product, size: 26),
                title: Text(item, style: const TextStyle(color: _blue, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.chevron_right, color: _blue),
                onTap: () => showDialog(context: context, builder: (_) => _InfoDialog(item, 'Especificações, estruturas, resinas e documentação da embalagem.')),
              ),
            ),
          ),
        ]),
      );
}

class UserProfileScreen extends StatefulWidget { final bool admin; const UserProfileScreen({super.key, this.admin = false}); @override State<UserProfileScreen> createState() => _UserProfileScreenState(); }
class _UserProfileScreenState extends State<UserProfileScreen> { int _tab = 0; @override Widget build(BuildContext context) => _Shell(title: 'Perfil', child: Column(children: [const CircleAvatar(radius: 62, backgroundColor: Colors.white, child: Padding(padding: EdgeInsets.all(20), child: PextAssetIcon(PextAssets.profileActive, size: 84))), const SizedBox(height: 10), Text(widget.admin ? 'André' : 'Igor', style: const TextStyle(color: _blue, fontSize: 23, fontWeight: FontWeight.bold)), const SizedBox(height: 12), _TabBar(labels: const ['Dados', 'Segurança'], value: _tab, onChanged: (value) => setState(() => _tab = value)), const SizedBox(height: 16), Expanded(child: SingleChildScrollView(child: _tab == 0 ? Column(children: const [_Field('CPF', value: '123.***.***-45'), _Field('Data de nascimento', value: '30/03/2005'), _Field('E-mail', value: 'igor@pext.com.br'), _Field('Telefone', value: '(17) 99999-9999'), _Field('Endereço', value: 'Rua Jorge Meneguel, 1948'), _Field('Cidade', value: 'Fernandópolis'), _Field('Função', value: 'Produção')]) : Column(children: const [_Field('Senha atual', value: '••••••••'), _Field('Nova senha', value: '••••••••'), _Field('Confirmar nova senha', value: '••••••••')]))), OutlinedButton(onPressed: () {}, child: Text(_tab == 0 ? 'EDITAR DADOS' : 'ALTERAR SENHA'))])); }

class _Shell extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  const _Shell({required this.title, required this.child, this.action});

  int get _selected {
    if (title == 'Treinamentos' || title == 'Processo de extrusão') return 0;
    if (title == 'Assistente IA' || title == 'Suporte administrativo') return 3;
    if (title == 'Perfil') return 4;
    return 2;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _canvas,
        appBar: AppBar(backgroundColor: _canvas, surfaceTintColor: _canvas, centerTitle: true, leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, color: _blue, size: 19)), title: Text(title, style: const TextStyle(color: _blue, fontWeight: FontWeight.w600, fontSize: 18)), actions: [if (action != null) action!, const SizedBox(width: 5)]),
        body: Padding(padding: const EdgeInsets.fromLTRB(28, 6, 28, 18), child: child),
        bottomNavigationBar: _CoreBottomBar(selected: _selected),
      );
}

class _CoreBottomBar extends StatelessWidget {
  final int selected;
  const _CoreBottomBar({required this.selected});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: _border)), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
        child: SafeArea(top: false, child: Row(children: [
          _CoreNavItem(asset: PextAssets.education, activeAsset: PextAssets.educationActive, label: 'Treinamento', active: selected == 0, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainingListScreen()))),
          _CoreNavItem(asset: PextAssets.heart, activeAsset: PextAssets.heartActive, label: 'Favoritos', active: selected == 1, onTap: () {}),
          _CoreNavItem(asset: PextAssets.home, activeAsset: PextAssets.homeActive, label: 'Home', active: selected == 2, onTap: () => Navigator.pop(context)),
          _CoreNavItem(asset: PextAssets.chat, activeAsset: PextAssets.chatActive, label: 'Chat', active: selected == 3, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatAssistantScreen()))),
          _CoreNavItem(asset: PextAssets.profile, activeAsset: PextAssets.profileActive, label: 'Perfil', active: selected == 4, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()))),
        ])),
      );
}

class _CoreNavItem extends StatelessWidget {
  final String asset, activeAsset, label;
  final bool active;
  final VoidCallback onTap;
  const _CoreNavItem({required this.asset, required this.activeAsset, required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.only(top: 6, bottom: 4), child: Column(mainAxisSize: MainAxisSize.min, children: [PextAssetIcon(active ? activeAsset : asset, size: 31), Text(label, style: TextStyle(fontSize: 10, color: active ? _blue : const Color(0xFF26313D), fontWeight: active ? FontWeight.w700 : FontWeight.normal))]))));
}
class _TabBar extends StatelessWidget { final List<String> labels; final int value; final ValueChanged<int> onChanged; const _TabBar({required this.labels, required this.value, required this.onChanged}); @override Widget build(BuildContext context) => Row(children: labels.asMap().entries.map((entry) => Expanded(child: InkWell(onTap: () => onChanged(entry.key), child: Column(children: [Text(entry.value, style: TextStyle(fontSize: 11, color: entry.key == value ? _blue : const Color(0xFF7A8290), fontWeight: entry.key == value ? FontWeight.bold : FontWeight.normal)), const SizedBox(height: 7), Container(height: 1.5, color: entry.key == value ? _blue : _border)])))).toList()); }
class _TrainingTile extends StatelessWidget { final int status; final bool admin; final VoidCallback onTap; const _TrainingTile({required this.status, required this.admin, required this.onTap}); @override Widget build(BuildContext context) { final labels = ['Em curso', 'Desistência', 'Concluído']; final colors = [const Color(0xFFF0A000), const Color(0xFFF04444), const Color(0xFF1AB65C)]; return InkWell(onTap: onTap, child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(10), decoration: _card(), child: Row(children: [Container(width: 58, height: 58, decoration: BoxDecoration(color: const Color(0xFFE6EBF2), borderRadius: BorderRadius.circular(9)), child: const Icon(Icons.precision_manufacturing_outlined, color: _blue)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Expanded(child: Text('Processo de extrusão', style: TextStyle(color: _blue, fontWeight: FontWeight.bold))), _Pill(labels[status], colors[status])]), const Text('Módulo 2 - Temperatura e pressão', style: TextStyle(fontSize: 8)), const SizedBox(height: 7), Row(children: [Expanded(child: LinearProgressIndicator(value: status == 2 ? 1 : status == 1 ? 0 : .7, color: _blue, backgroundColor: _border, minHeight: 5)), const SizedBox(width: 5), Text(status == 2 ? '100%' : status == 1 ? '0%' : '70%', style: const TextStyle(fontSize: 10, color: _blue))])])), Icon(status == 2 ? Icons.favorite : Icons.favorite_border, color: _blue, size: 20)]))); } }
class _Pill extends StatelessWidget { final String text; final Color color; const _Pill(this.text, this.color); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)), child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold))); }
class _ModuleTile extends StatelessWidget { final int index; final String title; final bool done; final VoidCallback onTap; const _ModuleTile({required this.index, required this.title, required this.done, required this.onTap}); @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 8), decoration: _card(), child: ListTile(onTap: onTap, leading: CircleAvatar(backgroundColor: done ? _blue : _border, child: Text('$index', style: TextStyle(color: done ? Colors.white : _blue))), title: Text(title, style: const TextStyle(color: _blue, fontWeight: FontWeight.w600)), subtitle: Text(done ? 'Concluído' : 'Não iniciado', style: const TextStyle(fontSize: 10)), trailing: Icon(done ? Icons.check_circle : Icons.play_circle_outline, color: done ? const Color(0xFF1AB65C) : _blue))); }
class _ChatBubble extends StatelessWidget { final String text; final bool mine; const _ChatBubble(this.text, this.mine); @override Widget build(BuildContext context) => Align(alignment: mine ? Alignment.centerRight : Alignment.centerLeft, child: Container(constraints: const BoxConstraints(maxWidth: 270), margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: mine ? _blue : const Color(0xFFE4E7EC), borderRadius: BorderRadius.circular(16)), child: Text(text, style: TextStyle(fontSize: 12, color: mine ? Colors.white : const Color(0xFF2D3542))))); }
class _EditorSection extends StatelessWidget { final String title; final IconData icon; const _EditorSection(this.title, this.icon); @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 10), decoration: _card(), child: ListTile(leading: Icon(icon, color: _blue), title: Text(title, style: const TextStyle(color: _blue, fontWeight: FontWeight.bold)), subtitle: const Text('Adicionar e organizar conteúdo', style: TextStyle(fontSize: 11)), trailing: const Icon(Icons.chevron_right, color: _blue))); }
class _Field extends StatelessWidget { final String label; final int lines; final String? value; const _Field(this.label, {this.lines = 1, this.value}); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: _blue, fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 5), TextField(maxLines: lines, controller: value == null ? null : TextEditingController(text: value), readOnly: value != null, decoration: InputDecoration(hintText: value == null ? 'Preencha $label' : null, filled: true, fillColor: Colors.white, border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: _border))))])); }
class _StepText extends StatelessWidget { final String text; const _StepText(this.text); @override Widget build(BuildContext context) => Text(text, style: const TextStyle(color: _blue, fontWeight: FontWeight.bold)); }
class _PrimaryButton extends StatelessWidget { final String text; const _PrimaryButton(this.text); @override Widget build(BuildContext context) => FilledButton(onPressed: () {}, child: Text(text)); }
class _InfoDialog extends StatelessWidget { final String title, body; const _InfoDialog(this.title, this.body); @override Widget build(BuildContext context) => AlertDialog(title: Text(title, style: const TextStyle(color: _blue)), content: Text(body), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))]); }
BoxDecoration _card() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11), border: Border.all(color: _border));
