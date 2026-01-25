# LaTeX Template – Paper/Monografia/Tese (SBC)

Este repositório é um template LaTeX "esqueleto" com três variantes (paper, monografia, tese), baseado no template da SBC. Todo o conteúdo foi reduzido a placeholders para rápida personalização.

## Template Variants / Variantes do Template

Este template oferece três variantes para diferentes tipos de documentos acadêmicos:

### 1. Paper (`paper-main.tex`)
- **Uso:** Artigos de conferência/periódico (6-10 páginas)
- **Classe:** `article`
- **Características:**
  - Estrutura simplificada e streamlined
  - Capítulos essenciais apenas (introdução, trabalhos relacionados, metodologia, resultados, conclusões)
  - Sem sumário (TOC) por padrão
  - Bibliografia: thebibliography (simples)
  - Ideal para: submissões rápidas, artigos curtos
- **Config:** `config/paper-config.tex`
- **Compilação:** `make compile MAIN_FILE=paper-main` ou `make view MAIN_FILE=paper-main`

### 2. Monografia (`monograph-main.tex`)
- **Uso:** Trabalhos de conclusão de curso (TCC), monografias de especialização
- **Classe:** `report`
- **Características:**
  - Estrutura completa com capítulos numerados
  - Sumário (TOC) incluído automaticamente
  - Todos os 8 capítulos padrão (introdução, trabalhos relacionados, metodologia, resultados, detalhes de implementação, desafios técnicos, trabalhos futuros, conclusões)
  - Bibliografia: thebibliography ou BibTeX
  - Ideal para: TCCs, monografias de 30-80 páginas
- **Config:** `config/monograph-config.tex`
- **Compilação:** `make compile MAIN_FILE=monograph-main` ou `make view MAIN_FILE=monograph-main`

### 3. Tese/Dissertação (`thesis-main.tex`)
- **Uso:** Dissertações de mestrado, teses de doutorado
- **Classe:** `report`
- **Características:**
  - Estrutura completa e formal
  - Sumário (TOC), lista de figuras, lista de tabelas
  - Dedicatória, agradecimentos, epígrafe (opcionais)
  - Glossário e índice remissivo habilitados por padrão
  - Bibliografia: thebibliography ou BibTeX
  - Ideal para: dissertações/teses longas (80-300+ páginas)
- **Config:** `config/thesis-config.tex`
- **Compilação:** `make compile MAIN_FILE=thesis-main` ou `make view MAIN_FILE=thesis-main`

### Guia de Seleção / Selection Guide

| Critério | Paper | Monografia | Tese/Dissertação |
|----------|-------|------------|------------------|
| **Páginas típicas** | 6-10 | 30-80 | 80-300+ |
| **Classe LaTeX** | article | report | report |
| **Sumário (TOC)** | Não | Sim | Sim |
| **Listas (figuras/tabelas)** | Não | Opcional | Sim |
| **Glossário/Índice** | Não | Não | Sim |
| **Capítulos** | Essenciais | Completos | Completos + extras |
| **Tempo de setup** | Rápido (~5 min) | Médio (~15 min) | Completo (~30 min) |

**Dica:** Se está em dúvida entre monografia e tese, comece com `monograph-main.tex` e migre para `thesis-main.tex` se precisar de recursos adicionais (glossário, índice, listas).

## Quick Start Automatizado / Automated Quick Start

**Novo:** Script de inicialização automática que configura tudo em menos de 5 minutos.

### O que é quick-start.sh? / What is quick-start.sh?

O script `quick-start.sh` é a maneira **mais rápida** de começar a usar este template. Ele automatiza todo o processo de configuração inicial:

1. **Verifica dependências** - Detecta se LaTeX, Make, BibTeX/Biber estão instalados
2. **Detecta sua plataforma** - macOS, Linux ou WSL
3. **Fornece orientações** - Instruções específicas se faltar alguma dependência
4. **Configura o projeto** - Executa `init-project.sh` para personalizar com suas informações
5. **Compila o primeiro PDF** - Gera seu documento inicial automaticamente

