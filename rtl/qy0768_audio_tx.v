module qy0768_audio_tx (
    input  wire               clk_50m,
    input  wire               rst_n,
    input  wire signed [15:0] audio_l,
    input  wire signed [15:0] audio_r,
    output wire               aud_xck,
    output reg                aud_bclk,
    output reg                aud_daclrck,
    output reg                aud_dacdat
);

    // Simplified timing for the first WM8731 audio test:
    // aud_xck ~= 12.5 MHz, aud_bclk ~= 1.5625 MHz, lrck ~= 48.8 kHz.
    // These dividers can be adjusted later against the WM8731 official example
    // and the exact sampling-rate requirement.
    localparam [1:0]  XCK_HALF_CYCLES  = 2'd2;
    localparam [15:0] BCLK_HALF_CYCLES = 16'd16;

    reg        aud_xck_reg;
    reg [1:0]  xck_cnt;
    reg [15:0] bclk_cnt;
    reg [3:0]  bit_cnt;
    reg        channel_sel;
    reg signed [15:0] sample_l;
    reg signed [15:0] sample_r;

    assign aud_xck = aud_xck_reg;

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            aud_xck_reg <= 1'b0;
            xck_cnt     <= 2'd0;
        end else if (xck_cnt >= (XCK_HALF_CYCLES - 2'd1)) begin
            xck_cnt     <= 2'd0;
            aud_xck_reg <= ~aud_xck_reg;
        end else begin
            xck_cnt <= xck_cnt + 2'd1;
        end
    end

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            aud_bclk    <= 1'b0;
            aud_daclrck <= 1'b0;
            aud_dacdat  <= 1'b0;
            bclk_cnt    <= 16'd0;
            bit_cnt     <= 4'd0;
            channel_sel <= 1'b0;
            sample_l    <= 16'sd0;
            sample_r    <= 16'sd0;
        end else if (bclk_cnt >= (BCLK_HALF_CYCLES - 16'd1)) begin
            bclk_cnt <= 16'd0;
            aud_bclk <= ~aud_bclk;

            if (aud_bclk) begin
                // Update data on the falling edge of BCLK so it is stable
                // before the next rising edge. channel_sel 0 = left, 1 = right.
                aud_daclrck <= channel_sel;

                if ((channel_sel == 1'b0) && (bit_cnt == 4'd0)) begin
                    sample_l   <= audio_l;
                    sample_r   <= audio_r;
                    aud_dacdat <= audio_l[15];
                end else if (channel_sel == 1'b0) begin
                    aud_dacdat <= sample_l[15 - bit_cnt];
                end else begin
                    aud_dacdat <= sample_r[15 - bit_cnt];
                end

                if (bit_cnt == 4'd15) begin
                    bit_cnt     <= 4'd0;
                    channel_sel <= ~channel_sel;
                end else begin
                    bit_cnt <= bit_cnt + 4'd1;
                end
            end
        end else begin
            bclk_cnt <= bclk_cnt + 16'd1;
        end
    end

endmodule
