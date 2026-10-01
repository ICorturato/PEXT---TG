import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import '../../widgets/pext_asset_icon.dart';

const _blue = Color(0xFF053488);
const _canvas = Color(0xFFF6F8FB);
const _border = Color(0xFFE5E7EB);

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 1; // 1: Email, 2: OTP + New Password, 3: Success
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Informe um endereço de e-mail válido.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiClient.instance.forgotPassword(email);
      if (!mounted) return;
      // If mock/seed returned a test code, prefill or let user type
      if (res['code'] != null) {
        _codeController.text = res['code'].toString();
      }
      setState(() {
        _step = 2;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código de recuperação enviado para seu e-mail! (Código: 123456)'),
          backgroundColor: Color(0xFF22C55E),
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (code.isEmpty) {
      setState(() => _errorMessage = 'Digite o código de verificação recebido.');
      return;
    }
    if (newPassword.length < 4) {
      setState(() => _errorMessage = 'A nova senha deve ter no mínimo 4 caracteres.');
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => _errorMessage = 'As senhas digitadas não coincidem.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await ApiClient.instance.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      if (!mounted) return;
      setState(() {
        _step = 3;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        surfaceTintColor: _canvas,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Recuperação de Senha',
          style: TextStyle(
            color: _blue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: switch (_step) {
                  1 => _buildStep1Email(),
                  2 => _buildStep2ResetPassword(),
                  _ => _buildStep3Success(),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1Email() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_reset, color: _blue, size: 34),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Esqueceu sua senha?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _blue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Digite seu e-mail cadastrado no PEXT para receber um código de redefinição de acesso.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 14),
        ],
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'E-mail cadastrado',
            hintText: 'exemplo@pext.local',
            prefixIcon: const Icon(Icons.email_outlined, color: _blue, size: 20),
            filled: true,
            fillColor: _canvas,
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
          ),
        ),
        const SizedBox(height: 22),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _blue,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _loading ? null : _sendCode,
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'ENVIAR CÓDIGO',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Lembrou sua senha? Voltar ao Login',
            style: TextStyle(color: _blue, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2ResetPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_outlined, color: Color(0xFF10B981), size: 34),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Definir Nova Senha',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _blue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enviamos um código para ${_emailController.text.trim()}. Informe o código e escolha sua nova senha.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 20),
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 14),
        ],
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 6),
          decoration: InputDecoration(
            labelText: 'Código de 6 dígitos',
            hintText: '123456',
            prefixIcon: const Icon(Icons.pin_outlined, color: _blue, size: 20),
            filled: true,
            fillColor: _canvas,
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
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _newPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Nova Senha',
            prefixIcon: const Icon(Icons.lock_outline, color: _blue, size: 20),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: _canvas,
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
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          decoration: InputDecoration(
            labelText: 'Confirmar Nova Senha',
            prefixIcon: const Icon(Icons.lock_outline, color: _blue, size: 20),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            filled: true,
            fillColor: _canvas,
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
          ),
        ),
        const SizedBox(height: 22),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _blue,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _loading ? null : _resetPassword,
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'REDEFINIR SENHA',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => setState(() => _step = 1),
          child: const Text(
            'Reenviar código para outro e-mail',
            style: TextStyle(color: _blue, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3Success() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 44),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Senha Alterada com Sucesso!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _blue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Sua credencial de acesso foi redefinida com segurança. Você já pode fazer login na plataforma.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 26),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _blue,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'VOLTAR AO LOGIN',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
