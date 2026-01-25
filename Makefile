# =================================================================
# Makefile - Template LaTeX (Article/Monografia)
# Autor: Thales Matheus Mendonça Santos
# =================================================================

# Configurações
# MAIN_FILE: arquivo principal sem extensão (.tex). Altere para trocar a entrada.
# OUTPUT_DIR: pasta onde ficam PDF e logs de compilação.
# BACKUP_DIR: pasta para backups gerados via make backup.
# ENGINE: motor LaTeX (pdflatex | xelatex | lualatex)
MAIN_FILE = article-main-v2
OUTPUT_DIR = output
BACKUP_DIR = backups
ENGINE = pdflatex
TEXFLAGS =

# Regras principais
.PHONY: all clean compile view backup help bib view-bib biblatex view-biblatex glossary index toc paper monograph thesis

all: compile

# Compilação principal (thebibliography por padrão)
# - Saída silenciosa (log: $(OUTPUT_DIR)/build.log)
# - Duas passagens do $(ENGINE) para resolver referências
compile:
	@echo "Compilando documento..."
	@mkdir -p $(OUTPUT_DIR)
	@LOG=$(OUTPUT_DIR)/build.log; \
	: > $$LOG; \
	$(ENGINE) $(TEXFLAGS) -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=$(OUTPUT_DIR) $(MAIN_FILE).tex >> $$LOG 2>&1 || (echo "Falha na compilação (passo 1). Veja $$LOG"; tail -n 40 $$LOG; exit 1); \
	$(ENGINE) $(TEXFLAGS) -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=$(OUTPUT_DIR) $(MAIN_FILE).tex >> $$LOG 2>&1 || (echo "Falha na compilação (passo 2). Veja $$LOG"; tail -n 40 $$LOG; exit 1); \
	# Checagem de referências/citações indefinidas
	if grep -Eq "Reference.*undefined|Undefined references|undefined references|Citation.*undefined|There were undefined citations" $$LOG; then \
		echo "Aviso: há referências/citações indefinidas. Consulte $$LOG."; \
		exit 2; \
	fi; \
	rm -f $(OUTPUT_DIR)/$(MAIN_FILE).aux $(OUTPUT_DIR)/$(MAIN_FILE).log $(OUTPUT_DIR)/$(MAIN_FILE).out $(OUTPUT_DIR)/$(MAIN_FILE).toc $(OUTPUT_DIR)/$(MAIN_FILE).lof $(OUTPUT_DIR)/$(MAIN_FILE).lot $(OUTPUT_DIR)/$(MAIN_FILE).bbl $(OUTPUT_DIR)/$(MAIN_FILE).blg $(OUTPUT_DIR)/$(MAIN_FILE).nav $(OUTPUT_DIR)/$(MAIN_FILE).snm $(OUTPUT_DIR)/$(MAIN_FILE).synctex.gz $(OUTPUT_DIR)/$(MAIN_FILE).fdb_latexmk $(OUTPUT_DIR)/$(MAIN_FILE).fls $(OUTPUT_DIR)/$(MAIN_FILE).xdv $(OUTPUT_DIR)/$(MAIN_FILE).dvi; \
	echo "Compilação concluída: $(OUTPUT_DIR)/$(MAIN_FILE).pdf"

# Visualizar PDF (thebibliography)
view: compile
	@open $(OUTPUT_DIR)/$(MAIN_FILE).pdf 2>/dev/null || xdg-open $(OUTPUT_DIR)/$(MAIN_FILE).pdf 2>/dev/null || echo "Abra manualmente: $(OUTPUT_DIR)/$(MAIN_FILE).pdf"

# Variantes do template
# - Compila variantes específicas (paper, monograph, thesis)
paper:
	@$(MAKE) compile MAIN_FILE=paper-main

monograph:
	@$(MAKE) compile MAIN_FILE=monograph-main

thesis:
	@$(MAKE) compile MAIN_FILE=thesis-main

# Limpeza de arquivos temporários
# - Remove artefatos na raiz e a pasta $(OUTPUT_DIR)
clean:
	@echo "Limpando arquivos temporários..."
	@rm -f *.aux *.log *.out *.toc *.lof *.lot *.bbl *.blg
	@rm -rf $(OUTPUT_DIR)
	@echo "Limpeza concluída."

# Backup do projeto
# - Gera .tar.gz com diretórios principais (sem a pasta $(OUTPUT_DIR))
backup:
	@echo "Criando backup..."
	@mkdir -p $(BACKUP_DIR)
	@tar -czf $(BACKUP_DIR)/article-backup-$(shell date +%Y%m%d-%H%M%S).tar.gz \
		chapters/ sections/ config/ bibliography/ $(MAIN_FILE).tex Makefile README.md
	@echo "Backup criado em $(BACKUP_DIR)/"

