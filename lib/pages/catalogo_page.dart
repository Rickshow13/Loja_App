import 'package:flutter/material.dart';
import '../widgets/carrinho_badge.dart';
import '../models/catalogo.dart';
import '../widgets/produto_card.dart';

class CatalogoPage extends StatelessWidget {
  const CatalogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('build CatalogoPage');
    return Scaffold(
      appBar: AppBar(
        title: const Text('LojaApp'),
        actions: const [CarrinhoBadge()],
      ),
      body: ListView.builder(
        itemCount: catalogo.length,
        itemBuilder: (context, i) => ProdutoCard(produto: catalogo[i]),
      ),
    );
  }
}