import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/produto.dart';
import '../state/carrinho_model.dart';
import '../util/formatar.dart';

class ProdutoCard extends StatelessWidget {
  final Produto produto;
  const ProdutoCard({super.key, required this.produto});

  @override
  Widget build(BuildContext context) {
    debugPrint('build ProdutoCard ${produto.sku}');   // marca cada reconstrução

    // VERSÃO 1 (watch): assina o carrinho inteiro
        // VERSÃO 2 (select): assina só o valor que importa
    final noCarrinho = context.select<CarrinhoModel, int>(
      (c) => c.quantidadeDe(produto.sku),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(produto.nome),
        subtitle: Text(
          '${formatarPreco(produto.preco)} · estoque: ${produto.estoque}'
          '${noCarrinho > 0 ? ' · no carrinho: $noCarrinho' : ''}',
        ),
        trailing: IconButton(
          tooltip: 'Adicionar ao carrinho',
          icon: const Icon(Icons.add_shopping_cart),
          onPressed: () {
            // read: dentro de callbacks, sem registrar o widget como ouvinte.
            final ok = context.read<CarrinhoModel>().adicionar(produto);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                duration: const Duration(seconds: 1),
                content: Text(ok
                    ? '${produto.nome} adicionado'
                    : 'Estoque insuficiente para ${produto.nome}'),
              ));
          },
        ),
      ),
    );
  }
}