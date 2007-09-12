# $Id: Makefile,v 1.9 2005/04/01 07:29:28 jaalto Exp $
#
#	Copyright (C)  2003  Jari Aalto
#	Keywords:      Makefile, Dynamic DNS, Networking, Cygwin
#
#	This program is free software; you can redistribute it and/or
#	modify it under the terms of the GNU General Public License as
#	published by the Free Software Foundation; either version 2 of the
#	License, or (at your option) any later version

ifneq (,)
This makefile requires GNU Make.
endif

PACKAGE		= dyndns
PL		= $(PACKAGE).pl

DOCS		= doc/txt doc/html doc/man
SRCS		= bin/$(PL)
MANS		= $(SRCS:.pl=.1)
OBJS		= $(SRCS) Makefile README ChangeLog

MAKE_INCLUDEDIR = etc/makefile

include $(MAKE_INCLUDEDIR)/id.mk
include $(MAKE_INCLUDEDIR)/vars.mk
include $(MAKE_INCLUDEDIR)/cygwin.mk
include $(MAKE_INCLUDEDIR)/unix.mk
#include $(MAKE_INCLUDEDIR)/net.mk

# ######################################################## &suffixes ###

.SUFFIXES:
.SUFFIXES: .pl .1

#   Pod generates .x~~ extra files and rm(1) cleans them
#
#   $< = name of the input (full)
#   $@ = name, but only basename part, without suffix
#   D  = macro; Give only directory part
#   F  = macro; Give only file part

.pl.1:
	perl $< --Help-man > doc/man/$(*F).1
	perl $< --Help-html > doc/html/$(*F).html
	perl $< --help > doc/txt/$(*F).txt
	-rm  -f *[~#] *.tmp

doc/man/$(PACKAGE).1: $(SRCS_PL)
	make docs

# ######################################################### &targets ###

# Rule: all - Make and Compile all.
all: perl-fix doc

install: install-log install-etc install-unix

# Rule: clean - Remove files that can be generated
clean: clean-temp-files

# Rule: distclean - Remove files that can be generated
distclean: clean

# Rule: distclean - Clean everything
realclean: clean-temp-realclean clean

test:
	@echo "Nothing to test. Try and report bugs to <$(EMAIL)>"

$(DOCS):
	$(INSTALL) $(INSTALL_DATA) -d $@

# Rule: docs - Generate or update documentation (force)
docs: $(DOCS) $(MANS)

# Rule: doc - Generate or update documentation
doc: $(DOCS) doc/man/$(PACKAGE).1

# Rule: perl-fix - Change 1st line in *.pl file to match system perl
perl-fix:
	@export perl=`which perl`;				 \
	if [ "$$perl" ] && [ "$$perl" != "/usr/bin/perl" ]; then \
	    echo "Fixing Perl location to #!$$perl";		 \
	    perl -pe 's/!.*perl/!$$ENV{perl}/ if $$. == 1'	 \
		$(SRCS) > $(SRCS).tmp &&			 \
	    if [ -s $(SRCS).tmp ] ; then			 \
		mv $(SRCS).tmp $(SRCS);				 \
	    fi							 \
	fi

# ######################################################### &release ###

#   Check that program does not have compilation errors
release-check:
	perl -cw $(SRCS)

# these two are Synonyms
release: kit

# Rule: kit - [maintenance] Make a World and Cygwin kits
kit: release-check release-world release-cygwin

# End of file