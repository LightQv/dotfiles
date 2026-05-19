# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "~/Documents/Boomerang/"

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "boomerang"; then

  # Create a new window inline within session layout definition.
  new_window "reference-api"
  run_cmd "cd boomerang-reference-api"
  new_window "api"
  run_cmd "cd boomerang-api"
  new_window "admin"
  run_cmd "cd boomerang-admin"
  new_window "distributor"
  run_cmd "cd boomerang-distributeurs"
  new_window "nameplate"
  run_cmd "cd boomerang-plaques-signaletiques"
  new_window "opencode"
  run_cmd "oc"

  # Load a defined window layout.
  #load_window "example"

  # Select the default active window on session creation.
  select_window "reference-api"

fi

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