# Estatísticas do documento (contagem simples)
stats:
	@echo "=== ESTATÍSTICAS DO DOCUMENTO ==="
	@echo "Capítulos: $(shell ls chapters/*.tex | wc -l)"
	@echo "Seções: $(shell ls sections/*.tex | wc -l)"
	@echo "Total de linhas: $(shell cat chapters/*.tex sections/*.tex | wc -l)"
	@echo "Total de palavras: $(shell cat chapters/*.tex sections/*.tex | wc -w)"

# Ajuda
help:
	@echo "=== COMANDOS DISPONÍVEIS ==="
	@echo "make compile  - Compila o documento LaTeX"
	@echo "make paper    - Compila variante paper"
	@echo "make monograph - Compila variante monograph"
	@echo "make thesis   - Compila variante thesis"
	@echo "make bib      - Compila usando BibTeX (.bib)"
	@echo "make view     - Compila e abre o PDF"
	@echo "make view-bib - Compila (BibTeX) e abre o PDF"
	@echo "make clean    - Remove arquivos temporários"
	@echo "make backup   - Cria backup do projeto"
	@echo "make stats    - Mostra estatísticas do documento"
	@echo "make help     - Mostra esta ajuda"
	@echo "(logs em $(OUTPUT_DIR)/build.log)"
# Compilação com BibTeX (.bib)
bib:
	@echo "Compilando documento (BibTeX)..."
	@mkdir -p $(OUTPUT_DIR)
	@LOG=$(OUTPUT_DIR)/build.log; \
	: > $$LOG; \
	$(ENGINE) $(TEXFLAGS) -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=$(OUTPUT_DIR) $(MAIN_FILE).tex >> $$LOG 2>&1 || (echo "Falha na compilação (passo 1). Veja $$LOG"; tail -n 40 $$LOG; exit 1); \
	if ! grep -q "\\\\bibdata" $(OUTPUT_DIR)/$(MAIN_FILE).aux 2>/dev/null; then \
		echo "BibTeX não configurado neste documento. Adicione \\bibliographystyle{...} e \\bibliography{...}."; \
		exit 1; \
	fi; \
	(cd $(OUTPUT_DIR) && bibtex $(MAIN_FILE)) >> $$LOG 2>&1 || (echo "Falha no BibTeX. Veja $$LOG"; tail -n 60 $$LOG; exit 1); \
	$(ENGINE) $(TEXFLAGS) -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=$(OUTPUT_DIR) $(MAIN_FILE).tex >> $$LOG 2>&1 || (echo "Falha na compilação (passo 2). Veja $$LOG"; tail -n 40 $$LOG; exit 1); \
	$(ENGINE) $(TEXFLAGS) -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=$(OUTPUT_DIR) $(MAIN_FILE).tex >> $$LOG 2>&1 || (echo "Falha na compilação (passo 3). Veja $$LOG"; tail -n 40 $$LOG; exit 1); \
	if grep -Eq "Reference.*undefined|Undefined references|undefined references|Citation.*undefined|There were undefined citations" $$LOG; then \
		echo "Aviso: há referências/citações indefinidas. Consulte $$LOG."; \
		exit 2; \
	fi; \
	rm -f $(OUTPUT_DIR)/$(MAIN_FILE).aux $(OUTPUT_DIR)/$(MAIN_FILE).log $(OUTPUT_DIR)/$(MAIN_FILE).out $(OUTPUT_DIR)/$(MAIN_FILE).toc $(OUTPUT_DIR)/$(MAIN_FILE).lof $(OUTPUT_DIR)/$(MAIN_FILE).lot $(OUTPUT_DIR)/$(MAIN_FILE).bbl $(OUTPUT_DIR)/$(MAIN_FILE).blg $(OUTPUT_DIR)/$(MAIN_FILE).nav $(OUTPUT_DIR)/$(MAIN_FILE).snm $(OUTPUT_DIR)/$(MAIN_FILE).synctex.gz $(OUTPUT_DIR)/$(MAIN_FILE).fdb_latexmk $(OUTPUT_DIR)/$(MAIN_FILE).fls $(OUTPUT_DIR)/$(MAIN_FILE).xdv $(OUTPUT_DIR)/$(MAIN_FILE).dvi; \
	echo "Compilação concluída: $(OUTPUT_DIR)/$(MAIN_FILE).pdf"

# Visualizar PDF (BibTeX)
view-bib: bib
	@open $(OUTPUT_DIR)/$(MAIN_FILE).pdf 2>/dev/null || xdg-open $(OUTPUT_DIR)/$(MAIN_FILE).pdf 2>/dev/null || echo "Abra manualmente: $(OUTPUT_DIR)/$(MAIN_FILE).pdf"

