module qy0768_display_timer (
    input  wire       clk_50m,
    input  wire       rst_n,
    input  wire       playing,
    input  wire       song_change_pulse,
    input  wire       song_restart_pulse,
    output reg  [7:0] play_sec
);

    localparam [31:0] SEC_CYCLES = 32'd50000000;

    reg [31:0] sec_cnt;

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            sec_cnt  <= 32'd0;
            play_sec <= 8'd0;
        end else if (song_change_pulse || song_restart_pulse) begin
            sec_cnt  <= 32'd0;
            play_sec <= 8'd0;
        end else if (playing) begin
            if (sec_cnt >= (SEC_CYCLES - 32'd1)) begin
                sec_cnt <= 32'd0;
                if (play_sec < 8'd99) begin
                    play_sec <= play_sec + 8'd1;
                end
            end else begin
                sec_cnt <= sec_cnt + 32'd1;
            end
        end
    end

endmodule
