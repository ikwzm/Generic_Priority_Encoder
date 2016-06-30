library ieee;
use     ieee.std_logic_1164.all;
entity  PRIORITY_ENCODER_SYNTH_TEST is
    generic (
        MODE    : integer :=   1;
        WIDTH   : integer :=  32
    );
    port (
        CLK     : in  std_logic;
        RST     : in  std_logic;
        M       : in  std_logic;
        D       : in  std_logic;
        Q       : out std_logic;
        Z       : out std_logic
    );
end PRIORITY_ENCODER_SYNTH_TEST;
library ieee;
use     ieee.std_logic_1164.all;
architecture RTL of PRIORITY_ENCODER_SYNTH_TEST is
    component PRIORITY_ENCODER is
        generic (
            MODE    : integer :=   1;
            LOW     : integer :=   0;
            HIGH    : integer :=  63
        );
        port (
            CLK     : in  std_logic;
            RST     : in  std_logic;
            D       : in  std_logic_vector(HIGH downto LOW);
            Q       : out std_logic_vector(HIGH downto LOW);
            Z       : out std_logic
        );
    end component;
    signal  I_REG   :     std_logic_vector(WIDTH-1 downto 0);
    signal  Q_REG   :     std_logic_vector(WIDTH-1 downto 0);
    signal  Z_REG   :     std_logic;
begin
    process (CLK, RST) begin
        if (RST = '1') then
            I_REG <= (others => '0');
            Z     <= '0';
        elsif (CLK'event and CLK = '1') then
            if (M = '1') then
                for i in I_REG'range loop
                    if (i = 0) then
                        I_REG(i) <= D;
                    else
                        I_REG(i) <= I_REG(i-1);
                    end if;
                end loop;
            else
                I_REG <= Q_REG;
                Z     <= Z_REG;
            end if;
        end if;
    end process;
    Q <= I_REG(I_REG'high);
    U: PRIORITY_ENCODER generic map (MODE, 0, WIDTH-1) port map(CLK, RST, I_REG, Q_REG, Z_REG);
end RTL;
