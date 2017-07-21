with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);
--  The "last chance handler" is the user-defined routine that is called when
--  an exception is propagated. We need it in the executable, therefore it
--  must be somewhere in the closure of the context clauses.

with System;
with Ravenscar_Time;

with STM32.Device; use STM32.Device;
with STM32.GPIO;   use STM32.GPIO;
with HD44780;      use HD44780;

procedure Hello_World is
   pragma Priority (System.Priority'First);

   subtype LCD_Pin is GPIO_Point;

   LCD_RS  : LCD_Pin renames PA1;
   LCD_RW  : LCD_Pin renames PA2;
   LCD_E   : LCD_Pin renames PA3;

   LCD_DB0 : LCD_Pin renames PD8;
   LCD_DB1 : LCD_Pin renames PD9;
   LCD_DB2 : LCD_Pin renames PD10;
   LCD_DB3 : LCD_Pin renames PD11;

   LCD_DB4 : LCD_Pin renames PE7;
   LCD_DB5 : LCD_Pin renames PE8;
   LCD_DB6 : LCD_Pin renames PE9;
   LCD_DB7 : LCD_Pin renames PE10;

   All_LCD_Pins : constant GPIO_Points :=
     (LCD_RS,  LCD_RW,  LCD_E,
      LCD_DB0, LCD_DB1, LCD_DB2, LCD_DB3,
      LCD_DB4, LCD_DB5, LCD_DB6, LCD_DB7);

   LCD : HD44780_Device_8
     (RS   => LCD_RS'Access,
      RW   => LCD_RW'Access,
      E    => LCD_E'Access,
      DB0  => LCD_DB0'Access,
      DB1  => LCD_DB1'Access,
      DB2  => LCD_DB2'Access,
      DB3  => LCD_DB3'Access,
      DB4  => LCD_DB4'Access,
      DB5  => LCD_DB5'Access,
      DB6  => LCD_DB6'Access,
      DB7  => LCD_DB7'Access,
      Time => Ravenscar_Time.Delays);

begin

   --  Initialize the MPU's GPIO
   declare
      Configuration : constant GPIO_Port_Configuration :=
        GPIO_Port_Configuration'(Mode        => Mode_Out,
                                 Output_Type => Push_Pull,
                                 Speed       => Speed_100MHz,
                                 Resistors   => Floating);
   begin
      Enable_Clock (All_LCD_Pins);
      Configure_IO (All_LCD_Pins, Configuration);
   end;

   --  Initialize the display
   LCD.Initialize
     (Lines     => Two,
      Font_Size => Dots_5x8,
      Direction => Left_To_Right,
      Shift     => No);

   LCD.Set_Display_Mode
     (Display => On,
      Cursor  => Off,
      Blink   => Off);

   declare
      S : constant String := "Hello World :-)";
   begin
      for Idx in S'Range loop
         LCD.Put (S (Idx), HD44780_Column_1L (Idx - 1));
      end loop;
   end;

   --  Loop forever
   loop
      null;
   end loop;

end Hello_World;
