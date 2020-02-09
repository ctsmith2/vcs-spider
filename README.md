# Spider Web
> Spider Web game for Atari VCS/2600<br />
> Created by D Cooper Dalrymple 2018 - [dcdalrymple.com](https://dcdalrymple.com/)<br />
> Licensed under GNU LGPL V3.0<br />
> Last revision: September 5th, 2019

## Compilation

The **dasm macro assembler** is required to compile this program on your local machine. Pre-compiled rom files are also available in the `bin` folder. To download the dasm executables, visit [dasm-dillon.sourceforge.net](http://dasm-dillon.sourceforge.net).

### Linux

Make sure that you have the `dasm` executable copied into a location in your bash path. Compile the project using the by giving the build file execute permission `chmod +x ./build.sh` and running it with `./build.sh` in your terminal while inside the `vcs-spider` directory.

### Windows

Make sure that you have the `dasm` executable copied into a location in your path variable. Either run the `build.bat` program from a command prompt or double click it in your file explorer.

## Distribution

Physical distribution for commercial use (whether in cartridge or compact format) is not permitted whereas for personal use is strongly recommended as this game is intended to be used on the original Atari 2600 hardware.

## Build With

* Assembled with dasm from [dasm-dillon.sourceforge.net](http://dasm-dillon.sourceforge.net)
* Tested with Stella from [stella-emu.github.io](https://stella-emu.github.io)
* Tested with real Atari 2600 using custom EEPROM cartridges

## TODO

- [x] Level variable with increasing difficulty and changing color palette
- [x] Difficulty switch support to increase starting difficulty
- [x] Health bar and level counter
- [ ] 6 digit score kernel with 16-bit score
- [ ] Black and white TV switch support
- [ ] Game select switch support? (Easter egg?)
- [x] Revised game kernel
- [x] Swatter collision logic
- [x] Swatter enemy sprite, kernel routines, and animation
- [x] Add strands of web holding each spider up on title screen using missles and balls

## BUGS

- [ ] Improve multiple sprite scanlines
- [x] Spider boundary
- [x] Line spawning

## License

This project is licensed under GNU LGPL V3.0 - see the [LICENSE](LICENSE) file for details.
