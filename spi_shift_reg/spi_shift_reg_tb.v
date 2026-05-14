`timescale 1ns/1ps

module tb_spi_shift_reg;

//
// INPUTS
//
reg p_clk;
reg p_reset;
reg ss;
reg lsbef;
reg cpha;
reg cpol;

reg send_data;
reg receive_data;

reg miso_receive_s_clk_rising;
reg miso_receive_s_clk_falling;

reg mosi_send_s_clk_rising;
reg mosi_send_s_clk_falling;

reg [7:0] data_from_spidr;

reg miso;

//
// OUTPUTS
//
wire mosi;

wire [7:0] data_to_spidr;

//
// DUT INSTANTIATION
//
spi_shift_reg DUT (
    .p_clk(p_clk),
    .p_reset(p_reset),
    .ss(ss),
    .lsbef(lsbef),
    .cpha(cpha),
    .cpol(cpol),

    .send_data(send_data),
    .receive_data(receive_data),

    .miso_receive_s_clk_rising(miso_receive_s_clk_rising),
    .miso_receive_s_clk_falling(miso_receive_s_clk_falling),

    .mosi_send_s_clk_rising(mosi_send_s_clk_rising),
    .mosi_send_s_clk_falling(mosi_send_s_clk_falling),

    .data_from_spidr(data_from_spidr),

    .miso(miso),

    .mosi(mosi),

    .data_to_spidr(data_to_spidr)
);

endmodule