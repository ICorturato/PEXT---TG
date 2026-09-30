import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'app_routes.dart';
import 'features/admin/admin_user_screens.dart';
import 'features/core/core_screens.dart';
import 'features/resins/resins_screens.dart';
import 'features/troubleshooting/troubleshooting_screens.dart';
import 'models/training_model.dart';
import 'services/api_client.dart';
import 'services/training_service.dart';
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
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 16),
            bodyMedium: TextStyle(fontSize: 14),
            bodySmall: TextStyle(fontSize: 12),
          ),
        ),
        home: const LoginPage(),
        onGenerateRoute: (settings) {
          final args = settings.arguments is PextRouteArgs
              ? settings.arguments as PextRouteArgs
              : const PextRouteArgs();
          final page = switch (settings.name) {
            PextRoutes.home => HomePage(admin: args.admin),
            PextRoutes.training => TrainingPage(admin: args.admin),
            PextRoutes.favorites => const FavoritesPage(),
            PextRoutes.dashboard =>
              args.admin ? const DashboardPage() : const HomePage(),
            PextRoutes.chat => ChatPage(admin: args.admin),
            PextRoutes.profile => ProfilePage(admin: args.admin),
            _ => const LoginPage(),
          };
          return MaterialPageRoute(builder: (_) => page, settings: settings);
        },
      );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController(text: 'admin@pext.local');
  final _password = TextEditingController(text: 'admin123');
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await ApiClient.instance.login(_email.text.trim(), _password.text);
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  HomePage(admin: ApiClient.instance.session.isAdmin)));
    } on ApiException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Could not reach ${ApiClient.baseUrl}. '
                'Check the local backend connection.')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
                FieldLabel('E-mail',
                    hint: 'admin@pext.local', controller: _email),
                const SizedBox(height: 6),
                FieldLabel('Password',
                    hint: 'Enter your password',
                    obscure: true,
                    controller: _password),
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
                  onPressed: _loading ? null : _login,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF17459A),
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('ENTRAR',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold)),
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
  final TextEditingController? controller;
  const FieldLabel(this.label,
      {super.key, required this.hint, this.obscure = false, this.controller});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: _blue, fontSize: 16)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
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
                  onTap: () => goToDestination(context, PextRoutes.training,
                      admin: admin)),
              if (admin)
                NavItem(
                    asset: PextAssets.dashboard,
                    activeAsset: PextAssets.dashboardActive,
                    text: 'Dashboard',
                    active: selected == 1,
                    onTap: () => goToDestination(context, PextRoutes.dashboard,
                        admin: true))
              else
                NavItem(
                    asset: PextAssets.heart,
                    activeAsset: PextAssets.heartActive,
                    text: 'Favoritos',
                    active: selected == 1,
                    onTap: () =>
                        goToDestination(context, PextRoutes.favorites)),
              NavItem(
                  asset: PextAssets.home,
                  activeAsset: PextAssets.homeActive,
                  text: 'Home',
                  active: selected == 2,
                  onTap: () =>
                      goToDestination(context, PextRoutes.home, admin: admin)),
              NavItem(
                  asset: PextAssets.chat,
                  activeAsset: PextAssets.chatActive,
                  text: 'Chat',
                  active: selected == 3,
                  onTap: () =>
                      goToDestination(context, PextRoutes.chat, admin: admin)),
              NavItem(
                  asset: PextAssets.profile,
                  activeAsset: PextAssets.profileActive,
                  text: 'Perfil',
                  active: selected == 4,
                  onTap: () => goToDestination(context, PextRoutes.profile,
                      admin: admin)),
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

void goToDestination(BuildContext context, String route,
        {bool admin = false}) =>
    Navigator.of(context).pushNamedAndRemoveUntil(
      route,
      (currentRoute) => false,
      arguments: PextRouteArgs(admin: admin),
    );

void _pageSafeBack(BuildContext context, {required bool admin}) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop();
    return;
  }
  goToDestination(context, PextRoutes.home, admin: admin);
}

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
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () => _confirmExit(context),
        child: AppShell(
          admin: admin,
          body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                  SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                          onPressed: () => goToDestination(
                              context, PextRoutes.dashboard,
                              admin: true),
                          child: const Text('Ver mais dashboards'))),
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
        ),
      );

  Future<bool> _confirmExit(BuildContext context) async =>
      await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
                title: const Text('Sair do aplicativo?'),
                content:
                    const Text('Você está na tela inicial administrativa.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Sair')),
                ],
              )) ??
      false;
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});
  @override
  Widget build(BuildContext context) {
    final avatarUrl = ApiClient.instance.session.avatarUrl;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: _line)),
      clipBehavior: Clip.antiAlias,
      child: (avatarUrl != null && avatarUrl.isNotEmpty)
          ? Image.network(
              ApiClient.instance.resolveMediaUrl(avatarUrl),
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.45),
              errorBuilder: (_, __, ___) => Image.asset(
                'images/profile_igor.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.45),
              ),
            )
          : Image.asset('images/profile_igor.png',
              fit: BoxFit.cover, alignment: const Alignment(0, -0.45)),
    );
  }
}

