import 'package:flutter/material.dart';
import 'features/core/core_screens.dart';
import 'features/resins/resins_screens.dart';
import 'features/troubleshooting/troubleshooting_screens.dart';
import 'widgets/pext_asset_icon.dart';

void main() => runApp(const PextApp());

const _blue = Color(0xFF053488);
const _canvas = Color(0xFFF6F8FB);
const _line = Color(0xFFE5E7EB);

class PextApp extends StatelessWidget {
  const PextApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PEXT',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: _canvas,
          colorScheme: ColorScheme.fromSeed(seedColor: _blue),
          fontFamily: 'Arial',
        ),
        home: const LoginPage(),
      );
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 3),
                const PextLogo(),
                const Spacer(flex: 3),
                const FieldLabel('CPF', hint: 'Digite seu CPF'),
                const SizedBox(height: 6),
                const FieldLabel('Senha',
                    hint: 'Digite sua senha', obscure: true),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Recuperar senha',
                        style: TextStyle(fontSize: 11)),
                  ),
                ),
                const Spacer(flex: 2),
                FilledButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    builder: (sheetContext) => SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          const Text('Escolha o perfil para visualizar',
                              style: TextStyle(
                                  color: _blue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 14),
                          ListTile(
                            leading: const Icon(Icons.engineering_outlined,
                                color: _blue),
                            title: const Text('Usuário'),
                            onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const HomePage())),
                          ),
                          ListTile(
                            leading: const Icon(
                                Icons.admin_panel_settings_outlined,
                                color: _blue),
                            title: const Text('Administrador'),
                            onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const HomePage(admin: true))),
                          ),
                        ]),
                      ),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF17459A),
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('ENTRAR',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      );
}

class PextLogo extends StatelessWidget {
  const PextLogo({super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(children: [
          Image.asset(PextAssets.logo, width: 230, fit: BoxFit.contain),
        ]),
      );
}

class FieldLabel extends StatelessWidget {
  final String label, hint;
  final bool obscure;
  const FieldLabel(this.label,
      {super.key, required this.hint, this.obscure = false});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: _blue, fontSize: 16)),
        const SizedBox(height: 5),
        TextField(
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9AA4B4), fontSize: 11),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: _line)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: _line)),
          ),
        ),
      ]);
}

class AppShell extends StatelessWidget {
  final Widget body;
  final int selected;
  final bool admin;
  const AppShell(
      {super.key, required this.body, this.selected = 2, this.admin = false});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: body),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _line)),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
          child: SafeArea(
            top: false,
            child: Row(children: [
              NavItem(
                  asset: PextAssets.education,
                  activeAsset: PextAssets.educationActive,
                  text: 'Treinamento',
                  active: selected == 0,
                  onTap: () => go(context, TrainingPage(admin: admin))),
              if (admin)
                NavItem(
                    asset: PextAssets.dashboard,
                    activeAsset: PextAssets.dashboardActive,
                    text: 'Dashboard',
                    active: selected == 1,
                    onTap: () => go(context, const DashboardPage()))
              else
                NavItem(
                    asset: PextAssets.heart,
                    activeAsset: PextAssets.heartActive,
                    text: 'Favoritos',
                    active: selected == 1,
                    onTap: () => go(context, const FavoritesPage())),
              NavItem(
                  asset: PextAssets.home,
                  activeAsset: PextAssets.homeActive,
                  text: 'Home',
                  active: selected == 2,
                  onTap: () => go(context, HomePage(admin: admin))),
              NavItem(
                  asset: PextAssets.chat,
                  activeAsset: PextAssets.chatActive,
                  text: 'Chat',
                  active: selected == 3,
                  onTap: () => go(context, ChatPage(admin: admin))),
              NavItem(
                  asset: PextAssets.profile,
                  activeAsset: PextAssets.profileActive,
                  text: 'Perfil',
                  active: selected == 4,
                  onTap: () => go(context, ProfilePage(admin: admin))),
            ]),
          ),
        ),
      );
}

