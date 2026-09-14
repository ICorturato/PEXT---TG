import 'package:flutter/material.dart';
import '../../widgets/pext_asset_icon.dart';

const _blue = Color(0xFF053488);
const _canvas = Color(0xFFF6F8FB);
const _border = Color(0xFFE5E7EB);

class ResinsListScreen extends StatefulWidget {
  final bool admin;
  const ResinsListScreen({super.key, this.admin = false});

  @override
  State<ResinsListScreen> createState() => _ResinsListScreenState();
}

class _ResinsListScreenState extends State<ResinsListScreen> {
  String _query = '';
  final _resins = const [
    ('PEBD', 'Polietileno de Baixa Densidade', Color(0xFFEDF9ED), 'PE'),
    ('PP', 'Polipropileno', Color(0xFFEAF2FF), 'P'),
    ('PEAD', 'Polietileno de Alta Densidade', Color(0xFFFFEFEF), 'PD'),
    ('PET', 'Polietileno Tereftalato', Color(0xFFF6EEFF), 'PE'),
  ];

  @override
  Widget build(BuildContext context) {
    final matches = _resins.where((r) => '${r.$1} ${r.$2}'.toLowerCase().contains(_query.toLowerCase())).toList();
    return _ResinScaffold(
      title: 'Resinas',
      action: widget.admin ? IconButton(tooltip: 'Adicionar resina', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResinFormScreen())), icon: const Icon(Icons.add_circle_outline, color: _blue)) : null,
      child: Column(children: [
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: const InputDecoration(prefixIcon: PextAssetIcon(PextAssets.search, size: 21), suffixIcon: Padding(padding: EdgeInsets.all(12), child: PextAssetIcon(PextAssets.filter, size: 20)), hintText: 'Ex: Coextrusão', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(11)), borderSide: BorderSide.none)),
        ),
        const SizedBox(height: 14),
        Expanded(child: ListView.separated(itemCount: matches.length, separatorBuilder: (_, separatorIndex) => const SizedBox(height: 9), itemBuilder: (_, index) {
          final resin = matches[index];
          return InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResinDetailScreen(admin: widget.admin, resin: resin.$1))),
            borderRadius: BorderRadius.circular(11),
            child: Container(padding: const EdgeInsets.all(13), decoration: _card(), child: Row(children: [
              Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: resin.$3, borderRadius: BorderRadius.circular(9), border: Border.all(color: _border)), child: Text(resin.$4, style: const TextStyle(color: _blue, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(resin.$1, style: const TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 16)), Text(resin.$2, style: const TextStyle(fontSize: 11, color: Color(0xFF687080)))])),
               Icon(widget.admin ? Icons.edit_outlined : Icons.arrow_forward_ios_rounded, size: 18, color: _blue),
            ])),
          );
        })),
      ]),
    );
  }
}

class ResinDetailScreen extends StatefulWidget {
  final bool admin;
  final String resin;
  const ResinDetailScreen({super.key, required this.admin, required this.resin});
  @override
  State<ResinDetailScreen> createState() => _ResinDetailScreenState();
}

