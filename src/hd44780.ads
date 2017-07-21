--  Driver for the Hitachi HD44780 LCD Controller

with HAL;      use HAL;
with HAL.GPIO; use HAL.GPIO;
with HAL.Time; use HAL.Time;

package HD44780 is

   --  Generic HD44780 device
   type HD44780_Device
     (Time : not null Any_Delays) is abstract tagged limited private;


   type HD44780_Lines           is (One, Two);
   type HD44780_Font_Size       is (Dots_5x8, Dots_5x10);
   type HD44780_Input_Direction is (Right_To_Left, Left_To_Right);
   type HD44780_Shift_Display   is (No, Yes);

   for HD44780_Lines           use (One           => 0, Two           => 1);
   for HD44780_Font_Size       use (Dots_5x8      => 0, Dots_5x10     => 1);
   for HD44780_Input_Direction use (Right_To_Left => 0, Left_To_Right => 1);
   for HD44780_Shift_Display   use (No            => 0, Yes           => 1);

   --  Initialize the HD44780
   procedure Initialize
     (Device    : in out HD44780_Device;
      Lines     :        HD44780_Lines;
      Font_Size :        HD44780_Font_Size;
      Direction :        HD44780_Input_Direction;
      Shift     :        HD44780_Shift_Display) is abstract;


   type HD44780_Register is private;
   type HD44780_Data     is private;
   type HD44780_Mode     is private;

   --  Write data to HD44780
   procedure Write
     (Device   : HD44780_Device;
      Register : HD44780_Register;
      Data     : HD44780_Data;
      Mode     : HD44780_Mode) is abstract;

   --  Read data from HD44780
   function Read
     (Device   : HD44780_Device;
      Register : HD44780_Register) return HD44780_Data is abstract;

   --  HD44780 device connected to MPU with 4 data lines (DB0 .. DB3)
   type HD44780_Device_4
     (RS   : not null Any_GPIO_Point;
      RW   : not null Any_GPIO_Point;
      E    : not null Any_GPIO_Point;
      DB4  : not null Any_GPIO_Point;
      DB5  : not null Any_GPIO_Point;
      DB6  : not null Any_GPIO_Point;
      DB7  : not null Any_GPIO_Point;
      Time : not null Any_Delays) is new HD44780_Device with private;

   overriding
   procedure Initialize
     (Device    : in out HD44780_Device_4;
      Lines     :        HD44780_Lines;
      Font_Size :        HD44780_Font_Size;
      Direction :        HD44780_Input_Direction;
      Shift     :        HD44780_Shift_Display);

   --  HD44780 device connected to MPU with 8 data lines (DB0 .. DB7)
   type HD44780_Device_8
     (RS   : not null Any_GPIO_Point;
      RW   : not null Any_GPIO_Point;
      E    : not null Any_GPIO_Point;
      DB0  : not null Any_GPIO_Point;
      DB1  : not null Any_GPIO_Point;
      DB2  : not null Any_GPIO_Point;
      DB3  : not null Any_GPIO_Point;
      DB4  : not null Any_GPIO_Point;
      DB5  : not null Any_GPIO_Point;
      DB6  : not null Any_GPIO_Point;
      DB7  : not null Any_GPIO_Point;
      Time : not null Any_Delays) is new HD44780_Device with private;

   overriding
   procedure Initialize
     (Device    : in out HD44780_Device_8;
      Lines     :        HD44780_Lines;
      Font_Size :        HD44780_Font_Size;
      Direction :        HD44780_Input_Direction;
      Shift     :        HD44780_Shift_Display);


   --  Clears the entire display and sets DDRAM address 0 in address counter
   procedure Clear
     (Device : HD44780_Device'Class) with Inline;

   --  Sets DDRAM address 0 in address counter. Also returns display from being
   --  shifted to original position. DDRAM contents remain unchanged.
   procedure Home
     (Device : HD44780_Device'Class) with Inline;

   type HD44780_Display_Mode is (Off, On);
   type HD44780_Cursor_Mode  is (Off, On);
   type HD44780_Cursor_Blink is (Off, On);

   for HD44780_Display_Mode use (Off => 0, On => 1);
   for HD44780_Cursor_Mode  use (Off => 0, On => 1);
   for HD44780_Cursor_Blink use (Off => 0, On => 1);

   --  Sets the entire display on/off, cursor on/off and
   --  blinking of cursor position character
   procedure Set_Display_Mode
     (Device  : HD44780_Device'Class;
      Display : HD44780_Display_Mode;
      Cursor  : HD44780_Cursor_Mode;
      Blink   : HD44780_Cursor_Blink) with Inline;


   type HD44780_Direction is (Left, Right);

   for HD44780_Direction use (Left => 0, Right => 1);

   --  Moves cursor without changing DDRAM contents
   procedure Move_Cursor
     (Device    : HD44780_Device'Class;
      Direction : HD44780_Direction;
      Amount    : Positive := 1) with Inline;

   --  Shifts the display without changing DDRAM contents
   procedure Shift_Display
     (Device    : HD44780_Device'Class;
      Direction : HD44780_Direction;
      Amount    : Positive := 1) with Inline;


   --  Check if an internal operation is being performed
   function Is_Busy
     (Device  :     HD44780_Device'Class;
      Address : out UInt7) return Boolean;

   --  Check if an internal operation is being performed
   function Is_Busy
     (Device : HD44780_Device'Class) return Boolean;

   --  Wait for an internal operation to finish
   procedure Wait
     (Device : HD44780_Device'Class);


   subtype HD44780_CGRAM_Slot_5x8  is UInt3;
   subtype HD44780_CGRAM_Slot_5x10 is UInt2;

   subtype HD44780_CGRAM_Row_5x8   is UInt3;
   subtype HD44780_CGRAM_Row_5x10  is UInt4 range 0 .. 2#1010#; -- 10

   subtype HD44780_CGRAM_Row_Data  is UInt5;

   type HD44780_CGRAM_Data_5x8  is
     array (HD44780_CGRAM_Row_5x8)  of HD44780_CGRAM_Row_Data;

   type HD44780_CGRAM_Data_5x10 is
     array (HD44780_CGRAM_Row_5x10) of HD44780_CGRAM_Row_Data;

   Empty_Bitmap_5x8  : constant HD44780_CGRAM_Data_5x8  := (others => 2#00000#);
   Empty_Bitmap_5x10 : constant HD44780_CGRAM_Data_5x10 := (others => 2#00000#);

   --  Store a custom character of size 5x8 in the CGRAM
   procedure Set_Custom_Character_5x8
     (Device   : HD44780_Device'Class;
      Location : HD44780_CGRAM_Slot_5x8;
      Bitmap   : HD44780_CGRAM_Data_5x8);

   --  Store a custom character of size 5x10 in the CGRAM
   procedure Set_Custom_Character_5x10
     (Device   : HD44780_Device'Class;
      Location : HD44780_CGRAM_Slot_5x10;
      Bitmap   : HD44780_CGRAM_Data_5x10);

   subtype HD44780_Character is Character;

   subtype HD44780_Row       is Bit   range 0 .. 1;
   subtype HD44780_Column_2L is UInt6 range 0 .. 39;

   subtype HD44780_Column_1L is UInt7 range 0 .. 79;

   --  Write a character to the LCD (use for 1 line displays only)
   procedure Put
     (Device : HD44780_Device'Class;
      Item   : HD44780_Character;
      Column : HD44780_Column_1L);

   --  Write a character to the LCD (use for 2 line displays only)
   procedure Put
     (Device : HD44780_Device'Class;
      Item   : HD44780_Character;
      Row    : HD44780_Row;
      Column : HD44780_Column_2L);

private

   type HD44780_Device
     (Time : not null Any_Delays) is abstract tagged limited null record;

   --  Instruction register (IR) or data register (DR)
   type HD44780_Register is (IR, DR);

   --  Write byte (DB7 .. DB0) or nibble (DB7 .. DB4)
   type HD44780_Mode is (Byte, Nibble);

   --  Databyte (DB)
   type HD44780_Data is
      record
         DB0 : Bit;
         DB1 : Bit;
         DB2 : Bit;
         DB3 : Bit;
         DB4 : Bit;
         DB5 : Bit;
         DB6 : Bit;
         DB7 : Bit;
      end record
     with
       Pack, Size => 8;

   ----------------------
   -- HD44780_Device_4 --
   ----------------------

   type HD44780_Device_4
     (RS   : not null Any_GPIO_Point;
      RW   : not null Any_GPIO_Point;
      E    : not null Any_GPIO_Point;
      DB4  : not null Any_GPIO_Point;
      DB5  : not null Any_GPIO_Point;
      DB6  : not null Any_GPIO_Point;
      DB7  : not null Any_GPIO_Point;
      Time : not null Any_Delays) is new HD44780_Device (Time)
     with
      record
         Initialized : Boolean := False;
      end record;

   overriding
   procedure Write
     (Device   : HD44780_Device_4;
      Register : HD44780_Register;
      Data     : HD44780_Data;
      Mode     : HD44780_Mode);

   overriding
   function Read
     (Device   : HD44780_Device_4;
      Register : HD44780_Register) return HD44780_Data;


   ----------------------
   -- HD44780_Device_8 --
   ----------------------

   type HD44780_Device_8
     (RS   : not null Any_GPIO_Point;
      RW   : not null Any_GPIO_Point;
      E    : not null Any_GPIO_Point;
      DB0  : not null Any_GPIO_Point;
      DB1  : not null Any_GPIO_Point;
      DB2  : not null Any_GPIO_Point;
      DB3  : not null Any_GPIO_Point;
      DB4  : not null Any_GPIO_Point;
      DB5  : not null Any_GPIO_Point;
      DB6  : not null Any_GPIO_Point;
      DB7  : not null Any_GPIO_Point;
      Time : not null Any_Delays) is new HD44780_Device (Time)
     with
      record
         Initialized : Boolean := False;
      end record;

   overriding
   procedure Write
     (Device   : HD44780_Device_8;
      Register : HD44780_Register;
      Data     : HD44780_Data;
      Mode     : HD44780_Mode);

   overriding
   function Read
     (Device   : HD44780_Device_8;
      Register : HD44780_Register) return HD44780_Data;

end HD44780;
