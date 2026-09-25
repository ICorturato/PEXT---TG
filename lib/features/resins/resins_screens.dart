import 'package:flutter/material.dart';
import '../../app_routes.dart';
import '../../widgets/pext_asset_icon.dart';
import '../../widgets/app_search_bar.dart';

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
    final matches = _resins
        .where((r) =>
            '${r.$1} ${r.$2}'.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return _ResinScaffold(
      title: 'Resinas',
      admin: widget.admin,
      action: widget.admin
          ? _HeaderAction(
              icon: Icons.add,
              tooltip: 'Adicionar resina',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ResinFormScreen(admin: true))))
          : null,
      child: Column(children: [
        Row(children: [
          Expanded(
              child: AppSearchBar(
                  hint: 'Ex: Coextrusão',
                  onChanged: (value) => setState(() => _query = value))),
          const SizedBox(width: 9),
          Container(
              width: 44,
              height: 52,
              decoration: _card(),
              child: const Padding(
                  padding: EdgeInsets.all(11),
                  child: PextAssetIcon(PextAssets.filter, size: 21)))
        ]),
        const SizedBox(height: 14),
        Expanded(
            child: ListView.separated(
                itemCount: matches.length,
                separatorBuilder: (_, separatorIndex) =>
                    const SizedBox(height: 9),
                itemBuilder: (_, index) {
                  final resin = matches[index];
                  return InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ResinDetailScreen(
                                admin: widget.admin, resin: resin.$1))),
                    borderRadius: BorderRadius.circular(11),
                    child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: _card(),
                        child: Row(children: [
                          Container(
                              width: 42,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: resin.$3,
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(color: _border)),
                              child: Text(resin.$4,
                                  style: const TextStyle(
                                      color: _blue,
                                      fontWeight: FontWeight.bold))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(resin.$1,
                                    style: const TextStyle(
                                        color: _blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text(resin.$2,
                                    style: const TextStyle(
                                        fontSize: 11, color: Color(0xFF687080)))
                              ])),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              size: 18, color: _blue),
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
  const ResinDetailScreen(
      {super.key, required this.admin, required this.resin});
  @override
  State<ResinDetailScreen> createState() => _ResinDetailScreenState();
}

class _ResinDetailScreenState extends State<ResinDetailScreen> {
  int _tab = 0;
  bool _favorite = false;
  final _tabs = const [
    'Visão Geral',
    'Características',
    'Propriedades',
    'Mais'
  ];
  @override
  Widget build(BuildContext context) => _ResinScaffold(
        title:
            '${widget.resin} - ${widget.resin == 'PP' ? 'Polipropileno' : 'Polietileno'}',
        admin: widget.admin,
        action: widget.admin
            ? null
            : _HeaderAction(
                icon: _favorite ? Icons.favorite : Icons.favorite_border,
                tooltip: 'Favoritar',
                onTap: () => setState(() => _favorite = !_favorite)),
        child: Column(children: [
          _Tabs(
              tabs: _tabs,
              selected: _tab,
              onChanged: (index) => setState(() => _tab = index)),
          const SizedBox(height: 16),
          Expanded(child: SingleChildScrollView(child: _content())),
        ]),
      );

  Widget _content() {
    if (_tab == 0)
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('images/training_extrusion.png',
                height: 120, width: double.infinity, fit: BoxFit.cover)),
        const SizedBox(height: 12),
        Row(children: [
          const _Chip('PP', Color(0xFFB9EFD1)),
          const SizedBox(width: 8),
          const _Chip('Termoplástico', Color(0xFFE7F8EC)),
          const Spacer(),
          if (widget.admin)
            Column(children: [
              OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      visualDensity: VisualDensity.compact),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ResinFormScreen(admin: true))),
                  icon: const PextAssetIcon(PextAssets.edit, size: 15),
                  label: const Text('Editar Conteúdo',
                      style: TextStyle(fontSize: 10))),
              const SizedBox(height: 5),
              OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF8494E),
                      side: const BorderSide(color: Color(0xFFF8494E)),
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      visualDensity: VisualDensity.compact),
                  onPressed: () {},
                  icon: const PextAssetIcon(PextAssets.trash, size: 15),
                  label: const Text('Excluir Conteúdo',
                      style: TextStyle(fontSize: 10)))
            ])
        ]),
        const SizedBox(height: 18),
        const Row(children: [
          Expanded(
              child: SizedBox(
                  height: 100,
                  child: _Stat(
                      'Densidade', '0,90 - 0,91\ng/cm³', PextAssets.density))),
          SizedBox(width: 8),
          Expanded(
              child: SizedBox(
                  height: 100,
                  child: _Stat('Temp. de Fusão', '160 - 170°C',
                      PextAssets.temperature))),
          SizedBox(width: 8),
          Expanded(
              child: SizedBox(
                  height: 100,
                  child: _Stat('MFI', '0,3 - 50\ng/10 min', PextAssets.mfi)))
        ]),
        const SizedBox(height: 20),
        _heading('Como Funciona?'),
        const Text(
            'O polipropileno (PP) é um termoplástico semicristalino produzido pela polimerização do propeno.',
            style: TextStyle(fontSize: 11)),
        const SizedBox(height: 16),
        _heading('Processos de Produção:'),
        const Row(children: [
          Expanded(
              child: _Production(PextAssets.resin, 'Matéria-Prima\n(Propeno)')),
          SizedBox(width: 5),
          Icon(Icons.arrow_forward, size: 16),
          SizedBox(width: 5),
          Expanded(
              child: _Production(PextAssets.polimerization, 'Polimerização')),
          SizedBox(width: 5),
          Icon(Icons.arrow_forward, size: 16),
          SizedBox(width: 5),
          Expanded(child: _Production(PextAssets.granulation, 'Granulação')),
          SizedBox(width: 5),
          Icon(Icons.arrow_forward, size: 16),
          SizedBox(width: 5),
          Expanded(child: _Production(PextAssets.finalProduct, 'Produto Final'))
        ]),
        const SizedBox(height: 20),
        _heading('Para o que é utilizado?'),
        const Text(
            'Devido às suas propriedades, o PP é utilizado em diversos segmentos da indústria.',
            style: TextStyle(fontSize: 11)),
        const SizedBox(height: 12),
        GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: .92,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: const [
              _Use(PextAssets.packaging,
                  'Embalagens\n(filmes flexíveis e\nrígidos)'),
              _Use(PextAssets.jar, 'Tampas e\nFechamentos'),
              _Use(PextAssets.fiber, 'Fibras Têxteis\ne não tecidos'),
              _Use(PextAssets.car, 'Peças Automotivas'),
              _Use(PextAssets.houseMachines, 'Eletrodomésticos\ne utilidades'),
              _Use(PextAssets.joys, 'Brinquedos e\nbens de consumo')
            ]),
      ]);
    if (_tab == 1)
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _heading('Dados técnicos'),
        GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: .86,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: const [
              _Stat('Densidade', '0,90 - 0,91\ng/cm³', PextAssets.density),
              _Stat('Temp. de Fusão', '160 - 170°C', PextAssets.temperature),
              _Stat('MFI', '0,3 - 50\ng/10 min', PextAssets.mfi),
              _Stat('HDT', '0,90 - 0,91\ng/cm³', PextAssets.density),
              _Stat('Resistência à Tração', '160 - 170°C',
                  PextAssets.temperature),
              _Stat('EB', '0,3 - 50\ng/10 min', PextAssets.mfi),
              _Stat('Módulo de Elasticidade', '0,90 - 0,91\ng/cm³',
                  PextAssets.density),
              _Stat(
                  'Impacto Izod (23°C)', '160 - 170°C', PextAssets.temperature),
              _Stat('Dureza Rockwell', '0,3 - 50\ng/10 min', PextAssets.mfi)
            ]),
        const SizedBox(height: 20),
        _heading('Principais características'),
        ...[
          'Leve e resistente',
          'Boa resistência química',
          'Flexível e versátil',
          'Alta resistência à fadiga',
          'Boa processabilidade',
          'Reciclável'
        ].map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              const Icon(Icons.check_circle,
                  size: 13, color: Color(0xFF22C55E)),
              const SizedBox(width: 7),
              Text(item, style: const TextStyle(fontSize: 11))
            ]))),
      ]);
    if (_tab == 2)
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _propertiesHeading('Propriedades principais'),
        const _Level('Resistência Química', .88, 'Alta'),
        const _Level('Resistência ao impacto', .5, 'Média'),
        const _Level('Rigidez', .9, 'Alta'),
        const _Level('Flexibilidade', .5, 'Média'),
        const _Level('Temperatura de uso contínuo', .3, '80-100 °C'),
        const _Level('Reciclabilidade', .9, 'Alta'),
        const SizedBox(height: 14),
        Container(
            padding: const EdgeInsets.all(14),
            decoration: _card(),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    PextAssetIcon(PextAssets.info, size: 15),
                    SizedBox(width: 6),
                    Text('Observações importantes',
                        style: TextStyle(
                            color: _blue, fontWeight: FontWeight.bold))
                  ]),
                  SizedBox(height: 7),
                  Text(
                      'Evitar contato prolongado com solventes aromáticos e clorados.\n\nArmazenar em local seco e protegido da luz solar direta.\n\nPara melhor performance, utilizar aditivos compatíveis com a aplicação.')
                ]))
      ]);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _heading('Documentos Relacionados'),
      ...List.generate(4, (_) => const _DocumentRow('Ficha Técnica ...')),
      OutlinedButton(
          onPressed: () {},
          child: const SizedBox(
              width: double.infinity,
              child: Text('Ver todos os documentos',
                  textAlign: TextAlign.center))),
      const SizedBox(height: 16),
      _heading('Vídeo Relacionados'),
      const _VideoRow(),
      const SizedBox(height: 16),
      _heading('Perguntas frequentes'),
      ...[
        'É resistente ao calor?',
        'Pergunta ai',
        'Alguma dúvida',
        'Pode ser usada com ...'
      ].map((item) => _FaqRow(item)),
      OutlinedButton(
          onPressed: () {},
          child: const SizedBox(
              width: double.infinity,
              child:
                  Text('Ver todas as perguntas', textAlign: TextAlign.center))),
    ]);
  }
}