class UserProgress extends StatefulWidget {
  const UserProgress({super.key});

  @override
  State<UserProgress> createState() => _UserProgressState();
}

class _UserProgressState extends State<UserProgress> {
  int _completed = 12;
  int _inProgress = 6;
  double _pct = 0.5;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await TrainingService.instance.fetchTrainings();
      final trainings = TrainingService.instance.trainings;
      if (trainings.isNotEmpty) {
        int completed = 0;
        int inProgress = 0;
        for (final t in trainings) {
          if (t.areAllModulesCompleted || t.progressPercentage >= 1.0) {
            completed++;
          } else if (t.progressPercentage > 0.0) {
            inProgress++;
          }
        }
        final total = trainings.length;
        final pct = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
        if (mounted) {
          setState(() {
            _completed = completed;
            _inProgress = inProgress;
            _pct = pct;
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Seu progresso',
            style: TextStyle(color: _blue, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
            height: 140,
            padding: const EdgeInsets.symmetric(horizontal: 26),
            decoration: card(),
            child: LayoutBuilder(builder: (context, constraints) {
              final ringSize = constraints.maxHeight * .68;
              final pctInt = (_pct * 100).toInt();
              return Row(children: [
                SizedBox(
                    width: ringSize,
                    height: ringSize,
                    child: Stack(alignment: Alignment.center, children: [
                      Positioned.fill(
                          child: CircularProgressIndicator(
                              value: _pct,
                              strokeWidth: ringSize * .085,
                              backgroundColor: const Color(0xFFE5E7EB),
                              color: _blue)),
                      Text('$pctInt%',
                          style: TextStyle(
                              fontSize: ringSize * .20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF000000)))
                    ])),
                const SizedBox(width: 22),
                Expanded(
                    child: ProgressStat('$_completed', 'Treinamentos\nConcluídos')),
                Expanded(
                    child: ProgressStat('$_inProgress', 'Treinamentos\nem Curso')),
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
            height: 174,
            padding: const EdgeInsets.all(16),
            decoration: card(),
            child: Row(children: [
              const SizedBox(
                  width: 118,
                  height: 118,
                  child: CustomPaint(painter: _AdminDonutPainter())),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                    LegendRow(Color(0xFFF8494E), '0 Treinamentos', '12,50%'),
                    LegendRow(Color(0xFF53A7FF), '1-2 Treinamentos', '12,50%'),
                    LegendRow(Color(0xFFF1A114), '3-4 Treinamentos', '25%'),
                    LegendRow(Color(0xFF22BE62), '5-7 Treinamentos', '37,50%'),
                    LegendRow(_blue, '8+ Treinamentos', '12,50%')
                  ]))
            ])),
        const SizedBox(height: 8),
      ]);
}

class LegendRow extends StatelessWidget {
  final Color color;
  final String text, value;
  const LegendRow(this.color, this.text, this.value, {super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 7),
        Expanded(
            child: Text(text,
                style:
                    const TextStyle(fontSize: 8, fontWeight: FontWeight.w600))),
        Text(value,
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold))
      ]);
}

