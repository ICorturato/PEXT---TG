import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import '../../widgets/pext_asset_icon.dart';

const _blue = Color(0xFF053488);
const _canvas = Color(0xFFF6F8FB);
const _border = Color(0xFFE5E7EB);

BoxDecoration _card() => BoxDecoration(
      color: Colors.white,
      border: Border.all(color: _border),
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final list = await ApiClient.instance.getAdminUsers();
      if (mounted) {
        setState(() {
          _users = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar usuários: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _openNewUserModal() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NewUserModal(),
    );
    if (created == true && mounted) {
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _users.where((u) {
      final name = (u['name'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      final cargo = (u['cargo'] ?? u['jobTitle'] ?? '').toString().toLowerCase();
      final q = _searchQuery.toLowerCase().trim();
      return name.contains(q) || email.contains(q) || cargo.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        surfaceTintColor: _canvas,
        centerTitle: true,
        title: const Text(
          'Gestão de Usuários',
          style: TextStyle(
            color: _blue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _openNewUserModal,
            icon: const Icon(Icons.add, size: 18, color: _blue),
            label: const Text(
              'NOVO USUÁRIO',
              style: TextStyle(
                color: _blue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _blue))
          : RefreshIndicator(
              onRefresh: _loadUsers,
              color: _blue,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Search Bar
                  Container(
                    decoration: _card(),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                            decoration: const InputDecoration(
                              hintText: 'Buscar por nome, e-mail ou cargo...',
                              hintStyle: TextStyle(
                                  fontSize: 13, color: Color(0xFF9CA3AF)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header with Count and Action
                  // Header with Count
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Usuários Cadastrados (${filtered.length})',
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // User Catalog
                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: _card(),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_outline,
                              size: 48, color: Color(0xFF9CA3AF)),
                          const SizedBox(height: 12),
                          const Text(
                            'Nenhum usuário encontrado',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Cadastre novos operadores ou administradores.',
                            style: TextStyle(
                                color: Color(0xFF9CA3AF), fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(backgroundColor: _blue),
                            onPressed: _openNewUserModal,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Cadastrar Usuário'),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filtered.map((user) => _UserCatalogCard(
                          user: user,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminUserDetailScreen(
                                  userId: user['id']?.toString() ?? '',
                                  initialData: user,
                                ),
                              ),
                            );
                            _loadUsers();
                          },
                        )),
                ],
              ),
            ),
    );
  }
}

class _UserCatalogCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;

  const _UserCatalogCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = user['name']?.toString() ?? 'Usuário';
    final email = user['email']?.toString() ?? '';
    final cargo = user['cargo'] ?? user['jobTitle'] ?? 'Operador';
    final role = user['role']?.toString() ?? 'USER';
    final isAdmin = role == 'ADMIN';
    final avatarUrl = user['avatarUrl']?.toString();
    final stats = user['stats'] is Map ? user['stats'] as Map : null;
    final totalEnrolled = stats?['totalEnrolled'] ?? 0;
    final completedCount = stats?['completedCount'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _card(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 26,
                  backgroundColor: _blue.withOpacity(0.1),
                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(ApiClient.instance.mediaUrl(avatarUrl))
                      : const AssetImage('images/profile_igor.png')
                          as ImageProvider,
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: _blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isAdmin
                                  ? const Color(0xFFFEE2E2)
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isAdmin ? 'ADMIN' : 'OPERADOR',
                              style: TextStyle(
                                color: isAdmin
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF2563EB),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cargo,
                        style: const TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11,
                        ),
                      ),
                      if (stats != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.school_outlined,
                                size: 14, color: _blue),
                            const SizedBox(width: 4),
                            Text(
                              '$completedCount de $totalEnrolled treinamentos concluídos',
                              style: const TextStyle(
                                fontSize: 10,
                                color: _blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewUserModal extends StatefulWidget {
  const _NewUserModal();

  @override
  State<_NewUserModal> createState() => _NewUserModalState();
}

class _NewUserModalState extends State<_NewUserModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cargoController = TextEditingController(text: 'Operador de Extrusão');
  String _role = 'USER';
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ApiClient.instance.createAdminUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        cargo: _cargoController.text.trim().isNotEmpty
            ? _cargoController.text.trim()
            : null,
        role: _role,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Usuário "${_nameController.text.trim()}" cadastrado com sucesso!'),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar usuário: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
              const Text(
                'Cadastrar Novo Usuário',
                style: TextStyle(
                  color: _blue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Preencha as informações do operador ou administrador.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Nome Completo
              TextFormField(
                controller: _nameController,
                decoration: _inputDeco('Nome Completo *', Icons.person_outline),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Informe o nome completo'
                    : null,
              ),
              const SizedBox(height: 12),

              // E-mail
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDeco('E-mail *', Icons.email_outlined),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Informe o e-mail';
                  if (!val.contains('@')) return 'E-mail inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Senha Inicial
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration:
                    _inputDeco('Senha Inicial *', Icons.lock_outline),
                validator: (val) => val == null || val.length < 4
                    ? 'Mínimo de 4 caracteres'
                    : null,
              ),
              const SizedBox(height: 12),

              // Telefone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration:
                    _inputDeco('Telefone (opcional)', Icons.phone_outlined),
              ),
              const SizedBox(height: 12),

              // Endereço
              TextFormField(
                controller: _addressController,
                decoration: _inputDeco(
                    'Endereço (opcional)', Icons.location_on_outlined),
              ),
              const SizedBox(height: 12),

              // Função / Cargo
              TextFormField(
                controller: _cargoController,
                decoration:
                    _inputDeco('Função / Cargo', Icons.badge_outlined),
              ),
              const SizedBox(height: 12),

              // Perfil de Acesso
              DropdownButtonFormField<String>(
                value: _role,
                decoration: _inputDeco('Nível de Permissão', Icons.security),
                items: const [
                  DropdownMenuItem(value: 'USER', child: Text('Operador')),
                  DropdownMenuItem(value: 'ADMIN', child: Text('Administrador')),
                ],
                onChanged: (val) => setState(() => _role = val ?? 'USER'),
              ),
              const SizedBox(height: 20),

              // Submit Button
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'CADASTRAR USUÁRIO',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _blue, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _blue, width: 1.5),
        ),
        filled: true,
        fillColor: _canvas,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
}

class AdminUserDetailScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? initialData;

  const AdminUserDetailScreen({
    super.key,
    required this.userId,
    this.initialData,
  });

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _user = widget.initialData;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final res = await ApiClient.instance.getAdminUserDetail(widget.userId);
      if (mounted) {
        setState(() {
          _user = res['user'] is Map ? Map<String, dynamic>.from(res['user'] as Map) : res;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user ?? {};
    final name = user['name']?.toString() ?? 'Usuário';
    final email = user['email']?.toString() ?? '';
    final phone = user['phone']?.toString() ?? 'Não informado';
    final address = user['address']?.toString() ?? 'Não informado';
    final cargo = user['cargo'] ?? user['jobTitle'] ?? 'Operador';
    final role = user['role']?.toString() ?? 'USER';
    final isAdmin = role == 'ADMIN';
    final avatarUrl = user['avatarUrl']?.toString();
    final enrolledTrainings = (user['enrolledTrainings'] ?? user['trainings']) as List? ?? [];

    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        surfaceTintColor: _canvas,
        centerTitle: true,
        title: Text(
          name,
          style: const TextStyle(
            color: _blue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _blue))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Personal & Contact Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _card(),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: _blue.withOpacity(0.1),
                            backgroundImage: avatarUrl != null &&
                                    avatarUrl.isNotEmpty
                                ? NetworkImage(
                                    ApiClient.instance.mediaUrl(avatarUrl))
                                : const AssetImage('images/profile_igor.png')
                                    as ImageProvider,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: _blue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cargo,
                                  style: const TextStyle(
                                    color: Color(0xFF4B5563),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isAdmin
                                        ? const Color(0xFFFEE2E2)
                                        : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isAdmin ? 'ADMINISTRADOR' : 'OPERADOR',
                                    style: TextStyle(
                                      color: isAdmin
                                          ? const Color(0xFFDC2626)
                                          : const Color(0xFF2563EB),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _contactRow(Icons.email_outlined, 'E-mail', email),
                      const SizedBox(height: 10),
                      _contactRow(Icons.phone_outlined, 'Telefone', phone),
                      const SizedBox(height: 10),
                      _contactRow(
                          Icons.location_on_outlined, 'Endereço', address),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Enrolled Trainings Header
                Row(
                  children: [
                    const Icon(Icons.school, color: _blue, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Treinamentos Matriculados (${enrolledTrainings.length})',
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Enrolled Courses List
                if (enrolledTrainings.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: _card(),
                    alignment: Alignment.center,
                    child: const Text(
                      'Nenhum treinamento matriculado para este usuário.',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                    ),
                  )
                else
                  ...enrolledTrainings.map((t) {
                    final map = Map<String, dynamic>.from(t as Map);
                    final courseTitle =
                        map['title']?.toString() ?? 'Treinamento';
                    final status = map['status']?.toString() ?? 'NAO_INICIADO';
                    final rawPct =
                        (map['progressPercentage'] as num?)?.toDouble() ?? 0.0;
                    final double normalizedPct = rawPct > 1.0
                        ? (rawPct / 100.0).clamp(0.0, 1.0)
                        : rawPct.clamp(0.0, 1.0);
                    final int displayPct = (normalizedPct * 100).round();
                    final score = map['score'] as num?;
                    final completedModules =
                        map['completedModules'] ?? 0;
                    final totalModules = map['totalModules'] ?? 0;

                    final (statusLabel, statusColor, statusBg) = switch (status.toUpperCase()) {
                      'CONCLUIDO' || 'CONCLUÍDO' => (
                          'Concluído',
                          const Color(0xFF16A34A),
                          const Color(0xFFDCFCE7)
                        ),
                      'EM_CURSO' || 'EM ANDAMENTO' => (
                          'Em andamento',
                          const Color(0xFFD97706),
                          const Color(0xFFFEF3C7)
                        ),
                      'DESISTENCIA' || 'DESISTÊNCIA' => (
                          'Desistência',
                          const Color(0xFFDC2626),
                          const Color(0xFFFEE2E2)
                        ),
                      _ => (
                          'Não iniciado',
                          const Color(0xFF6B7280),
                          const Color(0xFFF3F4F6)
                        ),
                    };

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: _card(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  courseTitle,
                                  style: const TextStyle(
                                    color: _blue,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: normalizedPct,
                                    minHeight: 6,
                                    color: statusLabel == 'Concluído'
                                        ? const Color(0xFF22C55E)
                                        : _blue,
                                    backgroundColor: const Color(0xFFE5E7EB),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$displayPct%',
                                style: const TextStyle(
                                  color: _blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$completedModules de $totalModules módulos concluídos',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              if (score != null)
                                Text(
                                  'Nota: $score%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: score >= 70
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
    );
  }

  Widget _contactRow(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _blue, size: 18),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B5563),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937)),
            ),
          ),
        ],
      );
}
