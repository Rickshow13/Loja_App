import 'package:flutter/foundation.dart';   // onde mora o ChangeNotifier
import '../models/produto.dart';

/// Estado de APLICAÇÃO: o carrinho é lido e alterado por várias telas.
class CarrinhoModel extends ChangeNotifier {
  // Estado privado: só o próprio modelo altera.
  final Map<String, int> _quantidades = {};     // sku -> quantidade
  final Map<String, Produto> _produtos = {};    // sku -> produto

  // Leitura segura (a UI não consegue alterar as coleções).
  List<Produto> get produtos => List.unmodifiable(_produtos.values);
  int quantidadeDe(String sku) => _quantidades[sku] ?? 0;
  bool get vazio => _quantidades.isEmpty;

  // Estado derivado: calculado, não armazenado.
  int get totalItens => _quantidades.values.fold<int>(0, (soma, q) => soma + q);
  double get valorTotal => _quantidades.entries.fold<double>(
      0, (soma, e) => soma + e.value * _produtos[e.key]!.preco);

  /// Retorna false (e não notifica) se não houver estoque.
  bool adicionar(Produto produto) {
    final atual = quantidadeDe(produto.sku);
    if (atual >= produto.estoque) return false;
    _produtos[produto.sku] = produto;
    _quantidades[produto.sku] = atual + 1;
    notifyListeners();
    return true;
  }

  /// Remove uma unidade do produto ou elimina do carrinho se chegar a zero.
  void remover(Produto produto) {
    final atual = quantidadeDe(produto.sku);
    if (atual <= 0) return;

    if (atual == 1) {
      _quantidades.remove(produto.sku);
      _produtos.remove(produto.sku);
    } else {
      _quantidades[produto.sku] = atual - 1;
    }
    notifyListeners();
  }

  /// Limpa totalmente o carrinho.
  void limpar() {
    _quantidades.clear();
    _produtos.clear();
    notifyListeners();
  }
}
