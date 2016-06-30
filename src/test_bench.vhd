-----------------------------------------------------------------------------------
--!     @file    test_bench.vhd
--!     @brief   TEST BENCH for Priority Encoder Procedures :
--!              Priority Encoder Procedurs Packageを検証するためのテストベンチ.
--!     @version 0.0.1
--!     @date    2016/6/30
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2016 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- テストベンチのコンポーネント宣言を含んだパッケージ
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
package COMPONENTS is
    component TEST_BENCH
        generic (
            MODE        : integer range 1 to 5 := 1;
            L           : integer := 0;
            H           : integer := 31;
            VERBOSE     : boolean := FALSE;
            AUTO_FINISH : boolean := FALSE
        );
        port (
            FINISH      : out std_logic
        );
    end component;
end package;
-----------------------------------------------------------------------------------
-- テストベンチのエンティティ宣言
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  TEST_BENCH is
    generic (
        MODE        : integer range 1 to 5 := 1;
        L           : integer := 0;
        H           : integer := 31;
        VERBOSE     : boolean := FALSE;
        AUTO_FINISH : boolean := FALSE
    );
    port (
        FINISH      : out std_logic
    );
end     TEST_BENCH;
-----------------------------------------------------------------------------------
-- テストベンチの本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all; 
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.MT19937AR.all;
use     DUMMY_PLUG.UTIL.BIN_TO_STRING;
use     DUMMY_PLUG.UTIL.HEX_TO_STRING;
use     DUMMY_PLUG.UTIL.INTEGER_TO_STRING;
architecture stimulus of TEST_BENCH is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal      CLK   :  std_logic;
    signal      RST   :  std_logic;
    signal      D     :  std_logic_vector(H downto L);
    signal      Q     :  std_logic_vector(H downto L);
    signal      Z     :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function    MESSAGE_TAG return STRING is
    begin
        return "(M="  & INTEGER_TO_STRING(MODE) &
               ",H="  & INTEGER_TO_STRING(H   ) &
               ",L="  & INTEGER_TO_STRING(L   ) &
               ")";
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
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
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    DUT: PRIORITY_ENCODER generic map(MODE, L, H) port map(CLK, RST, D, Q, Z);
    -------------------------------------------------------------------------------
    -- テスト開始
    -------------------------------------------------------------------------------
    process
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        variable  i_data   : std_logic_vector(H downto L);
        variable  rnd_data : std_logic_vector(i_data'length-1 downto 0);
        variable  rnd_gen  : PSEUDO_RANDOM_NUMBER_GENERATOR_TYPE := NEW_PSEUDO_RANDOM_NUMBER_GENERATOR(88);
        variable  mismatch : integer;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        procedure CHECK(I_DATA  : in  std_logic_vector) is
            variable  gen_data  : std_logic_vector(H downto L);
            variable  exp_data  : std_logic_vector(H downto L);
            variable  gen_valid : std_logic;
            variable  exp_valid : std_logic;
        begin
            D <= I_DATA;
            wait until(CLK'event and CLK = '1');
            wait until(CLK'event and CLK = '1');
            wait until(CLK'event and CLK = '1');
            gen_data  := Q;
            gen_valid := not Z;
            assert (VERBOSE = FALSE)
                report MESSAGE_TAG &
                       "Check Input="  & HEX_TO_STRING(I_DATA   ) &
                           ", Output=" & HEX_TO_STRING(gen_data ) &
                           ", Valid="  & BIN_TO_STRING(gen_valid)
                severity NOTE;
            exp_data  := (others => '0');
            exp_valid := '0';
            for i in I_DATA'low to I_DATA'high loop
                if (I_DATA(i) = '1') then
                    exp_data(i) := '1';
                    exp_valid   := '1';
                    exit;
                end if;
            end loop;
            if (gen_data /= exp_data) or (gen_valid /= exp_valid) then
                mismatch := mismatch + 1;
            end if;
            assert (gen_data = exp_data)
                report MESSAGE_TAG &
                       "Mismtch Input="  & HEX_TO_STRING(I_DATA  ) &
                             ", Output=" & HEX_TO_STRING(gen_data) &
                               ", Exp="  & HEX_TO_STRING(exp_data)
                severity ERROR;
            assert (gen_valid = exp_valid)
                report MESSAGE_TAG &
                       "Mismtch Input="  & HEX_TO_STRING(I_DATA   ) &
                             ", Valid="  & BIN_TO_STRING(gen_valid) &
                              ", Exp="   & BIN_TO_STRING(exp_valid)
                severity ERROR;
        end procedure;
    begin
        RST <= '1';
        wait until (CLK'event and CLK = '1');
        RST <= '0';
        wait until (CLK'event and CLK = '1');
        mismatch := 0;
        for pos in i_data'range loop
            i_data := (others => '0');
            i_data(pos) := '1';
            CHECK(i_data);
        end loop;
        for pos in i_data'range loop
            i_data := (others => '0');
            i_data(pos) := '1';
            if (pos < i_data'high) then
                i_data(i_data'high downto pos+1) := (i_data'high downto pos+1 => '1');
            end if;
            CHECK(i_data);
        end loop;
        for count in 0 to 100 loop
            for n in 0 to (rnd_data'length+31)/32 loop
                if 32*(n+1)-1 >  rnd_data'high then
                    GENERATE_RANDOM_STD_LOGIC_VECTOR(rnd_gen, rnd_data(rnd_data'high downto 32*n));
                else
                    GENERATE_RANDOM_STD_LOGIC_VECTOR(rnd_gen, rnd_data(   32*(n+1)-1 downto 32*n));
                end if;
            end loop;
            i_data := rnd_data;
            CHECK(i_data);
        end loop;
        if (AUTO_FINISH = FALSE) then
            assert(mismatch=0) report MESSAGE_TAG & "Run error!!!!!!" severity NOTE;
            assert(mismatch>0) report MESSAGE_TAG & "Run complete..." severity NOTE;
            FINISH <= 'Z';
        else
            FINISH <= 'Z';
            assert(mismatch=0) report MESSAGE_TAG & "Run error!!!!!!" severity FAILURE;
            assert(mismatch>0) report MESSAGE_TAG & "Run complete..." severity FAILURE;
        end if;
        wait;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process begin
        CLK <= '0';
        wait for 5 ns;
        CLK <= '1';
        wait for 5 ns;
    end process;
end stimulus;
-----------------------------------------------------------------------------------
-- TEST_BENCH_ALL
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  TEST_BENCH_ALL is
end     TEST_BENCH_ALL;
library ieee;
use     ieee.std_logic_1164.all;
use     WORK.COMPONENTS.TEST_BENCH;
architecture MODEL of TEST_BENCH_ALL is
    signal FINISH : std_logic;
begin
    M_GEN: for M in 1 to 4  generate
    L_GEN: for L in 0 to 2  generate
    H_GEN: for W in 4 to 8  generate
        TB:TEST_BENCH
            generic map(
                MODE        => M,
                L           => L,
                H           => L+W-1,
                VERBOSE     => FALSE,
                AUTO_FINISH => FALSE
            )
            port map (
                FINISH      => FINISH
            );
    end generate;
    end generate;
    end generate;
    TB_5_32:TEST_BENCH
        generic map(
            MODE        => 5,
            L           => 0,
            H           => 31,
            VERBOSE     => FALSE,
            AUTO_FINISH => FALSE
        )
        port map (
            FINISH      => FINISH
        );
    TB_5_64:TEST_BENCH
        generic map(
            MODE        => 5,
            L           => 0,
            H           => 63,
            VERBOSE     => FALSE,
            AUTO_FINISH => FALSE
        )
        port map (
            FINISH      => FINISH
        );
    TB_5_128:TEST_BENCH
        generic map(
            MODE        => 5,
            L           => 0,
            H           => 127,
            VERBOSE     => FALSE,
            AUTO_FINISH => FALSE
        )
        port map (
            FINISH      => FINISH
        );
    TB_5_256:TEST_BENCH
        generic map(
            MODE        => 5,
            L           => 0,
            H           => 255,
            VERBOSE     => FALSE,
            AUTO_FINISH => FALSE
        )
        port map (
            FINISH      => FINISH
        );
    TB_5_512:TEST_BENCH
        generic map(
            MODE        => 5,
            L           => 0,
            H           => 511,
            VERBOSE     => FALSE,
            AUTO_FINISH => FALSE
        )
        port map (
            FINISH      => FINISH
        );
    FINISH <= 'H' after 1 ns;
    process (FINISH) begin
        if (FINISH'event and FINISH = 'H') then
            assert(false) report "Run complete all." severity FAILURE;
        end if;
    end process;
end MODEL;
