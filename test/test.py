# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    dut._log.info("Test project behavior")
    for i in range(0, 1<<4):
        for j in range(0, 1<<4):
            # Set the input values you want to test
            dut.a.value = i
            dut.b.value = j

            # Wait for one clock cycle to see the output values
            await ClockCycles(dut.clk, 10)

            # The following assersion is just an example of how to check the output values.
            # Change it to match the actual expected output of your module:
            dut._log.info(f"value of outputs are: {dut.sum.value} and {dut.carry_out.value}.")
            # assert dut.sum.value == (i+j)-((i+j)&(1<<4)) and dut.carry_out.value == ((i+j)&(1<<4))>>4 
            assert dut.sum.value + (1<<4)*dut.carry_out.value == i+j

            # Keep testing the module by changing the input values, waiting for
            # one or more clock cycles, and asserting the expected output values.

