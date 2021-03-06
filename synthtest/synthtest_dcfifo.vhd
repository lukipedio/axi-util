library ieee;
library work;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
USE ieee.math_real.log2;
USE ieee.math_real.ceil;
use work.dcfifo;
use work.axiToOxiToAxiSkid;

-- allow a set amount of data to pass through a pipe
entity synthtest_dcfifo is
	generic(wordWidth: integer := 8);
	port(clk: in std_logic;
		
		-- input pipe
		din_tvalid: in std_logic;
		din_tready: out std_logic;
		din_tdata: in std_logic_vector(wordWidth-1 downto 0);
		
		-- output side
		dout_tvalid: out std_logic;
		dout_tready: in std_logic;
		dout_tdata: out std_logic_vector(wordWidth-1 downto 0));
end entity;
architecture a of synthtest_dcfifo is
    component skidbuffer 
		generic(DW: integer := 8);
		port (
			i_clk, i_reset: in std_logic;
			i_valid, i_ready: in std_logic;
			o_valid, o_ready: out std_logic;
			i_data: in std_logic_vector(DW-1 downto 0);
			o_data: out std_logic_vector(DW-1 downto 0)
		);
	end component;

	
	signal din2_tvalid, din2_tready: std_logic;
	signal din2_tdata: std_logic_vector(wordWidth-1 downto 0);

	signal dout0_tvalid, dout0_tready: std_logic;
	signal dout0_tdata: std_logic_vector(wordWidth-1 downto 0);
begin
	-- input skid buffer
	skidIn: entity axiToOxiToAxiSkid
		generic map(width=>wordWidth)
		port map(aclk=>clk,
			din_tvalid=>din_tvalid,
			din_tready=>din_tready,
			din_tdata=>din_tdata,
			dout_tvalid=>din2_tvalid,
			dout_tready=>din2_tready,
			dout_tdata=>din2_tdata);
--	skidIn: component skidbuffer
--		generic map(DW=>wordWidth)
--		port map(i_clk=>clk, i_reset=>'0',
--			i_valid=>din_tvalid,
--			o_ready=>din_tready,
--			i_data=>din_tdata,
--			o_valid=>din2_tvalid,
--			i_ready=>din2_tready,
--			o_data=>din2_tdata);

	-- output skid buffer
	skidOut: entity axiToOxiToAxiSkid
		generic map(width=>wordWidth)
		port map(aclk=>clk,
			din_tvalid=>dout0_tvalid,
			din_tready=>dout0_tready,
			din_tdata=>dout0_tdata,
			dout_tvalid=>dout_tvalid,
			dout_tready=>dout_tready,
			dout_tdata=>dout_tdata);
--	skidOut: component skidbuffer
--		generic map(DW=>wordWidth)
--		port map(i_clk=>clk, i_reset=>'0',
--			i_valid=>dout0_tvalid,
--			o_ready=>dout0_tready,
--			i_data=>dout0_tdata,
--			o_valid=>dout_tvalid,
--			i_ready=>dout_tready,
--			o_data=>dout_tdata);

	fifo: entity dcfifo
		generic map(
				width=>wordWidth,
				depthOrder=>13,
				singleClock=>true)
		port map(rdclk=>clk, wrclk=>clk,
				wrvalid=>din2_tvalid,
				wrready=>din2_tready,
				wrdata=>din2_tdata,
				rdvalid=>dout0_tvalid,
				rdready=>dout0_tready,
				rddata=>dout0_tdata);

--	gate: entity axiDataGating
--		generic map(addrWidth=>counterWidth,
--				wordWidth=>wordWidth)
--		port map(aclk=>clk, reset=>'0',
--				allowIssueBytes=>allowBytesU,
--				allowIssueEn=>allow2,
--				in_tvalid=>din2_tvalid,
--				in_tready=>din2_tready,
--				in_tdata=>din2_tdata,
--				in_tlast=>'0',
--				out_tvalid=>dout0_tvalid,
--				out_tready=>dout0_tready,
--				out_tdata=>dout0_tdata);
end a;
