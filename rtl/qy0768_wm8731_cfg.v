module qy0768_wm8731_cfg (
    input  wire        clk_50m,
    input  wire        rst_n,
    output reg         i2c_start,
    output wire [7:0]  i2c_dev_addr,
    output reg  [15:0] i2c_reg_data,
    input  wire        i2c_busy,
    input  wire        i2c_done,
    output reg         init_done,
    output reg         init_error
);

    localparam [7:0]  WM8731_DEV_ADDR = 8'h34;
    localparam [3:0]  CFG_COUNT       = 4'd10;
    localparam [31:0] POWER_WAIT_MAX  = 32'd2500000;  // 50 ms at 50 MHz
    localparam [31:0] I2C_TIMEOUT_MAX = 32'd50000000; // 1 s at 50 MHz

    localparam [2:0] STATE_POWER_WAIT = 3'd0;
    localparam [2:0] STATE_LOAD       = 3'd1;
    localparam [2:0] STATE_START      = 3'd2;
    localparam [2:0] STATE_WAIT_DONE  = 3'd3;
    localparam [2:0] STATE_DONE       = 3'd4;
    localparam [2:0] STATE_ERROR      = 3'd5;

    reg [2:0]  state;
    reg [3:0]  cfg_index;
    reg [31:0] wait_cnt;
    reg [31:0] timeout_cnt;

    assign i2c_dev_addr = WM8731_DEV_ADDR;

    always @(*) begin
        case (cfg_index)
            4'd0: i2c_reg_data = 16'h1e00; // R15 reset
            4'd1: i2c_reg_data = 16'h0c00; // R6 power down control: all required blocks on
            4'd2: i2c_reg_data = 16'h0017; // R0 left line in
            4'd3: i2c_reg_data = 16'h0217; // R1 right line in
            4'd4: i2c_reg_data = 16'h0479; // R2 left headphone out
            4'd5: i2c_reg_data = 16'h0679; // R3 right headphone out
            4'd6: i2c_reg_data = 16'h0812; // R4 analog audio path: DAC selected
            4'd7: i2c_reg_data = 16'h0a00; // R5 digital audio path
            4'd8: i2c_reg_data = 16'h0e02; // R7 digital audio interface: I2S, 16-bit
            4'd9: i2c_reg_data = 16'h1201; // R9 active control: active
            default: i2c_reg_data = 16'h0000;
        endcase
    end

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            i2c_start  <= 1'b0;
            init_done  <= 1'b0;
            init_error <= 1'b0;
            state      <= STATE_POWER_WAIT;
            cfg_index  <= 4'd0;
            wait_cnt   <= 32'd0;
            timeout_cnt <= 32'd0;
        end else begin
            i2c_start <= 1'b0;

            case (state)
                STATE_POWER_WAIT: begin
                    init_done  <= 1'b0;
                    init_error <= 1'b0;
                    cfg_index  <= 4'd0;
                    timeout_cnt <= 32'd0;
                    if (wait_cnt >= (POWER_WAIT_MAX - 32'd1)) begin
                        wait_cnt <= 32'd0;
                        state    <= STATE_LOAD;
                    end else begin
                        wait_cnt <= wait_cnt + 32'd1;
                    end
                end

                STATE_LOAD: begin
                    timeout_cnt <= 32'd0;
                    if (!i2c_busy) begin
                        state <= STATE_START;
                    end
                end

                STATE_START: begin
                    i2c_start <= 1'b1;
                    state     <= STATE_WAIT_DONE;
                end

                STATE_WAIT_DONE: begin
                    if (i2c_done) begin
                        timeout_cnt <= 32'd0;
                        if (cfg_index >= (CFG_COUNT - 4'd1)) begin
                            init_done <= 1'b1;
                            state     <= STATE_DONE;
                        end else begin
                            cfg_index <= cfg_index + 4'd1;
                            state     <= STATE_LOAD;
                        end
                    end else if (timeout_cnt >= (I2C_TIMEOUT_MAX - 32'd1)) begin
                        init_error <= 1'b1;
                        state      <= STATE_ERROR;
                    end else begin
                        timeout_cnt <= timeout_cnt + 32'd1;
                    end
                end

                STATE_DONE: begin
                    init_done <= 1'b1;
                end

                STATE_ERROR: begin
                    init_error <= 1'b1;
                end

                default: begin
                    state <= STATE_POWER_WAIT;
                end
            endcase
        end
    end

endmodule
