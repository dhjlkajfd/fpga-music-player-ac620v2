module qy0768_i2c_ctrl (
    input  wire        clk_50m,
    input  wire        rst_n,
    input  wire        start,
    input  wire [7:0]  dev_addr,
    input  wire [15:0] reg_data,
    output reg         busy,
    output reg         done,
    output reg         ack_error,
    output wire        i2c_sclk,
    inout  wire        i2c_sdat
);

    localparam [15:0] SCL_HALF_CYCLES = 16'd250; // 50 MHz / (2 * 100 kHz)

    localparam [3:0] STATE_IDLE         = 4'd0;
    localparam [3:0] STATE_START_HOLD   = 4'd1;
    localparam [3:0] STATE_START_SETUP  = 4'd2;
    localparam [3:0] STATE_BIT_LOW      = 4'd3;
    localparam [3:0] STATE_BIT_HIGH     = 4'd4;
    localparam [3:0] STATE_ACK_LOW      = 4'd5;
    localparam [3:0] STATE_ACK_HIGH     = 4'd6;
    localparam [3:0] STATE_STOP_LOW     = 4'd7;
    localparam [3:0] STATE_STOP_HIGH    = 4'd8;
    localparam [3:0] STATE_STOP_RELEASE = 4'd9;

    reg [3:0]  state;
    reg [15:0] div_cnt;
    reg [1:0]  byte_index;
    reg [2:0]  bit_index;
    reg [7:0]  dev_addr_latched;
    reg [15:0] reg_data_latched;
    reg [7:0]  current_byte;
    reg        sclk_reg;
    reg        sdat_drive_low;

    assign i2c_sclk = sclk_reg;

    // Open-drain SDA: drive only 0, release for 1/idle/ACK sampling.
    assign i2c_sdat = sdat_drive_low ? 1'b0 : 1'bz;

    always @(*) begin
        case (byte_index)
            2'd0: current_byte = dev_addr_latched;
            2'd1: current_byte = reg_data_latched[15:8];
            default: current_byte = reg_data_latched[7:0];
        endcase
    end

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            busy             <= 1'b0;
            done             <= 1'b0;
            ack_error        <= 1'b0;
            state            <= STATE_IDLE;
            div_cnt          <= 16'd0;
            byte_index       <= 2'd0;
            bit_index        <= 3'd7;
            dev_addr_latched <= 8'd0;
            reg_data_latched <= 16'd0;
            sclk_reg         <= 1'b1;
            sdat_drive_low   <= 1'b0;
        end else begin
            done <= 1'b0;

            if (state == STATE_IDLE) begin
                busy           <= 1'b0;
                div_cnt        <= 16'd0;
                byte_index     <= 2'd0;
                bit_index      <= 3'd7;
                sclk_reg       <= 1'b1;
                sdat_drive_low <= 1'b0;

                if (start) begin
                    busy             <= 1'b1;
                    ack_error        <= 1'b0;
                    dev_addr_latched <= dev_addr;
                    reg_data_latched <= reg_data;
                    state            <= STATE_START_HOLD;
                end
            end else begin
                busy <= 1'b1;

                if (div_cnt >= (SCL_HALF_CYCLES - 16'd1)) begin
                    div_cnt <= 16'd0;

                    case (state)
                        STATE_START_HOLD: begin
                            // Bus idle half-period before START: SCL high, SDA released high.
                            sclk_reg       <= 1'b1;
                            sdat_drive_low <= 1'b0;
                            state          <= STATE_START_SETUP;
                        end

                        STATE_START_SETUP: begin
                            // START condition: SDA falls while SCL is high.
                            sclk_reg       <= 1'b1;
                            sdat_drive_low <= 1'b1;
                            state          <= STATE_BIT_LOW;
                        end

                        STATE_BIT_LOW: begin
                            // Data changes only while SCL is low.
                            sclk_reg <= 1'b0;
                            sdat_drive_low <= (current_byte[bit_index] == 1'b0);
                            state <= STATE_BIT_HIGH;
                        end

                        STATE_BIT_HIGH: begin
                            // Receiver samples the bit while SCL is high.
                            sclk_reg <= 1'b1;
                            if (bit_index == 3'd0) begin
                                state <= STATE_ACK_LOW;
                            end else begin
                                bit_index <= bit_index - 3'd1;
                                state <= STATE_BIT_LOW;
                            end
                        end

                        STATE_ACK_LOW: begin
                            // Release SDA so the slave can drive ACK low.
                            sclk_reg       <= 1'b0;
                            sdat_drive_low <= 1'b0;
                            state          <= STATE_ACK_HIGH;
                        end

                        STATE_ACK_HIGH: begin
                            // ACK is valid while SCL is high. High means NACK/error.
                            sclk_reg <= 1'b1;
                            if (i2c_sdat) begin
                                ack_error <= 1'b1;
                            end

                            if (byte_index == 2'd2) begin
                                state <= STATE_STOP_LOW;
                            end else begin
                                byte_index <= byte_index + 2'd1;
                                bit_index  <= 3'd7;
                                state      <= STATE_BIT_LOW;
                            end
                        end

                        STATE_STOP_LOW: begin
                            // Prepare STOP with SDA low while SCL is low.
                            sclk_reg       <= 1'b0;
                            sdat_drive_low <= 1'b1;
                            state          <= STATE_STOP_HIGH;
                        end

                        STATE_STOP_HIGH: begin
                            // Raise SCL before releasing SDA.
                            sclk_reg       <= 1'b1;
                            sdat_drive_low <= 1'b1;
                            state          <= STATE_STOP_RELEASE;
                        end

                        STATE_STOP_RELEASE: begin
                            // STOP condition: SDA rises while SCL is high.
                            sclk_reg       <= 1'b1;
                            sdat_drive_low <= 1'b0;
                            busy           <= 1'b0;
                            done           <= 1'b1;
                            state          <= STATE_IDLE;
                        end

                        default: begin
                            state          <= STATE_IDLE;
                            sclk_reg       <= 1'b1;
                            sdat_drive_low <= 1'b0;
                        end
                    endcase
                end else begin
                    div_cnt <= div_cnt + 16'd1;
                end
            end
        end
    end

endmodule
