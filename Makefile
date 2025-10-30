
# ~/src/notes-md/Makefile
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

PANDOC := pandoc
META   := meta.yaml
TPL    := templates/index_template.html
CSS    := css/markdown-memo.css

# list your pages here
PAGES := index.html home.html diff_eq.html hw_1.html

.PHONY: all html clean

all: html

html: $(PAGES)
	@echo "==> html done."

# ------------------------------------------------------------
# 1) ensure css/markdown-memo.css exists
# ------------------------------------------------------------
$(CSS): templates/markdown-memo.css
	@mkdir -p css
	@cp templates/markdown-memo.css $(CSS)
	@echo "[make] copied templates/markdown-memo.css → $(CSS)"

# ------------------------------------------------------------
# 2) build each page using the proper CSS path (relative for GitHub Pages)
# ------------------------------------------------------------
%.html: %.md $(META) $(TPL) $(CSS)
	@echo "[make] pandoc $< → $@"
	@$(PANDOC) --standalone \
		--metadata-file=$(META) \
		--template=$(TPL) \
		--css=css/markdown-memo.css \
		--mathjax \
		-o $@ $<

# ------------------------------------------------------------
# 3) clean generated HTML
# ------------------------------------------------------------
clean:
	@rm -f $(PAGES)
	@echo "[make] cleaned all generated HTML files."