class _ResinDetailScreenState extends State<ResinDetailScreen> {
  int _tab = 0;
  bool _favorite = false;
  final _tabs = const ['Visão Geral', 'Características', 'Propriedades', 'Mais'];
  @override
  Widget build(BuildContext context) => _ResinScaffold(
    title: '${widget.resin} - ${widget.resin == 'PP' ? 'Polipropileno' : 'Polietileno'}',
    action: widget.admin
        ? IconButton(tooltip: 'Editar conteúdo', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResinFormScreen())), icon: const Icon(Icons.edit_outlined, color: _blue))
        : IconButton(tooltip: 'Favoritar', onPressed: () => setState(() => _favorite = !_favorite), icon: Icon(_favorite ? Icons.favorite : Icons.favorite_border, color: _blue)),
    child: Column(children: [
      _Tabs(tabs: _tabs, selected: _tab, onChanged: (index) => setState(() => _tab = index)),
      const SizedBox(height: 16),
      Expanded(child: SingleChildScrollView(child: _content())),
    ]),
  );

  Widget _content() {
    if (_tab == 0) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(height: 120, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.precision_manufacturing_outlined, size: 58, color: _blue))),
      const SizedBox(height: 12), Row(children: [const _Chip('PP', Color(0xFFE7F8EC)), const SizedBox(width: 8), const _Chip('Termoplástico', Color(0xFFF0F2F5)), const Spacer(), if (widget.admin) OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResinFormScreen())), icon: const Icon(Icons.edit, size: 15), label: const Text('Editar', style: TextStyle(fontSize: 11)))]),
      const SizedBox(height: 18), const Row(children: [Expanded(child: SizedBox(height: 100, child: _Stat('Densidade', '0,90 - 0,91\ng/cm³', PextAssets.density))), SizedBox(width: 8), Expanded(child: SizedBox(height: 100, child: _Stat('Temp. de Fusão', '160 - 170°C', PextAssets.temperature))), SizedBox(width: 8), Expanded(child: SizedBox(height: 100, child: _Stat('MFI', '0,3 - 50\ng/10 min', PextAssets.mfi)))]),
      const SizedBox(height: 20), _heading('Como Funciona?'), const Text('O polipropileno (PP) é um termoplástico semicristalino produzido pela polimerização do propeno.', style: TextStyle(fontSize: 11)),
      const SizedBox(height: 16), _heading('Processos de Produção:'), const Row(children: [Expanded(child: _Production(PextAssets.resin, 'Matéria-Prima\n(Propeno)')), SizedBox(width: 5), Icon(Icons.arrow_forward, size: 16), SizedBox(width: 5), Expanded(child: _Production(PextAssets.polimerization, 'Polimerização')), SizedBox(width: 5), Icon(Icons.arrow_forward, size: 16), SizedBox(width: 5), Expanded(child: _Production(PextAssets.granulation, 'Granulação')), SizedBox(width: 5), Icon(Icons.arrow_forward, size: 16), SizedBox(width: 5), Expanded(child: _Production(PextAssets.finalProduct, 'Produto Final'))]),
      const SizedBox(height: 20), _heading('Para o que é utilizado?'), const Text('Devido às suas propriedades, o PP é utilizado em diversos segmentos da indústria.', style: TextStyle(fontSize: 11)),
      const SizedBox(height: 12), GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: .92, mainAxisSpacing: 8, crossAxisSpacing: 8, children: const [_Use(PextAssets.packaging, 'Embalagens\n(filmes flexíveis e\nrígidos)'), _Use(PextAssets.jar, 'Tampas e\nFechamentos'), _Use(PextAssets.fiber, 'Fibras Têxteis\ne não tecidos'), _Use(PextAssets.car, 'Peças Automotivas'), _Use(PextAssets.houseMachines, 'Eletrodomésticos\ne utilidades'), _Use(PextAssets.joys, 'Brinquedos e\nbens de consumo')]),
    ]);
    if (_tab == 1) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _heading('Dados técnicos'), GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: .86, mainAxisSpacing: 8, crossAxisSpacing: 8, children: const [_Stat('Densidade', '0,90 - 0,91\ng/cm³', PextAssets.density), _Stat('Temp. de Fusão', '160 - 170°C', PextAssets.temperature), _Stat('MFI', '0,3 - 50\ng/10 min', PextAssets.mfi), _Stat('HDT', '0,90 - 0,91\ng/cm³', PextAssets.density), _Stat('Resistência à Tração', '160 - 170°C', PextAssets.temperature), _Stat('EB', '0,3 - 50\ng/10 min', PextAssets.mfi), _Stat('Módulo de Elasticidade', '0,90 - 0,91\ng/cm³', PextAssets.density), _Stat('Impacto Izod (23°C)', '160 - 170°C', PextAssets.temperature), _Stat('Dureza Rockwell', '0,3 - 50\ng/10 min', PextAssets.mfi)]), const SizedBox(height: 20), _heading('Principais características'), ...['Leve e resistente', 'Boa resistência química', 'Flexível e versátil', 'Alta resistência à fadiga', 'Boa processabilidade', 'Reciclável'].map((item) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [const Icon(Icons.check_circle, size: 13, color: Color(0xFF22C55E)), const SizedBox(width: 7), Text(item, style: const TextStyle(fontSize: 11))]))),
    ]);
    if (_tab == 2) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _heading('Propriedades principais'), const _Level('Resistência Química', .88, 'Alta'), const _Level('Resistência ao impacto', .5, 'Média'), const _Level('Rigidez', .9, 'Alta'), const _Level('Flexibilidade', .5, 'Média'), const _Level('Temperatura de uso contínuo', .3, '80-100 °C'), const _Level('Reciclabilidade', .9, 'Alta'), const SizedBox(height: 14), Container(padding: const EdgeInsets.all(14), decoration: _card(), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [PextAssetIcon(PextAssets.info, size: 15), SizedBox(width: 6), Text('Observações importantes', style: TextStyle(color: _blue, fontWeight: FontWeight.bold))]), SizedBox(height: 7), Text('Evitar contato prolongado com solventes aromáticos e clorados.\n\nArmazenar em local seco e protegido da luz solar direta.\n\nPara melhor performance, utilizar aditivos compatíveis com a aplicação.')]))
    ]);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _heading('Documentos Relacionados'), ...List.generate(4, (_) => const _DocumentRow('Ficha Técnica ...')), OutlinedButton(onPressed: () {}, child: const SizedBox(width: double.infinity, child: Text('Ver todos os documentos', textAlign: TextAlign.center))), const SizedBox(height: 16), _heading('Vídeo Relacionados'), const _VideoRow(), const SizedBox(height: 16), _heading('Perguntas frequentes'), ...['É resistente ao calor?', 'Pergunta ai', 'Alguma dúvida', 'Pode ser usada com ...'].map((item) => _FaqRow(item)), OutlinedButton(onPressed: () {}, child: const SizedBox(width: double.infinity, child: Text('Ver todas as perguntas', textAlign: TextAlign.center))),
    ]);
  }
}

