BIN_LIB=WSCLIB
DBGVIEW=*SOURCE

# make the build library (BIN_LIB) the one in binlib.inc in your home directory 
USER_UPPER := $(shell echo $(USER) | tr a-z A-Z)

# here you can do things when you are building in your home directory
ifeq ($(USER_UPPER), $(findstring $(USER_UPPER),$(CURDIR)))
    include  ~/binlib.inc
endif    


all: logerrors.srvpgm utilities.bnddir

logerrors.srvpgm: logerrors.sqlrpgle
 

utilities.bnddir: logerrors.entry 


%.sqlrpgle:
	system "CRTSQLRPGI OBJ($(BIN_LIB)/$*) SRCSTMF('./source/$*.sqlrpgle') \
	COMMIT(*NONE) OBJTYPE(*MODULE) OPTION(*EVENTF) REPLACE(*YES) DBGVIEW($(DBGVIEW)) \
	compileopt('INCDIR(''$(CURDIR)'' ''/wright-service-corp/Utility'')')"
#	@touch $@


%.rpgle:
	system "CRTRPGMOD MODULE($(BIN_LIB)/$*) SRCSTMF('./source/$*.rpgle') DBGVIEW($(DBGVIEW)) REPLACE(*YES)"
#	@touch $@

%.srvpgm:
    # We need the binder source as a member! SRCSTMF on CRTSRVPGM not available on all releases.
	-system -q "CRTSRCPF FILE($(BIN_LIB)/QSRC) RCDLEN(112)"
	system "CPYFRMSTMF FROMSTMF('./header/$*.binder') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QSRC.file/$*.mbr') MBROPT(*replace)"

	system "CRTSRVPGM SRVPGM($(BIN_LIB)/$*) MODULE($(patsubst %,$(BIN_LIB)/%,$(basename $^))) SRCFILE($(BIN_LIB)/QSRC)"
#	@touch $@

%.bnddir:
	-system -q "CRTBNDDIR BNDDIR($(BIN_LIB)/$*)"
	-system -q "ADDBNDDIRE BNDDIR($(BIN_LIB)/$*) OBJ($(patsubst %.entry,(*LIBL/% *SRVPGM *IMMED),$^))"

%.entry:
    # Basically do nothing..
	@echo ""