**Benefícios:**
- **Rápido** - De download a PDF em menos de 5 minutos
- **Sem erros** - Valida todas as dependências antes de começar
- **Automático** - Modo interativo (com prompts) ou não-interativo (scriptable)
- **Completo** - Tudo que você precisa em um único comando

---

The `quick-start.sh` script is the **fastest** way to start using this template. It automates the entire initial setup process:

1. **Checks dependencies** - Detects if LaTeX, Make, BibTeX/Biber are installed
2. **Detects your platform** - macOS, Linux, or WSL
3. **Provides guidance** - Platform-specific installation instructions if needed
4. **Sets up the project** - Runs `init-project.sh` to customize with your information
5. **Compiles first PDF** - Generates your initial document automatically

**Benefits:**
- **Fast** - From download to PDF in under 5 minutes
- **Error-free** - Validates all dependencies before starting
- **Automatic** - Interactive mode (with prompts) or non-interactive (scriptable)
- **Complete** - Everything you need in a single command

### Modo Interativo (Recomendado) / Interactive Mode (Recommended)

Execute sem argumentos para um setup guiado passo a passo:

```bash
bash quick-start.sh
```

O script irá:
1. Verificar se LaTeX e Make estão instalados
2. Mostrar instruções de instalação se algo estiver faltando (específicas para seu sistema)
3. Perguntar se deseja continuar com a configuração do projeto
4. Executar `init-project.sh` de forma interativa (você fornece nome, autor, instituição, etc.)
5. Compilar automaticamente o primeiro PDF

**Resultado:** Projeto configurado e PDF gerado em menos de 5 minutos.

---

Run without arguments for step-by-step guided setup:

```bash
bash quick-start.sh
```

The script will:
1. Check if LaTeX and Make are installed
2. Show installation instructions if anything is missing (specific to your system)
3. Ask if you want to proceed with project setup
4. Run `init-project.sh` interactively (you provide name, author, institution, etc.)
5. Automatically compile the first PDF

**Result:** Project configured and PDF generated in under 5 minutes.

### Modo Não-Interativo / Non-Interactive Mode

Para automação, CI/CD, ou quando você não quer prompts interativos:

```bash
bash quick-start.sh --non-interactive
```

Isso irá:
- Verificar dependências (sem interação)
- Executar `init-project.sh` com valores padrão
- Compilar o PDF automaticamente

**Nota:** Você pode personalizar seu projeto posteriormente rodando `bash init-project.sh` novamente ou editando os arquivos em `config/`.

---

For automation, CI/CD, or when you don't want interactive prompts:

```bash
bash quick-start.sh --non-interactive
```

This will:
- Check dependencies (without interaction)
- Run `init-project.sh` with default values
- Compile the PDF automatically

**Note:** You can customize your project later by running `bash init-project.sh` again or editing files in `config/`.

### Opções Disponíveis / Available Options

```bash
bash quick-start.sh --help              # Mostra ajuda completa / Show help
bash quick-start.sh --version           # Mostra versão / Show version
bash quick-start.sh --non-interactive   # Modo automático / Automatic mode
```

### Resolução de Problemas / Troubleshooting

**Dependências não encontradas?**
- O script detectará automaticamente seu sistema operacional
- Fornecerá comandos exatos para instalar LaTeX e Make
- Suporta: macOS (Homebrew), Linux (apt/dnf/pacman), e WSL

