GHDL=ghdl
GHDLFLAGS=--mb-comments

DUMMY_PLUG_SRC_PATH = ../../../Generic_Priority_Encoder/Dummy_Plug/src/main/vhdl
SRC_PATH            = ../../src

all : test_bench_all

clean:
	rm -f *.o *.cf test_bench_all

test_bench_all: test_bench.o 
	 $(GHDL) -e $(GHDLFLAGS) --work=WORK $@
	-$(GHDL) -r $(GHDLFLAGS) --work=WORK $@

test_bench    : test_bench.o 
	 $(GHDL) -e $(GHDLFLAGS) --work=WORK $@
	-$(GHDL) -r $(GHDLFLAGS) --work=WORK $@

test_bench.o  : $(SRC_PATH)/test_bench.vhd priority_encoder.o util.o mt19937ar.o
	 $(GHDL) -a $(GHDLFLAGS) --work=WORK   $<

priority_encoder.o : $(SRC_PATH)/priority_encoder.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=WORK   $<

util.o        : $(DUMMY_PLUG_SRC_PATH)/core/util.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=DUMMY_PLUG $<

mt19937ar.o   : $(DUMMY_PLUG_SRC_PATH)/core/mt19937ar.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=DUMMY_PLUG $<