class ResinFormScreen extends StatefulWidget {
  final bool admin;
  const ResinFormScreen({super.key, this.admin = true});
  @override
  State<ResinFormScreen> createState() => _ResinFormScreenState();
}

class _ResinFormScreenState extends State<ResinFormScreen> {
  int _tab = 0;
  final _featureController = TextEditingController();
  final _features = <String>['Resistente', 'Reciclável'];
  final _levels = <String, int>{
    'Rigidez': 1,
    'Resistência Química': 2,
    'Resistência ao Impacto': 0,
    'Transparência': 0,
    'Processabilidade': 2,
    'Reciclabilidade': 1,
  };
  final _tabs = const [
    'Visão Geral',
    'Características',
    'Propriedades',
    'Mais'
  ];

  @override
  void dispose() {
    _featureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ResinScaffold(
      title: 'Resinas',
      admin: widget.admin,
      child: Column(children: [
        _Tabs(
            tabs: _tabs,
            selected: _tab,
            onChanged: (index) => setState(() => _tab = index)),
        const SizedBox(height: 16),
        Expanded(child: SingleChildScrollView(child: _formContent())),
        SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: () => _success(context),
                child: const Text('CADASTRAR'))),
        const SizedBox(height: 8)
      ]));

  Widget _formContent() {
    if (_tab == 0)
      return const Column(children: [
        _Field('Nome do Material:', hint: 'Ex: Material irregular na matriz'),
        _Field('Nome técnico (opcional):',
            hint: 'Ex: Material irregular na matriz'),
        _Field('Sigla:', hint: 'Ex: PP'),
        _Field('Descrição curta:',
            hint: 'Ex: Material irregular na matriz', lines: 4),
        _SelectField('Categoria:'),
        _SelectField('Subcategoria (opcional):')
      ]);
    if (_tab == 1)
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Dados técnicos',
            style: TextStyle(
                color: _blue, fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...const [
          ('Densidade:', 'g/cm²'),
          ('Índice de Fluídez (MFI):', 'g/10 min'),
          ('Temperatura de Fusão:', '°C'),
          ('Temperatura de deflexão térmica:', '°C'),
          ('Resistência à Tração:', 'MPa'),
          ('Alongamento na ruptura:', '%'),
          ('Módulo de Elasticidade:', 'MPa'),
          ('Impacto Izod(23°C):', 'kJ/m²'),
          ('Dureza Rockwell:', ''),
        ].map((item) => _TechnicalField(label: item.$1, suffix: item.$2)),
        const Text('Principais características',
            style: TextStyle(
                color: _blue, fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: TextField(
                  controller: _featureController,
                  decoration: const InputDecoration(
                      hintText: 'Digite uma característica'))),
          const SizedBox(width: 8),
          OutlinedButton(
              onPressed: () {
                final feature = _featureController.text.trim();
                if (feature.isNotEmpty) {
                  setState(() => _features.add(feature));
                  _featureController.clear();
                }
              },
              child: const Text('Adicionar'))
        ]),
        const SizedBox(height: 10),
        const Text('Características adicionadas:',
            style: TextStyle(color: _blue, fontWeight: FontWeight.w600)),
        const SizedBox(height: 7),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _features
                .map((item) => _Chip(item, const Color(0xFFF0F2F5)))
                .toList())
      ]);
    if (_tab == 2)
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Propriedades',
            style: TextStyle(
                color: _blue, fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._levels.entries.map((entry) => _PropertySelector(
            label: entry.key,
            value: entry.value,
            onChanged: (value) => setState(() => _levels[entry.key] = value))),
        const SizedBox(height: 10),
        const Text('Observações',
            style: TextStyle(
                color: _blue, fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 7),
        const TextField(
            maxLines: 5,
            decoration:
                InputDecoration(hintText: 'Ex: Material irregular na matriz'))
      ]);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _heading('Documentos relacionados'),
      ...List.generate(
          3, (_) => const _EditableDocumentRow('Ficha Técnica ...')),
      _AddItemButton(onTap: () {}, label: 'ADICIONAR DOCUMENTO'),
      const SizedBox(height: 16),
      _heading('Vídeos relacionados'),
      const _EditableVideoRow(),
      _AddItemButton(onTap: () {}, label: 'ADICIONAR VÍDEO'),
      const SizedBox(height: 16),
      _heading('Perguntas frequentes'),
      ...[
        'É resistente ao calor?',
        'Pergunta ai',
        'Alguma dúvida',
        'Pode ser usada com ...'
      ].map((item) => _EditableFaqRow(item)),
      _AddItemButton(onTap: () {}, label: 'ADICIONAR PERGUNTA')
    ]);
  }

  void _success(BuildContext context) => showDialog(
      context: context,
      builder: (_) =>
          ResinaSucessoDialog(onAddMore: () => setState(() => _tab = 0)));
}

