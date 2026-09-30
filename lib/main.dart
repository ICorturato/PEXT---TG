import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'app_routes.dart';
import 'features/admin/admin_user_screens.dart';
import 'features/core/core_screens.dart';
import 'features/dashboard/dashboards_screen.dart';
import 'features/resins/resins_screens.dart';
import 'features/troubleshooting/troubleshooting_screens.dart';
import 'models/training_model.dart';
import 'services/api_client.dart';
import 'services/favorites_service.dart';
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
      FavoritesService.instance.loadFavorites();
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
                if (!admin) const UserTrainingSection(),
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

typedef _HomeTrainingFavoriteIcon = HomeTrainingFavoriteIcon;

class HomeTrainingFavoriteIcon extends StatelessWidget {
  final String trainingId;
  const HomeTrainingFavoriteIcon({super.key, required this.trainingId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FavoritesService.instance,
      builder: (context, _) {
        final isFav = FavoritesService.instance.isFavorited(trainingId);
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: InkWell(
            onTap: () => FavoritesService.instance.toggleFavorite(
              entityType: 'TRAINING',
              entityId: trainingId,
            ),
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? const Color(0xFFEF4444) : _blue,
              size: 16,
            ),
          ),
        );
      },
    );
  }
}

class UserTrainingSection extends StatefulWidget {
  const UserTrainingSection({super.key});

  @override
  State<UserTrainingSection> createState() => _UserTrainingSectionState();
}

class _UserTrainingSectionState extends State<UserTrainingSection> {
  @override
  void initState() {
    super.initState();
    TrainingService.instance.fetchTrainings();
    FavoritesService.instance.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TrainingService.instance,
      builder: (context, _) {
        final service = TrainingService.instance;
        final inProgress = service.inProgressTrainings;
        final readyForExam = service.readyForAssessmentTrainings;
        final dropped = service.droppedTrainings;
        final available = service.availableTrainings;

        if (inProgress.isEmpty && readyForExam.isEmpty && dropped.isEmpty && available.isEmpty) {
          if (service.isLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('Continue treinando'),
              TrainingCard(inProgress: true),
              SectionTitle('Refaça o teste'),
              TrainingCard(inProgress: false),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Em andamento ("Continue treinando")
            if (inProgress.isNotEmpty) ...[
              const SectionTitle('Continue treinando'),
              ...inProgress.map((t) => _ActionTrainingCard(
                    training: t,
                    statusLabel: 'Em curso',
                    statusColor: const Color(0xFFF59E0B),
                    subtitle: t.nextIncompleteModule != null
                        ? 'Módulo ${t.nextIncompleteModule!.order} - ${t.nextIncompleteModule!.title}'
                        : 'Módulo em andamento',
                    actionLabel: 'CONTINUAR',
                    actionColor: _blue,
                    onAction: () {
                      final mod = t.nextIncompleteModule ?? (t.modules.isNotEmpty ? t.modules.first : null);
                      if (mod != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonDetailScreen(
                              admin: false,
                              module: mod,
                              training: t,
                            ),
                          ),
                        ).then((_) => TrainingService.instance.fetchTrainings());
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrainingDetailScreen(training: t),
                          ),
                        ).then((_) => TrainingService.instance.fetchTrainings());
                      }
                    },
                  )),
            ],

            // 2. Aguardando Avaliação (100% módulos concluídos)
            if (readyForExam.isNotEmpty) ...[
              const SectionTitle('Aguardando Avaliação'),
              ...readyForExam.map((t) => _ActionTrainingCard(
                    training: t,
                    statusLabel: '100% Concluído',
                    statusColor: const Color(0xFF22C55E),
                    subtitle: 'Todos os módulos foram concluídos! Faça sua prova final.',
                    actionLabel: 'FAZER AVALIAÇÃO',
                    actionColor: const Color(0xFF0B4AA0),
                    onAction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExamScreen(training: t),
                        ),
                      ).then((_) => TrainingService.instance.fetchTrainings());
                    },
                  )),
            ],

            // 3. Desistência ("Treinamentos Interrompidos")
            if (dropped.isNotEmpty) ...[
              const SectionTitle('Treinamentos Interrompidos'),
              ...dropped.map((t) => _ActionTrainingCard(
                    training: t,
                    statusLabel: 'Desistência',
                    statusColor: const Color(0xFFF04444),
                    subtitle: 'Você interrompeu este curso. Retome seus estudos de onde parou.',
                    actionLabel: 'RETOMAR CURSO',
                    actionColor: const Color(0xFFD93838),
                    onAction: () async {
                      await TrainingService.instance.enroll(t.id);
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrainingDetailScreen(training: t),
                          ),
                        ).then((_) => TrainingService.instance.fetchTrainings());
                      }
                    },
                  )),
            ],

            // 4. Novos Treinamentos disponíveis
            if (available.isNotEmpty) ...[
              const SectionTitle('Novos Treinamentos'),
              ...available.take(3).map((t) => _ActionTrainingCard(
                    training: t,
                    statusLabel: 'Disponível',
                    statusColor: _blue,
                    subtitle: '${t.modules.length} Módulos  •  ${t.workload ?? 'Carga Flexível'}',
                    actionLabel: 'INSCREVER-SE',
                    actionColor: _blue,
                    onAction: () async {
                      await TrainingService.instance.enroll(t.id);
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrainingDetailScreen(training: t),
                          ),
                        ).then((_) => TrainingService.instance.fetchTrainings());
                      }
                    },
                  )),
            ],
          ],
        );
      },
    );
  }
}

