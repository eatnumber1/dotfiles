#SPACESHIP_PROMPT_ORDER=()
SPACESHIP_PROMPT_ORDER=(
  host           # Hostname section
  user           # Username section
  dir            # Current directory section
  #time           # Time stamps section
  #git            # Git section (git_branch + git_status)
  #hg             # Mercurial section (hg_branch  + hg_status)
  #package        # Package version
  #node           # Node.js section
  #bun            # Bun section
  #deno           # Deno section
  #ruby           # Ruby section
  #python         # Python section
  #elm            # Elm section
  #elixir         # Elixir section
  #xcode          # Xcode section
  #swift          # Swift section
  #golang         # Go section
  #perl           # Perl section
  #php            # PHP section
  #rust           # Rust section
  #haskell        # Haskell Stack section
  #scala          # Scala section
  #java           # Java section
  #lua            # Lua section
  #dart           # Dart section
  #julia          # Julia section
  #crystal        # Crystal section
  #docker         # Docker section
  #docker_compose # Docker section
  #aws            # Amazon Web Services section
  #gcloud         # Google Cloud Platform section
  #venv           # virtualenv section
  #conda          # conda virtualenv section
  #dotnet         # .NET section
  #ocaml          # OCaml section
  #vlang          # V section
  #kubectl        # Kubectl context section
  #ansible        # Ansible section
  #terraform      # Terraform workspace section
  #pulumi         # Pulumi stack section
  #ibmcloud       # IBM Cloud section
  #nix_shell      # Nix shell

  # doesn't seem to work
  #gnu_screen     # GNU Screen section

  exec_time      # Execution time
  async          # Async jobs indicator
  line_sep       # Line break
  battery        # Battery level and status
  jobs           # Background jobs indicator
  exit_code      # Exit code section
  sudo           # Sudo indicator
  char           # Prompt character
)

#spaceship remove async
#spaceship remove time
#spaceship remove git

SPACESHIP_RPROMPT_ORDER=(
  time
  #user
)

SPACESHIP_CHAR_SYMBOL="❯ "
SPACESHIP_CHAR_SYMBOL_ROOT="# "

SPACESHIP_HOST_PREFIX="on "

SPACESHIP_USER_PREFIX="as "
SPACESHIP_USER_SHOW=true

# Do not truncate path in repos
SPACESHIP_DIR_TRUNC_REPO=false

SPACESHIP_TIME_SHOW=true

SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_SEPARATE_LINE=false

#SPACESHIP_ASYNC_SHOW_COUNT=true