**Erro durante compilação?**
- Verifique `output/build.log` para detalhes
- Execute `make clean && make compile` para tentar novamente
- Veja a seção [Troubleshooting](#troubleshooting) abaixo

**Quer personalizar depois?**
- Execute `bash init-project.sh` novamente a qualquer momento
- Ou edite manualmente os arquivos em `config/` (veja documentação abaixo)

---

**Dependencies not found?**
- Script automatically detects your operating system
- Provides exact commands to install LaTeX and Make
- Supports: macOS (Homebrew), Linux (apt/dnf/pacman), and WSL

**Compilation error?**
- Check `output/build.log` for details
- Run `make clean && make compile` to try again
- See [Troubleshooting](#troubleshooting) section below

**Want to customize later?**
- Run `bash init-project.sh` again at any time
- Or manually edit files in `config/` (see documentation below)

### Próximos Passos / Next Steps

Após executar `quick-start.sh`, você terá:
- Projeto configurado com suas informações
- Primeiro PDF compilado em `output/`
- Template pronto para começar a escrever

**Agora você pode:**
1. Editar conteúdo em `chapters/` e `sections/`
2. Recompilar com `make compile` ou `make paper/monograph/thesis`
3. Personalizar configurações em `config/`
4. Ver [CLI de Inicialização de Projeto](#cli-de-inicialização-de-projeto--project-initialization-cli) para opções avançadas

---

After running `quick-start.sh`, you'll have:
- Project configured with your information
- First PDF compiled in `output/`
- Template ready to start writing

**Now you can:**
1. Edit content in `chapters/` and `sections/`
2. Recompile with `make compile` or `make paper/monograph/thesis`
3. Customize settings in `config/`
4. See [CLI de Inicialização de Projeto](#cli-de-inicialização-de-projeto--project-initialization-cli) for advanced options

## Quick Start / Início Rápido

Escolha sua variante e compile rapidamente:

### Paper (Artigo)
```bash
# Compilar e visualizar um paper
make paper          # compila output/paper-main.pdf e abre automaticamente
make compile MAIN_FILE=paper-main   # apenas compila
make view MAIN_FILE=paper-main      # compila e abre
```

### Monograph (Monografia/TCC)
```bash
# Compilar e visualizar uma monografia
make monograph      # compila output/monograph-main.pdf e abre automaticamente
make compile MAIN_FILE=monograph-main   # apenas compila
make view MAIN_FILE=monograph-main      # compila e abre
```

### Thesis (Tese/Dissertação)
```bash
# Compilar e visualizar uma tese/dissertação
make thesis         # compila output/thesis-main.pdf e abre automaticamente
make compile MAIN_FILE=thesis-main   # apenas compila
make view MAIN_FILE=thesis-main      # compila e abre
```

### Comandos Adicionais
```bash
make clean          # limpa arquivos temporários
make bib MAIN_FILE=paper-main       # compila com BibTeX (se configurado)
make view-bib MAIN_FILE=monograph-main  # compila com BibTeX e abre
```

## CLI de Inicialização de Projeto / Project Initialization CLI

**Nova funcionalidade:** Este template inclui uma ferramenta CLI interativa que automatiza a configuração inicial do projeto.

### Visão Geral / Overview

O script `init-project.sh` customiza automaticamente o template com suas informações (nome do projeto, autor, instituição, backend de bibliografia) e permite remover capítulos desnecessários. Elimina a necessidade de editar manualmente múltiplos arquivos de configuração.

**Benefícios:**
- Setup rápido - configure todo o projeto em menos de 1 minuto
- Zero erros - validação automática de inputs e formatos
- Flexível - suporta modo interativo e não-interativo (scriptable)
- Customizável - escolha variante, bibliografia, e capítulos

### Modo Interativo (Recomendado) / Interactive Mode (Recommended)

Execute o script sem argumentos para um setup guiado passo a passo:

```bash
bash init-project.sh
```

O script irá solicitar:
- **Nome do Projeto:** Título do seu trabalho
- **Nome do Autor:** Seu nome completo
- **Instituição:** Nome da universidade/instituto
- **Localização:** Formato "Cidade -- Estado -- País"
- **Email:** Seu endereço de email
- **Variante:** paper, monograph, ou thesis
- **Backend de Bibliografia:** thebibliography, bibtex, ou biblatex
- **Capítulos a Remover:** (Opcional) Lista separada por vírgulas (ex: chapter2,chapter4)

### Modo Não-Interativo / Non-Interactive Mode

Para automação ou scripting, use o modo não-interativo com todos os argumentos:

```bash
bash init-project.sh --non-interactive \
  --name "My Research Paper" \
  --author "John Doe" \
  --institution "MIT" \
  --location "Boston -- MA -- USA" \
  --email "john@mit.edu" \
  --variant paper \
  --biblio thebibliography
```

### Opções Disponíveis / Available Options

```
--help                      Mostra ajuda completa / Show help
--version                   Mostra versão / Show version
--non-interactive           Modo não-interativo / Non-interactive mode
--name NAME                 Nome do projeto / Project name
--author AUTHOR             Nome do autor / Author name
--institution INSTITUTION   Instituição / Institution
--location LOCATION         Localização / Location (City -- State -- Country)
--email EMAIL              Email de contato / Contact email
--variant VARIANT          Variante: paper, monograph, thesis
--biblio BACKEND           Backend: thebibliography, bibtex, biblatex
--remove-chapters CHAPTERS  Capítulos a remover (opcional) / Chapters to remove (optional)
```

### Valores Válidos / Valid Values

**Variants (Variantes):**
- `paper` - Artigo curto com estrutura simplificada (6-10 páginas)
- `monograph` - Monografia/TCC com sumário completo (30-80 páginas)
- `thesis` - Tese/dissertação com elementos pré-textuais (80-300+ páginas)

**Bibliography Backends:**
- `thebibliography` - Ambiente manual de bibliografia (sem arquivos externos)
- `bibtex` - BibTeX tradicional com arquivo .bib
- `biblatex` - BibLaTeX moderno com backend biber (recomendado para projetos grandes)

**Chapters (Capítulos):**
Use identificadores `chapter1` a `chapter10` separados por vírgula:
- `chapter1` = 01-introducao.tex
- `chapter2` = 02-trabalhos-relacionados.tex
- `chapter3` = 03-metodologia.tex
- `chapter4` = 04-avaliacao-resultados.tex
- `chapter5` = 05-detalhes-implementacao.tex
- `chapter6` = 06-desafios-tecnicos.tex
- `chapter7` = 07-trabalhos-futuros.tex
- `chapter8` = 08-conclusoes-e-contribuicoes.tex
- `chapter9` = 09-apendices.tex
- `chapter10` = 10-cronograma.tex

### Exemplos / Examples

**Exemplo 1: Setup interativo completo (mais fácil)**
```bash
# Inicia modo interativo - responda às perguntas
bash init-project.sh
```

**Exemplo 2: Paper rápido com BibTeX**
```bash
bash init-project.sh --non-interactive \
  --name "Machine Learning in Healthcare" \
  --author "Jane Smith" \
  --institution "Stanford University" \
  --location "Stanford -- CA -- USA" \
  --email "jane.smith@stanford.edu" \
  --variant paper \
  --biblio bibtex
```

**Exemplo 3: Monografia removendo capítulos desnecessários**
```bash
bash init-project.sh --non-interactive \
  --name "Sistema de Recomendação com Deep Learning" \
  --author "Carlos Silva" \
  --institution "Universidade de São Paulo" \
  --location "São Paulo -- SP -- Brasil" \
  --email "carlos.silva@usp.br" \
  --variant monograph \
  --biblio biblatex \
  --remove-chapters "chapter6,chapter7"
```

**Exemplo 4: Tese com BibLaTeX (recomendado para projetos longos)**
```bash
bash init-project.sh --non-interactive \
  --name "Quantum Computing Applications in Cryptography" \
  --author "Robert Johnson" \
  --institution "California Institute of Technology" \
  --location "Pasadena -- CA -- USA" \
  --email "rjohnson@caltech.edu" \
  --variant thesis \
  --biblio biblatex \
  --remove-chapters "chapter9,chapter10"
```

### Fluxo de Trabalho Recomendado / Recommended Workflow

1. **Clone o repositório:**
   ```bash
   git clone <repository-url>
   cd LaTeX-Paper-Template
   ```

2. **Execute o script de inicialização:**
   ```bash
   bash init-project.sh
   ```

3. **Compile e visualize:**
   ```bash
   make paper      # ou make monograph, ou make thesis
   ```

4. **Edite o conteúdo:**
   - Substitua placeholders em `chapters/`
   - Adicione suas figuras em `assets/`
   - Edite referências em `bibliography/`

5. **Compile novamente:**
   ```bash
   make paper      # gera PDF atualizado
   ```

**Dica:** Após executar o script, os arquivos de configuração em `config/` estarão automaticamente atualizados com seus dados. Você pode prosseguir diretamente para compilação com `make paper`, `make monograph`, ou `make thesis`.

---

## Estrutura

```
├── init-project.sh         # Script CLI de inicialização / CLI initialization script
├── quick-start.sh          # Script de início rápido / Quick start script
├── paper-main.tex          # Variante: Paper/Artigo (6-10 páginas)
├── monograph-main.tex      # Variante: Monografia/TCC (30-80 páginas)
├── thesis-main.tex         # Variante: Tese/Dissertação (80-300+ páginas)
├── article-main-v2.tex     # Variante legada (compatibilidade)
├── Makefile                # Comandos de build
├── chapters/               # Capítulos (numerados)
│   ├── 01-introducao.tex
│   ├── 02-trabalhos-relacionados.tex
│   ├── 03-metodologia.tex
│   ├── 04-avaliacao-resultados.tex       # usa template_fig1.jpg
│   ├── 05-detalhes-implementacao.tex     # usa template_diagram1/2.png
│   ├── 06-desafios-tecnicos.tex
│   ├── 07-trabalhos-futuros.tex
│   └── 08-conclusoes-e-contribuicoes.tex
├── sections/               # Abstract/Resumo
├── bibliography/           # Referências (thebibliography ou BibTeX)
│   ├── references.tex      # Exemplo com thebibliography
│   ├── sbc-template.bib    # Exemplo de base BibTeX (opcional)
│   └── sbc.bst             # Estilo SBC (opcional)
├── config/                 # Estilos e config (SBC + article-config)
├── tests/                  # Suíte de testes e validação / Test suite
│   ├── run_all_tests.sh    # Runner principal / Main test runner
│   ├── test_*.sh           # Testes unitários / Unit tests
│   └── validate-*.sh       # Validação E2E / E2E validation scripts
└── output/                 # Saída compilada
```

## Uso Rápido

1. Escolha a variante adequada (veja "Guia de Seleção" acima).
2. Edite metadados no arquivo de config da variante:
   - Paper: `config/paper-config.tex`
   - Monografia: `config/monograph-config.tex`
   - Tese: `config/thesis-config.tex`
   - Legado: `config/article-config.tex`
3. Substitua placeholders nos arquivos em `chapters/` e `sections/`.
4. Compile:

```bash
# Para paper-main.tex
make compile MAIN_FILE=paper-main   # gera output/paper-main.pdf
make view MAIN_FILE=paper-main      # compila e abre o PDF

# Para monograph-main.tex
make compile MAIN_FILE=monograph-main
make view MAIN_FILE=monograph-main

# Para thesis-main.tex
make compile MAIN_FILE=thesis-main
make view MAIN_FILE=thesis-main

# Para limpar temporários
make clean
```

### Uso com BibTeX (.bib)

```bash
# Após configurar \bibliographystyle e \bibliography no arquivo principal
make bib       # compila com BibTeX e gera o PDF
make view-bib  # compila (BibTeX) e abre o PDF
```

## Convenções

- Capítulos: arquivos numerados `NN-titulo.tex` e incluídos com `\input{chapters/NN-...}`.
- Labels: `fig:`, `tab:`, `sec:`, `eq:`. Ex.: `\label{fig:exemplo}`.
- Imagens: use `graphicx`. O template já inclui exemplos reais:
  - Imagens ficam em `assets/` (\graphicspath já configurado).
  - `chapters/05-detalhes-implementacao.tex` usa `template_diagram1.png` e `template_diagram2.png`.
  - `chapters/04-avaliacao-resultados.tex` usa `template_fig1.jpg`.
  Substitua esses arquivos pelas suas figuras ou ajuste os caminhos.
  - Subfiguras: devido ao uso do `caption2` no template SBC, o pacote `subcaption` não é compatível. Use `minipage` com legendas textuais (exemplo em `sections/guia-rapido.tex`).
- Bibliografia mínima em `bibliography/references.tex` (use BibTeX se preferir).
 - Bibliografia:
   - Padrão: `bibliography/references.tex` (thebibliography).
   - Alternativa: BibTeX com `bibliography/sbc-template.bib` + `bibliography/sbc.bst`.
     - Compilação manual (exemplo):
       `pdflatex article-main-v2.tex && bibtex article-main-v2 && pdflatex article-main-v2.tex && pdflatex article-main-v2.tex`

## Bibliografia: .tex vs .bib

- Arquivo `.tex` (thebibliography)
  - Entradas escritas manualmente em `bibliography/references.tex`.
  - Sem ferramentas extras; ideal para listas pequenas/estáticas.
- Arquivo `.bib` (BibTeX)
  - Referências estruturadas em `bibliography/sbc-template.bib`; estilo definido por `sbc.bst`.
  - Consistência automática e reuso entre projetos; ideal para muitas referências.
- Como alternar para BibTeX neste template
  - No arquivo principal da sua variante (ex.: `paper-main.tex`, `monograph-main.tex`, `thesis-main.tex`), comente a linha: `\input{bibliography/references}`.
  - Adicione ao final do arquivo principal:
    `\bibliographystyle{sbc}` e `\bibliography{bibliography/sbc-template}`.
  - Compile com: `make bib MAIN_FILE=<variante>` (ou manualmente `pdflatex → bibtex → pdflatex → pdflatex`).
  - Observação: se o BibTeX não localizar `sbc.bst` dentro de `bibliography/`, mova `sbc.bst` para a raiz do projeto ou ajuste seu TEXINPUTS.

## Como Usar (Passo a Passo)

1) Metadados (título, autor, instituição)
- Edite o arquivo de config da sua variante:
  - Paper: `config/paper-config.tex`
  - Monografia: `config/monograph-config.tex`
  - Tese: `config/thesis-config.tex`
  - Legado: `config/article-config.tex`
- Preencha os comandos:
  - `\newcommand{\DocumentTitle}{[Título do Trabalho]}`
  - `\newcommand{\AuthorName}{[Nome do Autor]}`
  - `\newcommand{\AuthorInstitution}{[Departamento / Curso] -- [Instituição]}`
  - `\newcommand{\AuthorLocation}{[Cidade] -- [UF] -- [País]}`
  - `\newcommand{\AuthorEmail}{[email@exemplo.com]}`
- Os metadados do PDF (hypersetup) são preenchidos automaticamente.

2) Estrutura de pastas
- `chapters/`: capítulos numerados `NN-nome.tex` incluídos via `\input{chapters/NN-nome}`.
- `sections/`: abstract/resumo.
- `bibliography/`: referências em `references.tex` (thebibliography) ou `sbc-template.bib` (BibTeX) + `sbc.bst`.
- `config/`: estilos e centralização de pacotes/macros.
- `assets/`: imagens/diagramas; já incluída no caminho por `\graphicspath`.
- `output/`: PDF final e `build.log` (gerado pelo Makefile).

3) Adicionar capítulos/seções
- Crie `chapters/09-apendices.tex` (exemplo) e adicione no arquivo principal da sua variante (ex.: `paper-main.tex`, `monograph-main.tex`, `thesis-main.tex`):
  `\input{chapters/09-apendices}`
- Use labels: `\label{sec:minha-secao}` e referências `\ref{sec:minha-secao}`.

4) Figuras e tabelas
- Imagens: coloque arquivos em `assets/` e inclua com `\includegraphics[width=...] {arquivo}` (sem caminho, graças ao `\graphicspath`). Rotule com `\label{fig:...}` e referencie com `\ref{fig:...}`.
- Tabelas: prefira `booktabs` (`\toprule`, `\midrule`, `\bottomrule`). Veja o exemplo em `04-avaliacao-resultados.tex`.
 - Tabelas largas com `tabularx`: exemplo em `sections/guia-rapido.tex` (usa colunas `X`).

