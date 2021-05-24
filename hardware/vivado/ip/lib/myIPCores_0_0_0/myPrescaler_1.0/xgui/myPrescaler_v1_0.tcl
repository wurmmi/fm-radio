# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CounterWidth" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ResetValue" -parent ${Page_0}


}

proc update_PARAM_VALUE.CounterWidth { PARAM_VALUE.CounterWidth } {
	# Procedure called to update CounterWidth when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CounterWidth { PARAM_VALUE.CounterWidth } {
	# Procedure called to validate CounterWidth
	return true
}

proc update_PARAM_VALUE.ResetValue { PARAM_VALUE.ResetValue } {
	# Procedure called to update ResetValue when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ResetValue { PARAM_VALUE.ResetValue } {
	# Procedure called to validate ResetValue
	return true
}


proc update_MODELPARAM_VALUE.CounterWidth { MODELPARAM_VALUE.CounterWidth PARAM_VALUE.CounterWidth } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CounterWidth}] ${MODELPARAM_VALUE.CounterWidth}
}

proc update_MODELPARAM_VALUE.ResetValue { MODELPARAM_VALUE.ResetValue PARAM_VALUE.ResetValue } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ResetValue}] ${MODELPARAM_VALUE.ResetValue}
}