class _AdminDonutPainter extends CustomPainter {
  const _AdminDonutPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const values = [.125, .125, .25, .375, .125];
    const colors = [
      Color(0xFFF8494E),
      Color(0xFF53A7FF),
      Color(0xFFF1A114),
      Color(0xFF22BE62),
      _blue,
    ];
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.butt;
    var start = -math.pi / 2;
    for (var index = 0; index < values.length; index++) {
      final sweep = values[index] * math.pi * 2;
      paint.color = colors[index];
      canvas.drawArc(rect.deflate(8), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
        QuickAction(PextAssets.dashb, 'Dashboard',
            () => goToDestination(context, PextRoutes.dashboard, admin: true)),
      if (admin)
        QuickAction(PextAssets.product, 'Embalagens',
            () => go(context, const PackagingPage(admin: true))),
      if (admin)
        QuickAction(PextAssets.profile, 'Usuários',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserManagementScreen()))),
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
            child: PextAssetIcon(PextAssets.warning, size: wide ? 17 : 10)),
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
  final bool returnToHome;
  const PageFrame(
      {super.key,
      required this.title,
      required this.child,
      this.admin = false,
      this.selected = 2,
      this.returnToHome = false});
  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        _pageSafeBack(context, admin: admin);
        return false;
      },
      child: AppShell(
          admin: admin,
          selected: selected,
          body: Column(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(children: [
                  IconButton(
                      onPressed: () => _pageSafeBack(context, admin: admin),
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: _blue, size: 19)),
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
          ])));
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  int _tab = 0; // 0: Todos, 1: Resinas, 2: Treinamentos, 3: Termos
  bool _loading = true;
  List<Map<String, dynamic>> _resins = [];
  List<Map<String, dynamic>> _trainings = [];
  List<Map<String, dynamic>> _terms = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.getFavorites();
      if (mounted) {
        setState(() {
          _resins = (res['resins'] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          _trainings = (res['trainings'] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          _terms = (res['terms'] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleFavorite(String entityType, String entityId) async {
    try {
      await ApiClient.instance.toggleFavorite(entityType: entityType, entityId: entityId);
      if (mounted) {
        setState(() {
          if (entityType == 'RESIN') {
            _resins.removeWhere((r) => r['id']?.toString() == entityId);
          } else if (entityType == 'TRAINING') {
            _trainings.removeWhere((t) => t['id']?.toString() == entityId);
          } else if (entityType == 'TERM') {
            _terms.removeWhere((t) => t['id']?.toString() == entityId);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removido dos favoritos.'),
            duration: Duration(seconds: 2),
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
  Widget build(BuildContext context) {
    final showResins = (_tab == 0 || _tab == 1) && _resins.isNotEmpty;
    final showTrainings = (_tab == 0 || _tab == 2) && _trainings.isNotEmpty;
    final showTerms = (_tab == 0 || _tab == 3) && _terms.isNotEmpty;
    final hasAny = showResins || showTrainings || showTerms;

    return PageFrame(
      title: 'Favoritos',
      selected: 1,
      returnToHome: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _favFilterChip('Todos', 0),
                  const SizedBox(width: 8),
                  _favFilterChip('Resinas (${_resins.length})', 1),
                  const SizedBox(width: 8),
                  _favFilterChip('Treinamentos (${_trainings.length})', 2),
                  const SizedBox(width: 8),
                  _favFilterChip('Termos (${_terms.length})', 3),
                ],
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _blue))
                : RefreshIndicator(
                    onRefresh: _loadFavorites,
                    color: _blue,
                    child: !hasAny
                        ? ListView(
                            padding: const EdgeInsets.all(32),
                            children: [
                              const SizedBox(height: 60),
                              const Icon(Icons.favorite_border,
                                  size: 64, color: Color(0xFF9CA3AF)),
                              const SizedBox(height: 16),
                              const Center(
                                child: Text(
                                  'Nenhum favorito encontrado',
                                  style: TextStyle(
                                    color: _blue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Center(
                                child: Text(
                                  'Toque no ícone de coração em resinas, treinamentos ou termos para adicioná-los aos seus favoritos.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF6B7280), fontSize: 13),
                                ),
                              ),
                            ],
                          )
                        : ListView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            children: [
                              // Resinas Section
                              if (showResins) ...[
                                FavoriteSectionHeader(
                                    'Resinas (${_resins.length})',
                                    PextAssets.recycling),
                                ..._resins.map((r) => _DynamicFavoriteResinCard(
                                      resin: r,
                                      onUnfavorite: () => _toggleFavorite(
                                          'RESIN', r['id']?.toString() ?? ''),
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DetalhesResinaScreen(
                                              resinId: r['id']?.toString() ?? '',
                                              admin: false,
                                            ),
                                          ),
                                        );
                                        _loadFavorites();
                                      },
                                    )),
                                if (_tab == 0 && (showTrainings || showTerms))
                                  const FavoriteDivider(),
                              ],

                              // Treinamentos Section
                              if (showTrainings) ...[
                                FavoriteSectionHeader(
                                    'Treinamentos (${_trainings.length})',
                                    PextAssets.training),
                                ..._trainings.map((t) =>
                                    _DynamicFavoriteTrainingCard(
                                      training: t,
                                      onUnfavorite: () => _toggleFavorite(
                                          'TRAINING', t['id']?.toString() ?? ''),
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => TrainingDetailScreen(
                                              training:
                                                  TrainingModel.fromJson(t),
                                              admin: false,
                                            ),
                                          ),
                                        );
                                        _loadFavorites();
                                      },
                                    )),
                                if (_tab == 0 && showTerms)
                                  const FavoriteDivider(),
                              ],

                              // Termos Section
                              if (showTerms) ...[
                                FavoriteSectionHeader(
                                    'Termos (${_terms.length})',
                                    PextAssets.glossary),
                                ..._terms.map((t) => _DynamicFavoriteTermCard(
                                      term: t,
                                      onUnfavorite: () => _toggleFavorite(
                                          'TERM', t['id']?.toString() ?? ''),
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DetalhesTermoScreen(
                                              item: ApiContent(t),
                                              admin: false,
                                            ),
                                          ),
                                        );
                                        _loadFavorites();
                                      },
                                    )),
                              ],
                              const SizedBox(height: 24),
                            ],
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _favFilterChip(String label, int index) {
    final active = _tab == index;
    return InkWell(
      onTap: () => setState(() => _tab = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? _blue : const Color(0xFFD1D5DB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF4B5563),
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
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

class _DynamicFavoriteResinCard extends StatelessWidget {
  final Map<String, dynamic> resin;
  final VoidCallback onTap;
  final VoidCallback onUnfavorite;

  const _DynamicFavoriteResinCard({
    required this.resin,
    required this.onTap,
    required this.onUnfavorite,
  });

  @override
  Widget build(BuildContext context) {
    final acronym = resin['acronym']?.toString() ?? resin['name']?.toString() ?? 'RESINA';
    final fullName = resin['fullName']?.toString() ?? resin['technicalName']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF8B9099), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: PextAssetIcon(PextAssets.resin, size: 30),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      acronym,
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (fullName.isNotEmpty)
                      Text(
                        fullName,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const PextAssetIcon(PextAssets.heartActive, size: 24),
                onPressed: onUnfavorite,
                tooltip: 'Remover dos favoritos',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DynamicFavoriteTrainingCard extends StatelessWidget {
  final Map<String, dynamic> training;
  final VoidCallback onTap;
  final VoidCallback onUnfavorite;

  const _DynamicFavoriteTrainingCard({
    required this.training,
    required this.onTap,
    required this.onUnfavorite,
  });

  @override
  Widget build(BuildContext context) {
    final title = training['title']?.toString() ?? 'Treinamento';
    final modules = training['modules'] as List? ?? [];
    final completedCount = (training['completedModuleCount'] as num?)?.toInt() ??
        modules.where((m) => (m is Map && m['isCompleted'] == true)).length;
    final totalCount = modules.isNotEmpty ? modules.length : 1;
    final progress = (completedCount / totalCount).clamp(0.0, 1.0);
    final isDone = progress >= 1.0;
    final badgeText = isDone ? 'Concluído' : (progress > 0 ? 'Em curso' : 'Não iniciado');
    final badgeColor = isDone
        ? const Color(0xFF22C55E)
        : (progress > 0 ? const Color(0xFFF59E0B) : const Color(0xFF6B7280));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'images/training_extrusion.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
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
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        StatusPill(badgeText, badgeColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedCount de $totalCount módulos concluídos',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 5,
                              color: _blue,
                              backgroundColor: const Color(0xFFE5E7EB),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: _blue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const PextAssetIcon(PextAssets.heartActive, size: 22),
                onPressed: onUnfavorite,
                tooltip: 'Remover dos favoritos',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DynamicFavoriteTermCard extends StatelessWidget {
  final Map<String, dynamic> term;
  final VoidCallback onTap;
  final VoidCallback onUnfavorite;

  const _DynamicFavoriteTermCard({
    required this.term,
    required this.onTap,
    required this.onUnfavorite,
  });

  @override
  Widget build(BuildContext context) {
    final termName = term['term']?.toString() ?? term['title']?.toString() ?? 'Termo';
    final initial = termName.isNotEmpty ? termName.substring(0, 1).toUpperCase() : 'T';
    final definition = term['definition']?.toString() ?? term['text']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  border: Border.all(color: const Color(0xFF93C5FD), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      termName,
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (definition.isNotEmpty)
                      Text(
                        definition,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const PextAssetIcon(PextAssets.heartActive, size: 22),
                onPressed: onUnfavorite,
                tooltip: 'Remover dos favoritos',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoriteDivider extends StatelessWidget {
  const FavoriteDivider({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)));
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
  final bool admin;
  const PackagingPage({super.key, this.admin = false});
  @override
  Widget build(BuildContext context) => PackagingListScreen(admin: admin);
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

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => PageFrame(
        title: 'Dashboards',
        admin: true,
        selected: 1,
        child: ListView(padding: const EdgeInsets.all(18), children: [
          _DashboardTabs(
              value: _tab, onChanged: (value) => setState(() => _tab = value)),
          const SizedBox(height: 16),
          switch (_tab) {
            0 => const _DashboardOverview(),
            1 => const _DashboardProblems(),
            2 => const _DashboardTraining(),
            _ => const _DashboardAssistant(),
          },
        ]),
      );
}

class _DashboardTabs extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _DashboardTabs({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const labels = [
      'Visão Geral',
      'Problemas',
      'Treinamentos',
      'Assistente IA'
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          labels.length,
          (index) => Padding(
            padding: EdgeInsets.only(right: index == labels.length - 1 ? 0 : 8),
            child: OutlinedButton(
              onPressed: () => onChanged(index),
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                side: BorderSide(
                    color: index == value
                        ? const Color(0xFF4A9FFF)
                        : const Color(0xFFB8C0CC)),
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: Text(labels[index],
                  style: TextStyle(
                      fontWeight:
                          index == value ? FontWeight.bold : FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview();

  @override
  Widget build(BuildContext context) => const Column(children: [
        _DashboardMetricGrid(metrics: [
          _DashboardMetric(
              'Problemas Reportados', '128', '8,3%', Color(0xFF0B4AA0), true),
          _DashboardMetric(
              'Solicitações de Ajuda', '32', '12,3%', Color(0xFFD93838), false),
          _DashboardMetric('Resolução pelo Sistema', '75,8%', '2%',
              Color(0xFF1CBF66), false),
          _DashboardMetric('Dúvidas não respondidas (IA)', '13', '8,3%',
              Color(0xFFF2A400), true),
          _DashboardMetric(
              'Treinamentos Concluídos', '36', '5,7%', Color(0xFF8B32EC), true),
          _DashboardMetric(
              'Aprovação Média', '78,3%', '2,1%', Color(0xFF1698EA), true),
        ]),
        SizedBox(height: 20),
        _DashboardSectionTitle('Evolução Geral'),
        SizedBox(height: 10),
        _LegendRow(),
        SizedBox(height: 12),
        _DashboardChart(height: 210, lines: [
          _ChartLine(
              Color(0xFFD93838), [57, 61, 55, 60, 56, 59, 73, 65, 62, 73, 66]),
          _ChartLine(
              Color(0xFF1768DF), [36, 36, 30, 34, 38, 40, 50, 44, 33, 45, 41]),
          _ChartLine(
              Color(0xFF14A957), [17, 25, 26, 26, 25, 28, 34, 28, 31, 28, 25]),
        ]),
      ]);
}

class _DashboardProblems extends StatelessWidget {
  const _DashboardProblems();

  @override
  Widget build(BuildContext context) => const Column(children: [
        _DashboardMetricGrid(compact: true, metrics: [
          _DashboardMetric(
              'Total de Problemas', '128', '8,3%', Color(0xFF0B4AA0), true),
          _DashboardMetric(
              'Resolvidos pelo Sistema', '97', '2%', Color(0xFF1CBF66), false),
          _DashboardMetric(
              'Encaminhados ao ADM', '32', '1,3%', Color(0xFFD93838), true),
        ]),
        SizedBox(height: 20),
        _DashboardSectionTitle('Problemas por categoria'),
        SizedBox(height: 10),
        _DashboardDonutCard(),
        SizedBox(height: 20),
        _DashboardSectionTitle('Problemas por produto'),
        SizedBox(height: 10),
        _DashboardProgressCard(items: [
          ('RAP10', 46),
          ('Macarrão Instantâneo', 26),
          ('Marcas de gel', 15),
          ('Iorgute', 32),
          ('Saco Pão Pulma', 63),
        ]),
        SizedBox(height: 20),
        _DashboardSectionTitle('Problemas ao longo do tempo'),
        SizedBox(height: 10),
        _DashboardChart(height: 160, lines: [
          _ChartLine(Color(0xFF1768DF),
              [16, 39, 30, 33, 43, 23, 40, 54, 24, 38, 49, 47])
        ]),
        SizedBox(height: 20),
        _DashboardSectionTitle('Solicitações'),
        SizedBox(height: 10),
        _DashboardMetricGrid(compact: true, metrics: [
          _DashboardMetric(
              'Total de Solicitações', '128', '8,3%', Color(0xFF0B4AA0), true),
          _DashboardMetric('Novas', '32', '1,3%', Color(0xFF1768DF), true),
          _DashboardMetric(
              'Em andamento', '32', '1,3%', Color(0xFFF2A400), true),
          _DashboardMetric('Concluídas', '32', '1,3%', Color(0xFF1CBF66), true),
        ]),
        SizedBox(height: 20),
        _DashboardSectionTitle('Solicitações por Status'),
        SizedBox(height: 10),
        _DashboardStatusDonutCard(),
        SizedBox(height: 20),
        _DashboardSectionTitle('Tempo Médio até a Conclusão'),
        SizedBox(height: 10),
        _DashboardTimeCard(),
        SizedBox(height: 20),
        _DashboardSectionTitle('Problemas que geram mais solicitações'),
        SizedBox(height: 10),
        _DashboardProgressCard(items: [
          ('Variação na espessura', 46),
          ('Bolhas no filme', 20),
          ('Marcas de gel', 15),
          ('Linhas na superfície do filme', 32),
          ('Fusão irregular do filme', 63),
        ]),
        SizedBox(height: 20),
        Row(children: [
          Expanded(
              child: _DashboardMetricCard(
                  compact: true,
                  metric: _DashboardMetric('Soluções Exibidas', '128', '8,3%',
                      Color(0xFF0B4AA0), true))),
          SizedBox(width: 10),
          Expanded(
              child: _DashboardMetricCard(
                  compact: true,
                  metric: _DashboardMetric('Taxa de sucesso', '82,3%', '2%',
                      Color(0xFF1CBF66), true))),
        ]),
        SizedBox(height: 20),
        _DashboardSectionTitle('Taxa de sucesso das soluções'),
        SizedBox(height: 10),
        _DashboardProgressCard(valueSuffix: '%', items: [
          ('Ajuste na Temperatura', 92),
          ('Ajuste de velocidade', 82),
          ('Verificar Resfriamento', 80),
          ('Ajuste na Composição', 70),
          ('Limpeza de Matriz', 62),
        ]),
      ]);
}

class _DashboardTraining extends StatefulWidget {
  const _DashboardTraining();

  @override
  State<_DashboardTraining> createState() => _DashboardTrainingState();
}

class _DashboardTrainingState extends State<_DashboardTraining> {
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.instance.getTrainingAnalytics();
      if (mounted) setState(() { _stats = res; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalTrainings = _stats['totalTrainings'] ?? 128;
    final inProgress = _stats['trainingsInProgress'] ?? 97;
    final finished = _stats['trainingsFinished'] ?? 32;
    final dropoutRate = (_stats['dropoutRate'] as num?)?.toDouble() ?? 12.5;
    final failureRate = (_stats['failureRate'] as num?)?.toDouble() ?? 23.4;
    final approvedPct = (100.0 - failureRate).round().clamp(0, 100);
    final reprovedPct = failureRate.round().clamp(0, 100);
    final avgScore = (_stats['averageAssessmentScore'] as num?)?.toDouble() ?? 76.6;

    final rankings = _stats['courseRankings'] as List? ?? [
      {'name': 'Processo de extrusão', 'percentage': 38},
      {'name': 'Segurança Operacional', 'percentage': 26},
      {'name': 'Boas Práticas de Produção', 'percentage': 18},
      {'name': 'Controle Térmico', 'percentage': 12},
      {'name': 'Regulagem de Matriz', 'percentage': 8},
    ];

    final progressItems = rankings.map<(String, int)>((r) {
      final map = Map<String, dynamic>.from(r as Map);
      return (map['name']?.toString() ?? 'Curso', (map['percentage'] as num?)?.toInt() ?? 20);
    }).toList();

    return Column(children: [
      _DashboardMetricGrid(compact: true, metrics: [
        _DashboardMetric('Total Treinamentos', '$totalTrainings', '8,3%', const Color(0xFF0B4AA0), true),
        _DashboardMetric('Em andamento', '$inProgress', '2%', const Color(0xFFF2A400), false),
        _DashboardMetric('Concluídos', '$finished', '1,3%', const Color(0xFF1CBF66), true),
        _DashboardMetric('Taxa Desistência', '${dropoutRate.toStringAsFixed(1)}%', '1,1%', const Color(0xFFD93838), false),
      ]),
      const SizedBox(height: 20),
      const _DashboardSectionTitle('Ranking de Cursos (Maior Desistência / Reprovação)'),
      const SizedBox(height: 10),
      _DashboardProgressCard(items: progressItems),
      const SizedBox(height: 20),
      const _DashboardSectionTitle('Taxa de Aprovação vs Reprovação'),
      const SizedBox(height: 10),
      _DashboardDonutCard(
        customEntries: [
          ('Aprovados', approvedPct, const Color(0xFF1CBF66)),
          ('Reprovados', reprovedPct, const Color(0xFFD93838)),
        ],
      ),
      const SizedBox(height: 20),
      const _DashboardSectionTitle('Situação dos usuários'),
      const SizedBox(height: 10),
      const _DashboardDonutCard(training: true),
      const SizedBox(height: 20),
      const _DashboardSectionTitle('Média de Acertos nas Avaliações'),
      const SizedBox(height: 10),
      _DashboardApprovalCard(score: '${avgScore.toStringAsFixed(1)}%'),
    ]);
  }
}

class _DashboardAssistant extends StatelessWidget {
  const _DashboardAssistant();

  @override
  Widget build(BuildContext context) => const Column(children: [
        _DashboardMetricGrid(compact: true, metrics: [
          _DashboardMetric('Conversas', '256', '8,3%', Color(0xFF0B4AA0), true),
          _DashboardMetric(
              'Dúvidas respondidas', '97', '2%', Color(0xFF1CBF66), false),
          _DashboardMetric(
              'Dúvidas não respondidas', '32', '1,3%', Color(0xFFD93838), true),
        ]),
        SizedBox(height: 20),
        _DashboardSectionTitle('Dúvidas não respondidas'),
        SizedBox(height: 10),
        _DashboardProgressCard(items: [
          ('Polímeros', 46),
          ('Matriz', 26),
          ('Processo de Extrusão', 15),
          ('Resfriamento', 32),
          ('Outros', 63),
        ]),
        SizedBox(height: 20),
        _DashboardSectionTitle('Conteúdos cadastrados'),
        SizedBox(height: 10),
        _DashboardMetricGrid(compact: true, metrics: [
          _DashboardMetric(
              'Total de conteúdos', '256', '8,3%', Color(0xFF0B4AA0), true),
          _DashboardMetric('Atualizados', '97', '2%', Color(0xFF1CBF66), false),
          _DashboardMetric('Novos', '32', '1,3%', Color(0xFFD93838), true),
        ]),
        SizedBox(height: 20),
        _DashboardSectionTitle('Interações com IA'),
        SizedBox(height: 10),
        _DashboardChart(height: 210, lines: [
          _ChartLine(Color(0xFF1768DF),
              [35, 36, 64, 61, 76, 68, 60, 95, 89, 105, 100, 118, 128])
        ]),
      ]);
}

class _DashboardMetric {
  final String title, value, trend;
  final Color color;
  final bool positive;
  const _DashboardMetric(
      this.title, this.value, this.trend, this.color, this.positive);
}

class _DashboardMetricGrid extends StatelessWidget {
  final List<_DashboardMetric> metrics;
  final bool compact;
  const _DashboardMetricGrid({required this.metrics, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact && metrics.length <= 3)
      return Row(
          children: metrics
              .map((metric) => Expanded(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child:
                          _DashboardMetricCard(metric: metric, compact: true))))
              .toList());
    return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: metrics
            .map((metric) => SizedBox(
                width: (MediaQuery.sizeOf(context).width - 60) / 2,
                child: _DashboardMetricCard(metric: metric)))
            .toList());
  }
}

class _DashboardMetricCard extends StatelessWidget {
  final _DashboardMetric metric;
  final bool compact;
  const _DashboardMetricCard({required this.metric, this.compact = false});
  @override
  Widget build(BuildContext context) => Container(
        height: compact ? 126 : 145,
        padding: EdgeInsets.all(compact ? 11 : 14),
        decoration: card(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(metric.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: metric.color,
                  fontSize: compact ? 10 : 12,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(metric.value,
              style: TextStyle(
                  fontSize: compact ? 31 : 38,
                  height: 1,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333946))),
          const SizedBox(height: 7),
          Row(children: [
            Icon(metric.positive ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                color: metric.positive
                    ? const Color(0xFF1CBF66)
                    : const Color(0xFFD93838),
                size: 21),
            Text(metric.trend,
                style: TextStyle(
                    color: metric.positive
                        ? const Color(0xFF1CBF66)
                        : const Color(0xFFD93838),
                    fontWeight: FontWeight.bold,
                    fontSize: compact ? 10 : 12))
          ]),
          Text('vs 30 dias ant.',
              style: TextStyle(
                  color: const Color(0xFF7A8290), fontSize: compact ? 8 : 10)),
        ]),
      );
}

class _DashboardSectionTitle extends StatelessWidget {
  final String value;
  const _DashboardSectionTitle(this.value);
  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.centerLeft,
      child: Text(value,
          style: const TextStyle(
              color: _blue, fontSize: 19, fontWeight: FontWeight.bold)));
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();
  @override
  Widget build(BuildContext context) =>
      const Wrap(spacing: 13, runSpacing: 6, children: [
        _LegendItem('Solicitação de ajuda', Color(0xFFD93838)),
        _LegendItem('Problemas reportados', Color(0xFF1768DF)),
        _LegendItem('Resolução pelo sistema', Color(0xFF14A957)),
      ]);
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendItem(this.label, this.color);
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))
      ]);
}

class _DashboardChart extends StatelessWidget {
  final double height;
  final List<_ChartLine> lines;
  const _DashboardChart({required this.height, required this.lines});
  @override
  Widget build(BuildContext context) => Container(
      height: height,
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.fromLTRB(10, 24, 6, 8),
      decoration: card(),
      child: CustomPaint(
          painter: _LineChartPainter(lines), child: const SizedBox.expand()));
}

class _ChartLine {
  final Color color;
  final List<double> values;
  const _ChartLine(this.color, this.values);
}

class _LineChartPainter extends CustomPainter {
  final List<_ChartLine> lines;
  _LineChartPainter(this.lines);
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFE5E8ED)
      ..strokeWidth = 1;
    for (var i = 1; i < 5; i++)
      canvas.drawLine(Offset(0, size.height * i / 5),
          Offset(size.width, size.height * i / 5), grid);
    final highest = lines
        .expand((line) => line.values)
        .fold<double>(0, (current, value) => math.max(current, value));
    final maxY = highest == 0 ? 1.0 : highest * 1.15;
    for (final line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      final path = Path();
      for (var i = 0; i < line.values.length; i++) {
        final point = Offset(size.width * i / (line.values.length - 1),
            size.height - (line.values[i] / maxY * (size.height - 10)) - 5);
        if (i == 0)
          path.moveTo(point.dx, point.dy);
        else
          path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
      final dots = Paint()..color = line.color;
      for (var i = 0; i < line.values.length; i++)
        canvas.drawCircle(
            Offset(size.width * i / (line.values.length - 1),
                size.height - (line.values[i] / maxY * (size.height - 10)) - 5),
            3.5,
            dots);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.lines != lines;
}

class _DashboardProgressCard extends StatelessWidget {
  final List<(String, int)> items;
  final String valueSuffix;
  const _DashboardProgressCard({required this.items, this.valueSuffix = ''});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: card(),
      child: Column(
          children: items
              .map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Expanded(
                        flex: 4,
                        child: Text(item.$1,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600))),
                    Expanded(
                        flex: 5,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                                value:
                                    item.$2 / (valueSuffix.isEmpty ? 70 : 100),
                                minHeight: 7,
                                color: _blue,
                                backgroundColor: const Color(0xFFE4E7EC)))),
                    const SizedBox(width: 14),
                    SizedBox(
                        width: 22,
                        child: Text('${item.$2}$valueSuffix',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)))
                  ])))
              .toList()));
}

class _DashboardStatusDonutCard extends StatelessWidget {
  const _DashboardStatusDonutCard();

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: card(),
      child: const Row(children: [
        SizedBox(
            width: 125,
            height: 125,
            child: CustomPaint(
                painter: _DonutPainter([
              (25.0, Color(0xFF2E7CF6)),
              (50.0, Color(0xFF1CBF66)),
              (25.0, Color(0xFFFFC107)),
            ]))),
        SizedBox(width: 14),
        Expanded(
            child: Column(children: [
          _StatusLegend('Novas', '25%', Color(0xFF2E7CF6)),
          _StatusLegend('Em andamento', '50%', Color(0xFF1CBF66)),
          _StatusLegend('Concluídas', '25%', Color(0xFFFFC107)),
        ]))
      ]));
}

class _StatusLegend extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatusLegend(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600))),
        Text(value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ]));
}

class _DashboardTimeCard extends StatelessWidget {
  const _DashboardTimeCard();
  @override
  Widget build(BuildContext context) => Container(
      height: 136,
      padding: const EdgeInsets.all(16),
      decoration: card(),
      child: const Row(children: [
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Text('2h 45m',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              SizedBox(height: 7),
              Row(children: [
                Icon(Icons.arrow_drop_down, color: Color(0xFF1CBF66)),
                Text('8,3%',
                    style: TextStyle(
                        color: Color(0xFF1CBF66), fontWeight: FontWeight.bold)),
                SizedBox(width: 6),
                Text('vs 30 dias ant.',
                    style: TextStyle(fontSize: 9, color: Color(0xFF7A8290))),
              ])
            ])),
        Expanded(
            child: _DashboardChart(height: 88, lines: [
          _ChartLine(Color(0xFF1768DF), [15, 30, 45, 34, 37, 35, 56, 46])
        ]))
      ]));
}

