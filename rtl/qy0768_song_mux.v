module qy0768_song_mux (
    input  wire [1:0] song_id,

    input  wire [4:0] rom0_note_id,
    input  wire [7:0] rom0_duration,
    input  wire       rom0_song_end,

    input  wire [4:0] rom1_note_id,
    input  wire [7:0] rom1_duration,
    input  wire       rom1_song_end,

    input  wire [4:0] rom2_note_id,
    input  wire [7:0] rom2_duration,
    input  wire       rom2_song_end,

    output reg  [4:0] selected_note_id,
    output reg  [7:0] selected_duration,
    output reg        selected_song_end
);

    always @(*) begin
        selected_note_id  = rom0_note_id;
        selected_duration = rom0_duration;
        selected_song_end = rom0_song_end;

        case (song_id)
            2'd0: begin
                selected_note_id  = rom0_note_id;
                selected_duration = rom0_duration;
                selected_song_end = rom0_song_end;
            end

            2'd1: begin
                selected_note_id  = rom1_note_id;
                selected_duration = rom1_duration;
                selected_song_end = rom1_song_end;
            end

            2'd2: begin
                selected_note_id  = rom2_note_id;
                selected_duration = rom2_duration;
                selected_song_end = rom2_song_end;
            end

            default: begin
                selected_note_id  = rom0_note_id;
                selected_duration = rom0_duration;
                selected_song_end = rom0_song_end;
            end
        endcase
    end

endmodule