void go(BuildContext context, Widget page) =>
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );

class NavItem extends StatelessWidget {
  final String asset;
  final String activeAsset;
  final String text;
  final bool active;
  final VoidCallback onTap;
  const NavItem(
      {super.key,
      required this.asset,
      required this.activeAsset,
      required this.text,
      required this.active,
      required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PextAssetIcon(active ? activeAsset : asset, size: 31),
                Text(text,
                    style: TextStyle(
                        fontSize: 10,
                        color: active ? _blue : const Color(0xFF26313D),
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.normal)),
              ],
            ),
          ),
        ),
      );
}

class HomePage extends StatelessWidget {
  final bool admin;
  const HomePage({super.key, this.admin = false});
  @override
  Widget build(BuildContext context) => AppShell(
        admin: admin,
        body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(admin ? 'Olá, André' : 'Olá, Igor',
                    style: const TextStyle(
                        color: _blue,
                        fontSize: 34,
                        fontWeight: FontWeight.w600)),
                const ProfileAvatar()
              ]),
              const SizedBox(height: 8),
              if (admin) const AdminProgress() else const UserProgress(),
              if (admin)
                OutlinedButton(
                    onPressed: () => go(context, const DashboardPage()),
                    child: const Text('Ver mais dashboards')),
              const SizedBox(height: 10),
              const SectionTitle('Acesso Rápido'),
              QuickGrid(admin: admin),
              if (!admin) ...[
                const SectionTitle('Continue treinando'),
                const TrainingCard(inProgress: true),
                const SectionTitle('Refaça o teste'),
                const TrainingCard(inProgress: false),
              ],
            ]),
      );
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});
  @override
  Widget build(BuildContext context) => Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: _line)),
      clipBehavior: Clip.antiAlias,
      child: Image.asset('images/profile_igor.png',
          fit: BoxFit.cover, alignment: const Alignment(0, -0.45)));
}

class UserProgress extends StatelessWidget {
  const UserProgress({super.key});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Seu progresso',
            style: TextStyle(color: _blue, fontSize: 18)),
        const SizedBox(height: 10),
        Container(
            height: 140,
            padding: const EdgeInsets.symmetric(horizontal: 26),
            decoration: card(),
            child: LayoutBuilder(builder: (context, constraints) {
              final ringSize = constraints.maxHeight * .68;
              return Row(children: [
                SizedBox(
                    width: ringSize,
                    height: ringSize,
                    child: Stack(alignment: Alignment.center, children: [
                      Positioned.fill(
                          child: CircularProgressIndicator(
                              value: .5,
                              strokeWidth: ringSize * .085,
                              backgroundColor: const Color(0xFFE5E7EB),
                              color: _blue)),
                      Text('50%',
                          style: TextStyle(
                              fontSize: ringSize * .20,
                              color: const Color(0xFF000000)))
                    ])),
                const SizedBox(width: 22),
                const Expanded(
                    child: ProgressStat('12', 'Treinamentos\nConcluídos')),
                const Expanded(
                    child: ProgressStat('6', 'Treinamentos\nem Curso')),
              ]);
            })),
        const SizedBox(height: 10),
      ]);
}

class ProgressStat extends StatelessWidget {
  final String value, label;
  const ProgressStat(this.value, this.label, {super.key});
  @override
  Widget build(BuildContext context) =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 10,
                height: 1.1,
                color: Color(0xFF363C46),
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 7),
        Text(value,
            style: const TextStyle(
                color: _blue, fontSize: 25, fontWeight: FontWeight.w500))
      ]);
}