class ResinFormScreen extends StatefulWidget { const ResinFormScreen({super.key}); @override State<ResinFormScreen> createState() => _ResinFormScreenState(); }
class _ResinFormScreenState extends State<ResinFormScreen> {
  int _tab = 0; final _tabs = const ['Visão Geral', 'Características', 'Propriedades', 'Mais'];
  @override Widget build(BuildContext context) => _ResinScaffold(title: 'Cadastrar resina', child: Column(children: [_Tabs(tabs: _tabs, selected: _tab, onChanged: (index) => setState(() => _tab = index)), const SizedBox(height: 16), Expanded(child: SingleChildScrollView(child: _formContent())), FilledButton(onPressed: () => _success(context), child: const Text('CADASTRAR')), const SizedBox(height: 8)]));
  Widget _formContent() {
    if (_tab == 0) return const Column(children: [_Field('Nome do material'), _Field('Nome técnico (opcional)'), _Field('Sigla'), _Field('Descrição curta', lines: 4), _Field('Categoria'), _Field('Subcategoria (opcional)')]);
    if (_tab == 1) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Dados técnicos', style: TextStyle(color: _blue, fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 10), ...['Densidade', 'Índice de fluidez (MFI)', 'Temperatura de fusão', 'Resistência à tração'].map((label) => _Field(label)), const Text('Principais características', style: const TextStyle(color: _blue, fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Wrap(spacing: 8, children: const [_Chip('Resistente', Color(0xFFF0F2F5)), _Chip('Reciclável', Color(0xFFF0F2F5))])]);
    if (_tab == 2) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Propriedades', style: TextStyle(color: _blue, fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 12), ...['Rigidez', 'Resistência química', 'Resistência ao impacto', 'Transparência', 'Processabilidade', 'Reciclabilidade'].map((label) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Expanded(child: Text(label)), const _Chip('Baixa', Color(0xFFF0F2F5)), const SizedBox(width: 5), const _Chip('Média', Color(0xFFEAF2FF)), const SizedBox(width: 5), const _Chip('Alta', Color(0xFFF0F2F5))])))]);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_heading('Documentos relacionados'), const _FileRow('Ficha técnica ...', Icons.picture_as_pdf_outlined), OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Adicionar documento')), const SizedBox(height: 16), _heading('Vídeos relacionados'), const _FileRow('Processamento ...', Icons.play_circle_outline), OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Adicionar vídeo')), const SizedBox(height: 16), _heading('Perguntas frequentes'), const _Field('Digite uma pergunta')]);
  }
  void _success(BuildContext context) => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Resina adicionada'), content: const Text('O cadastro visual foi concluído com sucesso.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))]));
}

