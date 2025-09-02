import 'package:check_raspadores/views/usina_list_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
/*
  Future<void> login() async {
    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }
  */
/*
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // 🔹 validações simples antes do Firebase
    if (email.isEmpty || password.isEmpty) {
      _showMessage("Preencha todos os campos.");
      return;
    }

    if (!email.contains("@") || !email.contains(".")) {
      _showMessage("Digite um email válido.");
      return;
    }
    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case "invalid-email":
          message = "O email informado é inválido.";
          break;
        case "user-not-found":
          message = "Usuário não encontrado. Verifique o email.";
          break;
        case "wrong-password":
          message = "Senha incorreta. Tente novamente.";
          break;
        case "user-disabled":
          message = "Usuário desativado. Contate o administrador.";
          break;
        case "invalid-credential": // 🔹 esse é o que você viu no print
          message = "Senha incorreta ou credencial inválida.";
          break;
        default:
          message = "Erro ao entrar: ${e.message}";
      }
      _showMessage(message);
    } catch (e) {
      _showMessage("Erro inesperado: $e");
    } finally {
      setState(() => loading = false);
    }
  }
  */
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // 🔹 validações simples antes do Firebase
    if (email.isEmpty || password.isEmpty) {
      _showMessage("Preencha todos os campos.");
      return;
    }

    if (!email.contains("@") || !email.contains(".")) {
      _showMessage("Digite um email válido.");
      return;
    }

    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔹 Se chegou até aqui, login deu certo → vai para UsinaListView
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UsinaListView(), // 👈 ajuste se usar construtor com service
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case "invalid-email":
          message = "O email informado é inválido.";
          break;
        case "user-not-found":
          message = "Usuário não encontrado. Verifique o email.";
          break;
        case "wrong-password":
          message = "Senha incorreta. Tente novamente.";
          break;
        case "user-disabled":
          message = "Usuário desativado. Contate o administrador.";
          break;
        case "invalid-credential":
          message = "Senha incorreta ou credencial inválida.";
          break;
        default:
          message = "Erro ao entrar: ${e.message}";
      }
      _showMessage(message);
    } catch (e) {
      _showMessage("Erro inesperado: $e");
    } finally {
      setState(() => loading = false);
    }
  }


  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> register() async {
    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF009379), Color(0xFF007F68)], // Verde Vale
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 10,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                   // const Icon(Icons.factory, size: 80, color: Color(0xFF009379)),
                    Image.asset(
                      "assets/logo.png",
                      height: 120, // 👈 controla o tamanho (antes era size: 80 do Icon)
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Checklist Raspadores",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6E6E6E), // cinza
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Campo Email
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email, color: Color(0xFF009379)),
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Campo Senha
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF009379)),
                        labelText: "Senha",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botão Entrar
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: loading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3A712), // Amarelo Vale
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "Entrar",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: loading ? null : register,
                      child: const Text(
                        "Criar Primeiro Acesso",
                        style: TextStyle(color: Color(0xFF009379)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
