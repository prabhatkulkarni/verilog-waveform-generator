# Recreate the waveform-generator project from the repository sources.
# Run from the repository root in the Vivado Tcl Console:
#   source scripts/create_project.tcl

set PROJECT_NAME "waveform_generator"
set PROJECT_DIR  [file normalize "./vivado_project"]
set PART         "xc7k70tfbv676-1"

create_project $PROJECT_NAME $PROJECT_DIR -part $PART -force
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

add_files -fileset sources_1 [file normalize "./src/waveform_generator.v"]
set_property top waveform_generator [get_filesets sources_1]

add_files -fileset sim_1 [file normalize "./sim/tb_wave_generator.v"]
set_property top tb_wave_generator [get_filesets sim_1]
set_property xsim.simulate.runtime "all" [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Project created at: $PROJECT_DIR"
puts "Next: Flow Navigator -> Simulation -> Run Behavioral Simulation"
