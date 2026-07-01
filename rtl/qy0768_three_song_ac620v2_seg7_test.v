module qy0768_three_song_ac620v2_seg7_test (
    input  wire clk_50m,
    input  wire rst_n,
    input  wire key_play_pause,
    input  wire key_next,
    output wire led0,
    output wire aud_xck,
    output wire aud_bclk,
    output wire aud_daclrck,
    output wire aud_dacdat,
    output wire i2c_sclk,
    inout  wire i2c_sdat,
    output wire seg7_sclk,
    output wire seg7_rclk,
    output wire seg7_dio
);

    wire        key_play_pause_state;
    wire        key_next_state;
    wire        play_pause_pulse;
    wire        next_key_pulse;

    wire        play_en;
    wire        next_song_pulse;
    wire        prev_song_pulse;
    wire [1:0]  speed_mode;

    wire [1:0]  song_id;
    wire [9:0]  rom_addr;
    wire [4:0]  rom0_note_id;
    wire [7:0]  rom0_duration;
    wire        rom0_song_end;
    wire [4:0]  rom1_note_id;
    wire [7:0]  rom1_duration;
    wire        rom1_song_end;
    wire [4:0]  rom2_note_id;
    wire [7:0]  rom2_duration;
    wire        rom2_song_end;
    wire [4:0]  selected_note_id;
    wire [7:0]  selected_duration;
    wire        selected_song_end;
    wire [4:0]  current_note_id;
    wire [4:0]  tone_note_id;
    wire [7:0]  play_time_sec;

    wire signed [15:0] audio_data;

    wire        i2c_start;
    wire [7:0]  i2c_dev_addr;
    wire [15:0] i2c_reg_data;
    wire        i2c_busy;
    wire        i2c_done;
    wire        i2c_ack_error;

    wire        wm8731_init_done;
    wire        wm8731_init_error;

    wire [3:0]  note_num;
    wire        note_is_rest;
    wire        note_is_low;
    wire        note_is_mid;
    wire        note_is_high;
    reg  [1:0]  note_octave;
    wire [7:0]  display_play_sec;
    wire [7:0]  seg0;
    wire [7:0]  seg1;
    wire [7:0]  seg2;
    wire [7:0]  seg3;
    wire [7:0]  seg4;
    wire [7:0]  seg5;
    wire [7:0]  seg6;
    wire [7:0]  seg7;

    qy0768_key_filter u_qy0768_key_filter_play_pause (
        .clk_50m(clk_50m),
        .rst_n(rst_n),
        .key_in(key_play_pause),
        .key_state(key_play_pause_state),
        .key_press_pulse(play_pause_pulse)
    );

    qy0768_key_filter u_qy0768_key_filter_next (
        .clk_50m(clk_50m),
        .rst_n(rst_n),
        .key_in(key_next),
        .key_state(key_next_state),
        .key_press_pulse(next_key_pulse)
    );

    qy0768_play_ctrl_frontend u_qy0768_play_ctrl_frontend (
        .clk_50m(clk_50m),
        .rst_n(rst_n),
        .play_pause_pulse(play_pause_pulse),
        .next_key_pulse(next_key_pulse),
        .prev_key_pulse(1'b0),
        .speed_key_pulse(1'b0),
        .play_en(play_en),
        .next_song_pulse(next_song_pulse),
        .prev_song_pulse(prev_song_pulse),
        .speed_mode(speed_mode)
    );

    qy0768_song_rom0 u_qy0768_song_rom0 (
        .addr(rom_addr),
        .note_id(rom0_note_id),
        .duration(rom0_duration),
        .song_end(rom0_song_end)
    );

    qy0768_song_rom1 u_qy0768_song_rom1 (
        .addr(rom_addr),
        .note_id(rom1_note_id),
        .duration(rom1_duration),
        .song_end(rom1_song_end)
    );

    qy0768_song_rom2 u_qy0768_song_rom2 (
        .addr(rom_addr),
        .note_id(rom2_note_id),
        .duration(rom2_duration),
        .song_end(rom2_song_end)
    );

    qy0768_song_mux u_qy0768_song_mux (
        .song_id(song_id),
        .rom0_note_id(rom0_note_id),
        .rom0_duration(rom0_duration),
        .rom0_song_end(rom0_song_end),
        .rom1_note_id(rom1_note_id),
        .rom1_duration(rom1_duration),
        .rom1_song_end(rom1_song_end),
        .rom2_note_id(rom2_note_id),
        .rom2_duration(rom2_duration),
        .rom2_song_end(rom2_song_end),
        .selected_note_id(selected_note_id),
        .selected_duration(selected_duration),
        .selected_song_end(selected_song_end)
    );

    qy0768_song_ctrl u_qy0768_song_ctrl (
        .clk_50m(clk_50m),
        .rst_n(rst_n),
        .play_en(play_en),
        .next_song_pulse(next_song_pulse),
        .prev_song_pulse(prev_song_pulse),
        .speed_mode(speed_mode),
        .song_id(song_id),
        .rom_addr(rom_addr),
        .rom_note_id(selected_note_id),
        .rom_duration(selected_duration),
        .rom_song_end(selected_song_end),
        .current_note_id(current_note_id),
        .play_time_sec(play_time_sec)
    );

    assign tone_note_id = play_en ? current_note_id : 5'd0;

    qy0768_tone_gen u_qy0768_tone_gen (
        .clk_50m(clk_50m),
        .rst_n(rst_n),
        .note_id(tone_note_id),
        .audio_data(audio_data)
    );

    qy0768_audio_tx u_qy0768_audio_tx (
        .clk_50m(clk_50m),
        .rst_n(rst_n),
        .audio_l(audio_data),
        .audio_r(audio_data),
        .aud_xck(aud_xck),
        .aud_bclk(aud_bclk),
        .aud_daclrck(aud_daclrck),
        .aud_dacdat(aud_dacdat)
    );

    qy0768_wm8731_cfg u_qy0768_wm8731_cfg (
        .clk_50m(clk_50m),
        .rst_n(rst_n),
        .i2c_start(i2c_start),
        .i2c_dev_addr(i2c_dev_addr),
        .i2c_reg_data(i2c_reg_data),
        .i2c_busy(i2c_busy),
        .i2c_done(i2c_done),
        .init_done(wm8731_init_done),
        .init_error(wm8731_init_error)
    );

    qy0768_i2c_ctrl u_qy0768_i2c_ctrl (
        .clk_50m(clk_50m),
        .rst_n(rst_n),
        .start(i2c_start),
        .dev_addr(i2c_dev_addr),
        .reg_data(i2c_reg_data),
        .busy(i2c_busy),
        .done(i2c_done),
        .ack_error(i2c_ack_error),
        .i2c_sclk(i2c_sclk),
        .i2c_sdat(i2c_sdat)
    );

    qy0768_note_display_decode u_qy0768_note_display_decode (
        .note_id(current_note_id),
        .note_num(note_num),
        .is_rest(note_is_rest),
        .is_low(note_is_low),
        .is_mid(note_is_mid),
        .is_high(note_is_high)
    );

    always @(*) begin
        if (note_is_low) begin
            note_octave = 2'd0;
        end else if (note_is_mid) begin
            note_octave = 2'd1;
        end else if (note_is_high) begin
            note_octave = 2'd2;
        end else begin
            note_octave = 2'd1;
        end
    end

    qy0768_display_timer u_qy0768_display_timer (
        .clk_50m(clk_50m),
        .rst_n(rst_n),
        .playing(play_en),
        .song_change_pulse(next_song_pulse),
        .song_restart_pulse(selected_song_end),
        .play_sec(display_play_sec)
    );

    qy0768_display_format u_qy0768_display_format (
        .clk_50m(clk_50m),
        .rst_n(rst_n),
        .song_id(song_id),
        .playing(play_en),
        .play_sec(display_play_sec),
        .note_num(note_num),
        .note_octave(note_octave),
        .seg0(seg0),
        .seg1(seg1),
        .seg2(seg2),
        .seg3(seg3),
        .seg4(seg4),
        .seg5(seg5),
        .seg6(seg6),
        .seg7(seg7)
    );

    qy0768_seg7_ac620v2_driver u_qy0768_seg7_ac620v2_driver (
        .clk_50m(clk_50m),
        .rst_n(rst_n),
        .seg0(seg0),
        .seg1(seg1),
        .seg2(seg2),
        .seg3(seg3),
        .seg4(seg4),
        .seg5(seg5),
        .seg6(seg6),
        .seg7(seg7),
        .seg7_sclk(seg7_sclk),
        .seg7_rclk(seg7_rclk),
        .seg7_dio(seg7_dio)
    );

    assign led0 = ~wm8731_init_done;

endmodule