5) Citações e bibliografia
- thebibliography: edite `bibliography/references.tex` e cite com `\cite{chave}`.
- BibTeX: comente `\input{bibliography/references}` e descomente:
  `\bibliographystyle{sbc}` e `\bibliography{bibliography/sbc-template}`.
  Compile com `make bib`.

6) Sumário e hyperlinks
- **Paper:** sumário não é comum em artigos curtos; descomente `\tableofcontents` se necessário.
- **Monografia/Tese:** sumário (`\tableofcontents`) já incluído automaticamente.
- Os links e metadados do PDF são configurados por `hyperref` (nos arquivos de config).

7) Guia Rápido de LaTeX
- Exemplos prontos (figuras lado a lado com `minipage`, tabela larga com `tabularx`, equações com `\eqref`, `listings` e opcional `minted`) estão em `sections/guia-rapido.tex`. Para incluir: `\input{sections/guia-rapido}`.

8) Glossário e Índice (opcionais)
- Glossário:
  - Ative em `config/article-config.tex`: `\usepackage[acronym]{glossaries}` e `\makeglossaries`.
  - Defina entradas com `\newglossaryentry`/`\newacronym` (crie um arquivo dedicado se preferir) e chame `\printglossaries` no final do documento.
  - Compile com: `make glossary` (gera e integra o glossário).
