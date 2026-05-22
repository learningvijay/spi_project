`timescale 1ns/1ps

module tb_spi_slave_control_select;

    reg p_clk;
    reg p_reset;
    reg mstr;
    reg spiswai;
    reg send_data;

    reg [12:0] baudrate_divisor;
    reg [1:0] spi_mode;

    wire recive_data;
    wire ss;
    wire tip;

    // DUT Instantiation
    spi_slave_control_select dut (
        .p_clk(p_clk),
        .p_reset(p_reset),
        .mstr(mstr),
        .spiswai(spiswai),
        .send_data(send_data),
        .baudrate_divisor(baudrate_divisor),
        .spi_mode(spi_mode),
        .recive_data(recive_data),
        .ss(ss),
        .tip(tip)
    );

    // Clock Generation
    initial begin
        p_clk = 0;
        forever #5 p_clk = ~p_clk;
    end

    // Test Sequence
    initial begin

        // Initial values
        p_reset = 0;
        mstr = 0;
        spiswai = 0;
        send_data = 0;
        baudrate_divisor = 13'd2;
        spi_mode = 2'b00;

        // Apply Reset
        #20;
        p_reset = 1;

        // Enable master mode
        #10;
        mstr = 1;

        // Send data pulse
        #10;
        send_data = 1;

        #10;
        send_data = 0;

        // Wait enough time for receive pulse
        #300;

        // Another transaction
        send_data = 1;

        #10;
        send_data = 0;

        #300;

        $finish;
    end

    // Monitor Signals
    initial begin
        $monitor("TIME=%0t RESET=%b SEND=%b SS=%b TIP=%b COUNT_RECIVE=%b",
                 $time,
                 p_reset,
                 send_data,
                 ss,
                 tip,
                 recive_data);
    end

endmodule
