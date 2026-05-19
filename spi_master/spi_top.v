`include "spi_slave_control_select.v"
`include "spi_baud_rate_generator.v"
`include "spi_master_apb_slave_interface.v"
`include "spi_shift_reg.v"

`timescale 1ns/1ps

module spi_top (

    //========================
    // APB INTERFACE
    //========================
    input         p_clk,
    input         p_reset,

    input         p_select,
    input         p_enable,
    input         p_write,

    input  [2:0] p_addr,
    input  [7:0] p_data_in,

    output [7:0] p_data_out,
    output        p_ready,
    output        p_slverr,

    //========================
    // SPI INTERFACE
    //========================
    output ss,
    output s_clk,
    output mosi,

    input  miso,

    output spi_interrupt_request

);


//=====================================================
// INTERNAL WIRES
//=====================================================

// APB ↔ SPI control
wire send_data;
wire receive_data;

wire [7:0] data_to_send_buffer_reg;
wire [7:0] data_from_receive_buffer_reg;

// SPI configuration
wire mstr;
wire cpol;
wire cpha;
wire lsbfe;
wire spiswai;

wire [1:0] spi_mode;

wire [2:0] spr;
wire [2:0] sppr;

// SPI status
wire tip;

// Baud generator
wire [12:0] spi_baud_rate_divisor;

// Shift register control
wire miso_receive_s_clk_rising;
wire miso_receive_s_clk_falling;

wire mosi_send_s_clk_rising;
wire mosi_send_s_clk_falling;


//=====================================================
// APB SLAVE INTERFACE
//=====================================================

spi_master_apb_slave_interface m4(

    .p_clk(p_clk),
    .p_reset(p_reset),

    .p_select(p_select),
    .p_enable(p_enable),
    .p_write(p_write),

    .p_addr(p_addr),
    .p_data_in(p_data_in),

    .ss(ss),
    .receive_data(receive_data),

    .data_from_receive_buffer_reg(data_from_receive_buffer_reg),

    .tip(tip),

    .p_data_out(p_data_out),

    .send_data(send_data),

    .p_ready(p_ready),
    .p_slverr(p_slverr),

    .spi_interrupt_request(spi_interrupt_request),

    .mstr(mstr),
    .cpol(cpol),
    .cpha(cpha),
    .lsbfe(lsbfe),
    .spiswai(spiswai),

    .data_to_send_buffer_reg(data_to_send_buffer_reg),

    .spi_mode(spi_mode),

    .spr(spr),
    .sppr(sppr)

);


//=====================================================
// SPI SLAVE CONTROL SELECT
//=====================================================

spi_slave_control_select  m1(

    .p_clk(p_clk),
    .p_reset(p_reset),

    .mstr(mstr),
    .spiswai(spiswai),

    .send_data(send_data),

    .baudrate_divisor(spi_baud_rate_divisor),

    .spi_mode(spi_mode),

    .recive_data(receive_data),

    .ss(ss),

    .tip(tip)

);


//=====================================================
// SPI BAUD RATE GENERATOR
//=====================================================

spi_baud_rate_generator m2(

    .p_clk(p_clk),
    .p_reset(p_reset),

    .spiswai(spiswai),

    .cpol(cpol),
    .cpha(cpha),

    .ss(ss),

    .spi_mode(spi_mode),

    .sppr(sppr),
    .spr(spr),

    .s_clk(s_clk),

    .miso_receive_s_clk_rising(miso_receive_s_clk_rising),
    .miso_receive_s_clk_falling(miso_receive_s_clk_falling),

    .mosi_send_s_clk_rising(mosi_send_s_clk_rising),
    .mosi_send_s_clk_falling(mosi_send_s_clk_falling),

    .spi_baud_rate_divisor(spi_baud_rate_divisor)

);


//=====================================================
// SPI SHIFT REGISTER
//=====================================================

spi_shift_reg  m3(

    .p_clk(p_clk),
    .p_reset(p_reset),

    .ss(ss),

    .lsbef(lsbfe),

    .cpha(cpha),
    .cpol(cpol),

    .send_data(send_data),
    .receive_data(receive_data),

    .miso_receive_s_clk_rising(miso_receive_s_clk_rising),
    .miso_receive_s_clk_falling(miso_receive_s_clk_falling),

    .mosi_send_s_clk_rising(mosi_send_s_clk_rising),
    .mosi_send_s_clk_falling(mosi_send_s_clk_falling),

    .data_from_spidr(data_to_send_buffer_reg),

    .miso(miso),

    .mosi(mosi),

    .data_to_spidr(data_from_receive_buffer_reg)

);

endmodule
