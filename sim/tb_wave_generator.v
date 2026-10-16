`timescale 1ns / 1ps

// Self-checking testbench for the programmable square-wave generator.
// Input clock: 10 MHz (100 ns period).
module tb_wave_generator;

    localparam integer CLK_PERIOD_NS = 100;

    reg        clk;
    reg        rst;
    reg  [1:0] freq_sel;
    wire       wave_out;

    integer tests_passed;
    integer tests_failed;
    time first_rising_edge;
    time second_rising_edge;
    time measured_period;

    waveform_generator dut (
        .clk      (clk),
        .rst      (rst),
        .freq_sel (freq_sel),
        .wave_out (wave_out)
    );

    initial clk = 1'b0;
    always #(CLK_PERIOD_NS / 2) clk = ~clk;

    // Assert reset, select one mode, then compare two consecutive
    // rising edges of wave_out against the expected full period.
    task check_frequency;
        input [1:0] selected_mode;
        input integer expected_period_ns;
        begin
            @(negedge clk);
            rst      = 1'b1;
            freq_sel = selected_mode;

            repeat (2) @(posedge clk);
            #1;
            if ((wave_out !== 1'b0) || (dut.counter !== 9'd0)) begin
                $display("FAIL: reset did not initialize outputs/counter for mode %b", selected_mode);
                tests_failed = tests_failed + 1;
            end

            @(negedge clk);
            rst = 1'b0;

            @(posedge wave_out);
            first_rising_edge = $time;
            @(posedge wave_out);
            second_rising_edge = $time;
            measured_period = second_rising_edge - first_rising_edge;

            if (measured_period == expected_period_ns) begin
                $display("PASS: freq_sel=%b | expected=%0d ns | measured=%0t ns",
                         selected_mode, expected_period_ns, measured_period);
                tests_passed = tests_passed + 1;
            end else begin
                $display("FAIL: freq_sel=%b | expected=%0d ns | measured=%0t ns",
                         selected_mode, expected_period_ns, measured_period);
                tests_failed = tests_failed + 1;
            end
        end
    endtask

    initial begin
        rst         = 1'b1;
        freq_sel    = 2'b00;
        tests_passed = 0;
        tests_failed = 0;

        // Full period = 2 * (terminal_count + 1) * CLK_PERIOD_NS.
        check_frequency(2'b00, 100000); // 10 kHz
        check_frequency(2'b01, 10000);  // 100 kHz
        check_frequency(2'b10, 2000);   // 500 kHz
        check_frequency(2'b11, 1000);   // 1 MHz

        $display("--------------------------------------------------");
        $display("Frequency checks passed: %0d / 4", tests_passed);
        $display("Checks failed (including reset checks): %0d", tests_failed);
        if (tests_passed == 4 && tests_failed == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: TESTS FAILED — inspect the messages above");
        $display("--------------------------------------------------");
        $finish;
    end

    initial begin
        $dumpfile("waveform_generator.vcd");
        $dumpvars(0, tb_wave_generator);
    end

endmodule
