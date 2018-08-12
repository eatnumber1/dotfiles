source_if_exists $HOME/.zprofile.local

if is_osx && [[ -f /etc/zprofile ]]; then
  # Restore the saved path and manpath
  # On GMac (and maybe all of OSX), /etc/zprofile runs path_helper(8).
  # path_helper then moves the system directories in front of anything that is
  # set here. Therefore, to work around this we saved the path and manpath in
  # .zshenv, and correct it here.
  if [[ -v saved_path ]]; then
    # This relies on path being declared with -U to deduplicate it.
    path=( $saved_path $path )
    unset saved_path
  fi
  if [[ -v saved_manpath ]]; then
    manpath=( $saved_manpath $manpath )
    unset saved_manpath
  fi
fi
