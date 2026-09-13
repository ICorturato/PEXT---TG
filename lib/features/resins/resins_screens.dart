import 'package:flutter/material.dart';
import '../../widgets/pext_asset_icon.dart';

const _blue = Color(0xFF073B98);
const _canvas = Color(0xFFF5F7FB);
const _border = Color(0xFFDCE1E9);

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
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search, color: _blue), hintText: 'Ex: Coextrusão', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(11)), borderSide: BorderSide.none)),
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
              PextAssetIcon(widget.admin ? PextAssets.edit : PextAssets.resin, size: 22),
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
      Container(height: 140, decoration: BoxDecoration(color: const Color(0xFFE6EBF2), borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.precision_manufacturing_outlined, size: 58, color: _blue))),
      const SizedBox(height: 12),
      Row(children: [const _Chip('PP', Color(0xFFE7F8EC)), const SizedBox(width: 8), const _Chip('Termoplástico', Color(0xFFF0F2F5)), const Spacer(), if (widget.admin) OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResinFormScreen())), icon: const Icon(Icons.edit, size: 15), label: const Text('Editar', style: TextStyle(fontSize: 11)))]),
      const SizedBox(height: 18),
      const Row(children: [Expanded(child: _Stat('Densidade', '0,90 - 0,91\ng/cm³', PextAssets.density)), SizedBox(width: 8), Expanded(child: _Stat('Temp. de fusão', '160 - 170°C', PextAssets.temperature)), SizedBox(width: 8), Expanded(child: _Stat('MFI', '0,3 - 50\ng/10 min', PextAssets.mfi))]),
      const SizedBox(height: 20), _heading('Como funciona?'), const Text('O polipropileno é um termoplástico semicristalino produzido pela polimerização do propeno. É leve, versátil e muito utilizado em embalagens industriais.'),
      const SizedBox(height: 20), _heading('Processo de produção'), const Row(children: [Expanded(child: _Flow(PextAssets.resin, 'Matéria-prima')), Icon(Icons.arrow_forward, size: 16), Expanded(child: _Flow(PextAssets.polimerization, 'Polimerização')), Icon(Icons.arrow_forward, size: 16), Expanded(child: _Flow(PextAssets.granulation, 'Granulação')), Icon(Icons.arrow_forward, size: 16), Expanded(child: _Flow(PextAssets.finalProduct, 'Produto final'))]),
      const SizedBox(height: 20), _heading('Aplicações'), GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: .92, mainAxisSpacing: 8, crossAxisSpacing: 8, children: const [_Use(PextAssets.packaging, 'Embalagens'), _Use(PextAssets.jar, 'Tampas'), _Use(PextAssets.fiber, 'Fibras'), _Use(PextAssets.car, 'Automotivo'), _Use(PextAssets.houseMachines, 'Utilidades'), _Use(PextAssets.joys, 'Consumo')]),
    ]);
    if (_tab == 1) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _heading('Dados técnicos'), GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.55, mainAxisSpacing: 8, crossAxisSpacing: 8, children: const [_Stat('Densidade', '0,90 - 0,91 g/cm³', PextAssets.density), _Stat('Temp. de fusão', '160 - 170°C', PextAssets.temperature), _Stat('Resistência à tração', '30 - 40 MPa', PextAssets.material), _Stat('Impacto Izod', '20 kJ/m²', PextAssets.joys)]), const SizedBox(height: 20), _heading('Principais características'), ...['Leve e resistente', 'Boa resistência química', 'Alta resistência à fadiga', 'Reciclável'].map((item) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [const PextAssetIcon(PextAssets.check, size: 18), const SizedBox(width: 8), Text(item)]))),
    ]);
    if (_tab == 2) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _heading('Propriedades principais'), const _Level('Rigidez', .72, 'Alta'), const _Level('Resistência química', .88, 'Alta'), const _Level('Resistência ao impacto', .55, 'Média'), const _Level('Transparência', .35, 'Baixa'), const _Level('Processabilidade', .82, 'Alta'), const _Level('Reciclabilidade', .72, 'Alta'), const SizedBox(height: 14), Container(padding: const EdgeInsets.all(14), decoration: _card(), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Observações importantes', style: TextStyle(color: _blue, fontWeight: FontWeight.bold)), SizedBox(height: 7), Text('Avaliar aditivos e condições de processamento antes de usar em estruturas multicamadas.')]))
    ]);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _heading('Documentos relacionados'), ...['Ficha técnica do material', 'Ficha de segurança'].map((item) => _FileRow(item, Icons.picture_as_pdf_outlined)), const SizedBox(height: 18), _heading('Vídeos relacionados'), const _FileRow('Processamento do polipropileno', Icons.play_circle_outline), const SizedBox(height: 18), _heading('Perguntas frequentes'), ...['É resistente ao calor?', 'Pode ser usado em coextrusão?', 'Qual é a faixa de fusão?'].map((item) => _FileRow(item, Icons.help_outline)),
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

