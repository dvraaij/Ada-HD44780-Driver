with Ada.Unchecked_Conversion;

package body HD44780 is

   ----------------
   -- Initialize --
   ----------------

   overriding
   procedure Initialize
     (Device    : in out HD44780_Device_4;
      Lines     :        HD44780_Lines;
      Font_Size :        HD44780_Font_Size;
      Direction :        HD44780_Input_Direction;
      Shift     :        HD44780_Shift_Display)
   is

      All_Low        : constant HD44780_Data :=
        HD44780_Data'(others => 0);

      Function_Set_8 : constant HD44780_Data :=
        HD44780_Data'(DB5    => 1,
                      DB4    => 1,  -- 8-bit interface
                      others => 0);

      Function_Set_4 : constant HD44780_Data :=
        HD44780_Data'(DB5    => 1,
                      DB4    => 0,  -- 4-bit interface
                      DB3    =>     Lines'Enum_Rep,
                      DB2    => Font_Size'Enum_Rep,
                      others => 0);

      Display_Off    : constant HD44780_Data :=
        HD44780_Data'(DB3    => 1,
                      others => 0);

      Display_Clear  : constant HD44780_Data :=
        HD44780_Data'(DB0    => 1,
                      others => 0);

      Entry_Mode     : constant HD44780_Data :=
        HD44780_Data'(DB2    => 1,
                      DB1    => Direction'Enum_Rep,
                      DB0    =>     Shift'Enum_Rep,
                      others => 0);
   begin

      --  Device can only be initialized once
      if Device.Initialized then
         return;
      end if;

      --  Two lines with font size 5x10 is not supported
      if Lines = Two and Font_Size = Dots_5x10 then
         return;
      end if;

      --  Switch control pins to write mode
      declare
         Result : Boolean;
         pragma Unreferenced (Result);     -- TODO: Handle failure
      begin
         Result :=
           Device.RS.Set_Mode (Output) and
           Device.RW.Set_Mode (Output) and
           Device.E.Set_Mode (Output);
      end;

      --  Init sequence
      Device.Write (IR, All_Low, Byte);
      Device.Time.Delay_Microseconds (15000);

      Device.Write (IR, Function_Set_8, Nibble);
      Device.Time.Delay_Microseconds (4100);

      Device.Write (IR, Function_Set_8, Nibble);  --  Repulse E
      Device.Time.Delay_Microseconds (100);

      Device.Write (IR, Function_Set_8, Nibble);  --  Repulse E
      Device.Time.Delay_Microseconds (37);

      Device.Write (IR, Function_Set_4, Nibble);  --  Fix interface
      Device.Time.Delay_Microseconds (37);

      Device.Write (IR, Function_Set_4, Byte);    --  Setup display
      Device.Time.Delay_Microseconds (37);

      Device.Write (IR, Display_Off, Byte);
      Device.Time.Delay_Microseconds (37);

      Device.Write (IR, Display_Clear, Byte);
      Device.Time.Delay_Microseconds (37);

      Device.Write (IR, Entry_Mode, Byte);
      Device.Time.Delay_Microseconds (37);

      --  The device has been initialized succesfully
      Device.Initialized := True;

   end Initialize;

   ----------------
   -- Initialize --
   ----------------

   overriding
   procedure Initialize
     (Device    : in out HD44780_Device_8;
      Lines     :        HD44780_Lines;
      Font_Size :        HD44780_Font_Size;
      Direction :        HD44780_Input_Direction;
      Shift     :        HD44780_Shift_Display)
   is

      All_Low        : constant HD44780_Data :=
        HD44780_Data'(others => 0);

      Function_Set_8 : constant HD44780_Data :=
        HD44780_Data'(DB5    => 1,
                      DB4    => 1,  -- 8-bit interface
                      DB3    =>     Lines'Enum_Rep,
                      DB2    => Font_Size'Enum_Rep,
                      others => 0);

      Display_Off    : constant HD44780_Data :=
        HD44780_Data'(DB3    => 1,
                      others => 0);

      Display_Clear  : constant HD44780_Data :=
        HD44780_Data'(DB0    => 1,
                      others => 0);

      Entry_Mode     : constant HD44780_Data :=
        HD44780_Data'(DB2    => 1,
                      DB1    => Direction'Enum_Rep,
                      DB0    =>     Shift'Enum_Rep,
                      others => 0);
   begin

      --  Device can only be initialized once
      if Device.Initialized then
         return;
      end if;

      --  Two lines with font size 5x10 is not supported
      if Lines = Two and Font_Size = Dots_5x10 then
         return;
      end if;

      --  Switch control pins to write mode
      declare
         Result : Boolean;
         pragma Unreferenced (Result);     -- TODO: Handle failure
      begin
         Result :=
           Device.RS.Set_Mode (Output) and
           Device.RW.Set_Mode (Output) and
           Device.E.Set_Mode (Output);
      end;

      --  Init sequence
      Device.Write (IR, All_Low, Byte);
      Device.Time.Delay_Microseconds (15000);

      Device.Write (IR, Function_Set_8, Nibble);
      Device.Time.Delay_Microseconds (4100);

      Device.Write (IR, Function_Set_8, Nibble);  --  Repulse E
      Device.Time.Delay_Microseconds (100);

      Device.Write (IR, Function_Set_8, Nibble);  --  Repulse E
      Device.Time.Delay_Microseconds (37);

      Device.Write (IR, Function_Set_8, Nibble);  --  Fix interface
      Device.Time.Delay_Microseconds (37);

      Device.Write (IR, Function_Set_8, Byte);    --  Setup display
      Device.Time.Delay_Microseconds (37);

      Device.Write (IR, Display_Off, Byte);
      Device.Time.Delay_Microseconds (37);

      Device.Write (IR, Display_Clear, Byte);
      Device.Time.Delay_Microseconds (37);

      Device.Write (IR, Entry_Mode, Byte);
      Device.Time.Delay_Microseconds (37);

      --  The device has been initialized succesfully
      Device.Initialized := True;

   end Initialize;

   -----------
   -- Write --
   -----------

   overriding
   procedure Write
     (Device   : HD44780_Device_4;
      Register :        HD44780_Register;
      Data     :        HD44780_Data;
      Mode     :        HD44780_Mode)
   is

      procedure Set_GPIO
        (Point : Any_GPIO_Point;
         Value : Bit);

      procedure Set_GPIO
        (Point : Any_GPIO_Point;
         Value : Bit)
      is
      begin
         case Value is
         when 1 => Point.Set;
         when 0 => Point.Clear;
         end case;
      end Set_GPIO;

   begin

      --  Select register
      case Register is
         when IR => Device.RS.Clear;
         when DR => Device.RS.Set;
      end case;

      --  This is a write action
      Device.RW.Clear;
      Device.Time.Delay_Microseconds (1);  --  Address Setup Time (t_AS)

      --  Switch data I/O pins to write mode
      declare
         Result : Boolean;
         pragma Unreferenced (Result);     -- TODO: Handle failure
      begin
         Result :=
           Device.DB7.Set_Mode (Output) and
           Device.DB6.Set_Mode (Output) and
           Device.DB5.Set_Mode (Output) and
           Device.DB4.Set_Mode (Output);
      end;

      --  Start the data transfer
      Device.E.Set;
      Set_GPIO (Device.DB7, Data.DB7);
      Set_GPIO (Device.DB6, Data.DB6);
      Set_GPIO (Device.DB5, Data.DB5);
      Set_GPIO (Device.DB4, Data.DB4);

      Device.Time.Delay_Microseconds (1);  --  Data Setup Time (t_DSW)
      Device.E.Clear;
      Device.Time.Delay_Microseconds (1);  --  Hold Time (t_H)

      if Mode = Nibble then
         return;
      end if;

      Device.E.Set;
      Set_GPIO (Device.DB7, Data.DB3);
      Set_GPIO (Device.DB6, Data.DB2);
      Set_GPIO (Device.DB5, Data.DB1);
      Set_GPIO (Device.DB4, Data.DB0);

      Device.Time.Delay_Microseconds (1);  --  Data Setup Time (t_DSW)
      Device.E.Clear;
      Device.Time.Delay_Microseconds (1);  --  Hold Time (t_H)

   end Write;

   -----------
   -- Write --
   -----------

   overriding
   procedure Write
     (Device   : HD44780_Device_8;
      Register :        HD44780_Register;
      Data     :        HD44780_Data;
      Mode     :        HD44780_Mode)
   is
      procedure Set_GPIO
        (Point : Any_GPIO_Point;
         Value : Bit);

      procedure Set_GPIO
        (Point : Any_GPIO_Point;
         Value : Bit)
      is
      begin
         case Value is
         when 1 => Point.Set;
         when 0 => Point.Clear;
         end case;
      end Set_GPIO;

   begin

      --  Select register
      case Register is
         when IR => Device.RS.Clear;
         when DR => Device.RS.Set;
      end case;

      --  This is a write action
      Device.RW.Clear;
      Device.Time.Delay_Microseconds (1);  --  Address Setup Time (t_AS)

      --  Switch data I/O pins to write mode
      declare
         Result : Boolean;
         pragma Unreferenced (Result);     -- TODO: Handle failure
      begin
         Result :=
           Device.DB7.Set_Mode (Output) and
           Device.DB6.Set_Mode (Output) and
           Device.DB5.Set_Mode (Output) and
           Device.DB4.Set_Mode (Output) and
           Device.DB3.Set_Mode (Output) and
           Device.DB2.Set_Mode (Output) and
           Device.DB1.Set_Mode (Output) and
           Device.DB0.Set_Mode (Output);
      end;

      --  Start the data transfer
      Device.E.Set;

      Set_GPIO (Device.DB7, Data.DB7);
      Set_GPIO (Device.DB6, Data.DB6);
      Set_GPIO (Device.DB5, Data.DB5);
      Set_GPIO (Device.DB4, Data.DB4);

      if Mode = Nibble then
         goto Done;
      end if;

      Set_GPIO (Device.DB3, Data.DB3);
      Set_GPIO (Device.DB2, Data.DB2);
      Set_GPIO (Device.DB1, Data.DB1);
      Set_GPIO (Device.DB0, Data.DB0);

      <<Done>>

      Device.Time.Delay_Microseconds (1);  --  Data Setup Time (t_DSW)
      Device.E.Clear;
      Device.Time.Delay_Microseconds (1);  --  Hold Time (t_H)

   end Write;

   ----------
   -- Read --
   ----------

   overriding
   function Read
     (Device   : HD44780_Device_4;
      Register : HD44780_Register) return HD44780_Data
   is
      Data : HD44780_Data;
   begin

      --  Switch data I/O pins to read mode
      declare
         Result : Boolean;
         pragma Unreferenced (Result);     -- TODO: Handle failure
      begin
         Result :=
           Device.DB7.Set_Mode (Input) and
           Device.DB6.Set_Mode (Input) and
           Device.DB5.Set_Mode (Input) and
           Device.DB4.Set_Mode (Input);
      end;

      --  Select register
      case Register is
         when IR => Device.RS.Clear;
         when DR => Device.RS.Set;
      end case;

      --  This is a read action
      Device.RW.Set;
      Device.Time.Delay_Microseconds (1);  --  Address Setup Time (t_AS)

      --  Start the data transfer
      Device.E.Set;
      Device.Time.Delay_Microseconds (1);  --  Data Delay Time (t_DDR)

      Data.DB7 := Boolean'Enum_Rep (Device.DB7.Set);
      Data.DB6 := Boolean'Enum_Rep (Device.DB6.Set);
      Data.DB5 := Boolean'Enum_Rep (Device.DB5.Set);
      Data.DB4 := Boolean'Enum_Rep (Device.DB4.Set);

      Device.E.Clear;
      Device.Time.Delay_Microseconds (1);  --  Data Hold Time (t_DHR)

      Device.E.Set;
      Device.Time.Delay_Microseconds (1);  --  Data Delay Time (t_DDR)

      Data.DB3 := Boolean'Enum_Rep (Device.DB7.Set);
      Data.DB2 := Boolean'Enum_Rep (Device.DB6.Set);
      Data.DB1 := Boolean'Enum_Rep (Device.DB5.Set);
      Data.DB0 := Boolean'Enum_Rep (Device.DB4.Set);

      Device.E.Clear;
      Device.Time.Delay_Microseconds (1);  --  Data Hold Time (t_DHR)

      return Data;

   end Read;

   ----------
   -- Read --
   ----------

   overriding
   function Read
     (Device   : HD44780_Device_8;
      Register : HD44780_Register) return HD44780_Data
   is
      Data : HD44780_Data;
   begin

      --  Switch data I/O pins to read mode
      declare
         Result : Boolean;
         pragma Unreferenced (Result);     -- TODO: Handle failure
      begin
         Result :=
           Device.DB7.Set_Mode (Input) and
           Device.DB6.Set_Mode (Input) and
           Device.DB5.Set_Mode (Input) and
           Device.DB4.Set_Mode (Input) and
           Device.DB3.Set_Mode (Input) and
           Device.DB2.Set_Mode (Input) and
           Device.DB1.Set_Mode (Input) and
           Device.DB0.Set_Mode (Input);
      end;

      --  Select register
      case Register is
         when IR => Device.RS.Clear;
         when DR => Device.RS.Set;
      end case;

      --  This is a read action
      Device.RW.Set;
      Device.Time.Delay_Microseconds (1);  --  Address Setup Time (t_AS)

      --  Start the data transfer
      Device.E.Set;
      Device.Time.Delay_Microseconds (1);  --  Data Delay Time (t_DDR)

      Data.DB7 := Boolean'Enum_Rep (Device.DB7.Set);
      Data.DB6 := Boolean'Enum_Rep (Device.DB6.Set);
      Data.DB5 := Boolean'Enum_Rep (Device.DB5.Set);
      Data.DB4 := Boolean'Enum_Rep (Device.DB4.Set);
      Data.DB3 := Boolean'Enum_Rep (Device.DB3.Set);
      Data.DB2 := Boolean'Enum_Rep (Device.DB2.Set);
      Data.DB1 := Boolean'Enum_Rep (Device.DB1.Set);
      Data.DB0 := Boolean'Enum_Rep (Device.DB0.Set);

      Device.E.Clear;
      Device.Time.Delay_Microseconds (1);  --  Data Hold Time (t_DHR)

      return Data;

   end Read;

   -----------
   -- Clear --
   -----------

   procedure Clear
     (Device : HD44780_Device'Class)
   is
      Clear : constant HD44780_Data :=
        HD44780_Data'(DB0    => 1,
                      others => 0);
   begin
      Device.Wait;
      Device.Write (IR, Clear, Byte);
   end Clear;

   ----------
   -- Home --
   ----------

   procedure Home
     (Device : HD44780_Device'Class)
   is
      Home : constant HD44780_Data :=
        HD44780_Data'(DB1    => 1,
                      others => 0);
   begin
      Device.Wait;
      Device.Write (IR, Home, Byte);
   end Home;

   ----------------------
   -- Set_Display_Mode --
   ----------------------

   procedure Set_Display_Mode
     (Device  : HD44780_Device'Class;
      Display : HD44780_Display_Mode;
      Cursor  : HD44780_Cursor_Mode;
      Blink   : HD44780_Cursor_Blink)
   is
      Set_Display_Mode : constant HD44780_Data :=
        HD44780_Data'(DB3    => 1,
                      DB2    => Display'Enum_Rep,
                      DB1    =>  Cursor'Enum_Rep,
                      DB0    =>   Blink'Enum_Rep,
                      others => 0);
   begin
      Device.Wait;
      Device.Write (IR, Set_Display_Mode, Byte);
   end Set_Display_Mode;

   -----------------
   -- Move_Cursor --
   -----------------

   procedure Move_Cursor
     (Device    : HD44780_Device'Class;
      Direction : HD44780_Direction;
      Amount    : Positive := 1)
   is
      Move_Cursor : constant HD44780_Data :=
        HD44780_Data'(DB4    => 1,
                      DB3    => 0,
                      DB2    => Direction'Enum_Rep,
                      others => 0);
   begin
      for Count in 1 .. Amount loop
         Device.Wait;
         Device.Write (IR, Move_Cursor, Byte);
      end loop;
   end Move_Cursor;

   -------------------
   -- Shift_Display --
   -------------------

   procedure Shift_Display
     (Device    : HD44780_Device'Class;
      Direction : HD44780_Direction;
      Amount    : Positive := 1)
   is
      Shift_Display : constant HD44780_Data :=
        HD44780_Data'(DB4    => 1,
                      DB3    => 1,
                      DB2    => Direction'Enum_Rep,
                      others => 0);
   begin
      for Count in 1 .. Amount loop
         Device.Wait;
         Device.Write (IR, Shift_Display, Byte);
      end loop;
   end Shift_Display;

   -------------
   -- Is_Busy --
   -------------

   function Is_Busy
     (Device  :     HD44780_Device'Class;
      Address : out UInt7) return Boolean
   is

      type Status is
         record
            Address : UInt7;
            Busy    : Bit;
         end record
        with
          Pack, Size => 8;

      function HD44780_Data_To_Status is
        new Ada.Unchecked_Conversion (HD44780_Data, Status);

      S : constant Status :=
        HD44780_Data_To_Status (Device.Read (IR));

   begin

      Address := S.Address;
      return (S.Busy = 1);

   end Is_Busy;

   -------------
   -- Is_Busy --
   -------------

   function Is_Busy
     (Device : HD44780_Device'Class) return Boolean
   is
      Address : UInt7;
   begin
      return Is_Busy (Device, Address);
   end Is_Busy;

   ----------
   -- Wait --
   ----------

   procedure Wait
     (Device : HD44780_Device'Class)
   is
   begin
      while Device.Is_Busy loop
         Device.Time.Delay_Microseconds (20);
      end loop;
   end Wait;

   ------------------------------
   -- Set_Custom_Character_5x8 --
   ------------------------------

   procedure Set_Custom_Character_5x8
     (Device   : HD44780_Device'Class;
      Location : HD44780_CGRAM_Slot_5x8;
      Bitmap   : HD44780_CGRAM_Data_5x8)
   is

      type Set_CGRAM_Address is
         record
            CGRAM_Address_Low  : HD44780_CGRAM_Row_5x8  := 0;
            CGRAM_Address_High : HD44780_CGRAM_Slot_5x8 := 0;
            DB6                : Bit                    := 1;
            DB7                : Bit                    := 0;
         end record
        with
          Pack, Size => 8;

      type Data is
         record
            CGRAM_Row_Data : HD44780_CGRAM_Row_Data := 0;
            DB6            : Bit                    := 0;
            DB7            : Bit                    := 0;
         end record
        with
          Pack, Size => 8;

      function To_HD44780_Data is
        new Ada.Unchecked_Conversion (Set_CGRAM_Address, HD44780_Data);

      function To_HD44780_Data is
        new Ada.Unchecked_Conversion (Data, HD44780_Data);

      I : Set_CGRAM_Address;
      D : Data;

   begin

      for Row in Bitmap'Range loop

         I.CGRAM_Address_High := Location;
         I.CGRAM_Address_Low  := Row;

         D.CGRAM_Row_Data     := Bitmap (Row);

         Device.Wait;
         Device.Write (IR, To_HD44780_Data (I), Byte);
         Device.Wait;
         Device.Write (DR, To_HD44780_Data (D), Byte);

      end loop;

   end Set_Custom_Character_5x8;

   -------------------------------
   -- Set_Custom_Character_5x10 --
   -------------------------------

   procedure Set_Custom_Character_5x10
     (Device   : HD44780_Device'Class;
      Location : HD44780_CGRAM_Slot_5x10;
      Bitmap   : HD44780_CGRAM_Data_5x10)
   is

      type Set_CGRAM_Address is
         record
            CGRAM_Address_Low  : HD44780_CGRAM_Row_5x10  := 0;
            CGRAM_Address_High : HD44780_CGRAM_Slot_5x10 := 0;
            DB6                : Bit                     := 1;
            DB7                : Bit                     := 0;
         end record
        with
          Pack, Size => 8;


      type Data is
         record
            CGRAM_Row_Data : HD44780_CGRAM_Row_Data := 0;
            DB6            : Bit                    := 0;
            DB7            : Bit                    := 0;
         end record
        with
          Pack, Size => 8;

      function To_HD44780_Data is
        new Ada.Unchecked_Conversion (Set_CGRAM_Address, HD44780_Data);

      function To_HD44780_Data is
        new Ada.Unchecked_Conversion (Data, HD44780_Data);

      I : Set_CGRAM_Address;
      D : Data;

   begin

      for Row in Bitmap'Range loop

         I.CGRAM_Address_High := Location;
         I.CGRAM_Address_Low  := Row;

         D.CGRAM_Row_Data     := Bitmap (Row);

         Device.Wait;
         Device.Write (IR, To_HD44780_Data (I), Byte);
         Device.Wait;
         Device.Write (DR, To_HD44780_Data (D), Byte);

      end loop;

   end Set_Custom_Character_5x10;

   ---------
   -- Put --
   ---------

   procedure Put
     (Device : HD44780_Device'Class;
      Item   : HD44780_Character;
      Column : HD44780_Column_1L)
   is

      --  Set DDRAM address instruction
      type Set_DDRAM_Address is
         record
            Column : HD44780_Column_1L := 0;
            DB7    : Bit               := 1;
         end record
        with
          Pack, Size => 8;

      function To_HD44780_Data is
        new Ada.Unchecked_Conversion (Set_DDRAM_Address, HD44780_Data);

      function To_HD44780_Data is
        new Ada.Unchecked_Conversion (Character, HD44780_Data);

      I : Set_DDRAM_Address;

   begin

      I.Column := Column;

      Device.Wait;
      Device.Write (IR, To_HD44780_Data (I), Byte);
      Device.Wait;
      Device.Write (DR, To_HD44780_Data (Item), Byte);

   end Put;


   ---------
   -- Put --
   ---------

   procedure Put
     (Device : HD44780_Device'Class;
      Item   : HD44780_Character;
      Row    : HD44780_Row;
      Column : HD44780_Column_2L)
   is

      --  Set DDRAM address instruction
      type Set_DDRAM_Address is
         record
            Column : HD44780_Column_2L := 0;
            Row    : HD44780_Row       := 0;
            DB7    : Bit               := 1;
         end record
        with
          Pack, Size => 8;

      function To_HD44780_Data is
        new Ada.Unchecked_Conversion (Set_DDRAM_Address, HD44780_Data);

      function To_HD44780_Data is
        new Ada.Unchecked_Conversion (Character, HD44780_Data);

      I : Set_DDRAM_Address;

   begin

      I.Row    := Row;
      I.Column := Column;

      Device.Wait;
      Device.Write (IR, To_HD44780_Data (I), Byte);
      Device.Wait;
      Device.Write (DR, To_HD44780_Data (Item), Byte);

   end Put;

end HD44780;
