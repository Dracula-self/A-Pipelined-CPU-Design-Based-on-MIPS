-makelib ies_lib/xpm -sv \
  "E:/vivado/vivado/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib ies_lib/xpm \
  "E:/vivado/vivado/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../thinpad_top.srcs/sources_1/ip/pll_example/pll_example_clk_wiz.v" \
  "../../../../thinpad_top.srcs/sources_1/ip/pll_example/pll_example.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

