# library for programs
BINLIB=WSCLIB

# library for data
FILELIB=WSCFIL

# shell to use (for consistency)
SHELL=/QOpenSys/usr/bin/qsh

# Compile option for easy debugging
DBGVIEW=*SOURCE


# get your user name in all caps
USER_UPPER := $(shell echo $(USER) | tr a-z A-Z)

# If your user name is in the path, we're assuming this is not 
# going to build in the main libraries
ifeq ($(USER_UPPER), $(findstring $(USER_UPPER),$(CURDIR)))
# so override the BINLIB and FILELIB in binlib.inc in your home directory
    include  ~/binlib.inc
endif

# your library list for rpg compiles
LIBLIST=$(FILELIB) $(BINLIB) WSCFIL CMSFIL


# list of objects for your binding directory
BNDDIRLIST = empclshst.entrymod logerrors.entrysrv

# everything you want to build here
all: empoccchg.sql return_employee_occupation_description.sql empclshst.pgm 

# dependency lists
empclshst.pgm: empclshst.bnddir empclshst.sqlrpgle

empclshst.bnddir: $(BNDDIRLIST)



%.bnddir:
	-system -q "CRTBNDDIR BNDDIR($(BINLIB)/$*)"
	-system -q "ADDBNDDIRE BNDDIR($(BINLIB)/$*) OBJ($(patsubst %.entrysrv,(*LIBL/% *SRVPGM *IMMED), $(patsubst %.entrymod,(*LIBL/% *MODULE *IMMED),$^)))"



# sql statements should build in the data library
%.sql:
	sed 's/FILELIB/$(FILELIB)/g' ./source/$*.sql  > ./source/$*.sql2
	system -q "RUNSQLSTM SRCSTMF('./source/$*.sql2')"
	rm ./source/$*.sql2

%.sqlrpgle:
	liblist -a $(LIBLIST);\
	system "CRTSQLRPGI OBJ($(BINLIB)/$*) SRCSTMF('./source/$*.sqlrpgle') \
	COMMIT(*NONE) OBJTYPE(*MODULE) OPTION(*EVENTF) REPLACE(*YES) DBGVIEW($(DBGVIEW)) \
	compileopt('INCDIR(''$(CURDIR)''   ''/wright-service-corp/Utility'')')"
#   	@touch $@


%.rpgle:
	liblist -a $(LIBLIST);\
	system "CRTRPGMOD MODULE($(BINLIB)/$*) SRCSTMF('./source/$*.rpgle') DBGVIEW($(DBGVIEW)) REPLACE(*YES)"
#	@touch $@


%.pgm:
	liblist -a $(LIBLIST);\
	system "CRTPGM PGM($(BINLIB)/$*)  BNDDIR($(BINLIB)/$*) REPLACE(*YES)"
#	@touch $@

%.clle: 
	-system -q "CRTSRCPF FILE($(BINLIB)/QCLLESRC) RCDLEN(112)"
	system "CPYFRMSTMF FROMSTMF('./source/$*.clle') TOMBR('/QSYS.lib/$(BINLIB).lib/QCLLESRC.file/$*.mbr') MBROPT(*replace)"
	liblist -a $(LIBLIST); system "CRTBNDCL PGM($(BINLIB)/$*) SRCFILE($(BINLIB)/QCLLESRC)"

%.srvpgm:
    # We need the binder source as a member! SRCSTMF on CRTSRVPGM not available on all releases.
	-system -q "CRTSRCPF FILE($(BINLIB)/QSRC) RCDLEN(112)"
	system "CPYFRMSTMF FROMSTMF('./headers/$*.binder') TOMBR('/QSYS.lib/$(BINLIB).lib/QSRC.file/$*.mbr') MBROPT(*replace)"

	system "CRTSRVPGM SRVPGM($(BINLIB)/$*) MODULE($(patsubst %,$(BINLIB)/%,$(basename $^))) SRCFILE($(BINLIB)/QSRC)"
#	@touch $@


%.entry:
    # Basically do nothing..
	@echo ""
	
%.entrymod:
    # Basically do nothing..
	@echo ""
	
%.entrysrv:
    # Basically do nothing..
	@echo ""