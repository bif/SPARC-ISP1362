module ISP1362_IF(	//	avalon MM slave port, ISP1362, host control
					// avalon MM slave, hc interface to nios
					avs_hc_writedata_iDATA,
					avs_hc_readdata_oDATA,
					avs_hc_address_iADDR,
					avs_hc_read_n_iRD_N,
					avs_hc_write_n_iWR_N,
					avs_hc_chipselect_n_iCS_N,
					avs_hc_reset_n_iRST_N,
					avs_hc_clk_iCLK,
					avs_hc_irq_n_oINT0_N,
					// avalon MM slave, dcc interface to nios
					avs_dc_writedata_iDATA,
					avs_dc_readdata_oDATA,
					avs_dc_address_iADDR,
					avs_dc_read_n_iRD_N,
					avs_dc_write_n_iWR_N,
					avs_dc_chipselect_n_iCS_N,
					avs_dc_reset_n_iRST_N,
					avs_dc_clk_iCLK,
					avs_dc_irq_n_oINT0_N,
					//	ISP1362 Side
					USB_DATA,
					USB_ADDR,
					USB_RD_N,
					USB_WR_N,
					USB_CS_N,
					USB_RST_N,
					USB_INT0,
					USB_INT1
				 );
//	to nios
// slave hc
input	[15:0]	avs_hc_writedata_iDATA;
input	 		avs_hc_address_iADDR;
input			avs_hc_read_n_iRD_N;
input			avs_hc_write_n_iWR_N;
input			avs_hc_chipselect_n_iCS_N;
input			avs_hc_reset_n_iRST_N;
input			avs_hc_clk_iCLK;
output	[15:0]	avs_hc_readdata_oDATA;
output			avs_hc_irq_n_oINT0_N;
// slave dc
input	[15:0]	avs_dc_writedata_iDATA;
input			avs_dc_address_iADDR;
input			avs_dc_read_n_iRD_N;
input			avs_dc_write_n_iWR_N;
input			avs_dc_chipselect_n_iCS_N;
input			avs_dc_reset_n_iRST_N;
input			avs_dc_clk_iCLK;
output	[15:0]	avs_dc_readdata_oDATA;
output			avs_dc_irq_n_oINT0_N;



//	ISP1362 Side
inout	[15:0]	USB_DATA;
output	[1:0]	USB_ADDR;
output			USB_RD_N;
output			USB_WR_N;
output			USB_CS_N;
output			USB_RST_N;
input			USB_INT0;
input			USB_INT1;





assign	USB_DATA		=	avs_dc_chipselect_n_iCS_N ? (avs_hc_write_n_iWR_N	?	16'hzzzz	:	avs_hc_writedata_iDATA) :  (avs_dc_write_n_iWR_N	?	16'hzzzz	:	avs_dc_writedata_iDATA) ;
assign	avs_hc_readdata_oDATA		=	avs_hc_read_n_iRD_N	?	16'hzzzz	:	USB_DATA;
assign	avs_dc_readdata_oDATA		=	avs_dc_read_n_iRD_N	?	16'hzzzz	:	USB_DATA;
assign	USB_ADDR		=	avs_dc_chipselect_n_iCS_N? {1'b0,avs_hc_address_iADDR} : {1'b1,avs_dc_address_iADDR};
assign	USB_CS_N		=	avs_hc_chipselect_n_iCS_N & avs_dc_chipselect_n_iCS_N;
assign	USB_WR_N		=	avs_dc_chipselect_n_iCS_N? avs_hc_write_n_iWR_N : avs_dc_write_n_iWR_N;
assign	USB_RD_N		=	avs_dc_chipselect_n_iCS_N? avs_hc_read_n_iRD_N  : avs_dc_read_n_iRD_N;
assign	USB_RST_N		=	avs_dc_chipselect_n_iCS_N? avs_hc_reset_n_iRST_N: avs_dc_reset_n_iRST_N;
assign	avs_hc_irq_n_oINT0_N		=	USB_INT0;
assign	avs_dc_irq_n_oINT0_N		=	USB_INT1;


