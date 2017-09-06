###############################################################################
#
# CalmLogic event handlers
#
###############################################################################

#
# This is the namespace in which all functions below will exist. The name
# must match the corresponding section "[CalmLogic]" in the configuration
# file. The name may be changed but it must be changed in both places.
#
namespace eval CalmLogic {

variable rx_squelch_closed 1;  # Time the squelch closed.

#
# A variable used to store a timestamp for the last identification.
#
variable prev_ident 0;

#
# Short identification interval, set from config variable below.
#
variable short_ident_interval 500;
variable need_ident 0;

#
# Checking to see if this is the correct logic core
#
if {$logic_name != [namespace tail [namespace current]]} {
  return;
}

proc clean {s} {
  regsub -all {[^ -~]+} $s {~}
}
proc Calmly {args} {
  set ts [clock format $now -format {%d@%H:%M:%S} -gmt 1]
  puts [clean "($ts) Noted Calmly: $args"]
  flush stdout
}

#
# Executed when the SvxLink software is started
#
proc startup {} {
  global logic_name;
  append func $logic_name "::checkPeriodicIdentify";
  Logic::addTimerTickSubscriber $func;
  Logic::startup;
}


#
# Executed when a specified module could not be found
#
proc no_such_module {module_id} {
  Calmly Logic::no_such_module $module_id;
}


#
# Executed when a manual identification is initiated with the * DTMF code
#
proc manual_identification {} {
  Calmly Logic::manual_identification;
}


#
# Executed when the squelch just have closed and the RGR_SOUND_DELAY timer has
# expired.
#
proc send_rgr_sound {} {
  Calmly Logic::send_rgr_sound;
}


#
# Executed when an empty macro command (i.e. D#) has been entered.
#
proc macro_empty {} {
  Calmly Logic::macro_empty;
}


#
# Executed when an entered macro command could not be found
#
proc macro_not_found {} {
  Calmly Logic::macro_not_found;
}


#
# Executed when a macro syntax error occurs (configuration error).
#
proc macro_syntax_error {} {
  Calmly Logic::macro_syntax_error;
}


#
# Executed when the specified module in a macro command is not found
# (configuration error).
#
proc macro_module_not_found {} {
  Calmly Logic::macro_module_not_found;
}


#
# Executed when the activation of the module specified in the macro command
# failed.
#
proc macro_module_activation_failed {} {
  Calmly Logic::macro_module_activation_failed;
}


#
# Executed when a macro command is executed that requires a module to
# be activated but another module is already active.
#
proc macro_another_active_module {} {
  Calmly Logic::macro_another_active_module;
}


#
# Executed when an unknown DTMF command is entered
#
proc unknown_command {cmd} {
  Calmly Logic::unknown_command $cmd;
}


#
# Executed when an entered DTMF command failed
#
proc command_failed {cmd} {
  Calmly Logic::command_failed $cmd;
}


#
# Executed when a link to another logic core is activated.
#   name  - The name of the link
#
proc activating_link {name} {
  Calmly Logic::activating_link $name;
}


#
# Executed when a link to another logic core is deactivated.
#   name  - The name of the link
#
proc deactivating_link {name} {
  Calmly Logic::deactivating_link $name;
}


#
# Executed when trying to deactivate a link to another logic core but the
# link is not currently active.
#   name  - The name of the link
#
proc link_not_active {name} {
  Calmly Logic::link_not_active $name;
}


#
# Executed when trying to activate a link to another logic core but the
# link is already active.
#   name  - The name of the link
#
proc link_already_active {name} {
  Calmly Logic::link_already_active $name;
}


#
# Executed once every whole minute
#
proc every_minute {} {
  Logic::every_minute;
}


#
# Executed each time the transmitter is turned on or off
#   is_on - Set to 1 if the transmitter is on or 0 if it's off
#
proc transmit {is_on} {
  variable prev_ident;
  variable need_ident;
  if {$is_on && ([clock seconds] - $prev_ident > 10)} {
    set need_ident 1;
  }
}


#
# Executed each time the squelch is opened or closed
#   rx_id   - The ID of the RX that the squelch opened/closed on
#   is_open - Set to 1 if the squelch is open or 0 if it's closed
#
proc squelch_open {rx_id is_open} {
  variable sql_rx_id;
  variable rx_squelch_closed;
  #puts "@@@ CalmLogic: The squelch is $is_open on RX $rx_id";
  set sql_rx_id $rx_id;
  set rx_squelch_closed [expr {$is_open ? 0 : [clock seconds]}]
}




#
# Executed when a DTMF digit has been received
#   digit     - The detected DTMF digit
#   duration  - The duration, in milliseconds, of the digit
#
# Return 1 to hide the digit from further processing in SvxLink or
# return 0 to make SvxLink continue processing as normal.
#
proc dtmf_digit_received {digit duration} {
  return 0;
}


#
# Executed when a DTMF command has been received
#   cmd - The command
#
# Return 1 to hide the command from further processing is SvxLink or
# return 0 to make SvxLink continue processing as normal.
#
proc dtmf_cmd_received {cmd} {
  return 0;
}




#
# Use this function to add a function to the list of functions that
# should be executed once every whole minute. This is not an event
# function but rather a management function.
#
proc addTimerTickSubscriber {func} {
  variable timer_tick_subscribers;
  lappend timer_tick_subscribers $func;
}


#
# Should be executed once every whole minute to check if it is time to
# identify. Not exactly an event function. This function handle the
# identification logic.
#
proc checkPeriodicIdentify {} {
  variable rx_squelch_closed;
  variable prev_ident;
  variable short_ident_interval;
  variable need_ident;

  set now [clock seconds]
  set ts [clock format $now -format {%d@%H:%M:%S} -gmt 1]
  if {! $need_ident} {
    puts "@@@@@@ $ts CalmLogic: Ident not needed."
    return
  }

  if {!$rx_squelch_closed} {
    puts "@@@@@@ $ts CalmLogic: Squelch is open."
    return
  }

  set ago [expr {$now - $rx_squelch_closed}]
  if {$ago < 3} {
    puts "@@@@@@ $ts CalmLogic: Squelch was recently open, $ago seconds ago."
    return
  }

  set ago [expr {$now - $prev_ident}]
  if {$ago < $short_ident_interval} {
    puts "@@@@@@ $ts CalmLogic: Only $ago < $short_ident_interval seconds between idents."
    return
  }

  puts "@@@@@@ $ts CalmLogic: @@@ PLAYING IDENT @@@"
  ::playSilence 1000
  CW::play %identify%
  ::playSilence 500
  set prev_ident $now
  set need_ident 0
  return
}


#
# Executed when the QSO recorder is being activated
#
proc activating_qso_recorder {} {
  Calmly Logic::activating_qso_recorder;
}


#
# Executed when the QSO recorder is being deactivated
#
proc deactivating_qso_recorder {} {
  Calmly Logic::deactivating_qso_recorder;
}


#
# Executed when trying to deactivate the QSO recorder even though it's
# not active
#
proc qso_recorder_not_active {} {
  Calmly Logic::qso_recorder_not_active;
}


#
# Executed when trying to activate the QSO recorder even though it's
# already active
#
proc qso_recorder_already_active {} {
  Calmly Logic::qso_recorder_already_active;
}


#
# Executed when the timeout kicks in to activate the QSO recorder
#
proc qso_recorder_timeout_activate {} {
  Calmly Logic::qso_recorder_timeout_activate
}


#
# Executed when the timeout kicks in to deactivate the QSO recorder
#
proc qso_recorder_timeout_deactivate {} {
  Calmly Logic::qso_recorder_timeout_deactivate
}


#
# Executed when the user is requesting a language change
#
proc set_language {lang_code} {
  Calmly Logic::set_language "$lang_code";
}


#
# Executed when the user requests a list of available languages
#
proc list_languages {} {
  Calmly Logic::list_languages
}


#
# Executed when the node is being brought online after being offline
#
proc logic_online {online} {
  Calmly Logic::logic_online $online
}


##############################################################################
#
# Main program
#
##############################################################################

if [info exists CFG_SHORT_IDENT_INTERVAL] {
  if {$CFG_SHORT_IDENT_INTERVAL > 0} {
    set short_ident_interval $CFG_SHORT_IDENT_INTERVAL;
  }
}

if [info exists CFG_LONG_IDENT_INTERVAL] {
  if {$CFG_LONG_IDENT_INTERVAL > 0} {
    set long_ident_interval $CFG_LONG_IDENT_INTERVAL;
    if {$short_ident_interval == 0} {
      set short_ident_interval $long_ident_interval;
    }
  }
}




# end of namespace
}


#
# This file has not been truncated
#