class _DashboardDonutCard extends StatelessWidget {
  final bool training;
  final List<(String, int, Color)>? customEntries;
  const _DashboardDonutCard({this.training = false, this.customEntries});
  @override
  Widget build(BuildContext context) {
    final entries = customEntries ??
        (training
            ? const [
                ('Concluídos', 45, Color(0xFF2E7CF6)),
                ('Em andamento', 30, Color(0xFF1CBF66)),
                ('Não iniciados', 25, Color(0xFFFFC107))
              ]
            : const [
                ('Variação na espessura', 38, Color(0xFF1768DF)),
                ('Bolhas no filme', 22, Color(0xFF4AA5ED)),
                ('Marcas de gel', 15, Color(0xFFFFC107)),
                ('Linhas na superfície', 10, Color(0xFFD93838)),
                ('Fusão irregular', 8, Color(0xFF9564E8)),
                ('Outros', 6, Color(0xFF1CBF66))
              ]);
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: card(),
        child: Row(children: [
          SizedBox(
              width: 125,
              height: 125,
              child: CustomPaint(
                  painter: _DonutPainter(entries
                      .map((entry) => (entry.$2.toDouble(), entry.$3))
                      .toList()))),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  children: entries
                      .map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(children: [
                            Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: entry.$3, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Expanded(
                                child: Text(entry.$1,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600))),
                            Text('${entry.$2}%',
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold))
                          ])))
                      .toList()))
        ]));
  }
}