- Índice remissivo:
  - Ative em `config/article-config.tex`: `\usepackage{imakeidx}` e `\makeindex`.
  - Marque termos com `\index{termo}` e chame `\printindex` no final.
  - Compile com: `make index`.

9) Compilar e visualizar
- Padrão: `make compile` (2 passagens de pdflatex) e `make view`.
- BibTeX: `make bib` ou `make view-bib`.
- Logs: consulte `output/build.log` em caso de erro.

## Makefile explicado

- Variáveis:
  - `MAIN_FILE`: arquivo principal sem extensão (padrão: `article-main-v2`).
    - Para outras variantes, use: `MAIN_FILE=paper-main`, `MAIN_FILE=monograph-main`, ou `MAIN_FILE=thesis-main`.
  - `OUTPUT_DIR`: pasta de saída (`output/`).
  - `BACKUP_DIR`: onde ficam backups (`backups/`).
  - `ENGINE`: motor LaTeX (`pdflatex`, `xelatex` ou `lualatex`).
  - `TEXFLAGS`: flags extras (ex.: `-shell-escape` para `minted`).
- Alvos:
  - `make compile`: compila com thebibliography; saída silenciosa; log em `output/build.log`.
  - `make toc`: executa uma terceira passada do engine quando o log indicar mudança de TOC/refs.
  - `make bib`: compila com BibTeX (requer `\bibliographystyle` e `\bibliography`).
  - `make view` / `make view-bib` / `make view-biblatex`: compila e abre o PDF.
  - `make clean`: limpa temporários e apaga `output/`.
  - `make backup`: cria um `.tar.gz` com diretórios principais (sem `output/`).
  - `make stats`: contagem simples de linhas/palavras.
  - `make help`: resume os comandos; indique logs em `output/build.log`.
  - Variável `ENGINE`: troca do motor (`pdflatex` padrão):
    - Ex.: `make ENGINE=xelatex compile` ou `make ENGINE=lualatex biblatex`.