class _ResinScaffold extends StatelessWidget { final String title; final Widget child; final Widget? action; const _ResinScaffold({required this.title, required this.child, this.action}); @override Widget build(BuildContext context) => Scaffold(backgroundColor: _canvas, appBar: AppBar(backgroundColor: _canvas, surfaceTintColor: _canvas, leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, color: _blue, size: 19)), centerTitle: true, title: Text(title, style: const TextStyle(color: _blue, fontSize: 18, fontWeight: FontWeight.w600)), actions: [if (action != null) action!, const SizedBox(width: 5)]), body: Padding(padding: const EdgeInsets.fromLTRB(18, 6, 18, 18), child: child)); }
class _Tabs extends StatelessWidget { final List<String> tabs; final int selected; final ValueChanged<int> onChanged; const _Tabs({required this.tabs, required this.selected, required this.onChanged}); @override Widget build(BuildContext context) => SizedBox(height: 36, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: tabs.length, separatorBuilder: (_, separatorIndex) => const SizedBox(width: 17), itemBuilder: (_, index) => InkWell(onTap: () => onChanged(index), child: Column(children: [Text(tabs[index], style: TextStyle(color: index == selected ? _blue : const Color(0xFF7A8290), fontSize: 12, fontWeight: index == selected ? FontWeight.bold : FontWeight.normal)), const Spacer(), Container(height: 2, width: 68, color: index == selected ? _blue : Colors.transparent)])))); }
class _Stat extends StatelessWidget { final String label, value, asset; const _Stat(this.label, this.value, this.asset); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(9), decoration: _card(), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [PextAssetIcon(asset, size: 20), const SizedBox(height: 5), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9)), const SizedBox(height: 3), Text(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: _blue, fontWeight: FontWeight.bold))])); }
class _Chip extends StatelessWidget { final String label; final Color color; const _Chip(this.label, this.color); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(7)), child: Text(label, style: const TextStyle(fontSize: 11))); }
class _Flow extends StatelessWidget { final String asset; final String label; const _Flow(this.asset, this.label); @override Widget build(BuildContext context) => Column(children: [PextAssetIcon(asset, size: 24), const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 8))]); }
class _Use extends StatelessWidget { final String asset; final String label; const _Use(this.asset, this.label); @override Widget build(BuildContext context) => Container(decoration: _card(), padding: const EdgeInsets.all(6), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [PextAssetIcon(asset, size: 22), const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9))])); }
class _Level extends StatelessWidget { final String label, level; final double value; const _Level(this.label, this.value, this.level); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 5), Row(children: [Expanded(child: LinearProgressIndicator(value: value, color: _blue, backgroundColor: _border, minHeight: 8, borderRadius: BorderRadius.circular(5))), const SizedBox(width: 10), SizedBox(width: 44, child: Text(level, style: const TextStyle(fontSize: 11)))]) ])); }
class _FileRow extends StatelessWidget { final String text; final IconData icon; const _FileRow(this.text, this.icon); @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(11), decoration: _card(), child: Row(children: [Icon(icon, color: _blue), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(fontSize: 12))), const Icon(Icons.chevron_right, color: _blue)])); }
class _Field extends StatelessWidget { final String label; final int lines; const _Field(this.label, {this.lines = 1}); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: _blue, fontWeight: FontWeight.w600, fontSize: 13)), const SizedBox(height: 5), TextField(maxLines: lines, decoration: InputDecoration(hintText: 'Preencha $label', filled: true, fillColor: Colors.white, border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: _border)) ))])); }
Widget _heading(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(color: _blue, fontSize: 17, fontWeight: FontWeight.bold)));
BoxDecoration _card() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11), border: Border.all(color: _border));