class _SelectField extends StatelessWidget {
  final String label;
  const _SelectField(this.label);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: _blue, fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
            items: const [
              DropdownMenuItem(
                  value: 'Termoplástico', child: Text('Termoplástico')),
              DropdownMenuItem(value: 'Termofixo', child: Text('Termofixo')),
            ],
            onChanged: (_) {},
            decoration: const InputDecoration(hintText: 'Selecionar'))
      ]));
}

class _TechnicalField extends StatelessWidget {
  final String label, suffix;
  const _TechnicalField({required this.label, required this.suffix});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Expanded(
            flex: 6,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600))),
        const SizedBox(width: 10),
        Expanded(
            flex: 5,
            child: TextField(
                textAlign: TextAlign.right,
                decoration: InputDecoration(suffixText: suffix)))
      ]));
}

class _PropertySelector extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _PropertySelector(
      {required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(children: [
        Expanded(
            flex: 5,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600))),
        const SizedBox(width: 7),
        Expanded(
            flex: 7,
            child: Row(
                children: List.generate(3, (index) {
              const labels = ['Baixa', 'Média', 'Alta'];
              final active = index == value;
              return Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(right: index == 2 ? 0 : 5),
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 38),
                              foregroundColor:
                                  active ? _blue : const Color(0xFF363C46),
                              side: BorderSide(
                                  color: active
                                      ? const Color(0xFF4DA3FF)
                                      : _border)),
                          onPressed: () => onChanged(index),
                          child: Text(labels[index],
                              style: const TextStyle(fontSize: 10)))));
            })))
      ]));
}

