
#  Traffic Light Controller – Advanced Digital Design

##  Project Overview

This project implements a **Finite State Machine (FSM)**–based **traffic light controller** for a main road, side road, and pedestrian crossing.
It was developed as part of the **Advanced Digital Design (ENCS3310)** course.

The controller is written in **Verilog HDL**, verified using **simulation waveforms**, and designed with clear state encoding, timing control, and reset behavior.

---

##  Objectives

* Design a clear and correct **FSM** for traffic light control
* Implement the FSM using **Verilog**
* Handle **timed transitions** between states
* Support **pedestrian crossing**
* Verify functionality using **testbench simulation and waveforms**
* Apply **synchronous clocking** with **negative-edge reset**

---

## System Description

### Controlled Signals

* **Main Road Traffic Light**: GREEN, YELLOW, RED
* **Side Road Traffic Light**: GREEN, YELLOW, RED
* **Pedestrian Signal**: GREEN, RED

### FSM States

The system state is a combination of traffic and pedestrian signals, resulting in **six main FSM states**, including:

* M-GREEN
* M-YELLOW
* M-RED
* S-GREEN
* S-YELLOW
* Pedestrian-GREEN / RED combinations

---

## Timing & Control

* State transitions are controlled using **timers/counters**
* The system operates on the **positive edge of the clock**
* **Reset is asserted on the negative edge**

  * When reset is asserted, the system transitions to **M-GREEN**
  * Reset behavior is verified separately before functional testing

---

## Verification & Testing

* A **Verilog testbench** is used to validate the FSM behavior
* Simulation waveforms are generated to verify:

  * Correct state transitions
  * Proper timing
  * Reset functionality
* Waveform results confirm compliance with the design specifications

---

## Tools & Technologies

* **Language**: Verilog HDL
* **Simulation Tool**: Active-HDL
* **Design Methodology**: Finite State Machine (FSM)

---

## Simulation Results

Waveforms demonstrate:

* Correct FSM sequencing
* Accurate timer-based transitions
* Proper reset behavior

(See waveform files/screenshots in the `waveform/` directory)

---

## Author

**Leen Alqazaqi**
Computer Engineering
Birzeit University

---

## Course Information

* **Course**: Advanced Digital Design (ENCS3310)
* **Instructor**: Dr. Abdellatif Abu-Issa
* **Semester**: January 2026

Just tell me ✨
