vlib work
vmap work work 

vlib grlib
vmap grlib grlib

vlib gaisler
vmap gaisler gaisler

vlib techmap
vmap techmap techmap


vcom  -work work ../VHDL/altera_pll.vhd

vcom  -work work ../../../VHDL/common/scarts_amba_pkg.vhd
vcom  -work work ../../../VHDL/common/scarts_pkg.vhd
vcom  -work work ../../../VHDL/common/math_pkg.vhd
vcom  -work work ../../../VHDL/common/synchronizer/sync_pkg.vhd
vcom  -work work ../../../VHDL/common/synchronizer/sync.vhd
vcom  -work work ../../../VHDL/common/synchronizer/sync_beh.vhd

vcom  -work work ../../../VHDL/scarts_core/scarts_core_pkg.vhd
vcom  -work work ../../../VHDL/scarts_core/altera/boot_rom.vhd
vcom  -work work ../../../VHDL/scarts_core/brom.vhd
vcom  -work work ../../../VHDL/scarts_core/byteram.vhd
vcom  -work work ../../../VHDL/scarts_core/dram.vhd
vcom  -work work ../../../VHDL/scarts_core/iram.vhd
vcom  -work work ../../../VHDL/scarts_core/prog.vhd
vcom  -work work ../../../VHDL/scarts_core/regf.vhd
vcom  -work work ../../../VHDL/scarts_core/regfram.vhd
vcom  -work work ../../../VHDL/scarts_core/sysc.vhd
vcom  -work work ../../../VHDL/scarts_core/vectab.vhd
vcom  -work work ../../../VHDL/scarts_core/core.vhd
vcom  -work work ../../../VHDL/scarts_core/bpt.vhd
vcom  -work work ../../../VHDL/scarts_core/wpt.vhd
vcom  -work work ../../../VHDL/scarts_core/rs232.vhd
vcom  -work work ../../../VHDL/scarts_core/AMBA_sharedmem_byteram.vhd
vcom  -work work ../../../VHDL/scarts_core/AMBA_sharedmem_dram.vhd
vcom  -work work ../../../VHDL/scarts_core/ext_AMBA_sharedmem.vhd
vcom  -work work ../../../VHDL/scarts_core/AMBA_AHBMasterStatemachine.vhd
vcom  -work work ../../../VHDL/scarts_core/ext_AMBA.vhd
vcom  -work work ../../../VHDL/scarts_core/scarts.vhd

vcom  -work grlib ../../libraries/grlib/lib/grlib/stdlib/version.vhd
vcom  -work grlib ../../libraries/grlib/lib/grlib/stdlib/stdlib.vhd
vcom  -work grlib ../../libraries/grlib/lib/grlib/stdlib/config.vhd
vcom  -work grlib ../../libraries/grlib/lib/grlib/stdlib/stdio.vhd
vcom  -work grlib ../../libraries/grlib/lib/grlib/stdlib/testlib.vhd
vcom  -work grlib ../../libraries/grlib/lib/grlib/amba/amba.vhd
vcom  -work grlib ../../libraries/grlib/lib/grlib/amba/devices.vhd
vcom  -work grlib ../../libraries/grlib/lib/grlib/amba/defmst.vhd
vcom  -work grlib ../../libraries/grlib/lib/grlib/amba/ahbctrl.vhd
vcom  -work grlib ../../libraries/grlib/lib/grlib/amba/apbctrl.vhd
vcom  -work grlib ../../libraries/grlib/lib/grlib/util/util.vhd

vcom  -work techmap ../../libraries/grlib/lib/techmap/gencomp/gencomp.vhd
vcom  -work techmap ../../libraries/grlib/lib/techmap/maps/allpads.vhd
vcom  -work techmap ../../libraries/grlib/lib/techmap/maps/inpad.vhd
vcom  -work techmap ../../libraries/grlib/lib/techmap/maps/iopad.vhd
vcom  -work techmap ../../libraries/grlib/lib/techmap/maps/outpad.vhd
vcom  -work techmap ../../libraries/grlib/lib/techmap/altera_mf/memory_altera_mf.vhd
vcom  -work techmap ../../libraries/grlib/lib/techmap/maps/allmem.vhd

vcom  -work gaisler ../../libraries/grlib/lib/techmap/maps/allmem.vhd
vcom  -work gaisler ../../libraries/grlib/lib/gaisler/misc/misc.vhd
vcom  -work gaisler ../../libraries/grlib/lib/gaisler/misc/charrom_package.vhd
vcom  -work gaisler ../../libraries/grlib/lib/gaisler/misc/charrom.vhd
vcom  -work gaisler ../../libraries/grlib/lib/techmap/maps/syncram_2p.vhd
vcom  -work gaisler ../../libraries/grlib/lib/gaisler/misc/apbvga.vhd

vcom  -work gaisler ../../libraries/grlib/lib/gaisler/misc/ahbmst.vhd
vcom  -work gaisler ../../libraries/grlib/lib/gaisler/misc/svgactrl.vhd
vcom  -work gaisler ../../libraries/grlib/lib/gaisler/memctrl/memctrl.vhd
vcom  -work gaisler ../../libraries/grlib/lib/gaisler/memctrl/sdctrl.vhd

vcom  -work work ../../../VHDL/ext_modules/ext_Dis7Seg/pkg_Dis7Seg.vhd
vcom  -work work ../../../VHDL/ext_modules/ext_Dis7Seg/ext_Dis7Seg_ent.vhd
vcom  -work work ../../../VHDL/ext_modules/ext_Dis7Seg/ext_Dis7Seg.vhd
vcom  -work work ../../../VHDL/ext_modules/ext_counter/pkg_counter.vhd
vcom  -work work ../../../VHDL/ext_modules/ext_counter/ext_counter_ent.vhd
vcom  -work work ../../../VHDL/ext_modules/ext_counter/ext_counter.vhd
vcom  -work work ../../../VHDL/ext_modules/ext_miniUART/ext_miniUART_pkg.vhd


vcom  -work work ../../../VHDL/ext_modules/ext_key_matrix/debounce/debounce_pkg.vhd
vcom  -work work ../../../VHDL/ext_modules/ext_key_matrix/debounce/debounce.vhd
vcom  -work work ../../../VHDL/ext_modules/ext_key_matrix/debounce/debounce_struct.vhd
vcom  -work work ../../../VHDL/ext_modules/ext_key_matrix/debounce/debounce_fsm.vhd
vcom  -work work ../../../VHDL/ext_modules/ext_key_matrix/debounce/debounce_fsm_beh.vhd

vcom  -work work ../../../VHDL/ext_modules/ext_key_matrix/key_matrix/key_matrix_pkg.vhd
vcom  -work work ../../../VHDL/ext_modules/ext_key_matrix/key_matrix/key_matrix.vhd
vcom  -work work ../../../VHDL/ext_modules/ext_key_matrix/key_matrix/key_matrix_beh.vhd
vcom  -work work ../../../VHDL/ext_modules/ext_key_matrix/ext_key_matrix_pkg.vhd
vcom  -work work ../../../VHDL/ext_modules/ext_key_matrix/ext_key_matrix.vhd
vcom  -work work ../../../VHDL/ext_modules/ext_key_matrix/ext_key_matrix_beh.vhd

vcom  -work work ../VHDL/top_pkg.vhd
vcom  -work work ../VHDL/top.vhd

vcom  -work gaisler ../../libraries/grlib/lib/gaisler/sim/sim.vhd
vcom  -work work ../../libraries/grlib/lib/micron/sdram/mt48lc16m16a2.vhd