# Compilação com biblatex + biber (opção B2)
biblatex:
	@echo "Compilando documento (biblatex + biber)..."
	@mkdir -p $(OUTPUT_DIR)
	@LOG=$(OUTPUT_DIR)/build.log; \
	: > $$LOG; \
	$(ENGINE) $(TEXFLAGS) -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=$(OUTPUT_DIR) $(MAIN_FILE).tex >> $$LOG 2>&1 || (echo "Falha na compilação (passo 1). Veja $$LOG"; tail -n 40 $$LOG; exit 1); \
	if [ ! -f $(OUTPUT_DIR)/$(MAIN_FILE).bcf ]; then \
		echo "biblatex não configurado. Ative o pacote e o addbibresource em config/article-config.tex e \printbibliography no arquivo principal."; \
		exit 1; \
	fi; \
	(cd $(OUTPUT_DIR) && biber $(MAIN_FILE)) >> $$LOG 2>&1 || (echo "Falha no biber. Veja $$LOG"; tail -n 60 $$LOG; exit 1); \
	$(ENGINE) $(TEXFLAGS) -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=$(OUTPUT_DIR) $(MAIN_FILE).tex >> $$LOG 2>&1 || (echo "Falha na compilação (passo 2). Veja $$LOG"; tail -n 40 $$LOG; exit 1); \
	$(ENGINE) $(TEXFLAGS) -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=$(OUTPUT_DIR) $(MAIN_FILE).tex >> $$LOG 2>&1 || (echo "Falha na compilação (passo 3). Veja $$LOG"; tail -n 40 $$LOG; exit 1); \
	if grep -Eq "Reference.*undefined|Undefined references|undefined references|Citation.*undefined|There were undefined citations" $$LOG; then \
		echo "Aviso: há referências/citações indefinidas. Consulte $$LOG."; \
		exit 2; \
	fi; \
	rm -f $(OUTPUT_DIR)/$(MAIN_FILE).aux $(OUTPUT_DIR)/$(MAIN_FILE).log $(OUTPUT_DIR)/$(MAIN_FILE).out $(OUTPUT_DIR)/$(MAIN_FILE).toc $(OUTPUT_DIR)/$(MAIN_FILE).lof $(OUTPUT_DIR)/$(MAIN_FILE).lot $(OUTPUT_DIR)/$(MAIN_FILE).bbl $(OUTPUT_DIR)/$(MAIN_FILE).blg $(OUTPUT_DIR)/$(MAIN_FILE).nav $(OUTPUT_DIR)/$(MAIN_FILE).snm $(OUTPUT_DIR)/$(MAIN_FILE).synctex.gz $(OUTPUT_DIR)/$(MAIN_FILE).fdb_latexmk $(OUTPUT_DIR)/$(MAIN_FILE).fls $(OUTPUT_DIR)/$(MAIN_FILE).xdv $(OUTPUT_DIR)/$(MAIN_FILE).dvi; \
	echo "Compilação concluída: $(OUTPUT_DIR)/$(MAIN_FILE).pdf"

view-biblatex: biblatex
	@open $(OUTPUT_DIR)/$(MAIN_FILE).pdf 2>/dev/null || xdg-open $(OUTPUT_DIR)/$(MAIN_FILE).pdf 2>/dev/null || echo "Abra manualmente: $(OUTPUT_DIR)/$(MAIN_FILE).pdf"

# Glossário (glossaries)
glossary: compile
	@if [ ! -f $(OUTPUT_DIR)/$(MAIN_FILE).glo ]; then echo "Glossário não detectado. Ative glossaries (\usepackage[acronym]{glossaries} e \makeglossaries) e use \newglossaryentry/\newacronym."; exit 1; fi
	@cd $(OUTPUT_DIR) && makeglossaries $(MAIN_FILE) >/dev/null 2>&1 || true
	@$(MAKE) compile >/dev/null 2>&1 || true
	@echo "Glossário atualizado."

# Índice remissivo (imakeidx)
index: compile
	@if [ ! -f $(OUTPUT_DIR)/$(MAIN_FILE).idx ]; then echo "Índice não detectado. Ative imakeidx (\usepackage{imakeidx} e \makeindex) e insira \index{termo}."; exit 1; fi
	@cd $(OUTPUT_DIR) && makeindex $(MAIN_FILE) >/dev/null 2>&1 || true
	@$(MAKE) compile >/dev/null 2>&1 || true
	@echo "Índice atualizado."

# Terceira passada opcional (TOC/refs)
toc: compile
	@LOG=$(OUTPUT_DIR)/build.log; \
	if grep -Eq "Rerun to get (cross-references|outlines) right|Label\(s\) may have changed" $$LOG; then \
		echo "Executando terceira passada do $(ENGINE) (TOC/refs)..."; \
		$(ENGINE) $(TEXFLAGS) -interaction=nonstopmode -halt-on-error -file-line-error -output-directory=$(OUTPUT_DIR) $(MAIN_FILE).tex >> $$LOG 2>&1 || (echo "Falha na terceira passada. Veja $$LOG"; tail -n 60 $$LOG; exit 1); \
		echo "Terceira passada concluída."; \
	else \
		echo "Sem indicação de rerun (TOC/refs)."; \
	fi
