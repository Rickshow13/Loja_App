# LojaApp

Aplicativo de loja feito com **Flutter** (a ferramenta do Google para criar apps) e **Provider** (um pacote que cuida do "estado" do app, explicado mais abaixo). Ele tem um catálogo de produtos, um ícone de carrinho que mostra a quantidade de itens e uma tela de carrinho com total e botão **Finalizar**.

> Exercício 1 de **Desenvolvimento Mobile (Flutter)**, Aula 01, UNIP. Prof. Eduardo Furlanetti.

---

## Sumário

- [O que o app faz](#o-que-o-app-faz)
- [Prints](#prints)
- [Tecnologias](#tecnologias)
- [A ideia central: onde guardar o carrinho?](#a-ideia-central-onde-guardar-o-carrinho)
- [Como o Provider funciona](#como-o-provider-funciona)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Como rodar o projeto](#como-rodar-o-projeto)
- [Como rodar os testes](#como-rodar-os-testes)
- [Decisões de projeto](#decisões-de-projeto)
- [Limitações e próximos passos](#limitações-e-próximos-passos)
- [Autor](#autor)

---

## O que o app faz

| Tela / elemento | O que faz |
|---|---|
| **Catálogo** | Mostra 6 produtos com nome, preço e estoque. Cada um tem um botão para adicionar ao carrinho. |
| **Aviso de estoque** | Se você tentar adicionar mais unidades do que existem em estoque, aparece "Estoque insuficiente". |
| **Ícone do carrinho** | Fica no topo e mostra o número total de itens. Some quando o carrinho está vazio. |
| **"no carrinho: n"** | Em cada produto do catálogo, mostra quantas unidades dele já estão no carrinho. |
| **Tela do carrinho** | Lista os itens com quantidade e subtotal, botões **+** e **−**, o **Total** e o botão **Finalizar**. |
| **Finalizar** | Mostra o valor do pedido, esvazia o carrinho e volta ao catálogo. O botão fica desabilitado se o carrinho estiver vazio. |

O catálogo é uma **lista fixa** dentro do código. Na próxima aula ele virá de uma API (um serviço na internet que entrega dados).

### Produtos do catálogo

| SKU (código) | Produto | Preço | Estoque |
|---|---|---|---|
| TEC-001 | Teclado mecânico | R$ 289,90 | 5 |
| MOU-002 | Mouse sem fio | R$ 99,90 | 10 |
| MON-003 | Monitor 24 polegadas | R$ 899,00 | 3 |
| HEA-004 | Headset USB | R$ 199,50 | 4 |
| WEB-005 | Webcam Full HD | R$ 249,00 | 2 |
| SSD-006 | SSD 1 TB | R$ 459,90 | 6 |

---


---

## Tecnologias

| Tecnologia | Para que serve neste projeto |
|---|---|
| [Flutter](https://flutter.dev) (3.19 ou mais novo) | Cria as telas e roda o app (no Chrome, Windows ou celular). |
| [Dart](https://dart.dev) | A linguagem de programação do Flutter. |
| [provider](https://pub.dev/packages/provider) | Guarda o carrinho num lugar central e avisa as telas quando ele muda. |
| flutter_test | Ferramenta que já vem com o Flutter para escrever testes automáticos. |
| VS Code + extensões Flutter e Dart | Editor de código, com o *hot reload* (atualizar o app sem fechar). |

---

## A ideia central: onde guardar o carrinho?

No Flutter, **estado** é qualquer dado que muda e que a tela precisa mostrar (por exemplo, quantos itens há no carrinho). Existem dois tipos:

| Tipo | O que é | Exemplo | Ferramenta |
|---|---|---|---|
| **Estado efêmero** (local) | Pertence a **um único** widget (peça da tela) e mais ninguém precisa dele. | O texto digitado num campo de busca. | `setState` |
| **Estado de aplicação** (compartilhado) | **Várias telas** leem ou alteram o mesmo dado. | **O carrinho** deste app. | `ChangeNotifier` + Provider |

O carrinho é usado por três lugares ao mesmo tempo: o **catálogo** (botão de adicionar), o **ícone** (quantidade) e a **tela do carrinho** (lista e total). Se ele ficasse dentro de uma tela só, as outras teriam de receber o carrinho passando de mão em mão por vários níveis (um problema chamado *prop drilling*). Por isso ele mora num **modelo à parte**, que todas as telas consultam.

> **Analogia:** pense num **quadro de avisos** de um prédio. Em vez de cada morador guardar sua própria cópia da informação, existe **um quadro só**. Quando alguém muda um aviso, todo mundo que olha o quadro enxerga a mudança.

---

## Como o Provider funciona

São três peças trabalhando juntas:

1. **`CarrinhoModel`** (o quadro de avisos): a classe que guarda os itens e as quantidades. Ela usa `ChangeNotifier`, que dá a ela o poder de chamar `notifyListeners()` ("avise todo mundo que mudou").
2. **`ChangeNotifierProvider`** (quem pendura o quadro): fica no `main.dart`, **acima do `MaterialApp`**, para que todas as telas enxerguem o mesmo carrinho. Ele cria o modelo **uma única vez**.
3. **Os widgets** (quem olha o quadro): leem o carrinho de quatro formas diferentes, descritas abaixo.

### As formas de acessar o carrinho

| Forma | Reconstrói o widget? | Quando usar | Onde aparece no app |
|---|---|---|---|
| `context.read<T>()` | **Não** | Para **agir** (num clique), sem ficar "ouvindo". | Botão de adicionar do `ProdutoCard`; função `_finalizar`. |
| `context.watch<T>()` | Sim, a **qualquer** mudança do modelo | Para exibir dados quando tudo importa. | Usado só como experimento (comparação). |
| `context.select<T, R>()` | Só se o **valor escolhido** mudar | Para exibir **um** valor do modelo, de forma econômica. | `CarrinhoBadge` (total de itens) e `ProdutoCard` (quantidade daquele produto). |
| `Consumer<T>` | Sim, **só o seu trecho** | Quando só uma parte da tela depende do modelo. | Lista de itens e texto do **Total** na tela do carrinho. |
| `Selector<T, R>` | Só se o valor escolhido mudar, **só o seu trecho** | Trecho que depende de um valor derivado. | Botão **Finalizar** (muda só entre vazio e não vazio). |

> **Analogia:** o `watch` é um **grupo de WhatsApp** em que toda mensagem chega para todos, mesmo as que não interessam. O `select` é uma **notificação só do que importa** para você.

### Medindo na prática (o experimento do `watch` x `select`)

O código imprime `build ProdutoCard ...` no console toda vez que um card é redesenhado. Ao adicionar **um** mouse ao carrinho:

| Versão | Cards redesenhados |
|---|---|
| `context.watch` | Os **6** cards (todos ouvem o carrinho inteiro). |
| `context.select` | **Só 1** card (o do mouse). |

Em um catálogo com 2.000 produtos, essa diferença seria a de um app travando ou fluindo.

---

## Estrutura do projeto

```
loja_app/
├── pubspec.yaml                  # "ficha" do projeto: dependências (inclui o provider)
├── lib/
│   ├── main.dart                 # ponto de partida; ChangeNotifierProvider acima do MaterialApp
│   ├── models/
│   │   ├── produto.dart          # Produto: entidade imutável (final + const)
│   │   └── catalogo.dart         # lista fixa dos 6 produtos
│   ├── state/
│   │   └── carrinho_model.dart   # CarrinhoModel: o estado do carrinho (ChangeNotifier)
│   ├── pages/
│   │   ├── catalogo_page.dart    # tela inicial com a lista de produtos
│   │   └── checkout_page.dart    # tela do carrinho (Consumer e Selector)
│   ├── widgets/
│   │   ├── produto_card.dart     # card de produto (read e select)
│   │   └── carrinho_badge.dart   # ícone do carrinho com a quantidade (select)
│   └── util/
│       └── formatar.dart         # transforma 1234.5 em "R$ 1234,50"
├── test/
│   └── carrinho_model_test.dart  # testes automáticos do CarrinhoModel
└── docs/
    └── prints/                   # imagens usadas neste README
```

### O que cada arquivo faz

- **`produto.dart`**: descreve o que é um produto (código, nome, preço, estoque). Todos os campos são `final` (só recebem valor uma vez), então o produto **não muda depois de criado**.
- **`carrinho_model.dart`**: o cérebro do app. Tem os métodos `adicionar`, `remover` e `limpar`, e os valores calculados `totalItens` e `valorTotal`. É código Dart puro (sem telas), por isso pode ser testado sem abrir o app.
- **`main.dart`**: liga tudo. Cria o `CarrinhoModel` uma vez e o entrega ao app inteiro.
- **`produto_card.dart`**: cada linha do catálogo. Usa `read` ao clicar e `select` para mostrar "no carrinho: n".
- **`carrinho_badge.dart`**: o ícone no topo. Usa `select` para redesenhar só quando o total de itens muda.
- **`checkout_page.dart`**: a tela do carrinho, com `Consumer` (lista e total) e `Selector` (botão Finalizar).
- **`formatar.dart`**: formata o preço no padrão brasileiro. A barra em `R\$` faz o cifrão aparecer como texto (em Dart, `$` normalmente significa "insira uma variável aqui").

---

## Como rodar o projeto

### O que você precisa ter instalado

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.19 ou mais novo). Confira com `flutter doctor`.
- [VS Code](https://code.visualstudio.com/) com as extensões **Flutter** e **Dart**.
- Um destino para rodar: o **Chrome** já basta (o Android e o Visual Studio são opcionais).

### Passo a passo

```bash
# 1. Baixar o projeto
git clone https://github.com/Rickshow13/loja_app.git
cd loja_app

# 2. Baixar as dependências (o pacote provider)
flutter pub get

# 3. Rodar o app no Chrome
flutter run -d chrome
```

O que cada comando faz:

- `git clone ...`: baixa uma cópia do projeto do GitHub para o seu computador.
- `cd loja_app`: entra na pasta do projeto.
- `flutter pub get`: baixa os pacotes que o projeto usa (como o `provider`).
- `flutter run -d chrome`: compila e abre o app no navegador. No terminal, a tecla **r** faz o *hot reload* (atualiza sem reiniciar) e **R** faz o *hot restart* (reinicia o app). Para parar, aperte **q**.

Para ver a lista de destinos disponíveis, use `flutter devices`.

---

## Como rodar os testes

```bash
flutter analyze   # procura erros no código, sem rodar o app
flutter test      # roda os testes automáticos
```

O resultado esperado do segundo comando é **`All tests passed!`**, com **5 testes**.

### O que os testes verificam (`test/carrinho_model_test.dart`)

| # | Teste | O que garante |
|---|---|---|
| 1 | Começa vazio | Um carrinho novo tem 0 itens e valor 0. |
| 2 | Adicionar soma e notifica | As quantidades e o valor total somam certo, e o modelo avisa a cada mudança. |
| 3 | Respeita o estoque | Não deixa passar do estoque e **não avisa** quando nada mudou. |
| 4 | Remover | Diminui a quantidade e tira o produto ao chegar a zero. |
| 5 | Lista protegida | A lista de produtos exposta **não pode ser alterada** pela interface. |

Como o `CarrinhoModel` não tem telas, os testes rodam em segundos, sem emulador.

---

## Decisões de projeto

- **A regra de estoque fica no modelo, não no botão.** Assim, qualquer tela que adicione itens (o catálogo, o **+** do carrinho) obedece à mesma regra, e ela pode ser testada sem abrir o app.
- **`totalItens` e `valorTotal` são calculados na hora**, e não guardados em variáveis. Isso evita o risco de esquecer de atualizá-los e mostrar um valor errado.
- **As coleções do carrinho são privadas** (`_quantidades`, `_produtos`), e a lista exposta é `List.unmodifiable`. Só o próprio modelo altera o carrinho, e toda alteração passa por `notifyListeners()`.
- **O modelo só avisa quando algo realmente mudou.** Se não há estoque, o método devolve `false` sem notificar, evitando redesenhos desnecessários.
- **O `Produto` é imutável** (`final` + `const`): várias telas usam o mesmo objeto, e ninguém consegue alterar o preço por engano.
- **`select` e `Selector` em vez de `watch`** nos pontos onde só um valor importa, para redesenhar o mínimo possível.
- **No `_finalizar`, o total é lido antes de `limpar()`.** Depois de limpar, o valor seria 0.

---

## Limitações e próximos passos

- O catálogo é fixo. Na **Aula 02**, ele virá de uma API, com a chamada HTTP numa **camada de serviço** (chamada pelo modelo de estado, mantendo a tela só com a parte visual).
- O carrinho vive na memória: se o app fechar, ele se perde. Dá para guardar no aparelho ou num servidor.
- Não há login, pagamento real nem histórico de pedidos.
- **Desafio opcional:** um `FavoritosModel` com `MultiProvider` (mais de um modelo disponível ao mesmo tempo), em que favoritar um produto reconstrói só o card dele.

---

## Autor

**Henrique**, estudante de Análise e Desenvolvimento de Sistemas na UNIP.

GitHub: [@Rickshow13](https://github.com/Rickshow13)