class AdminProgress extends StatelessWidget {
  const AdminProgress({super.key});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Treinamentos por usuário',
            style: TextStyle(color: _blue, fontSize: 18)),
        const SizedBox(height: 10),
        Container(
            height: 150,
            padding: const EdgeInsets.all(18),
            decoration: card(),
            child: Row(children: [
              const SizedBox(
                  width: 95,
                  height: 95,
                  child: CircularProgressIndicator(
                      value: .88,
                      strokeWidth: 8,
                      backgroundColor: Color(0xFFF1A114),
                      color: Color(0xFF22BE62))),
              const SizedBox(width: 18),
              Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                    LegendRow(Colors.red, '0 Treinamentos'),
                    LegendRow(Color(0xFF53A7FF), '1-2 Treinamentos'),
                    LegendRow(Color(0xFFF1A114), '3-4 Treinamentos'),
                    LegendRow(Color(0xFF22BE62), '5-7 Treinamentos'),
                    LegendRow(_blue, '8+ Treinamentos')
                  ]))
            ])),
        const SizedBox(height: 8),
      ]);
}

class LegendRow extends StatelessWidget {
  final Color color;
  final String text;
  const LegendRow(this.color, this.text, {super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 7),
        Text(text, style: const TextStyle(fontSize: 8))
      ]);
}

class QuickGrid extends StatelessWidget {
  final bool admin;
  const QuickGrid({super.key, required this.admin});
  @override
  Widget build(BuildContext context) {
    final items = <QuickAction>[
      QuickAction(PextAssets.chatbot, 'Assistente IA',
          () => go(context, ChatPage(admin: admin))),
      QuickAction(PextAssets.glossary, 'Dicionário',
          () => go(context, TermsPage(admin: admin))),
      QuickAction(PextAssets.recycling, 'Resinas',
          () => go(context, ResinsPage(admin: admin))),
      QuickAction(PextAssets.training, 'Treinamentos',
          () => go(context, TrainingPage(admin: admin))),
      QuickAction(PextAssets.problem, 'Problemas\ne Soluções',
          () => go(context, ProblemsPage(admin: admin))),
      if (admin)
        QuickAction(PextAssets.dashboardActive, 'Dashboard',
            () => go(context, const DashboardPage())),
      if (admin)
        QuickAction(PextAssets.product, 'Embalagens',
            () => go(context, const PackagingPage())),
    ];
    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: .88),
        itemCount: items.length,
        itemBuilder: (_, i) => items[i]);
  }
}

class QuickAction extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback onTap;
  const QuickAction(this.asset, this.label, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
          decoration: card(),
          padding: const EdgeInsets.all(10),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            PextAssetIcon(asset, size: 47),
            const SizedBox(height: 5),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _blue, fontSize: 11))
          ])));
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Text(text, style: const TextStyle(color: _blue, fontSize: 17)));
}

BoxDecoration card() => BoxDecoration(
    color: Colors.white,
    border: Border.all(color: _line),
    borderRadius: BorderRadius.circular(11));

