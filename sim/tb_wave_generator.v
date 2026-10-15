`timescale 1ns / 1ps

module tb_wave_generator;

    localparam integer CLK_PERIOD_NS = 100; // 10 MHz input clock

    reg        clk;
    reg        rst;
    reg  [1:0] freq_sel;
    wire       wave_out;

    integer tests_passed;
    time first_rising_edge;
    time second_rising_edge;
    time measured_period;
    time expected_period;

    waveform_generator dut (
        .clk      (clk),
        .rst      (rst),
        .freq_sel (freq_sel),
        .wave_out (wave_out)
    );

    // 10 MHz clock: 100 ns period.
    initial clk = 1'b0;
    always #(CLK_PERIOD_NS / 2) clk = ~clk;

    // Apply reset, then measure the time between two consecutive
    // rising edges of the generated square wave.
    task check_frequency;
        input [1:0] selected_mode;
        input time expected_full_period;
        begin
            @(negedge clk);
            rst      = 1'b1;
            freq_sel = selected_mode;

            repeat (2) @(posedge clk);
            @(negedge clk);
            rst = 1'b0;

            @(posedge wave_out);
            first_rising_edge = $time;
            @(posedge wave_out);
            second_rising_edge = $time;

            measured_period = second_rising_edge - first_rising_edge;

            if (measured_period == expected_full_period) begin
                $display(
                    "PASS: freq_sel=%b | expected period=%0t ns | measured period=%0t ns",
                    selected_mode, expected_full_period, measured_period
                );
                tests_passed = tests_passed + 1;
            end else begin
                $display(
                    "FAIL: freq_sel=%b | expected period=%0t ns | measured period=%0t ns",
                    selected_mode, expected_full_period, measured_period
                );
            end
        end
    endtask

    initial begin
        rst = 1'b1;
        freq_sel = 2'b00;
        tests_passed = 0;

        // Full output period = 2 * (terminal_count + 1) * input-clock period.
        check_frequency(2'b00, 100000); // 10 kHz
        check_frequency(2'b01, 10000);  // 100 kHz
        check_frequency(2'b10, 2000);   // 500 kHz
        check_frequency(2'b11, 1000);   // 1 MHz

        $display("--------------------------------------------------");
        $display("Frequency tests passed: %0d / 4", tests_passed);
        if (tests_passed == 4)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: ONE OR MORE TESTS FAILED");
        $display("--------------------------------------------------");
        $finish;
    end

    initial begin
        $dumpfile("waveform_generator.vcd");
        $dumpvars(0, tb_wave_generator);
    end

endmodule
