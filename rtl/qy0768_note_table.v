module qy0768_note_table (
    input  wire [4:0]  note_id,
    output reg  [31:0] half_period
);

    always @(*) begin
        case (note_id)
            5'd0:  half_period = 32'd0;      // rest, 0 Hz
            5'd1:  half_period = 32'd113636; // jianpu low 1, 220.00 Hz
            5'd2:  half_period = 32'd101239; // jianpu low 2, 246.94 Hz
            5'd3:  half_period = 32'd90194;  // jianpu low 3, 277.18 Hz
            5'd4:  half_period = 32'd85132;  // jianpu low 4, 293.66 Hz
            5'd5:  half_period = 32'd75843;  // jianpu low 5, 329.63 Hz
            5'd6:  half_period = 32'd67569;  // jianpu low 6, 369.99 Hz
            5'd7:  half_period = 32'd60197;  // jianpu low 7, 415.30 Hz
            5'd8:  half_period = 32'd56818;  // jianpu mid 1, 440.00 Hz
            5'd9:  half_period = 32'd50620;  // jianpu mid 2, 493.88 Hz
            5'd10: half_period = 32'd45096;  // jianpu mid 3, 554.37 Hz
            5'd11: half_period = 32'd42566;  // jianpu mid 4, 587.33 Hz
            5'd12: half_period = 32'd37922;  // jianpu mid 5, 659.25 Hz
            5'd13: half_period = 32'd33784;  // jianpu mid 6, 739.99 Hz
            5'd14: half_period = 32'd30098;  // jianpu mid 7, 830.61 Hz
            5'd15: half_period = 32'd28409;  // jianpu high 1, 880.00 Hz
            5'd16: half_period = 32'd25310;  // jianpu high 2, 987.77 Hz
            5'd17: half_period = 32'd22548;  // jianpu high 3, 1108.73 Hz
            5'd18: half_period = 32'd21283;  // jianpu high 4, 1174.66 Hz
            default: half_period = 32'd0;    // unused note_id
        endcase
    end

endmodule