## FAQ / Erros Comuns

- Referências indefinidas (??) ou citações em branco
  - Rode outra passagem de `make compile` (refs internas) ou `make bib`/`make biblatex` (quando usar bibliografia externa).
  - Verifique chaves `\label{...}` e `\cite{...}` correspondentes.
- Figura não encontrada
  - Confirme o nome e extensão do arquivo em `assets/` (sensível a maiúsculas/minúsculas).
  - `\graphicspath` já aponta para `assets/`; inclua sem caminho: `\includegraphics{arquivo}`.
- Erros de fonte/acentuação
  - O template usa `\usepackage[T1]{fontenc}` e `\usepackage[utf8]{inputenc}`; se usar XeLaTeX/LuaLaTeX, remova `inputenc` e configure fontes com `fontspec` (opcional).
- Links não clicáveis
  - `hyperref` já está ativado; compile duas vezes para ajustar sumário e anchors.

## Dicas

- Centralize novos macros/pacotes no arquivo de config da sua variante (`config/paper-config.tex`, `config/monograph-config.tex`, `config/thesis-config.tex`).
- Mantenha o texto conciso e evite linhas muito longas.
- Em caso de erro, rode `make clean` e compile novamente.
- Para migrar entre variantes, copie os metadados do config e ajuste os `\input{chapters/...}` no arquivo principal.