endmodule

--******************************************* verilog to vhdl ***********************************************************


-- assign	USB_DATA		=	avs_dc_chipselect_n_iCS_N ? (avs_hc_write_n_iWR_N	?	16'hzzzz	:	avs_hc_writedata_iDATA) :  (avs_dc_write_n_iWR_N	?	16'hzzzz	:	avs_dc_writedata_iDATA) ;
if avs_dc_chipselect_n_iCS_N == '1' then
	if avs_hc_write_n_iWR_N = '1' then
 		USB_DATA <=	HIGH_IMPENDANT;	
	else
		USB_DATA <= avs_hc_writedata_iDATA;
	end if;
else
	if avs_dc_write_n_iWR_N	= '1' then
		USB_DATA <= HIGH_IMPENDANT;
	else
		USB_DATA <= avs_dc_writedata_iDATA;
	end if;
end if;

-- assign	avs_hc_readdata_oDATA		=	avs_hc_read_n_iRD_N	?	16'hzzzz	:	USB_DATA;
if avs_hc_read_n_iRD_N = '1' then
	avs_hc_readdata_oDATA <= HIGH_IMPENDANT;
else
	avs_hc_readdata_oDATA <= USB_DATA;
end if;

--assign	avs_dc_readdata_oDATA		=	avs_dc_read_n_iRD_N	?	16'hzzzz	:	USB_DATA;
if avs_dc_read_n_iRD_N = '1' then
	avs_dc_readdata_oDATA <= HIGH_IMPENDANTG;
else
	avs_dc_readdata_oDATA <= USB_DATA;
end if;

--assign	USB_ADDR		=	avs_dc_chipselect_n_iCS_N? {1'b0,avs_hc_address_iADDR} : {1'b1,avs_dc_address_iADDR};
if avs_dc_chipselect_n_iCS_N = '1' then
	USB_ADDR <= ('0', avs_hc_address_iADDR);
else
	USB_ADDR <= ('1', avs_dc_address_iADDR);
end if; 

--assign	USB_CS_N		=	avs_hc_chipselect_n_iCS_N & avs_dc_chipselect_n_iCS_N;
USB_CS_N <= (avs_hc_chipselect_n_iCS_N & avs_dc_chipselect_n_iCS_N); 

--assign	USB_WR_N		=	avs_dc_chipselect_n_iCS_N? avs_hc_write_n_iWR_N : avs_dc_write_n_iWR_N;
if avs_dc_chipselect_n_iCS_N = '1' then
	USB_WR_N <= avs_hc_write_n_iWR_N;
else
	USB_WR_N <= avs_dc_write_n_iWR_N;
end if;

--assign	USB_RD_N		=	avs_dc_chipselect_n_iCS_N? avs_hc_read_n_iRD_N  : avs_dc_read_n_iRD_N;
if avs_dc_chipselect_n_iCS_N = '1' then
	USB_RD_N <= avs_hc_read_n_iRD_N;
else
	USB_RD_N <= avs_dc_read_n_iRD_N;
end if; 

--assign	USB_RST_N		=	avs_dc_chipselect_n_iCS_N? avs_hc_reset_n_iRST_N: avs_dc_reset_n_iRST_N;
if avs_dc_chipselect_n_iCS_N = '1' then
	USB_RST_N <= avs_hc_reset_n_iRST_N;
else
	USB_RST_N <= avs_dc_reset_n_iRST_N;
end if;

--assign	avs_hc_irq_n_oINT0_N		=	USB_INT0;
avs_hc_irq_n_oINT0_N <=	USB_INT0;

--assign	avs_dc_irq_n_oINT0_N		=	USB_INT1;
avs_dc_irq_n_oINT0_N <=	USB_INT1;

