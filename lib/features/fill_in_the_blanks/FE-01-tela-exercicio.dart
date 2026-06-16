import 'package:flutter/material.dart';

class FillInTheBlanksPage extends StatefulWidget {
  const FillInTheBlanksPage({super.key});

  @override
  State<FillInTheBlanksPage> createState() => _FillInTheBlanksPageState();
}

class _FillInTheBlanksPageState extends State<FillInTheBlanksPage> {
  final TextEditingController _lacuna1Controller = TextEditingController();
  final TextEditingController _lacuna2Controller = TextEditingController();

  // Variáveis para controlar o feedback do exercício
  String _mensagemFeedback = '';
  Color _corFeedback = Colors.transparent;
  bool _mostrarErroLacuna1 = false;
  bool _mostrarErroLacuna2 = false;

  // Função que valida as respostas do usuário
  void _verificarRespostas() {
    // Remove espaços em branco extras (.trim())
    String resp1 = _lacuna1Controller.text.trim();
    String resp2 = _lacuna2Controller.text.trim();

    // As respostas corretas esperadas
    bool lacuna1Correta = (resp1 == 'void');
    bool lacuna2Correta = (resp2 == 'print');

    // Atualiza a tela com o resultado
    setState(() {
      _mostrarErroLacuna1 = !lacuna1Correta;
      _mostrarErroLacuna2 = !lacuna2Correta;

      if (lacuna1Correta && lacuna2Correta) {
        _mensagemFeedback = '🎉 Parabéns! Código correto!';
        _corFeedback = Colors.green;
      } else {
        _mensagemFeedback = '❌ Código incorreto. Verifique as lacunas destacadas!';
        _corFeedback = Colors.red;
      }
    });
  }

  // Função auxiliar para gerar a decoração dos campos de forma dinâmica
  InputDecoration _buildInputDecoration(String hint, bool temErro) {
    Color corBorda = temErro ? Colors.red : Colors.grey;
    double espessura = temErro ? 2.0 : 1.0;

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      // Mantém a cor vermelha mesmo se o campo estiver focado (clicado)
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: corBorda, width: espessura)),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: corBorda, width: espessura + 0.5)),
    );
  }

  @override
  void dispose() {
    _lacuna1Controller.dispose();
    _lacuna2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const estiloCodigo = TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 18);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercício: Preencher Lacunas'),
        centerTitle: true,
      ),
      // SingleChildScrollView evita erros de overflow quando o teclado abre
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instrução
              const Text(
                'Complete o código abaixo para exibir a mensagem no console:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Bloco do Editor de Código
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LINHA 1: [Caixinha 1] main() {
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 65,
                          child: TextField(
                            controller: _lacuna1Controller,
                            style: estiloCodigo,
                            decoration: _buildInputDecoration('___', _mostrarErroLacuna1),
                            // Limpa o destaque de erro assim que o usuário volta a digitar
                            onChanged: (_) => setState(() => _mostrarErroLacuna1 = false),
                          ),
                        ),
                        const Text(' main() {', style: estiloCodigo),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // LINHA 2:    [Caixinha 2]("Hello World");
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('  ', style: estiloCodigo),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _lacuna2Controller,
                            style: estiloCodigo,
                            decoration: _buildInputDecoration('_____', _mostrarErroLacuna2),
                            // Limpa o destaque de erro assim que o usuário volta a digitar
                            onChanged: (_) => setState(() => _mostrarErroLacuna2 = false),
                          ),
                        ),
                        const Text('("Hello World");', style: estiloCodigo),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // LINHA 3: }
                    const Text('}', style: estiloCodigo),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Área de Feedback Imediato
              if (_mensagemFeedback.isNotEmpty) ...[
                Text(
                  _mensagemFeedback,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _corFeedback),
                ),
                const SizedBox(height: 24),
              ],

              // Botão de Verificar Resposta
              ElevatedButton(
                onPressed: _verificarRespostas,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Verificar Resposta', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}