class _ResinScaffold extends StatelessWidget { final String title; final Widget child; final Widget? action; const _ResinScaffold({required this.title, required this.child, this.action}); @override Widget build(BuildContext context) => Scaffold(backgroundColor: _canvas, appBar: AppBar(backgroundColor: _canvas, surfaceTintColor: _canvas, leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, color: _blue, size: 19)), centerTitle: true, title: Text(title, style: const TextStyle(color: _blue, fontSize: 18, fontWeight: FontWeight.w600)), actions: [if (action != null) action!, const SizedBox(width: 5)]), body: Padding(padding: const EdgeInsets.fromLTRB(38, 6, 38, 18), child: child), bottomNavigationBar: const _ResinBottomBar()); }
class _ResinBottomBar extends StatelessWidget { const _ResinBottomBar(); @override Widget build(BuildContext context) => Container(decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: _border)), borderRadius: BorderRadius.vertical(top: Radius.circular(12))), child: SafeArea(top: false, child: Row(children: const [_ResinNav(PextAssets.education, 'Treinamento'), _ResinNav(PextAssets.heart, 'Favoritos'), _ResinNav(PextAssets.home, 'Home'), _ResinNav(PextAssets.chat, 'Chat'), _ResinNav(PextAssets.profile, 'Perfil')]))); }
class _ResinNav extends StatelessWidget { final String asset, text; const _ResinNav(this.asset, this.text); @override Widget build(BuildContext context) => Expanded(child: Padding(padding: const EdgeInsets.only(top: 6, bottom: 4), child: Column(mainAxisSize: MainAxisSize.min, children: [PextAssetIcon(asset, size: 31), Text(text, style: const TextStyle(fontSize: 10, color: Color(0xFF363C46)))]))); }
class _Tabs extends StatelessWidget { final List<String> tabs; final int selected; final ValueChanged<int> onChanged; const _Tabs({required this.tabs, required this.selected, required this.onChanged}); @override Widget build(BuildContext context) => SizedBox(height: 36, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: tabs.length, separatorBuilder: (_, separatorIndex) => const SizedBox(width: 17), itemBuilder: (_, index) => InkWell(onTap: () => onChanged(index), child: Column(children: [Text(tabs[index], style: TextStyle(color: index == selected ? _blue : const Color(0xFF7A8290), fontSize: 12, fontWeight: index == selected ? FontWeight.bold : FontWeight.normal)), const Spacer(), Container(height: 2, width: 68, color: index == selected ? _blue : Colors.transparent)])))); }
class _Stat extends StatelessWidget { final String label, value, asset; const _Stat(this.label, this.value, this.asset); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(9), decoration: _card(), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [PextAssetIcon(asset, size: 20), const SizedBox(height: 5), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9)), const SizedBox(height: 3), Text(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: _blue, fontWeight: FontWeight.bold))])); }
class _Chip extends StatelessWidget { final String label; final Color color; const _Chip(this.label, this.color); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(7)), child: Text(label, style: const TextStyle(fontSize: 11))); }
class _Production extends StatelessWidget { final String asset; final String label; const _Production(this.asset, this.label); @override Widget build(BuildContext context) => Column(children: [Container(height: 48, decoration: _card(), child: Center(child: PextAssetIcon(asset, size: 26))), const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 7))]); }
class _Use extends StatelessWidget { final String asset; final String label; const _Use(this.asset, this.label); @override Widget build(BuildContext context) => Container(decoration: _card(), padding: const EdgeInsets.all(6), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [PextAssetIcon(asset, size: 22), const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9))])); }
class _Level extends StatelessWidget { final String label, level; final double value; const _Level(this.label, this.value, this.level); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 5), Row(children: [Expanded(child: LinearProgressIndicator(value: value, color: _blue, backgroundColor: _border, minHeight: 8, borderRadius: BorderRadius.circular(5))), const SizedBox(width: 10), SizedBox(width: 44, child: Text(level, style: const TextStyle(fontSize: 11)))]) ])); }
class _FileRow extends StatelessWidget { final String text; final IconData icon; const _FileRow(this.text, this.icon); @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(11), decoration: _card(), child: Row(children: [Icon(icon, color: _blue), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(fontSize: 12))), const Icon(Icons.chevron_right, color: _blue)])); }
class _DocumentRow extends StatelessWidget { final String text; const _DocumentRow(this.text); @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 5), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: _card(), child: Row(children: [const PextAssetIcon(PextAssets.pdf, size: 30), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(text, style: const TextStyle(color: _blue, fontWeight: FontWeight.bold, fontSize: 12)), const Text('PDF - 1,2 MB', style: TextStyle(fontSize: 7, color: Color(0xFF6B7280)))])), const PextAssetIcon(PextAssets.download, size: 21)])); }
class _VideoRow extends StatelessWidget { const _VideoRow(); @override Widget build(BuildContext context) => Container(height: 84, padding: const EdgeInsets.all(5), decoration: _card(), child: Row(children: [Container(width: 118, decoration: BoxDecoration(color: const Color(0xFFD1D1D1), borderRadius: BorderRadius.circular(14)), child: const Center(child: PextAssetIcon(PextAssets.videoWatch, size: 40))), const SizedBox(width: 7), const Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Processamento ...', style: TextStyle(color: _blue, fontSize: 10, fontWeight: FontWeight.bold)), Text('03:20', style: TextStyle(fontSize: 7))])), const Icon(Icons.chevron_right, color: _blue)])); }
class _FaqRow extends StatelessWidget { final String text; const _FaqRow(this.text); @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 5), padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8), decoration: _card(), child: Row(children: [Expanded(child: Text(text, style: const TextStyle(fontSize: 11))), const Icon(Icons.chevron_right, size: 18, color: _blue)])); }
class _Field extends StatelessWidget { final String label; final int lines; const _Field(this.label, {this.lines = 1}); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: _blue, fontWeight: FontWeight.w600, fontSize: 13)), const SizedBox(height: 5), TextField(maxLines: lines, decoration: InputDecoration(hintText: 'Preencha $label', filled: true, fillColor: Colors.white, border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: _border)) ))])); }
Widget _heading(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(color: _blue, fontSize: 17, fontWeight: FontWeight.bold)));
BoxDecoration _card() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11), border: Border.all(color: _border));
