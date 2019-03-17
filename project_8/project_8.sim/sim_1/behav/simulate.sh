#!/bin/bash -f
xv_path="/opt/Xilinx/Vivado/2016.4"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xsim displayinterface_behav -key {Behavioral:sim_1:Functional:displayinterface} -tclbatch displayinterface.tcl -view /home/dual/cs5170402/project_8/testbencher_behav.wcfg -view /home/dual/cs5170402/project_8/displayinterface_behav.wcfg -log simulate.log
