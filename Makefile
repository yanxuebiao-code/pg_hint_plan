#
# pg_hint_plan: Makefile
#
# Copyright (c) 2012-2021, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
#

MODULES = pg_hint_plan
HINTPLANVER = 1.4

REGRESS = init base_plan pg_hint_plan ut-init ut-A ut-S ut-J ut-L ut-G ut-R ut-fdw ut-W ut-T ut-fini hints_anywhere

#REGRESSION_EXPECTED = expected/init.out expected/base_plan.out expected/pg_hint_plan.out expected/ut-A.out expected/ut-S.out expected/ut-J.out expected/ut-L.out expected/ut-G.out expected/hints_anywhere.out

REGRESS_OPTS = --encoding=UTF8

EXTENSION = pg_hint_plan
DATA = pg_hint_plan--*.sql

EXTRA_CLEAN = sql/ut-fdw.sql expected/ut-fdw.out RPMS

# Switch environment between standalone make and make check with
# EXTRA_INSTALL from PostgreSQL tree
# run the following command in the PG tree to run a regression test
# loading this module.
# $ make check EXTRA_INSTALL=<this directory> EXTRA_REGRESS_OPTS="--temp-config <this directory>/pg_hint_plan.conf"
ifeq ($(wildcard $(DESTDIR)/../src/Makefile.global),)
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
subdir = `pwd`
top_builddir = $(DESTDIR)/..
include $(DESTDIR)/../src/Makefile.global
include $(DESTDIR)/../contrib/contrib-global.mk
endif

STARBALL14 = pg_hint_plan14-$(HINTPLANVER).tar.gz
STARBALLS = $(STARBALL14)

TARSOURCES = Makefile *.c  *.h COPYRIGHT* \
	pg_hint_plan--*.sql \
	pg_hint_plan.control \
	doc/* expected/*.out sql/*.sql sql/maskout.sh \
	data/data.csv input/*.source output/*.source SPECS/*.spec

installcheck: $(REGRESSION_EXPECTED)

rpms: rpm14

# pg_hint_plan.c includes core.c and make_join_rel.c
pg_hint_plan.o: core.c make_join_rel.c # pg_stat_statements.c

$(STARBALLS): $(TARSOURCES)
	if [ -h $(subst .tar.gz,,$@) ]; then rm $(subst .tar.gz,,$@); fi
	if [ -e $(subst .tar.gz,,$@) ]; then \
	  echo "$(subst .tar.gz,,$@) is not a symlink. Stop."; \
	  exit 1; \
	fi
	ln -s . $(subst .tar.gz,,$@)
	tar -chzf $@ $(addprefix $(subst .tar.gz,,$@)/, $^)
	rm $(subst .tar.gz,,$@)

rpm14: $(STARBALL14)
	MAKE_ROOT=`pwd` rpmbuild -bb SPECS/pg_hint_plan14.spec
