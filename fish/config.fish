if status is-interactive
    # Commands to run in interactive sessions can go here
    set -U fish_greeting ""
    fastfetch
end

function fish_prompt
    set_color cyan
    echo -n (basename (prompt_pwd))

    set_color normal
    echo -n " > "
end
