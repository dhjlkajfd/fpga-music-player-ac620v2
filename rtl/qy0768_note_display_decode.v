module qy0768_note_display_decode (
    input  wire [4:0] note_id,
    output reg  [3:0] note_num,
    output reg        is_rest,
    output reg        is_low,
    output reg        is_mid,
    output reg        is_high
);

    always @(*) begin
        note_num = 4'd0;
        is_rest  = 1'b1;
        is_low   = 1'b0;
        is_mid   = 1'b0;
        is_high  = 1'b0;

        if ((note_id >= 5'd1) && (note_id <= 5'd7)) begin
            note_num = {1'b0, note_id[2:0]};
            is_rest  = 1'b0;
            is_low   = 1'b1;
        end else if ((note_id >= 5'd8) && (note_id <= 5'd14)) begin
            note_num = note_id - 5'd7;
            is_rest  = 1'b0;
            is_mid   = 1'b1;
        end else if ((note_id >= 5'd15) && (note_id <= 5'd18)) begin
            note_num = note_id - 5'd14;
            is_rest  = 1'b0;
            is_high  = 1'b1;
        end
    end

endmodule
