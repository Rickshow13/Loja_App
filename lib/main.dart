import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/catalogo_page.dart';
import 'state/carrinho_model.dart';

void main() {
  runApp(
    // O provider fica ACIMA do MaterialApp: todas as telas enxergam o carrinho.
    ChangeNotifierProvider(
      create: (_) => CarrinhoModel(),
      child: const LojaApp(),
    ),
  );
}

class LojaApp extends StatelessWidget {
  const LojaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LojaApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const CatalogoPage(),
    );
  }
}