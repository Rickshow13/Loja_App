import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/checkout_page.dart';
import '../state/carrinho_model.dart';

class CarrinhoBadge extends StatelessWidget {
  const CarrinhoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    // select: só reconstrói quando o VALOR escolhido (totalItens) muda.
    final qtd = context.select<CarrinhoModel, int>((c) => c.totalItens);
    debugPrint('build CarrinhoBadge ($qtd)');
    return IconButton(
      tooltip: 'Carrinho',
      // Navigator.push empilha a tela do carrinho por cima do catálogo.
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CheckoutPage()),
      ),
      icon: Badge(
        isLabelVisible: qtd > 0,
        label: Text('$qtd'),
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}