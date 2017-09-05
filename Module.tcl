###############################################################################
#
# Generic module event handlers
#
###############################################################################

#
# This is the namespace in which all functions and variables below will exist.
#
namespace eval Module {


#
# Executed when a module is being activated
#
proc activating_module {module_name} {
  #yak# playMsg "Default" "activating";
  #yak# playSilence 100;
  #yak# playMsg $module_name "name";
  #yak# playSilence 200;
}


#
# Executed when a module is being deactivated.
#
proc deactivating_module {module_name} {
  #yak# playMsg "Default" "deactivating";
  #yak# playSilence 100;
  #yak# playMsg $module_name "name";
  #yak# playSilence 200;
}


#
# Executed when the inactivity timeout for a module has expired.
#
proc timeout {module_name} {
  #yak# playMsg "Default" "timeout";
  #yak# playSilence 100;
}


#
# Executed when playing of the help message for a module has been requested.
#
proc play_help {module_name} {
  #yak# playMsg $module_name "help"
  #yak# playSubcommands $module_name help_subcmd "sub_commands_are"
}


# End of namespace
}

#
# This file has not been truncated
#
