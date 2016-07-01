require 'fileutils'

def create_project(mode, width)
  project_name = sprintf("project_%d_%04d", mode, width)
  FileUtils.mkdir(project_name) unless FileTest.exist?(project_name)
  File.open("#{project_name}/#{project_name}.qpf", "w") do |file|
    file.printf("QUARTUS_VERSION  = 15.1\n")
    file.printf("PROJECT_REVISION = \"%s\"\n", project_name)
  end
  File.open("#{project_name}/#{project_name}.qsf", "w") do |file|
    file.print <<"    EOT"
      set_global_assignment -name FAMILY "Cyclone V"
      set_global_assignment -name DEVICE 5CSEMA4U23C6
      set_global_assignment -name TOP_LEVEL_ENTITY PRIORITY_ENCODER_SYNTH_TEST
      set_global_assignment -name ORIGINAL_QUARTUS_VERSION 15.1.0
      set_global_assignment -name PROJECT_CREATION_TIME_DATE "01:08:43  JULY 01, 2016"
      set_global_assignment -name LAST_QUARTUS_VERSION 15.1.0
      set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
      set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
      set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
      set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
      set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (VHDL)"
      set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
      set_global_assignment -name VHDL_FILE ../../../src/priority_encoder_synth_test.vhd
      set_global_assignment -name VHDL_FILE ../../../src/priority_encoder.vhd
      set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
      set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
      set_parameter -name MODE #{mode}
      set_parameter -name WIDTH #{width}
      set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top
      set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
      set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
      set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
    EOT
  end
  return project_name
end

def compile(mode, width)
  project_name = create_project(mode, width)
  project_file = "#{project_name}/#{project_name}.qpf"
  err_file     = "#{project_name}/quartus_sh.err"
  log_file     = "#{project_name}/quartus_sh.log"
  command = "quartus_sh --flow compile #{project_file} 2> #{err_file} > #{log_file}"
  puts command
  system(command)
end

[1,2,3,4,5].each do |mode|
  [4,8,12,16,32,48,64,96].each do |width|
    compile(mode,width)
  end
end

[1,2,3,4,5].each do |mode|
  [128,160,192,224,256,384,512].each do |width|
    compile(mode,width)
  end
end

[1,2,4,5].each do |mode|
   [1024,2048,3072,4096].each do |width|
    compile(mode,width)
  end
end