class TrainingCard extends StatelessWidget {
  final bool inProgress;
  const TrainingCard({super.key, required this.inProgress});
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 540;
        final coverSize = wide ? 190.0 : 66.0;
        final titleSize = wide ? 29.0 : 13.0;
        final bodySize = wide ? 17.0 : 8.0;
        final padding = wide ? 36.0 : 10.0;
        return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _line, width: wide ? 3 : 1),
                borderRadius: BorderRadius.circular(wide ? 30 : 11)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(wide ? 30 : 9),
                  child: Image.asset('images/training_extrusion.png',
                      width: coverSize, height: coverSize, fit: BoxFit.cover)),
              SizedBox(width: wide ? 30 : 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Expanded(
                          child: Text('Processo de extrusão',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: _blue,
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.bold))),
                      StatusPill(
                          inProgress ? 'Em curso' : 'Concluído',
                          inProgress
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF22C55E),
                          fontSize: wide ? 16 : 7),
                    ]),
                    SizedBox(height: wide ? 7 : 2),
                    Text('Módulo 2 - Temperatura e pressão',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: bodySize,
                            color: const Color(0xFF6B7280))),
                    SizedBox(height: wide ? 25 : 7),
                    Row(children: [
                      Expanded(
                          child: LinearProgressIndicator(
                              value: inProgress ? .7 : 1,
                              color: _blue,
                              minHeight: wide ? 16 : 5,
                              borderRadius: BorderRadius.circular(9))),
                      SizedBox(width: wide ? 10 : 6),
                      Text(inProgress ? '70%' : '100%',
                          style: TextStyle(
                              color: _blue, fontSize: wide ? 29 : 10)),
                      SizedBox(width: wide ? 22 : 5),
                      SizedBox(
                          height: wide ? 52 : 21,
                          child: inProgress
                              ? FilledButton(
                                  onPressed: () {},
                                  style: FilledButton.styleFrom(
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: wide ? 13 : 5),
                                      backgroundColor: _blue),
                                  child: Text('CONTINUAR',
                                      style:
                                          TextStyle(fontSize: wide ? 16 : 6)))
                              : OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: wide ? 13 : 5),
                                      side: const BorderSide(
                                          color: Color(0xFFF59E0B))),
                                  child: Text('REFAZER TESTE',
                                      style: TextStyle(
                                          color: const Color(0xFFF59E0B),
                                          fontSize: wide ? 16 : 6)))),
                    ]),
                    if (!inProgress) ...[
                      SizedBox(height: wide ? 10 : 5),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                              widthFactor: wide ? .82 : .74,
                              child: _FailedTrainingNotice(wide: wide)))
                    ],
                  ])),
              SizedBox(width: wide ? 22 : 5),
              Icon(Icons.favorite_border, color: _blue, size: wide ? 42 : 20),
            ]));
      });
}

class _FailedTrainingNotice extends StatelessWidget {
  final bool wide;
  const _FailedTrainingNotice({required this.wide});
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: wide ? 16 : 5, vertical: wide ? 10 : 3),
      decoration: BoxDecoration(
          color: const Color(0xFFFFE1AD),
          borderRadius: BorderRadius.circular(wide ? 19 : 8)),
      child: Row(children: [
        CircleAvatar(
            radius: wide ? 12 : 7,
            backgroundColor: const Color(0xFFF59E0B),
            child: Icon(Icons.warning_amber_rounded,
                size: wide ? 17 : 10, color: Colors.white)),
        SizedBox(width: wide ? 10 : 4),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Reprovado',
              style: TextStyle(
                  color: const Color(0xFF363C46),
                  fontSize: wide ? 14 : 8,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: wide ? 2 : 0),
          Text('Você acertou 11 de 20 questões (55%).',
              style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: wide ? 10 : 5,
                  fontWeight: FontWeight.w600)),
        ])),
      ]));
}

class StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  const StatusPill(this.text, this.color, {super.key, this.fontSize = 7});
  @override
  Widget build(BuildContext context) => Container(
      padding: EdgeInsets.symmetric(
          horizontal: fontSize * 1.1, vertical: fontSize * .28),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(text,
          style: TextStyle(
              fontSize: fontSize,
              color: Colors.white,
              fontWeight: FontWeight.bold)));
}

class PageFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final bool admin;
  final int selected;
  const PageFrame(
      {super.key,
      required this.title,
      required this.child,
      this.admin = false,
      this.selected = 2});
  @override
  Widget build(BuildContext context) => AppShell(
      admin: admin,
      selected: selected,
      body: Column(children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(children: [
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.chevron_left, size: 32)),
              Expanded(
                  child: Text(title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: _blue,
                          fontSize: 20,
                          fontWeight: FontWeight.w600))),
              const SizedBox(width: 42)
            ])),
        Expanded(child: child)
      ]));
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
      title: 'Favoritos',
      selected: 1,
      child: const SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            FavoriteSectionHeader('Resinas', PextAssets.recycling),
            FavoriteResinCard(),
            FavoriteResinCard(),
            FavoriteResinCard(),
            FavoriteSectionButton('Ver todas as resinas favoritas'),
            FavoriteDivider(),
            FavoriteSectionHeader('Treinamentos', PextAssets.training),
            FavoriteTrainingCard(status: FavoriteTrainingStatus.inProgress),
            FavoriteTrainingCard(status: FavoriteTrainingStatus.dropped),
            FavoriteTrainingCard(status: FavoriteTrainingStatus.completed),
            FavoriteSectionButton('Ver todos os treinamentos favoritos'),
            FavoriteDivider(),
            FavoriteSectionHeader('Termos', PextAssets.glossary),
            FavoriteTermCard(initials: 'P', color: Color(0xFF0A9B53)),
            FavoriteTermCard(initials: 'PE', color: Color(0xFFA36BE2)),
            SizedBox(height: 18),
          ])));
}

