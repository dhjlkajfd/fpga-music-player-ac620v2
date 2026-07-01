module qy0768_play_ctrl_frontend (
    input  wire       clk_50m,
    input  wire       rst_n,
    input  wire       play_pause_pulse,
    input  wire       next_key_pulse,
    input  wire       prev_key_pulse,
    input  wire       speed_key_pulse,
    output reg        play_en,
    output reg        next_song_pulse,
    output reg        prev_song_pulse,
    output reg  [1:0] speed_mode
);

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            play_en         <= 1'b1;
            next_song_pulse <= 1'b0;
            prev_song_pulse <= 1'b0;
            speed_mode      <= 2'b00;
        end else begin
            next_song_pulse <= 1'b0;
            prev_song_pulse <= 1'b0;

            if (play_pause_pulse) begin
                play_en <= ~play_en;
            end

            if (next_key_pulse) begin
                next_song_pulse <= 1'b1;
            end

            if (prev_key_pulse) begin
                prev_song_pulse <= 1'b1;
            end

            if (speed_key_pulse) begin
                case (speed_mode)
                    2'b00: speed_mode <= 2'b01;
                    2'b01: speed_mode <= 2'b10;
                    default: speed_mode <= 2'b00;
                endcase
            end
        end
    end

endmodule
