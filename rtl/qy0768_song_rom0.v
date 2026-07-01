module qy0768_song_rom0 (
    input  wire [9:0] addr,
    output reg  [4:0] note_id,
    output reg  [7:0] duration,
    output reg        song_end
);

    always @(*) begin
        case (addr)
            // Placeholder melody 0. Replace these entries with the final full score.
            // One ROM entry is one note. duration is counted in base beats.
            // Current ROM0 total duration = 112.
            // At speed_mode=00, total play time = 28 seconds.
            10'd0:  begin note_id = 5'd8;  duration = 8'd2; song_end = 1'b0; end // mid 1
            10'd1:  begin note_id = 5'd9;  duration = 8'd2; song_end = 1'b0; end // mid 2
            10'd2:  begin note_id = 5'd10; duration = 8'd2; song_end = 1'b0; end // mid 3
            10'd3:  begin note_id = 5'd11; duration = 8'd2; song_end = 1'b0; end // mid 4
            10'd4:  begin note_id = 5'd12; duration = 8'd2; song_end = 1'b0; end // mid 5
            10'd5:  begin note_id = 5'd13; duration = 8'd2; song_end = 1'b0; end // mid 6
            10'd6:  begin note_id = 5'd14; duration = 8'd2; song_end = 1'b0; end // mid 7
            10'd7:  begin note_id = 5'd15; duration = 8'd4; song_end = 1'b0; end // high 1
            10'd8:  begin note_id = 5'd15; duration = 8'd2; song_end = 1'b0; end // high 1
            10'd9:  begin note_id = 5'd14; duration = 8'd2; song_end = 1'b0; end // mid 7
            10'd10: begin note_id = 5'd13; duration = 8'd2; song_end = 1'b0; end // mid 6
            10'd11: begin note_id = 5'd12; duration = 8'd2; song_end = 1'b0; end // mid 5
            10'd12: begin note_id = 5'd11; duration = 8'd2; song_end = 1'b0; end // mid 4
            10'd13: begin note_id = 5'd10; duration = 8'd2; song_end = 1'b0; end // mid 3
            10'd14: begin note_id = 5'd9;  duration = 8'd2; song_end = 1'b0; end // mid 2
            10'd15: begin note_id = 5'd8;  duration = 8'd4; song_end = 1'b0; end // mid 1
            10'd16: begin note_id = 5'd10; duration = 8'd2; song_end = 1'b0; end // mid 3
            10'd17: begin note_id = 5'd12; duration = 8'd2; song_end = 1'b0; end // mid 5
            10'd18: begin note_id = 5'd15; duration = 8'd2; song_end = 1'b0; end // high 1
            10'd19: begin note_id = 5'd12; duration = 8'd2; song_end = 1'b0; end // mid 5
            10'd20: begin note_id = 5'd11; duration = 8'd2; song_end = 1'b0; end // mid 4
            10'd21: begin note_id = 5'd10; duration = 8'd2; song_end = 1'b0; end // mid 3
            10'd22: begin note_id = 5'd9;  duration = 8'd2; song_end = 1'b0; end // mid 2
            10'd23: begin note_id = 5'd8;  duration = 8'd6; song_end = 1'b0; end // mid 1
            10'd24: begin note_id = 5'd8;  duration = 8'd2; song_end = 1'b0; end // repeat 0, mid 1
            10'd25: begin note_id = 5'd9;  duration = 8'd2; song_end = 1'b0; end // repeat 1, mid 2
            10'd26: begin note_id = 5'd10; duration = 8'd2; song_end = 1'b0; end // repeat 2, mid 3
            10'd27: begin note_id = 5'd11; duration = 8'd2; song_end = 1'b0; end // repeat 3, mid 4
            10'd28: begin note_id = 5'd12; duration = 8'd2; song_end = 1'b0; end // repeat 4, mid 5
            10'd29: begin note_id = 5'd13; duration = 8'd2; song_end = 1'b0; end // repeat 5, mid 6
            10'd30: begin note_id = 5'd14; duration = 8'd2; song_end = 1'b0; end // repeat 6, mid 7
            10'd31: begin note_id = 5'd15; duration = 8'd4; song_end = 1'b0; end // repeat 7, high 1
            10'd32: begin note_id = 5'd15; duration = 8'd2; song_end = 1'b0; end // repeat 8, high 1
            10'd33: begin note_id = 5'd14; duration = 8'd2; song_end = 1'b0; end // repeat 9, mid 7
            10'd34: begin note_id = 5'd13; duration = 8'd2; song_end = 1'b0; end // repeat 10, mid 6
            10'd35: begin note_id = 5'd12; duration = 8'd2; song_end = 1'b0; end // repeat 11, mid 5
            10'd36: begin note_id = 5'd11; duration = 8'd2; song_end = 1'b0; end // repeat 12, mid 4
            10'd37: begin note_id = 5'd10; duration = 8'd2; song_end = 1'b0; end // repeat 13, mid 3
            10'd38: begin note_id = 5'd9;  duration = 8'd2; song_end = 1'b0; end // repeat 14, mid 2
            10'd39: begin note_id = 5'd8;  duration = 8'd4; song_end = 1'b0; end // repeat 15, mid 1
            10'd40: begin note_id = 5'd10; duration = 8'd2; song_end = 1'b0; end // repeat 16, mid 3
            10'd41: begin note_id = 5'd12; duration = 8'd2; song_end = 1'b0; end // repeat 17, mid 5
            10'd42: begin note_id = 5'd15; duration = 8'd2; song_end = 1'b0; end // repeat 18, high 1
            10'd43: begin note_id = 5'd12; duration = 8'd2; song_end = 1'b0; end // repeat 19, mid 5
            10'd44: begin note_id = 5'd11; duration = 8'd2; song_end = 1'b0; end // repeat 20, mid 4
            10'd45: begin note_id = 5'd10; duration = 8'd2; song_end = 1'b0; end // repeat 21, mid 3
            10'd46: begin note_id = 5'd9;  duration = 8'd2; song_end = 1'b0; end // repeat 22, mid 2
            10'd47: begin note_id = 5'd8;  duration = 8'd6; song_end = 1'b0; end // repeat 23, mid 1
            10'd48: begin note_id = 5'd0;  duration = 8'd0; song_end = 1'b1; end // song end
            default: begin note_id = 5'd0; duration = 8'd0; song_end = 1'b1; end // song end
        endcase
    end

endmodule
