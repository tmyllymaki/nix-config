# Propagate ZMX_SESSION to wezterm user variables for status bar display.
# Only emit the OSC escape in interactive TTY-attached shells — otherwise
# it leaks into captured command output (e.g. neovim's :!pwd).
if status is-interactive; and isatty stdout
    if set -q ZMX_SESSION; and set -q WEZTERM_PANE
        printf "\033]1337;SetUserVar=%s=%s\007" zmx_session (echo -n $ZMX_SESSION | base64)
    end
end