class _AddItemButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  const _AddItemButton({required this.onTap, required this.label});
  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add_circle_outline),
          label: Text(label)));
}

class _EditableDocumentRow extends StatelessWidget {
  final String text;
  const _EditableDocumentRow(this.text);
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(10),
      decoration: _card(),
      child: Row(children: [
        const PextAssetIcon(PextAssets.pdf, size: 28),
        const SizedBox(width: 9),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(text,
              style:
                  const TextStyle(color: _blue, fontWeight: FontWeight.bold)),
          const Text('PDF - 1,2 MB',
              style: TextStyle(fontSize: 9, color: Color(0xFF687080)))
        ])),
        const Icon(Icons.close, size: 20)
      ]));
}

class _EditableVideoRow extends StatelessWidget {
  const _EditableVideoRow();
  @override
  Widget build(BuildContext context) => Container(
      height: 95,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(6),
      decoration: _card(),
      child: Row(children: [
        Container(
            width: 110,
            decoration: BoxDecoration(
                color: const Color(0xFFD1D1D1),
                borderRadius: BorderRadius.circular(10))),
        const SizedBox(width: 9),
        const Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text('Processamento ...',
                  style: TextStyle(color: _blue, fontWeight: FontWeight.bold)),
              Text('03:20',
                  style: TextStyle(fontSize: 10, color: Color(0xFF687080)))
            ])),
        const Icon(Icons.close, size: 20)
      ]));
}