## Validação e Testes / Testing & Validation

Este template inclui uma **suíte de testes abrangente** que valida automaticamente a integridade do template e garante que todas as variantes compilam corretamente.

### Visão Geral / Overview

A suíte de testes valida:
- **Arquivos Obrigatórios** - Todos os arquivos essenciais do template estão presentes
- **Compilação** - Todas as 3 variantes (paper, monograph, thesis) compilam com sucesso
- **Bibliografia** - Todos os 3 backends (thebibliography, BibTeX, BibLaTeX) funcionam
- **Avisos LaTeX** - Detecção de referências indefinidas, citações, overfull hbox, etc.
- **Sistema de Build** - Makefile e scripts de inicialização funcionam corretamente

**Cobertura Total:** ~75 verificações individuais em ~80 segundos

---

The template includes a **comprehensive test suite** that automatically validates template integrity and ensures all variants compile correctly.

The test suite validates:
- **Required Files** - All essential template files are present
- **Compilation** - All 3 variants (paper, monograph, thesis) compile successfully
- **Bibliography** - All 3 backends (thebibliography, BibTeX, BibLaTeX) work
- **LaTeX Warnings** - Detection of undefined references, citations, overfull hbox, etc.
- **Build System** - Makefile and initialization scripts work correctly

**Total Coverage:** ~75 individual checks in ~80 seconds

