# SoC-Pong-Showdown

## Overview
SoC-Pong-Showdown is a fun two-player Pong game implemented using software/hardware co-design on an FPGA. This project leverages VHDL for hardware-specific functionality and real-time constraints, while using C for the game controller and application logic. The game features push button controls and VGA display output, providing a hands-on experience with System-on-Chip (SoC) design and embedded systems.

## Features
- **Two-Player Pong Game**: Play against a friend using push button controls to move your paddles up and down.
- **VGA Display Output**: The game is displayed on a VGA monitor, providing a classic retro gaming experience.
- **Hardware/Software Co-Design**: Combines VHDL and C to efficiently manage game logic and hardware interfacing.
- **Microblaze Soft Processor**: Utilizes the Microblaze processor implemented with configurable logic resources.
- **AXI Bus**: Employs the high-performance AXI bus protocol for interconnect between the processor and peripherals.

## Hardware Configuration
- **FPGA**: The game is designed to run on an FPGA, using its GPIO for button inputs and VGA for video output.
- **Buttons**: Two push buttons per player to move the paddles up and down.
- **VGA Monitor**: Displays the game screen.

## Software Configuration
### VHDL
- **VGA Controller**: Manages the VGA signal timing and frame generation.
- **GPIO Interface**: Reads button states for player inputs.
- **Real-Time Constraints**: Ensures smooth paddle movement and game play.

### C Code
- **Game Controller**: Implements the game logic, including paddle movement and collision detection.
- **Frame Signal Handling**: Updates paddle positions based on button presses at the start of each new frame.

## How It Works
- **Paddle Movement**: The C code checks the GPIO addresses for button states. If a button is pressed, the corresponding paddle position is updated.
- **Frame Generation**: The VGA controller asserts a new frame signal when a full frame is populated. The game controller then updates paddle positions and redraws the frame.
- **Game Logic**: Paddle positions are adjusted by 5 pixels per clock cycle based on button inputs.

## Development Environment
- **VHDL**: Used for implementing the VGA controller, GPIO interface, and other hardware-specific functions.
- **C**: Used for the main game logic, including paddle movement and frame handling.

## Conclusion
SoC-Pong-Showdown is an educational and entertaining project that demonstrates the power of software/hardware co-design. By integrating VHDL and C, it provides a comprehensive example of FPGA-based game development. Enjoy the game and explore the world of embedded systems and SoC design!

## Future Enhancements
- **Enhanced Graphics**: Improve the visual quality of the game.
- **Additional Features**: Add new gameplay features such as scoring and sound effects.
- **Portability**: Explore porting the game to other platforms using different languages like Python.

Feel free to contribute and make this project even more exciting!