class _ActionTrainingCard extends StatelessWidget {
  final TrainingModel training;
  final String statusLabel;
  final Color statusColor;
  final String subtitle;
  final String actionLabel;
  final Color actionColor;
  final VoidCallback onAction;

  const _ActionTrainingCard({
    required this.training,
    required this.statusLabel,
    required this.statusColor,
    required this.subtitle,
    required this.actionLabel,
    required this.actionColor,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 540;
      final coverSize = wide ? 190.0 : 66.0;
      final titleSize = wide ? 29.0 : 13.0;
      final bodySize = wide ? 17.0 : 8.0;
      final padding = wide ? 36.0 : 10.0;
      final progress = training.progressPercentage;
      final pctStr = '${(progress * 100).toInt()}%';

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _line, width: wide ? 3 : 1),
          borderRadius: BorderRadius.circular(wide ? 30 : 11),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(wide ? 30 : 9),
              child: Image.asset(
                'images/training_extrusion.png',
                width: coverSize,
                height: coverSize,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: wide ? 30 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          training.title.isNotEmpty ? training.title : 'Treinamento',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _blue,
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (training.id.isNotEmpty)
                        _HomeTrainingFavoriteIcon(trainingId: training.id),
                      StatusPill(statusLabel, statusColor, fontSize: wide ? 16 : 7),
                    ],
                  ),
                  SizedBox(height: wide ? 7 : 2),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: bodySize,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: wide ? 25 : 7),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          color: _blue,
                          backgroundColor: const Color(0xFFE5E7EB),
                          minHeight: wide ? 16 : 5,
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      SizedBox(width: wide ? 10 : 6),
                      Text(
                        pctStr,
                        style: TextStyle(
                          color: _blue,
                          fontSize: wide ? 29 : 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: wide ? 22 : 6),
                      SizedBox(
                        height: wide ? 52 : 22,
                        child: FilledButton(
                          onPressed: onAction,
                          style: FilledButton.styleFrom(
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.symmetric(horizontal: wide ? 14 : 7),
                            backgroundColor: actionColor,
                          ),
                          child: Text(
                            actionLabel,
                            style: TextStyle(
                              fontSize: wide ? 16 : 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: wide ? 14 : 6),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrainingDetailScreen(training: training),
                  ),
                ).then((_) => TrainingService.instance.fetchTrainings());
              },
              child: Icon(Icons.chevron_right, color: _blue, size: wide ? 36 : 18),
            ),
          ],
        ),
      );
    });
  }
}

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

  @override
  void initState() {
    super.initState();
    FavoritesService.instance.loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await FavoritesService.instance.loadFavorites();
  }

  Future<void> _toggleFavorite(String entityType, String entityId) async {
    try {
      await FavoritesService.instance.toggleFavorite(
        entityType: entityType,
        entityId: entityId,
      );
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
    return ListenableBuilder(
      listenable: FavoritesService.instance,
      builder: (context, _) {
        final resins = FavoritesService.instance.resins;
        final trainings = FavoritesService.instance.trainings;
        final terms = FavoritesService.instance.terms;
        final loading = FavoritesService.instance.isLoading;

        final showResins = (_tab == 0 || _tab == 1) && resins.isNotEmpty;
        final showTrainings = (_tab == 0 || _tab == 2) && trainings.isNotEmpty;
        final showTerms = (_tab == 0 || _tab == 3) && terms.isNotEmpty;
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
                      _favFilterChip('Resinas (${resins.length})', 1),
                      const SizedBox(width: 8),
                      _favFilterChip('Treinamentos (${trainings.length})', 2),
                      const SizedBox(width: 8),
                      _favFilterChip('Termos (${terms.length})', 3),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: loading && !hasAny
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
                                        'Resinas (${resins.length})',
                                        PextAssets.recycling),
                                    ...resins.map((r) => _DynamicFavoriteResinCard(
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
                                        'Treinamentos (${trainings.length})',
                                        PextAssets.training),
                                    ...trainings.map((t) =>
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
                                        'Termos (${terms.length})',
                                        PextAssets.glossary),
                                    ...terms.map((t) => _DynamicFavoriteTermCard(
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
      },
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

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => const PageFrame(
        title: 'Dashboards',
        admin: true,
        selected: 1,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(18),
          child: DashboardsScreen(),
        ),
      );
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
