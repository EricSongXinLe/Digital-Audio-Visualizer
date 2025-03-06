`timescale 1ns/1ns

module slotMachine_top(
    input  logic         clk,         // 50 MHz FPGA clock
    input  logic         rst,         // Global reset (active high)
    input  logic         start_stop,  // Start/Stop button (asynchronous)
    output logic         buzzer_out,  // Buzzer output
    output logic [7:0]   displayBits [0:5]  // 6-digit seven-segment display outputs
);

    //-------------------------------------------------------------------------
    // Instantiate Clock Dividers
    //-------------------------------------------------------------------------
    // Generate separate slower clocks for each slot module update rate.
    wire slot_clk;
    clock_divider #(.BASESPEED(50000000)) slot_clk_divider (
        .clk   (clk),
        .speed (20'd1510),  // Update rate for slot1 (example value)
        .rst   (rst),
        .outClk(slot_clk)
    );
    
    wire slot_clk2;
    clock_divider #(.BASESPEED(50000000)) slot_clk_divider2 (
        .clk   (clk),
        .speed (20'd0017),  // Update rate for slot2 (example value)
        .rst   (rst),
        .outClk(slot_clk2)
    );
    
    wire slot_clk3;
    clock_divider #(.BASESPEED(50000000)) slot_clk_divider3 (
        .clk   (clk),
        .speed (20'd0022),  // Update rate for slot3 (example value)
        .rst   (rst),
        .outClk(slot_clk3)
    );
    
    // Generate a clock for driving the buzzer tone (e.g., 2 kHz)
    wire buzzer_clk;
    clock_divider #(.BASESPEED(50000000)) buzzer_clk_divider (
        .clk   (clk),
        .speed (20'd0029),  // 2 kHz tone frequency
        .rst   (rst),
        .outClk(buzzer_clk)
    );
    
    //-------------------------------------------------------------------------
    // Shift Register Synchronizers for rst and start_stop
    //-------------------------------------------------------------------------
    // These shift registers synchronize the asynchronous inputs to slot_clk domain.
    reg [1:0] rst_sync;
    reg [1:0] start_stop_sync;
    
    // Synchronize the asynchronous reset.
    // Note: The asynchronous "rst" is used as the reset for the synchronizer.
    always_ff @(posedge slot_clk or posedge rst) begin
        if (rst)
            rst_sync <= 2'b11;  // When reset is asserted, drive the synchronizer to '1'
        else
            rst_sync <= {rst_sync[0], rst};
    end
    wire rst_debounced = rst_sync[1];
    
    // Synchronize the asynchronous start_stop button.
    always_ff @(posedge slot_clk or posedge rst) begin
        if (rst)
            start_stop_sync <= 2'b00; // Assume button is not pressed on reset
        else
            start_stop_sync <= {start_stop_sync[0], start_stop};
    end
    wire start_stop_debounced = start_stop_sync[1];
    
    //-------------------------------------------------------------------------
    // FSM and Slot Modules
    //-------------------------------------------------------------------------
    // Define FSM states: SET, RUN, STOP, WIN
    typedef enum logic [1:0] {SET, RUN, STOP, WIN} state_t;
    state_t current_state, next_state;
    
    // Slot module outputs (each 4 bits)
    logic [3:0] slot1, slot2, slot3;
    
    // Control signal: update slots only when in RUN state
    logic running_slots;
    assign running_slots = (current_state == RUN);
    
    // Instantiate three slot modules (from slot.sv)
    slot slot1_inst (
        .clk    (slot_clk),
        .running(running_slots),
        .rst    (rst),  // The slot module can use the asynchronous reset or a synchronized version if desired.
        .number (slot1)
    );
    
    slot slot2_inst (
        .clk    (slot_clk2),
        .running(running_slots),
        .rst    (rst),
        .number (slot2)
    );
    
    slot slot3_inst (
        .clk    (slot_clk3),
        .running(running_slots),
        .rst    (rst),
        .number (slot3)
    );
    
    // Combine the three 4-bit slot outputs into a single 12-bit bus.
    // The ordering here places slot3 as the most significant group.
    wire [11:0] slots_combined;
    assign slots_combined = {slot3, slot2, slot1};
    
    //-------------------------------------------------------------------------
    // Instantiate the Display Encoder
    //-------------------------------------------------------------------------
    // display_encoder.sv should contain the module "displayEncoder"
    displayEncoder display_inst (
        .slot        (slots_combined),
        .displayBits (displayBits)
    );
    
    //-------------------------------------------------------------------------
    // FSM Implementation (Clocked by slot_clk)
    //-------------------------------------------------------------------------
    // Update state on each slot_clk edge using the debounced reset.
    always_ff @(posedge slot_clk or posedge rst_debounced) begin
        if (rst_debounced )
            current_state <= SET;
        else
            current_state <= next_state;
    end
    
    // Determine next state based on current state, debounced button press, and slot outputs.
    always_comb begin
        next_state = current_state;  // Default: hold current state
        case (current_state)
            SET: begin
                // Wait for the button press to start running the slots.
                if (start_stop_debounced)
                    next_state = RUN;
            end
            RUN: begin
                // On a button press, transition to STOP.
                if (start_stop_debounced)
                    next_state = STOP;
            end
            STOP: begin
                // Check winning condition: all three slot values match.
                if ((slot1 == slot2) && (slot2 == slot3))
                    next_state = WIN;
                else
                    next_state = SET;
            end
            WIN: begin
                // Remain in WIN until a button press resets to SET.
                if (start_stop_debounced)
                    next_state = SET;
            end
            default: next_state = SET;
        endcase
    end
    
    //-------------------------------------------------------------------------
    // Buzzer Control
    //-------------------------------------------------------------------------
    // Drive the buzzer with the buzzer_clk only in the WIN state.
    assign buzzer_out = (current_state == WIN) ? buzzer_clk : 1'b0;
    
endmodule
