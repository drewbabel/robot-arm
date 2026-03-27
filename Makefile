# Robot Arm - FPGA Build Flow (Basys 3 / Artix-7)

TOP          = top
SOURCES      = top.v pwm.v clk_div.v spi.v

# Tool paths
NEXTPNR      = $(HOME)/Documents/code/nextpnr-xilinx/nextpnr-xilinx
CHIPDB       = $(HOME)/Documents/code/nextpnr-xilinx/xilinx/xc7a35t.bin
DBROOT       = $(HOME)/Documents/code/nextpnr-xilinx/xilinx/external/prjxray-db/artix7
FASM2FRAMES  = python3 $(HOME)/Documents/code/prjxray/utils/fasm2frames.py
FRAMES2BIT   = $(HOME)/Documents/code/prjxray/build/tools/xc7frames2bit
DEVICE       = xc7a35tcpg236-1

# Default target
all: $(TOP).bit

# Step 1: Synthesis
$(TOP).json: $(SOURCES)
	yosys -p "synth_xilinx -flatten -abc9 -nodsp -arch xc7 -top $(TOP); write_json $@" $(SOURCES)

# Step 2: Place & Route
$(TOP).fasm: $(TOP).json basys3.xdc
	$(NEXTPNR) --chipdb $(CHIPDB) --xdc basys3.xdc --json $< --fasm $@

# Step 3: FASM to Frames
$(TOP).frames: $(TOP).fasm
	$(FASM2FRAMES) --db-root $(DBROOT) --part $(DEVICE) $< > $@ 2>/dev/null

# Step 4: Frames to Bitstream
$(TOP).bit: $(TOP).frames
	$(FRAMES2BIT) --part-file $(DBROOT)/$(DEVICE)/part.yaml \
	              --part-name $(DEVICE) \
	              --frm-file $< --output-file $@

# Program
program: $(TOP).bit
	openFPGALoader -b basys3 $<

# Simulation
sim: $(SOURCES) $(TOP)_tb.v
	iverilog -o $(TOP)_tb $(SOURCES) $(TOP)_tb.v
	vvp $(TOP)_tb

# Clean
clean:
	rm -f *.json *.fasm *.frames *.bit *.vcd *_tb

.PHONY: all program sim clean
