module qy0768_key_filter #(
    parameter CNT_MAX = 20'd999999
) (
    input  wire clk_50m,
    input  wire rst_n,
    input  wire key_in,
    output reg  key_state,
    output reg  key_press_pulse
);

    reg key_sync0;
    reg key_sync1;
    reg [19:0] cnt;

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            key_sync0 <= 1'b1;
            key_sync1 <= 1'b1;
        end else begin
            key_sync0 <= key_in;
            key_sync1 <= key_sync0;
        end
    end

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            key_state       <= 1'b1;
            key_press_pulse <= 1'b0;
            cnt             <= 20'd0;
        end else begin
            key_press_pulse <= 1'b0;

            if (key_sync1 == key_state) begin
                cnt <= 20'd0;
            end else if (cnt >= CNT_MAX) begin
                cnt       <= 20'd0;
                key_state <= key_sync1;
                if (key_sync1 == 1'b0) begin
                    key_press_pulse <= 1'b1;
                end
            end else begin
                cnt <= cnt + 20'd1;
            end
        end
    end

endmodule
