library ieee;
library work;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.oxiToAxiSkid;

-- axi skid buffer
entity axiToOxiToAxiSkid is
	generic(width: integer := 8; tuserWidth: integer := 1);
	port(aclk: in std_logic;
		din_tvalid: in std_logic;
		din_tready: out std_logic;
		din_tdata: in std_logic_vector(width-1 downto 0);
		din_tuser: in std_logic_vector(tuserWidth-1 downto 0) := (others=>'0');
		din_tlast: in std_logic := '0';

		dout_tvalid: out std_logic;
		dout_tready: in std_logic;
		dout_tdata: out std_logic_vector(width-1 downto 0);
		dout_tuser: out std_logic_vector(tuserWidth-1 downto 0);
		dout_tlast: out std_logic);
end entity;
architecture a of axiToOxiToAxiSkid is
	attribute X_INTERFACE_INFO : string;
	attribute X_INTERFACE_PARAMETER : string;

	attribute X_INTERFACE_INFO of aclk : signal is "xilinx.com:signal:clock:1.0 signal_clock CLK";
	attribute X_INTERFACE_PARAMETER of aclk: signal is "ASSOCIATED_BUSIF din:dout";

	attribute X_INTERFACE_INFO of din_tvalid: signal is "xilinx.com:interface:axis_rtl:1.0 din tvalid";
	attribute X_INTERFACE_INFO of din_tready: signal is "xilinx.com:interface:axis_rtl:1.0 din tready";
	attribute X_INTERFACE_INFO of din_tdata: signal is "xilinx.com:interface:axis_rtl:1.0 din tdata";
	attribute X_INTERFACE_INFO of din_tuser: signal is "xilinx.com:interface:axis_rtl:1.0 din tuser";
	attribute X_INTERFACE_INFO of din_tlast: signal is "xilinx.com:interface:axis_rtl:1.0 din tlast";
	attribute X_INTERFACE_INFO of dout_tvalid: signal is "xilinx.com:interface:axis_rtl:1.0 dout tvalid";
	attribute X_INTERFACE_INFO of dout_tready: signal is "xilinx.com:interface:axis_rtl:1.0 dout tready";
	attribute X_INTERFACE_INFO of dout_tdata: signal is "xilinx.com:interface:axis_rtl:1.0 dout tdata";
	attribute X_INTERFACE_INFO of dout_tuser: signal is "xilinx.com:interface:axis_rtl:1.0 dout tuser";
	attribute X_INTERFACE_INFO of dout_tlast: signal is "xilinx.com:interface:axis_rtl:1.0 dout tlast";

	constant W: integer := width+tuserWidth+1;
	signal i_tstrobe, i_tready, i_tready1: std_logic;
	signal i_tdata, o_tdata: std_logic_vector(W-1 downto 0);
begin
	-- convert axi to oxi
	i_tdata <= din_tlast & din_tuser & din_tdata;
	i_tstrobe <= din_tvalid and i_tready1;
	i_tready1 <= i_tready when rising_edge(aclk);
	din_tready <= i_tready1;

	skid: entity oxiToAxiSkid
		generic map(width=>W, depthOrder=>3)
		port map(aclk=>aclk,
			din_tstrobe=>i_tstrobe,
			din_tready=>i_tready,
			din_tdata=>i_tdata,
			dout_tvalid=>dout_tvalid,
			dout_tready=>dout_tready,
			dout_tdata=>o_tdata);
	dout_tdata <= o_tdata(dout_tdata'range);
	dout_tuser <= o_tdata(width+tuserWidth-1 downto width);
	dout_tlast <= o_tdata(o_tdata'left);
end a;
