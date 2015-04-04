PROG = $(subst .pl,,$(wildcard *.pl))
PERL = $(shell which perl)
INSTALL = install
POD2MAN = pod2man
POD2HTML = pod2html
POD2LATEX = pod2latex
LATEX = latex
DVIPS = dvips
ETAGS = etags
ifndef DESTDIR
DESTDIR = /usr/local
endif
TARGET = $(PROG)
SRC = $(PROG).pl
VERSION = $(shell perl -e 'while (<>) { $$_ =~ "VERSION ?= ?([0-9.]+)" && print $$1 }' $(SRC))

DIST = $(TARGET)-$(VERSION)

all: man $(TARGET)

$(TARGET): $(SRC)
	$(PERL) -e 'while (<>) { s:/usr/bin/perl:$(PERL):; print; } ' $< > $@
	chmod 755 $@

man: $(TARGET).1
$(TARGET).1: $(SRC)
	$(POD2MAN) --release=$(VERSION) --center "" $< $@

html: $(TARGET).html
$(TARGET).html: $(SRC)
	$(POD2HTML) $< > $@

install-strip:
install: all installdirs
	$(INSTALL) $(PROG).1 ${DESTDIR}/man/man1
	$(INSTALL) -m 755 $(TARGET) ${DESTDIR}/bin

installdirs:
	$(INSTALL) -d ${DESTDIR}/man/man1
	$(INSTALL) -d ${DESTDIR}/bin

uninstall:
	rm -f ${DESTDIR}/man/man1
	rm -f ${DESTDIR}/bin


clean: mostlyclean
mostlyclean:
	rm -f *~ \#*\# *.aux *.log *.tex *.tmp

distclean: clean
	rm -rf *.dvi *.html *.1 $(TARGET) *.gz

maintainer-clean: distclean
	@echo 'This command is intended for maintainers to use; it'
	@echo 'deletes files that may need special tools to rebuild.'
	rm -f TAGS *.tar.gz

TAGS: $(SRC)
	$(ETAGS) $(SRC)

dvi: $(TARGET).dvi
$(TARGET).dvi: $(TARGET).tex
	$(LATEX) $<

ps: $(TARGET).ps
$(TARGET).ps: $(TARGET).dvi
	$(DVIPS) -o $(TARGET).ps $(TARGET).dvi

$(TARGET).tex: $(SRC)
	$(POD2LATEX) $<
	echo "\documentclass[a4paper, 10pt]{article}" > $@
	echo "\begin{document}" >> $@
	cat $(SRC).tex >> $@
	echo "\end{document}" >> $@

dist: distclean
	rm -rf $(DIST)
	all=`echo *` && mkdir $(DIST) && cp -r $$all $(DIST)
	tar cvzf $(PKGDIR)$(DIST).tar.gz $(DIST)
	$(POD2MAN) --release=$(VERSION) --center "" $(SRC) $(TARGET).1
	groff -C -s -p -t -e -Tascii -mandoc $(TARGET).1 |\
          sed -e 's:.::g' > $(PKGDIR)$(TARGET).txt
	rm -rf $(DIST) *.tmp $(TARGET).1
# NB : pod2txt is bugged with newline

check: $(TARGET)
	./$(PROG)

installcheck:
	$(DESTDIR)/bin/$(TARGET)

info:
	@echo "No info manual available"