### Executar Testes / Running Tests

**Executar todos os testes:** / **Run all tests:**
```bash
bash tests/run_all_tests.sh
```

**Executar teste específico:** / **Run specific test:**
```bash
bash tests/run_all_tests.sh --test required_files
bash tests/run_all_tests.sh --test compilation_bibtex
```

**Listar testes disponíveis:** / **List available tests:**
```bash
bash tests/run_all_tests.sh --list
```

**Modo verboso (debugging):** / **Verbose mode (debugging):**
```bash
bash tests/run_all_tests.sh --verbose
```

### Testes Disponíveis / Available Tests

1. **test_required_files** - Valida presença de todos os arquivos essenciais
2. **test_compilation_thebibliography** - Compila todas as variantes com `thebibliography`
3. **test_compilation_bibtex** - Compila todas as variantes com BibTeX
4. **test_compilation_biblatex** - Compila todas as variantes com BibLaTeX/Biber
5. **test_latex_warnings** - Detecta e reporta avisos comuns do LaTeX

### Pré-requisitos para Testes / Test Prerequisites

**Para testes de compilação, você precisa:** / **For compilation tests, you need:**
- Distribuição LaTeX (TeX Live, MiKTeX, ou MacTeX)
- `pdflatex` disponível no PATH
- `bibtex` para testes com BibTeX
- `biber` para testes com BibLaTeX
- Utilitário `make`

**Nota:** O teste de arquivos obrigatórios (`test_required_files`) funciona sem instalação do LaTeX.

---

**Note:** The required files test (`test_required_files`) works without LaTeX installation.

### Documentação Completa / Complete Documentation

Para documentação detalhada sobre a suíte de testes, incluindo:
- Arquitetura dos testes
- Integração CI/CD
- Como adicionar novos testes
- Troubleshooting
- Melhores práticas

**Veja:** [`tests/README.md`](tests/README.md)

---

For detailed test suite documentation, including:
- Test architecture
- CI/CD integration
- How to add new tests
- Troubleshooting
- Best practices

**See:** [`tests/README.md`](tests/README.md)

### Integração CI/CD / CI/CD Integration

A suíte de testes é projetada para integração com pipelines CI/CD:

```yaml
# Exemplo GitHub Actions
- name: Run LaTeX Template Tests
  run: bash tests/run_all_tests.sh
```

**Códigos de saída:** / **Exit codes:**
- `0` - Todos os testes passaram (seguro para deploy)
- `1` - Alguns testes falharam (bloquear deployment)

---

The test suite is designed for CI/CD pipeline integration:

```yaml
# GitHub Actions example
- name: Run LaTeX Template Tests
  run: bash tests/run_all_tests.sh
```

**Exit codes:**
- `0` - All tests passed (safe to deploy)
- `1` - Some tests failed (block deployment)
