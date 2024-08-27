
# CISESS Summer 2024 Intern Project

> Authored by Nathan Ho, mentored by Dr. Hu Yang.

This repository contains the RTL control logic for a Digilent Arty S7 FPGA board, which implements the signal processing suite of a microwave radiometer prototype; as well its associated documentation.

## Cloning

Version control was made possible by the [vivado-git](https://github.com/barbedo/vivado-git) tool. Clone the repository as normal, and then run the TCL script located in the root directory labeled `microwave-radiometer-2024.tcl` to regenerate the auxiliary project files (in Vivado: `Tools -> Run TCL Script`). See the `vivado-git` repository for project structure.

## Board Files

When regenerating the project it's important that you have all of the board files. These files outline hardware specifications and other details for Vivado. You can follow [this guide](https://digilent.com/reference/programmable-logic/guides/install-board-files?srsltid=AfmBOooB3LuIsrNLY9teGl__aQFtgg-Aye3OvFdzyjYyEtIfhCszMPRF) for more information on how to acquire the Digilent board files.