class _EditableFaqRow extends StatelessWidget {
  final String text;
  const _EditableFaqRow(this.text);
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: _card(),
      child: Row(children: [
        Expanded(
            child: Text(text,
                style: const TextStyle(fontWeight: FontWeight.w600))),
        const Icon(Icons.close, size: 20)
      ]));
}

class ResinaSucessoDialog extends StatelessWidget {
  final VoidCallback onAddMore;
  const ResinaSucessoDialog({super.key, required this.onAddMore});
  @override
  Widget build(BuildContext context) => Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF9AA3B0))),
      child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Resina adicionada com sucesso!',
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

class _ResinScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  final bool admin;
  final bool returnToHome;
  const _ResinScaffold(
      {required this.title,
      required this.child,
      this.action,
      this.admin = false,
      this.returnToHome = false});
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
              leading: IconButton(
                  onPressed: () => _safeBack(context),
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: _blue, size: 19)),
              centerTitle: true,
              title: Text(title,
                  style: const TextStyle(
                      color: _blue, fontSize: 20, fontWeight: FontWeight.w600)),
              actions: [if (action != null) action!, const SizedBox(width: 5)]),
          body: Padding(
              padding: const EdgeInsets.fromLTRB(38, 6, 38, 18), child: child),
          bottomNavigationBar: _ResinBottomBar(admin: admin, selected: 2)));

  void _safeBack(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    _goToRoot(context, PextRoutes.home, admin: admin);
  }
}

class _ResinBottomBar extends StatelessWidget {
  final bool admin;
  final int selected;
  const _ResinBottomBar({required this.admin, required this.selected});
  @override
  Widget build(BuildContext context) => Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _border)),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      child: SafeArea(
          top: false,
          child: Row(children: [
            _ResinNav(
                PextAssets.education,
                PextAssets.educationActive,
                'Treinamento',
                selected == 0,
                () => _goToRoot(context, PextRoutes.training, admin: admin)),
            _ResinNav(
                admin ? PextAssets.dashboard : PextAssets.heart,
                admin ? PextAssets.dashboardActive : PextAssets.heartActive,
                admin ? 'Dashboard' : 'Favoritos',
                selected == 1,
                () => _goToRoot(context,
                    admin ? PextRoutes.dashboard : PextRoutes.favorites,
                    admin: admin)),
            _ResinNav(
                PextAssets.home,
                PextAssets.homeActive,
                'Home',
                selected == 2,
                () => _goToRoot(context, PextRoutes.home, admin: admin)),
            _ResinNav(
                PextAssets.chat,
                PextAssets.chatActive,
                'Chat',
                selected == 3,
                () => _goToRoot(context, PextRoutes.chat, admin: admin)),
            _ResinNav(
                PextAssets.profile,
                PextAssets.profileActive,
                'Perfil',
                selected == 4,
                () => _goToRoot(context, PextRoutes.profile, admin: admin))
          ])));
}

class _ResinNav extends StatelessWidget {
  final String asset, activeAsset, text;
  final bool active;
  final VoidCallback onTap;
  const _ResinNav(
      this.asset, this.activeAsset, this.text, this.active, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(
      child: InkWell(
          onTap: onTap,
          child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 4),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                PextAssetIcon(active ? activeAsset : asset, size: 31),
                Text(text,
                    style: TextStyle(
                        fontSize: 10,
                        color: active ? _blue : const Color(0xFF363C46),
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.normal))
              ]))));
}

void _goToRoot(BuildContext context, String route, {bool admin = false}) =>
    Navigator.of(context).pushNamedAndRemoveUntil(
        route, (currentRoute) => false,
        arguments: PextRouteArgs(admin: admin));

class _Tabs extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChanged;
  const _Tabs(
      {required this.tabs, required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 36,
      child: Row(
          children: tabs
              .asMap()
              .entries
              .map((entry) => Expanded(
                  child: InkWell(
                      onTap: () => onChanged(entry.key),
                      child: Column(children: [
                        Text(entry.value,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: entry.key == selected
                                    ? _blue
                                    : const Color(0xFF6B7280),
                                fontSize: 9,
                                fontWeight: entry.key == selected
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                        const Spacer(),
                        Container(
                            height: 2,
                            width: double.infinity,
                            color: entry.key == selected ? _blue : _border)
                      ]))))
              .toList()));
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _HeaderAction(
      {required this.icon, required this.tooltip, required this.onTap});
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
          tooltip: tooltip,
          onPressed: onTap,
          icon: Icon(icon, size: 19, color: _blue)));
}

