-----------------------------------------------------------------------------------
--!     @file    priority_encoder.vhd
--!     @brief   Sample for Priority Encoder.
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
library ieee;
use     ieee.std_logic_1164.all;
entity  PRIORITY_ENCODER is
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
end PRIORITY_ENCODER;
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of PRIORITY_ENCODER is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  minimum(L,R:integer) return integer is
    begin
        if (L < R) then return L;
        else            return R;
        end if;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  or_reduce(Arg : std_logic_vector) return std_logic is
        variable result : std_logic;
    begin
        result := '0';
        for i in Arg'range loop
            result := result or Arg(i);
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot_Use_Exit(
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    ) is
        variable result      :     std_logic_vector(Data'range);
    begin
        result := (others => '0');
        for i in Data'low to Data'high loop
            result(i) := Data(i);
            exit when (Data(i) = '1');
        end loop;
        Output := result;
        Valid  := or_reduce(Data);
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot_Use_Flag(
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    ) is
        variable result      :     std_logic_vector(Data'range);
        variable found_1     :     boolean;
    begin
        found_1 := false;
        for i in Data'low to Data'high loop
            if found_1 = false then
                result(i) := Data(i);
                found_1   := (Data(i) = '1');
            else
                result(i) := '0';
            end if;
        end loop;
        Output := result;
        Valid  := or_reduce(Data);
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot_Use_OrReduce(
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    ) is
        variable result      :     std_logic_vector(Data'range);
    begin
        for i in Data'range loop
            if (i = Data'low) then
                result(i) := Data(i);
            else
                result(i) := Data(i) and (not or_reduce(Data(i-1 downto Data'low)));
            end if;
        end loop;
        Output := result;
        Valid  := or_reduce(Data);
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot_Use_Decriment(
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    ) is
        variable i_data      :     std_logic_vector(Data'length-1 downto 0);
        variable t_data      :     std_logic_vector(Data'length   downto 0);
        variable d_data      :     std_logic_vector(Data'length   downto 0);
        variable r_data      :     std_logic_vector(Data'length-1 downto 0);
        variable o_data      :     std_logic_vector(Data'range);
    begin
        i_data := Data;
        t_data := "0" & i_data;
        d_data := std_logic_vector(unsigned(t_data) - 1);
        r_data := i_data and not d_data(i_data'range);
        o_data := r_data;
        Valid  := or_reduce(i_data);
        Output := o_data;
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot_Selectable(
                 Min_Dec_Len : in  integer;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    ) is
    begin
        if Data'length >= Min_Dec_Len then
            Priority_Encode_To_OneHot_Use_Decriment(
                Data        => Data       ,
                Output      => Output     ,
                Valid       => Valid
            );
        else
            Priority_Encode_To_OneHot_Use_OrReduce(
                Data        => Data       ,
                Output      => Output     ,
                Valid       => Valid
            );
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    procedure Priority_Encode_To_OneHot_Use_RecursiveCall(
                 Min_Dec_Len : in  integer;
                 Max_Dec_Len : in  integer;
                 Data        : in  std_logic_vector;
        variable Output      : out std_logic_vector;
        variable Valid       : out std_logic
    ) is
        constant Dec_Num     :     integer := (Data'length+Max_Dec_Len-1)/Max_Dec_Len;
        constant Dec_Bits    :     integer := (Data'length+Dec_Num-1)/Dec_Num;
        variable result      :     std_logic_vector(Data'range);
        alias    i_data      :     std_logic_vector(Data'length-1 downto 0) is Data;
        variable o_data      :     std_logic_vector(Data'length-1 downto 0);
        variable o_valid     :     std_logic_vector(Dec_Num-1 downto 0);
        variable onehot      :     std_logic_vector(Dec_Num-1 downto 0);
    begin
        for i in 0 to Dec_Num-1 loop
            Priority_Encode_To_OneHot_Selectable(
                Min_Dec_Len => Min_Dec_Len,
                Data        => i_data(minimum(i_data'left, (i+1)*Dec_Bits-1) downto i*Dec_Bits),
                Output      => o_data(minimum(i_data'left, (i+1)*Dec_Bits-1) downto i*Dec_Bits),
                Valid       => o_valid(i)
            );
        end loop;
        if (Dec_Num > 1) then
            Priority_Encode_To_OneHot_Use_RecursiveCall(
                Min_Dec_Len => Min_Dec_Len,
                Max_Dec_Len => Max_Dec_Len,
                Data        => o_valid,
                Output      => onehot,
                Valid       => Valid
            );
            for i in 1 to Dec_Num-1 loop
                if (onehot(i) = '0') then
                    if (i = Dec_Num-1) then
                        o_data(o_data'left      downto i*Dec_Bits) := (others => '0');
                    else
                        o_data((i+1)*Dec_Bits-1 downto i*Dec_Bits) := (others => '0');
                    end if;
                end if;
            end loop;
        else
            Valid := o_valid(0);
        end if;
        Output := o_data;
    end procedure;
begin
    MODE_1: if (MODE = 1) generate
        process (CLK, RST)
            variable q_data  : std_logic_vector(Q'range);
            variable q_valid : std_logic;
        begin
            if (RST = '1') then
                Q      <= (others => '0');
                Z      <= '0';
            elsif (CLK'event and CLK = '1') then
                Priority_Encode_To_OneHot_Use_Exit(
                    Data        => D,
                    Output      => q_data,
                    Valid       => q_valid
                );
                Q <= q_data;
                Z <= not q_valid;
            end if;
        end process;
    end generate;
    MODE_2: if (MODE = 2) generate
        process (CLK, RST)
            variable q_data  : std_logic_vector(Q'range);
            variable q_valid : std_logic;
        begin
            if (RST = '1') then
                Q      <= (others => '0');
                Z      <= '0';
            elsif (CLK'event and CLK = '1') then
                Priority_Encode_To_OneHot_Use_Flag(
                    Data        => D,
                    Output      => q_data,
                    Valid       => q_valid
                );
                Q <= q_data;
                Z <= not q_valid;
            end if;
        end process;
    end generate;
    MODE_3: if (MODE = 3) generate
        process (CLK, RST)
            variable q_data  : std_logic_vector(Q'range);
            variable q_valid : std_logic;
        begin
            if (RST = '1') then
                Q      <= (others => '0');
                Z      <= '0';
            elsif (CLK'event and CLK = '1') then
                Priority_Encode_To_OneHot_Use_OrReduce(
                    Data        => D,
                    Output      => q_data,
                    Valid       => q_valid
                );
                Q <= q_data;
                Z <= not q_valid;
            end if;
        end process;
    end generate;
    MODE_4: if (MODE = 4) generate
        process (CLK, RST)
            variable q_data  : std_logic_vector(Q'range);
            variable q_valid : std_logic;
        begin
            if (RST = '1') then
                Q      <= (others => '0');
                Z      <= '0';
            elsif (CLK'event and CLK = '1') then
                Priority_Encode_To_OneHot_Use_Decriment(
                    Data        => D,
                    Output      => q_data,
                    Valid       => q_valid
                );
                Q <= q_data;
                Z <= not q_valid;
            end if;
        end process;
    end generate;
    MODE_5: if (MODE = 5) generate
        process (CLK, RST)
            variable q_data  : std_logic_vector(Q'range);
            variable q_valid : std_logic;
        begin
            if (RST = '1') then
                Q      <= (others => '0');
                Z      <= '0';
            elsif (CLK'event and CLK = '1') then
                Priority_Encode_To_OneHot_Use_RecursiveCall(
                    Min_Dec_Len => 20,
                    Max_Dec_Len => 64,
                    Data        => D,
                    Output      => q_data,
                    Valid       => q_valid
                );
                Q <= q_data;
                Z <= not q_valid;
            end if;
        end process;
    end generate;
end RTL;