class _DonutPainter extends CustomPainter {
  final List<(double, Color)> values;
  const _DonutPainter(this.values);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    var start = -math.pi / 2;
    final total = values.fold<double>(0, (sum, item) => sum + item.$1);
    for (final value in values) {
      final sweep = value.$1 / (total > 0 ? total : 1) * math.pi * 2;
      canvas.drawArc(
          rect.deflate(8), start, sweep, true, Paint()..color = value.$2);
      start += sweep;
    }
    canvas.drawCircle(size.center(Offset.zero), size.width * .24,
        Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _DashboardApprovalCard extends StatelessWidget {
  final String score;
  const _DashboardApprovalCard({this.score = '76,6%'});
  @override
  Widget build(BuildContext context) => Container(
      height: 135,
      padding: const EdgeInsets.all(16),
      decoration: card(),
      child: Row(children: [
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Text(score,
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: _blue)),
              const Row(children: [
                Icon(Icons.arrow_drop_up, color: Color(0xFF1CBF66)),
                Text('8,3%',
                    style: TextStyle(
                        color: Color(0xFF1CBF66), fontWeight: FontWeight.bold)),
                SizedBox(width: 6),
                Text('vs 30 dias ant.',
                    style: TextStyle(fontSize: 9, color: Color(0xFF7A8290)))
              ])
            ])),
        const Expanded(
            child: _DashboardChart(height: 88, lines: [
          _ChartLine(Color(0xFF1768DF), [25, 52, 76, 49, 63, 90, 58])
        ]))
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
