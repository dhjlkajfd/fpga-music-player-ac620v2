module qy0768_display_format (
    input  wire       clk_50m,
    input  wire       rst_n,
    input  wire [1:0] song_id,
    input  wire       playing,
    input  wire [7:0] play_sec,
    input  wire [3:0] note_num,
    input  wire [1:0] note_octave,
    output reg  [7:0] seg0,
    output reg  [7:0] seg1,
    output reg  [7:0] seg2,
    output reg  [7:0] seg3,
    output reg  [7:0] seg4,
    output reg  [7:0] seg5,
    output reg  [7:0] seg6,
    output reg  [7:0] seg7
);

    localparam [1:0] NOTE_OCTAVE_LOW  = 2'd0;
    localparam [1:0] NOTE_OCTAVE_MID  = 2'd1;
    localparam [1:0] NOTE_OCTAVE_HIGH = 2'd2;

    reg [7:0] sec_limited;
    reg [3:0] sec_tens;
    reg [3:0] sec_ones;
    reg [7:0] next_seg0;
    reg [7:0] next_seg1;
    reg [7:0] next_seg2;
    reg [7:0] next_seg3;
    reg [7:0] next_seg4;
    reg [7:0] next_seg5;
    reg [7:0] next_seg6;
    reg [7:0] next_seg7;

    function [6:0] digit_to_seg;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: digit_to_seg = 7'b0111111;
                4'd1: digit_to_seg = 7'b0000110;
                4'd2: digit_to_seg = 7'b1011011;
                4'd3: digit_to_seg = 7'b1001111;
                4'd4: digit_to_seg = 7'b1100110;
                4'd5: digit_to_seg = 7'b1101101;
                4'd6: digit_to_seg = 7'b1111101;
                4'd7: digit_to_seg = 7'b0000111;
                4'd8: digit_to_seg = 7'b1111111;
                4'd9: digit_to_seg = 7'b1101111;
                default: digit_to_seg = 7'b0000000;
            endcase
        end
    endfunction

    function [7:0] digit_to_seg8;
        input [3:0] digit;
        begin
            digit_to_seg8 = {1'b0, digit_to_seg(digit)};
        end
    endfunction

    always @(*) begin
        sec_limited = (play_sec > 8'd99) ? 8'd99 : play_sec;
        sec_tens = sec_limited / 8'd10;
        sec_ones = sec_limited % 8'd10;

        next_seg0 = digit_to_seg8(playing ? 4'd1 : 4'd0);

        case (note_octave)
            NOTE_OCTAVE_LOW:  next_seg1 = 8'b00001000; // d segment
            NOTE_OCTAVE_MID:  next_seg1 = 8'b01000000; // g segment
            NOTE_OCTAVE_HIGH: next_seg1 = 8'b00000001; // a segment
            default:          next_seg1 = 8'b00000000;
        endcase

        if (note_num <= 4'd7) begin
            next_seg2 = digit_to_seg8(note_num);
        end else begin
            next_seg2 = 8'b00000000;
        end

        next_seg3 = 8'b00000000;
        next_seg4 = digit_to_seg8(sec_ones);
        next_seg5 = digit_to_seg8(sec_tens);
        next_seg6 = 8'b00000000;

        case (song_id)
            2'd0: next_seg7 = digit_to_seg8(4'd1);
            2'd1: next_seg7 = digit_to_seg8(4'd2);
            2'd2: next_seg7 = digit_to_seg8(4'd3);
            default: next_seg7 = 8'b00000000;
        endcase
    end

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            seg0 <= 8'b00000000;
            seg1 <= 8'b00000000;
            seg2 <= 8'b00000000;
            seg3 <= 8'b00000000;
            seg4 <= 8'b00000000;
            seg5 <= 8'b00000000;
            seg6 <= 8'b00000000;
            seg7 <= 8'b00000000;
        end else begin
            seg0 <= next_seg0;
            seg1 <= next_seg1;
            seg2 <= next_seg2;
            seg3 <= next_seg3;
            seg4 <= next_seg4;
            seg5 <= next_seg5;
            seg6 <= next_seg6;
            seg7 <= next_seg7;
        end
    end

endmodule