class FavoriteSectionHeader extends StatelessWidget {
  final String title, asset;
  const FavoriteSectionHeader(this.title, this.asset, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Row(children: [
        Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF9CA3AF)),
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
                padding: const EdgeInsets.all(7),
                child: PextAssetIcon(asset, size: 24))),
        const SizedBox(width: 12),
        Text(title,
            style: const TextStyle(
                color: _blue, fontSize: 18, fontWeight: FontWeight.bold)),
      ]));
}

class FavoriteResinCard extends StatelessWidget {
  const FavoriteResinCard({super.key});
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF8B9099), width: 1.5),
                borderRadius: BorderRadius.circular(12)),
            child: const Padding(
                padding: EdgeInsets.all(8),
                child: PextAssetIcon(PextAssets.resin, size: 30))),
        const SizedBox(width: 10),
        const Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PEBD',
              style: TextStyle(
                  color: _blue, fontSize: 17, fontWeight: FontWeight.bold)),
          Text('Polietileno de Baixa Densidade',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 9))
        ])),
        const PextAssetIcon(PextAssets.heartActive, size: 25),
      ]));
}

class FavoriteSectionButton extends StatelessWidget {
  final String label;
  const FavoriteSectionButton(this.label, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 4),
      child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(38),
              side: const BorderSide(color: Color(0xFF4DA3FF), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          child: Text(label,
              style:
                  const TextStyle(color: _blue, fontWeight: FontWeight.bold))));
}

class FavoriteDivider extends StatelessWidget {
  const FavoriteDivider({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
      padding: EdgeInsets.only(top: 12),
      child: Divider(height: 1, thickness: 1, color: Color(0xFF6B7280)));
}

enum FavoriteTrainingStatus { inProgress, dropped, completed }

class FavoriteTrainingCard extends StatelessWidget {
  final FavoriteTrainingStatus status;
  const FavoriteTrainingCard({super.key, required this.status});
  @override
  Widget build(BuildContext context) {
    final inProgress = status == FavoriteTrainingStatus.inProgress;
    final dropped = status == FavoriteTrainingStatus.dropped;
    final completed = status == FavoriteTrainingStatus.completed;
    final badgeText = inProgress
        ? 'Em curso'
        : dropped
            ? 'Desistência'
            : 'Concluído';
    final badgeColor = inProgress
        ? const Color(0xFFF59E0B)
        : dropped
            ? const Color(0xFFEF4444)
            : const Color(0xFF22C55E);
    final progress = inProgress
        ? .7
        : completed
            ? 1.0
            : 0.0;
    return Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(16)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('images/training_extrusion.png',
                  width: 64, height: 64, fit: BoxFit.cover)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  const Expanded(
                      child: Text('Processo de ...',
                          style: TextStyle(
                              color: _blue, fontWeight: FontWeight.bold))),
                  StatusPill(badgeText, badgeColor)
                ]),
                const Text('Módulo 2 - Temperatura de...',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 8)),
                const SizedBox(height: 7),
                Row(children: [
                  Expanded(
                      child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(5),
                          color: _blue,
                          backgroundColor: const Color(0xFFE5E7EB))),
                  const SizedBox(width: 5),
                  Text('${(progress * 100).round()}%',
                      style: const TextStyle(color: _blue, fontSize: 10)),
                  if (!completed) ...[
                    const SizedBox(width: 7),
                    _FavoriteAction(
                        label: inProgress ? 'CONTINUAR' : 'RETOMAR',
                        outlined: dropped)
                  ]
                ]),
                if (dropped)
                  const _FavoriteTrainingAlert(
                      asset: PextAssets.tryAgain,
                      text:
                          'Você parou de estudar. Retome de onde parou para continuar seu progresso.',
                      background: Color(0xFFFFE8E8),
                      foreground: Color(0xFFEF4444)),
                if (completed)
                  const _FavoriteTrainingAlert(
                      asset: PextAssets.approved,
                      text: 'Aprovado - Você acertou 18 de 20 questões (90%).',
                      background: Color(0xFFB5F7B5),
                      foreground: Color(0xFF22A852)),
              ])),
          const SizedBox(width: 7),
          const PextAssetIcon(PextAssets.heartActive, size: 22),
        ]));
  }
}

