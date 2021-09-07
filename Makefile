#!/usr/bin/make -f

BLOG := $(MAKE) -f $(lastword $(MAKEFILE_LIST)) --no-print-directory
ifneq ($(filter-out help,$(MAKECMDGOALS)),)
include config
endif

# The following can be configured in config
BLOG_DATE_FORMAT_INDEX ?= %x
BLOG_DATE_FORMAT ?= %x %X
BLOG_TITLE ?= blog
BLOG_DESCRIPTION ?= blog
BLOG_URL_ROOT ?= http://localhost/blog
BLOG_FEED_MAX ?= 20
BLOG_LAST_MAX ?= 3
BLOG_FEEDS ?=sitemap
BLOG_SRC ?= articles


.PHONY: help init build deploy clean taglist

ARTICLES = $(shell git ls-tree HEAD --name-only -- $(BLOG_SRC)/*.md 2>/dev/null)
TAGFILES = $(patsubst $(BLOG_SRC)/%.md,tags/%,$(ARTICLES))

help:
	$(info make init|build|deploy|clean|taglist)

init:
	mkdir -p $(BLOG_SRC) data templates
	printf '<!DOCTYPE html><html><head><title>$$TITLE</title></head><body>' > templates/header.html
	printf '</body></html>' > templates/footer.html
	printf '' > templates/index_header.html
	printf '<h2>Articles</h2><ul id=artlist>' > templates/article_list_header.html
	printf '<li><a href="$$URL">$$DATE $$TITLE</a></li>' > templates/article_entry.html
	printf '' > templates/article_separator.html
	printf '</ul>' > templates/article_list_footer.html
	printf '' > templates/index_footer.html
	printf '' > templates/tag_index.html
	printf '' > templates/article_header.html
	printf '' > templates/article_footer.html
	printf 'blog\n' > .git/info/exclude

build: blog/index.html blog/acerca.html blog/enviar.html tagpages $(patsubst $(BLOG_SRC)/%.md,blog/%.html,$(ARTICLES)) $(patsubst %,blog/%.xml,$(BLOG_FEEDS))

deploy:build
	diff -u --exclude=CNAME docs/ blog/ > deploy.diff; [ $$? -eq 1 ]
	patch -p0  < deploy.diff 


clean:
	rm -rf blog tags deploy.diff

config:
	printf 'BLOG_REMOTE:=%s\n' \
		'$(shell printf "Blog remote (eg: host:/var/www/html): ">/dev/tty; head -n1)' \
		> $@

tags/%: $(BLOG_SRC)/%.md
	mkdir -p tags
	grep -ih '^; *tags:' "$<" | cut -d: -f2- | tr -c '[^a-z\-]' ' ' | sed 's/  */\n/g' | sed '/^$$/d' | sort -u > $@

blog/acerca.html: index.md $(ARTICLES) $(addprefix templates/,$(addsuffix .html,header banner footer))
	mkdir -p blog
	cp data/style.css blog/
	TITLE="$(BLOG_TITLE)"; \
	PAGE_TITLE="Acerca de este sitio"; \
	export TITLE; \
	export PAGE_TITLE; \
	envsubst < templates/header.html > $@; \
	envsubst < templates/banner.html >> $@; \
	markdown < index.md >> $@; \
	envsubst < templates/footer.html >> $@; \

blog/enviar.html: $(ARTICLES) $(addprefix templates/,$(addsuffix .html,header banner footer))
	mkdir -p blog
	TITLE="$(BLOG_TITLE)"; \
	PAGE_TITLE="Enviar recetas"; \
	export TITLE; \
	export PAGE_TITLE; \
	envsubst < templates/header.html > $@; \
	envsubst < templates/banner.html >> $@; \
	markdown < enviar.md >> $@; \
	envsubst < templates/footer.html >> $@; \

blog/index.html: $(ARTICLES) $(addprefix templates/,$(addsuffix .html,header banner article_list_header article_entry article_separator article_list_footer footer))
	mkdir -p blog
	TITLE="$(BLOG_TITLE)"; \
	PAGE_TITLE="$(BLOG_TITLE)"; \
	export TITLE; \
	export PAGE_TITLE; \
	envsubst < templates/header.html > $@; \
	envsubst < templates/banner.html >> $@; \
	printf '<p>Esta es una pagina web de recetas de cocina. Sin anuncios, sin seguimiento, nada mas que recetas.</p>\n' >> $@; \
	envsubst < templates/article_list_header.html >> $@; \
	first=true; \
	echo $(ARTICLES); \
	for f in $(ARTICLES); do \
		printf '%s ' "$$f"; \
		git log -n 1 --diff-filter=A --date="format:%s $(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
	done | sort | cut -d" " -f1,3- | while IFS=" " read -r FILE DATE; do \
		"$$first" || envsubst < templates/article_separator.html; \
		URL="`printf '%s' "\$$FILE" | sed 's,^$(BLOG_SRC)/\(.*\).md,\1,'`.html" \
		DATE="$$DATE" \
		TITLE="`head -n1 "\$$FILE" | sed -e 's/^# //g'`" \
		envsubst < templates/article_entry.html; \
		first=false; \
	done >> $@; \
	envsubst < templates/article_list_footer.html >> $@; \
	envsubst < templates/footer.html >> $@; \

blog/tag/%.html: $(ARTICLES) $(addprefix templates/,$(addsuffix .html,header tag_header index_entry tag_footer footer))

.PHONY: tagpages
tagpages: $(TAGFILES)
	+$(BLOG) $(patsubst %,blog/@%.html,$(shell cat $(TAGFILES) | sort -u))

blog/@%.html: $(TAGFILES) $(addprefix templates/,$(addsuffix .html,header tag_index article_entry article_separator article_list_footer footer))
	mkdir -p blog
	PAGE_TITLE="Etiqueta: $* -- $(BLOG_TITLE)"; \
	TAGS="$*"; \
	TITLE="$(BLOG_TITLE)"; \
	export PAGE_TITLE; \
	export TAGS; \
	export TITLE; \
	envsubst < templates/header.html > $@; \
	envsubst < templates/banner.html >> $@; \
	envsubst < templates/tag_index.html >> $@; \
	printf '<ul id="myUL">\n' >> $@; \
	first=true; \
	for f in $(shell awk '$$0 == "$*" { gsub("tags", "$(BLOG_SRC)", FILENAME); print FILENAME  ".md"; nextfile; }' $(TAGFILES)); do \
		printf '%s ' "$$f"; \
		git log -n 1 --diff-filter=A --date="format:%s $(BLOG_DATE_FORMAT_INDEX)" --pretty=format:'%ad%n' -- "$$f"; \
	done | sort | cut -d" " -f1,3- | while IFS=" " read -r FILE DATE; do \
		"$$first" || envsubst < templates/article_separator.html; \
		URL="`printf '%s' "\$$FILE" | sed 's,^$(BLOG_SRC)/\(.*\).md,\1,'`.html" \
		DATE="$$DATE" \
		TITLE="`head -n1 "\$$FILE" | sed -e 's/^# //g'`" \
		envsubst < templates/article_entry.html; \
		first=false; \
	done >> $@; \
	printf '</ul>\n' >> $@; \
	envsubst < templates/footer.html >> $@; \


blog/%.html: $(BLOG_SRC)/%.md $(addprefix templates/,$(addsuffix .html,header article_header tag_link article_footer footer))
	mkdir -p blog
	TITLE="$(shell head -n1 $< | sed 's/^# \+//')"; \
	export TITLE; \
	PAGE_TITLE="Receta: $${TITLE}  -- $(BLOG_TITLE)"; \
	export PAGE_TITLE; \
	AUTHOR="$(shell git log --format="%an" -- "$<" | tail -n 1)"; \
	export AUTHOR; \
	DATE_POSTED="$(shell git log -n 1 --diff-filter=A --date="format:$(BLOG_DATE_FORMAT)" --pretty=format:'%ad' -- "$<")"; \
	export DATE_POSTED; \
	DATE_EDITED="$(shell git log -n 1 --date="format:$(BLOG_DATE_FORMAT)" --pretty=format:'%ad' -- "$<")"; \
	export DATE_EDITED; \
	TAGS="$(shell grep -i '^; *tags:' "$<" | cut -d: -f2- | paste -sd ',')"; \
	export TAGS; \
	envsubst < templates/header.html > $@; \
	envsubst < templates/article_header.html >> $@; \
	sed -e '/^;/d' < $< | markdown -f fencedcode >> $@; \
	printf '<p><i>Etiquetas de la receta:\n' >> $@; \
	for i in $${TAGS} ; do \
		TAG_NAME="$$i" \
		TAG_LINK="./@$$i.html" \
		envsubst < templates/tag_link.html >> $@; \
	done; \
	printf '</i></p>\n' >> $@; \
	envsubst < templates/article_footer.html >> $@; \
	envsubst < templates/footer.html >> $@; \

blog/sitemap.xml: $(ARTICLES)
	printf '<?xml version="1.0" encoding="ISO-8859-2"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' >> $@
	for f in $(ARTICLES); do \
		printf '%s ' "$$f"; \
		git log  -1 --date="format:%s %Y-%m-%dT%H:%M:%S" --pretty=format:'%ad%n' -- "$$f"; \
	done | sort -k2nr | cut -d" " -f1,3- | while IFS=" " read -r FILE DATE; do \
		printf '<url>\n<loc>%s</loc>\n<lastmod>%s</lastmod>\n</url>\n' \
			"$(BLOG_URL_ROOT)`basename $$FILE | sed 's/\.md/\.html/'`" \
			"$$DATE"; \
	done >> $@
	printf '</urlset>\n' >> $@

taglist:
	grep -RIh '^;tags:' src | cut -d' ' -f2- | tr ' ' '\n' | sort | uniq