class _Stat extends StatelessWidget {
  final String label, value, asset;
  const _Stat(this.label, this.value, this.asset);
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(9),
      decoration: _card(),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        PextAssetIcon(asset, size: 20),
        const SizedBox(height: 5),
        Text(label,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 9)),
        const SizedBox(height: 3),
        Text(value,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 10, color: _blue, fontWeight: FontWeight.bold))
      ]));
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(7)),
      child: Text(label, style: const TextStyle(fontSize: 13)));
}

class _Production extends StatelessWidget {
  final String asset;
  final String label;
  const _Production(this.asset, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
            height: 48,
            decoration: _card(),
            child: Center(child: PextAssetIcon(asset, size: 26))),
        const SizedBox(height: 4),
        Text(label,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 7))
      ]);
}

class _Use extends StatelessWidget {
  final String asset;
  final String label;
  const _Use(this.asset, this.label);
  @override
  Widget build(BuildContext context) => Container(
      decoration: _card(),
      padding: const EdgeInsets.all(6),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        PextAssetIcon(asset, size: 22),
        const SizedBox(height: 4),
        Text(label,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 9))
      ]));
}

class _Level extends StatelessWidget {
  final String label, level;
  final double value;
  const _Level(this.label, this.value, this.level);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF132B5C),
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(children: [
          Expanded(
              child: LinearProgressIndicator(
                  value: value,
                  color: _blue,
                  backgroundColor: _border,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(5))),
          const SizedBox(width: 10),
          SizedBox(
              width: 44,
              child: Text(level,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF687080))))
        ])
      ]));
}

class _FileRow extends StatelessWidget {
  final String text;
  final IconData icon;
  const _FileRow(this.text, this.icon);
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: _card(),
      child: Row(children: [
        Icon(icon, color: _blue),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        const Icon(Icons.chevron_right, color: _blue)
      ]));
}

class _DocumentRow extends StatelessWidget {
  final String text;
  const _DocumentRow(this.text);
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: _card(),
      child: Row(children: [
        const PextAssetIcon(PextAssets.pdf, size: 30),
        const SizedBox(width: 8),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(text,
              style: const TextStyle(
                  color: _blue, fontWeight: FontWeight.bold, fontSize: 12)),
          const Text('PDF - 1,2 MB',
              style: TextStyle(fontSize: 7, color: Color(0xFF6B7280)))
        ])),
        const PextAssetIcon(PextAssets.download, size: 21)
      ]));
}

class _VideoRow extends StatelessWidget {
  const _VideoRow();
  @override
  Widget build(BuildContext context) => Container(
      height: 84,
      padding: const EdgeInsets.all(5),
      decoration: _card(),
      child: Row(children: [
        Container(
            width: 118,
            decoration: BoxDecoration(
                color: const Color(0xFFD1D1D1),
                borderRadius: BorderRadius.circular(14)),
            child: const Center(
                child: PextAssetIcon(PextAssets.videoWatch, size: 40))),
        const SizedBox(width: 7),
        const Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text('Processamento ...',
                  style: TextStyle(
                      color: _blue, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('03:20', style: TextStyle(fontSize: 7))
            ])),
        const Icon(Icons.chevron_right, color: _blue)
      ]));
}

class _FaqRow extends StatelessWidget {
  final String text;
  const _FaqRow(this.text);
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: _card(),
      child: Row(children: [
        Expanded(child: Text(text, style: const TextStyle(fontSize: 11))),
        const Icon(Icons.chevron_right, size: 18, color: _blue)
      ]));
}

class _Field extends StatelessWidget {
  final String label;
  final String? hint;
  final int lines;
  const _Field(this.label, {this.hint, this.lines = 1});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: _blue, fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 5),
        TextField(
            maxLines: lines,
            decoration: InputDecoration(
                hintText: hint ?? 'Preencha $label',
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: _border))))
      ]));
}

Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: const TextStyle(
            color: _blue, fontSize: 17, fontWeight: FontWeight.bold)));

Widget _propertiesHeading(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: const TextStyle(
            color: _blue, fontSize: 15, fontWeight: FontWeight.bold)));
BoxDecoration _card() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(11),
    border: Border.all(color: _border));
