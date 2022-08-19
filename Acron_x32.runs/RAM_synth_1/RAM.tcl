# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param project.vivado.isBlockSynthRun true
set_msg_config -msgmgr_mode ooc_run
create_project -in_memory -part xc7z010clg400-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.cache/wt [current_project]
set_property parent.project_path D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.xpr [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property board_part_repo_paths {C:/Users/Julian/AppData/Roaming/Xilinx/Vivado/2019.2/xhub/board_store} [current_project]
set_property board_part digilentinc.com:zybo-z7-10:part0:1.0 [current_project]
set_property ip_output_repo d:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_ip -quiet D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.srcs/sources_1/ip/RAM/RAM.xci
set_property used_in_implementation false [get_files -all d:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.srcs/sources_1/ip/RAM/RAM_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
set_param ips.enableIPCacheLiteLoad 1

set cached_ip [config_ip_cache -export -no_bom  -dir D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.runs/RAM_synth_1 -new_name RAM -ip [get_ips RAM]]

if { $cached_ip eq {} } {
close [open __synthesis_is_running__ w]

synth_design -top RAM -part xc7z010clg400-1 -mode out_of_context

#---------------------------------------------------------
# Generate Checkpoint/Stub/Simulation Files For IP Cache
#---------------------------------------------------------
# disable binary constraint mode for IPCache checkpoints
set_param constraints.enableBinaryConstraints false

catch {
 write_checkpoint -force -noxdef -rename_prefix RAM_ RAM.dcp

 set ipCachedFiles {}
 write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ RAM_stub.v
 lappend ipCachedFiles RAM_stub.v

 write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ RAM_stub.vhdl
 lappend ipCachedFiles RAM_stub.vhdl

 write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ RAM_sim_netlist.v
 lappend ipCachedFiles RAM_sim_netlist.v

 write_vhdl -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ RAM_sim_netlist.vhdl
 lappend ipCachedFiles RAM_sim_netlist.vhdl
set TIME_taken [expr [clock seconds] - $TIME_start]

 config_ip_cache -add -dcp RAM.dcp -move_files $ipCachedFiles -use_project_ipc  -synth_runtime $TIME_taken  -ip [get_ips RAM]
}

rename_ref -prefix_all RAM_

# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef RAM.dcp
create_report "RAM_synth_1_synth_report_utilization_0" "report_utilization -file RAM_utilization_synth.rpt -pb RAM_utilization_synth.pb"

if { [catch {
  write_verilog -force -mode synth_stub D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.runs/RAM_synth_1/RAM_stub.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a Verilog synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  write_vhdl -force -mode synth_stub D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.runs/RAM_synth_1/RAM_stub.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a VHDL synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  write_verilog -force -mode funcsim D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.runs/RAM_synth_1/RAM_sim_netlist.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the Verilog functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}

if { [catch {
  write_vhdl -force -mode funcsim D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.runs/RAM_synth_1/RAM_sim_netlist.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the VHDL functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}


} else {


}; # end if cached_ip 

add_files D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.runs/RAM_synth_1/RAM_stub.v -of_objects [get_files D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.srcs/sources_1/ip/RAM/RAM.xci]

add_files D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.runs/RAM_synth_1/RAM_stub.vhdl -of_objects [get_files D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.srcs/sources_1/ip/RAM/RAM.xci]

add_files D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.runs/RAM_synth_1/RAM_sim_netlist.v -of_objects [get_files D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.srcs/sources_1/ip/RAM/RAM.xci]

add_files D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.runs/RAM_synth_1/RAM_sim_netlist.vhdl -of_objects [get_files D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.srcs/sources_1/ip/RAM/RAM.xci]

add_files D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.runs/RAM_synth_1/RAM.dcp -of_objects [get_files D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.srcs/sources_1/ip/RAM/RAM.xci]

if {[file isdir D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.ip_user_files/ip/RAM]} {
  catch { 
    file copy -force D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.runs/RAM_synth_1/RAM_sim_netlist.v D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.ip_user_files/ip/RAM
  }
}

if {[file isdir D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.ip_user_files/ip/RAM]} {
  catch { 
    file copy -force D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.runs/RAM_synth_1/RAM_sim_netlist.vhdl D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.ip_user_files/ip/RAM
  }
}

if {[file isdir D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.ip_user_files/ip/RAM]} {
  catch { 
    file copy -force D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.runs/RAM_synth_1/RAM_stub.v D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.ip_user_files/ip/RAM
  }
}

if {[file isdir D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.ip_user_files/ip/RAM]} {
  catch { 
    file copy -force D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.runs/RAM_synth_1/RAM_stub.vhdl D:/Benutzer/Documents/Vivado/Projects/Verilog/Acron_x32/Acron_x32.ip_user_files/ip/RAM
  }
}
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]