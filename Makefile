src:=simple.v
tb:=simple_tb.v
vvp:=$(patsubst %.v,%.vvp,$(src))
vcd:=$(patsubst %.v,%.vcd,$(src))

.PHONY: clean wf

all: $(vvp)
	@echo Run simulation and dump waveform
	vvp $(vvp)

$(vvp): $(src) $(tb)
	@echo Compile RTL: $(src), $(tb)
	iverilog -o $@ $^

clean:
	rm -f $(vvp) $(vcd)

wf:
	gtkwave $(vcd) &

