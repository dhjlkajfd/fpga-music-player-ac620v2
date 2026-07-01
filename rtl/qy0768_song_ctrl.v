module qy0768_song_ctrl (
    input  wire       clk_50m,
    input  wire       rst_n,
    input  wire       play_en,
    input  wire       next_song_pulse,
    input  wire       prev_song_pulse,
    input  wire [1:0] speed_mode,
    output reg  [1:0] song_id,
    output reg  [9:0] rom_addr,
    input  wire [4:0] rom_note_id,
    input  wire [7:0] rom_duration,
    input  wire       rom_song_end,
    output reg  [4:0] current_note_id,
    output reg  [7:0] play_time_sec
);

    localparam [31:0] BEAT_CYCLES_1X = 32'd12500000; // 0.25 s at 50 MHz
    localparam [31:0] BEAT_CYCLES_2X = 32'd6250000;  // 0.125 s at 50 MHz
    localparam [31:0] BEAT_CYCLES_4X = 32'd3125000;  // 0.0625 s at 50 MHz
    localparam [31:0] SEC_CYCLES     = 32'd50000000; // 1 s at 50 MHz

    localparam [1:0] STATE_LOAD = 2'd0;
    localparam [1:0] STATE_PLAY = 2'd1;

    reg [1:0]  state;
    reg [31:0] beat_cnt;
    reg [31:0] sec_cnt;
    reg [7:0]  note_beats_left;
    reg [31:0] beat_cycles;

    wire beat_tick;

    assign beat_tick = (beat_cnt >= (beat_cycles - 32'd1));

    always @(*) begin
        case (speed_mode)
            2'b00: beat_cycles = BEAT_CYCLES_1X;
            2'b01: beat_cycles = BEAT_CYCLES_2X;
            2'b10: beat_cycles = BEAT_CYCLES_4X;
            default: beat_cycles = BEAT_CYCLES_1X;
        endcase
    end

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            song_id         <= 2'd0;
            rom_addr        <= 10'd0;
            current_note_id <= 5'd0;
            play_time_sec   <= 8'd0;
            state           <= STATE_LOAD;
            beat_cnt        <= 32'd0;
            sec_cnt         <= 32'd0;
            note_beats_left <= 8'd0;
        end else if (next_song_pulse) begin
            song_id         <= (song_id == 2'd2) ? 2'd0 : (song_id + 2'd1);
            rom_addr        <= 10'd0;
            current_note_id <= 5'd0;
            play_time_sec   <= 8'd0;
            state           <= STATE_LOAD;
            beat_cnt        <= 32'd0;
            sec_cnt         <= 32'd0;
            note_beats_left <= 8'd0;
        end else if (prev_song_pulse) begin
            song_id         <= (song_id == 2'd0) ? 2'd2 : (song_id - 2'd1);
            rom_addr        <= 10'd0;
            current_note_id <= 5'd0;
            play_time_sec   <= 8'd0;
            state           <= STATE_LOAD;
            beat_cnt        <= 32'd0;
            sec_cnt         <= 32'd0;
            note_beats_left <= 8'd0;
        end else if (play_en) begin
            if (sec_cnt >= (SEC_CYCLES - 32'd1)) begin
                sec_cnt <= 32'd0;
                if (play_time_sec != 8'hff) begin
                    play_time_sec <= play_time_sec + 8'd1;
                end
            end else begin
                sec_cnt <= sec_cnt + 32'd1;
            end

            case (state)
                STATE_LOAD: begin
                    // LOAD: sample the ROM output for rom_addr and prepare one note.
                    beat_cnt <= 32'd0;
                    if (rom_song_end) begin
                        // End marker: loop the current song from address 0.
                        rom_addr        <= 10'd0;
                        current_note_id <= 5'd0;
                        play_time_sec   <= 8'd0;
                        sec_cnt         <= 32'd0;
                        note_beats_left <= 8'd0;
                        state           <= STATE_LOAD;
                    end else begin
                        current_note_id <= rom_note_id;
                        note_beats_left <= (rom_duration == 8'd0) ? 8'd1 : rom_duration;
                        state           <= STATE_PLAY;
                    end
                end

                STATE_PLAY: begin
                    // PLAY: hold current_note_id until duration basic beats finish.
                    if (beat_tick) begin
                        beat_cnt <= 32'd0;
                        if (note_beats_left <= 8'd1) begin
                            note_beats_left <= 8'd0;
                            rom_addr <= (rom_addr == 10'd1023) ? 10'd0 : (rom_addr + 10'd1);
                            state <= STATE_LOAD;
                        end else begin
                            note_beats_left <= note_beats_left - 8'd1;
                        end
                    end else begin
                        beat_cnt <= beat_cnt + 32'd1;
                    end
                end

                default: begin
                    // Recovery for an invalid state.
                    state           <= STATE_LOAD;
                    beat_cnt        <= 32'd0;
                    note_beats_left <= 8'd0;
                    current_note_id <= 5'd0;
                end
            endcase
        end
        // When play_en is 0, all registers hold their values to pause playback.
    end

endmodule
