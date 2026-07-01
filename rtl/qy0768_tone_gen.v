module qy0768_tone_gen (
    input  wire              clk_50m,
    input  wire              rst_n,
    input  wire [4:0]        note_id,
    output wire signed [15:0] audio_data
);

    localparam signed [15:0] TONE_POS = 16'sd16000;
    localparam signed [15:0] TONE_NEG = -16'sd16000;

    wire [31:0] half_period;

    reg [31:0] tone_cnt;
    reg        tone_level;
    reg [4:0]  note_id_d;

    qy0768_note_table u_qy0768_note_table (
        .note_id(note_id),
        .half_period(half_period)
    );

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            tone_cnt   <= 32'd0;
            tone_level <= 1'b1;
            note_id_d  <= 5'd0;
        end else if (note_id != note_id_d) begin
            tone_cnt   <= 32'd0;
            tone_level <= 1'b1;
            note_id_d  <= note_id;
        end else if ((note_id == 5'd0) || (half_period == 32'd0)) begin
            tone_cnt   <= 32'd0;
            tone_level <= 1'b1;
        end else if (tone_cnt >= (half_period - 32'd1)) begin
            tone_cnt   <= 32'd0;
            tone_level <= ~tone_level;
        end else begin
            tone_cnt <= tone_cnt + 32'd1;
        end
    end

    assign audio_data = ((!rst_n) || (note_id == 5'd0) || (half_period == 32'd0)) ?
                        16'sd0 :
                        (tone_level ? TONE_POS : TONE_NEG);

endmodule
