module qy0768_seg7_ac620v2_driver (
    input  wire       clk_50m,
    input  wire       rst_n,
    input  wire [7:0] seg0,
    input  wire [7:0] seg1,
    input  wire [7:0] seg2,
    input  wire [7:0] seg3,
    input  wire [7:0] seg4,
    input  wire [7:0] seg5,
    input  wire [7:0] seg6,
    input  wire [7:0] seg7,
    output reg        seg7_sclk,
    output reg        seg7_rclk,
    output reg        seg7_dio
);

    localparam [15:0] SCAN_CYCLES      = 16'd50000;
    localparam [15:0] SCLK_HALF_CYCLES = 16'd25;

    localparam [2:0] STATE_IDLE      = 3'd0;
    localparam [2:0] STATE_SCLK_HIGH = 3'd1;
    localparam [2:0] STATE_SCLK_LOW  = 3'd2;
    localparam [2:0] STATE_RCLK_HIGH = 3'd3;
    localparam [2:0] STATE_RCLK_LOW  = 3'd4;

    reg [2:0]  state;
    reg [15:0] scan_cnt;
    reg [15:0] div_cnt;
    reg [4:0]  bit_cnt;
    reg [2:0]  scan_digit;
    reg [15:0] shift_reg;

    wire scan_tick;

    assign scan_tick = (scan_cnt == (SCAN_CYCLES - 16'd1));

    function [7:0] select_seg;
        input [2:0] digit;
        begin
            case (digit)
                3'd0: select_seg = seg0;
                3'd1: select_seg = seg1;
                3'd2: select_seg = seg2;
                3'd3: select_seg = seg3;
                3'd4: select_seg = seg4;
                3'd5: select_seg = seg5;
                3'd6: select_seg = seg6;
                3'd7: select_seg = seg7;
                default: select_seg = 8'd0;
            endcase
        end
    endfunction

    function [15:0] build_shift_word;
        input [2:0] digit;
        reg [7:0] seg_logic;
        reg [7:0] seg_hw;
        reg [7:0] dig_hw;
        begin
            seg_logic = select_seg(digit);
            seg_hw    = ~seg_logic;
            dig_hw    = (8'b00000001 << digit);

            build_shift_word = {seg_hw, dig_hw};
        end
    endfunction

    function select_shift_bit;
        input [15:0] data;
        input [4:0]  index;
        begin
            select_shift_bit = data[5'd15 - index];
        end
    endfunction

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            scan_cnt  <= 16'd0;
            div_cnt   <= 16'd0;
            bit_cnt   <= 5'd0;
            scan_digit <= 3'd0;
            shift_reg <= 16'd0;
            state     <= STATE_IDLE;
            seg7_sclk <= 1'b0;
            seg7_rclk <= 1'b0;
            seg7_dio  <= 1'b0;
        end else begin
            if (scan_tick) begin
                scan_cnt <= 16'd0;
            end else begin
                scan_cnt <= scan_cnt + 16'd1;
            end

            case (state)
                STATE_IDLE: begin
                    seg7_sclk <= 1'b0;
                    seg7_rclk <= 1'b0;
                    div_cnt   <= 16'd0;
                    bit_cnt   <= 5'd0;

                    if (scan_tick) begin
                        shift_reg <= build_shift_word(scan_digit);
                        seg7_dio  <= select_shift_bit(build_shift_word(scan_digit), 5'd0);
                        scan_digit <= scan_digit + 3'd1;
                        state     <= STATE_SCLK_HIGH;
                    end
                end

                STATE_SCLK_HIGH: begin
                    if (div_cnt >= (SCLK_HALF_CYCLES - 16'd1)) begin
                        div_cnt   <= 16'd0;
                        seg7_sclk <= 1'b1;
                        state     <= STATE_SCLK_LOW;
                    end else begin
                        div_cnt <= div_cnt + 16'd1;
                    end
                end

                STATE_SCLK_LOW: begin
                    if (div_cnt >= (SCLK_HALF_CYCLES - 16'd1)) begin
                        div_cnt   <= 16'd0;
                        seg7_sclk <= 1'b0;

                        if (bit_cnt == 5'd15) begin
                            state <= STATE_RCLK_HIGH;
                        end else begin
                            bit_cnt  <= bit_cnt + 5'd1;
                            seg7_dio <= select_shift_bit(shift_reg, bit_cnt + 5'd1);
                            state    <= STATE_SCLK_HIGH;
                        end
                    end else begin
                        div_cnt <= div_cnt + 16'd1;
                    end
                end

                STATE_RCLK_HIGH: begin
                    seg7_rclk <= 1'b1;
                    state     <= STATE_RCLK_LOW;
                end

                STATE_RCLK_LOW: begin
                    seg7_rclk <= 1'b0;
                    state     <= STATE_IDLE;
                end

                default: begin
                    state     <= STATE_IDLE;
                    seg7_sclk <= 1'b0;
                    seg7_rclk <= 1'b0;
                end
            endcase
        end
    end

endmodule
