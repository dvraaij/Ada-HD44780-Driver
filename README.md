# Driver for the Hitachi HD44780 LCD controller

LCD display units with an
[HD44780](https://en.wikipedia.org/wiki/Hitachi_HD44780_LCD_controller)
controller used to be quite popular as they could be easily connected to an MCU.
As I was experimenting with Ada on embedded platforms and happen to own an
HD44780 LCD unit, I was curious how difficult it would be to design and
implement a driver for these controllers.

### Prerequisites

The driver relies on the driver framework which comes with the [Ada Drivers
Library](https://github.com/AdaCore/Ada_Drivers_Library) and as such requires
the library to be available during compilation. You may need to change the path
to the library in `hd44780_driver.gpr`.

### Custom Characters

The HD44780 controller can store up to 8 custom characters of 8x4 pixels or 4
custom characters of 8x10 pixels in its RAM. Please have a look in the
[bitmap](bitmap/) directory for some example characters in [PBM file
format](https://en.wikipedia.org/wiki/Netpbm_format). PBM graphics files can be
generated using e.g. the [GIMP](https://www.gimp.org/) although you have to
remove the comments (i.e. lines starting with #) that the GIMP typically inserts
in order to use the Python script `pbm_to_ada.py`. This script can be used to
convert ASCII PBM files to Ada code:

```
$ ./pbm_to_ada.py Euro.pbm Euro_Character
Euro_Character : constant HD44780_Bitmap :=
  (0 => 2#00000#,
   1 => 2#00110#,
   2 => 2#01001#,
   3 => 2#11100#,
   4 => 2#01000#,
   5 => 2#11100#,
   6 => 2#01001#,
   7 => 2#00110#);
```

### Open Issues

Please note that this project is still work-in-progress.