class _FavoriteAction extends StatelessWidget {
  final String label;
  final bool outlined;
  const _FavoriteAction({required this.label, required this.outlined});
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 23,
      child: outlined
          ? OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: Color(0xFFEF4444))),
              child: Text(label,
                  style:
                      const TextStyle(color: Color(0xFFEF4444), fontSize: 7)))
          : FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: _blue),
              child: Text(label, style: const TextStyle(fontSize: 7))));
}

class _FavoriteTrainingAlert extends StatelessWidget {
  final String asset, text;
  final Color background, foreground;
  const _FavoriteTrainingAlert(
      {required this.asset,
      required this.text,
      required this.background,
      required this.foreground});
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(top: 7),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(7)),
      child: Row(children: [
        PextAssetIcon(asset, size: 12),
        const SizedBox(width: 4),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    color: foreground,
                    fontSize: 6,
                    fontWeight: FontWeight.w600)))
      ]));
}

class FavoriteTermCard extends StatelessWidget {
  final String initials;
  final Color color;
  const FavoriteTermCard(
      {super.key, required this.initials, required this.color});
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF8B9099), width: 1.5),
                borderRadius: BorderRadius.circular(12)),
            child: Text(initials,
                style: TextStyle(
                    color: color, fontSize: 21, fontWeight: FontWeight.bold))),
        const SizedBox(width: 10),
        const Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PEBD',
              style: TextStyle(
                  color: _blue, fontSize: 17, fontWeight: FontWeight.bold)),
          Text('Polietileno de Baixa Densidade',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 9))
        ])),
        const PextAssetIcon(PextAssets.heartActive, size: 25)
      ]));
}

class SimpleListPage extends StatelessWidget {
  final String title, description;
  final IconData icon;
  final bool admin;
  final int selected;
  const SimpleListPage(
      {super.key,
      required this.title,
      required this.description,
      required this.icon,
      this.admin = false,
      this.selected = 2});
  @override
  Widget build(BuildContext context) => PageFrame(
      title: title,
      admin: admin,
      selected: selected,
      child: ListView(padding: const EdgeInsets.all(18), children: [
        TextField(
            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none))),
        const SizedBox(height: 14),
        ...List.generate(
            6,
            (i) => Card(
                child: ListTile(
                    onTap: () => showDialog(
                        context: context,
                        builder: (_) =>
                            InfoDialog(title: title, description: description)),
                    leading: Icon(icon, color: _blue),
                    title: Text(i == 0 ? 'PEBD' : '$title ${i + 1}',
                        style: const TextStyle(
                            color: _blue, fontWeight: FontWeight.bold)),
                    subtitle: Text(description),
                    trailing: admin
                        ? const Icon(Icons.edit_outlined, color: _blue)
                        : const Icon(Icons.chevron_right, color: _blue)))),
        if (admin)
          FilledButton.icon(
              onPressed: () => showDialog(
                  context: context,
                  builder: (_) => InfoDialog(
                      title: 'Adicionar $title',
                      description:
                          'Formulário visual para cadastrar um novo registro.')),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'))
      ]));
}

