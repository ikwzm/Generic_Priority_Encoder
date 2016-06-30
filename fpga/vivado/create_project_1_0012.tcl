
  set     project_directory   [file dirname [info script]]
  set     device_part         "xc7z010clg400-1"
  set     project_name        "project_1_0012"
  create_project -force $project_name $project_directory
  #
  # Set project properties
  #
  set_property "part"               $device_part     [current_project]
  set_property "default_lib"        "xil_defaultlib" [current_project]
  set_property "simulator_language" "Mixed"          [current_project]
  set_property "target_language"    "VHDL"           [current_project]
  #
  # Create fileset "sources_1"
  #
  if {[string equal [get_filesets -quiet sources_1] ""]} {
    create_fileset -srcset sources_1
  }
  #
  # Create fileset "constrs_1"
  #
  if {[string equal [get_filesets -quiet constrs_1] ""]} {
    create_fileset -constrset constrs_1
  }
  #
  # Create fileset "sim_1"
  #
  if {[string equal [get_filesets -quiet sim_1] ""]} {
    create_fileset -simset sim_1
  }
  #
  # Create run "synth_1" and set property
  #
  set synth_1_flow     "Vivado Synthesis 2015"
  set synth_1_strategy "Vivado Synthesis Defaults"
  if {[string equal [get_runs -quiet synth_1] ""]} {
      create_run -name synth_1 -flow $synth_1_flow -strategy $synth_1_strategy -constrset constrs_1
  } else {
      set_property flow     $synth_1_flow     [get_runs synth_1]
      set_property strategy $synth_1_strategy [get_runs synth_1]
  }
  current_run -synthesis [get_runs synth_1]
  #
  # Create run "impl_1" and set property
  #
  set impl_1_flow      "Vivado Implementation 2015"
  set impl_1_strategy  "Vivado Implementation Defaults"
  if {[string equal [get_runs -quiet impl_1] ""]} {
    create_run -name impl_1 -flow $impl_1_flow -strategy $impl_1_strategy -constrset constrs_1 -parent_run synth_1
  } else {
    set_property flow     $impl_1_flow      [get_runs impl_1]
    set_property strategy $impl_1_strategy  [get_runs impl_1]
  }
  current_run -implementation [get_runs impl_1]
  #
  # Import Constraint files
  #
  add_files -fileset constrs_1 -norecurse ./timing_400mhz.xdc
  #
  # Import Source files
  #
  proc add_vhdl_file {fileset library_name file_name} {
      set file     [file normalize $file_name]
      set fileset  [get_filesets   $fileset  ] 
      set file_obj [import_files -norecurse -fileset $fileset $file]
      set_property "file_type" "VHDL"        $file_obj
      set_property "library"   $library_name $file_obj
  }
  add_vhdl_file sources_1 WORK ../../src/priority_encoder.vhd
  add_vhdl_file sources_1 WORK ../../src/priority_encoder_synth_test.vhd
  #
  # Set Property MODE & WIDTH
  # 
  set_property generic {MODE=1 WIDTH=12} [current_fileset]
  #
  # Run Synthesis
  #
  launch_runs synth_1
  wait_on_run synth_1
  #
  # Run Implementation
  #
  launch_runs impl_1
  wait_on_run impl_1
  #
  # Create Report File
  #
  open_run    impl_1
  report_utilization -hierarchical -file [file join $project_directory "project_1_0012.rpt" ]
  report_timing      -setup        -file [file join $project_directory "project_1_0012.rpt" ] -append
  # Close Project
  #
  close_project