class TermsPage extends StatelessWidget {
  final bool admin;
  const TermsPage({super.key, this.admin = false});
  @override
  Widget build(BuildContext context) => TermsDictionaryScreen(admin: admin);
}

class ResinsPage extends StatelessWidget {
  final bool admin;
  const ResinsPage({super.key, this.admin = false});
  @override
  Widget build(BuildContext context) => ResinsListScreen(admin: admin);
}

class PackagingPage extends StatelessWidget {
  const PackagingPage({super.key});
  @override
  Widget build(BuildContext context) => const PackagingListScreen();
}

class TrainingPage extends StatelessWidget {
  final bool admin;
  const TrainingPage({super.key, this.admin = false});
  @override
  Widget build(BuildContext context) => TrainingListScreen(admin: admin);
}

class ProblemsPage extends StatelessWidget {
  final bool admin;
  const ProblemsPage({super.key, this.admin = false});
  @override
  Widget build(BuildContext context) => TroubleshootingListScreen(admin: admin);
}

class ChatPage extends StatelessWidget {
  final bool admin;
  const ChatPage({super.key, this.admin = false});
  @override
  Widget build(BuildContext context) => ChatAssistantScreen(admin: admin);
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool mine;
  const ChatBubble(this.text, this.mine, {super.key});
  @override
  Widget build(BuildContext context) => Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 280),
          decoration: BoxDecoration(
              color: mine ? _blue : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: mine ? null : Border.all(color: _line)),
          child: Text(text,
              style: TextStyle(
                  color: mine ? Colors.white : const Color(0xFF26313D)))));
}

class ProfilePage extends StatelessWidget {
  final bool admin;
  const ProfilePage({super.key, this.admin = false});
  @override
  Widget build(BuildContext context) => UserProfileScreen(admin: admin);
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
      title: 'Dashboard',
      admin: true,
      selected: 1,
      child: ListView(padding: const EdgeInsets.all(18), children: [
        const Text('Indicadores de treinamento',
            style: TextStyle(color: _blue, fontSize: 18)),
        const SizedBox(height: 12),
        Container(
            height: 180,
            decoration: card(),
            child: const Center(
                child: Icon(Icons.bar_chart, size: 125, color: _blue))),
        const SizedBox(height: 18),
        Row(children: const [
          Metric('Usuários ativos', '32'),
          SizedBox(width: 10),
          Metric('Aprovação média', '82%')
        ]),
        const SizedBox(height: 18),
        const Text('Últimas atividades',
            style: TextStyle(color: _blue, fontSize: 18)),
        ...[
          'Ana concluiu Processo de extrusão',
          'Jorge atualizou a resina PEBD',
          'Novo ticket de suporte criado'
        ].map((x) => ListTile(
            leading: const Icon(Icons.history, color: _blue),
            title: Text(x),
            subtitle: const Text('Hoje')))
      ]));
}

class Metric extends StatelessWidget {
  final String title, value;
  const Metric(this.title, this.value, {super.key});
  @override
  Widget build(BuildContext context) => Expanded(
      child: Container(
          padding: const EdgeInsets.all(14),
          decoration: card(),
          child: Column(children: [
            Text(value,
                style: const TextStyle(
                    color: _blue, fontSize: 26, fontWeight: FontWeight.bold)),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11))
          ])));
}

class InfoDialog extends StatelessWidget {
  final String title, description;
  const InfoDialog({super.key, required this.title, required this.description});
  @override
  Widget build(BuildContext context) => AlertDialog(
          title: Text(title, style: const TextStyle(color: _blue)),
          content: Text(description),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'))
          ]);
}
