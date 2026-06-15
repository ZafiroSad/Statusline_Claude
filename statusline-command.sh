#!/bin/sh

# Detectar jq
if command -v jq >/dev/null 2>&1; then
    JQ="jq"
else
    WINGET_JQ=$(find "/c/Users/$USERNAME/AppData/Local/Microsoft/WinGet/Packages" -name "jq.exe" 2>/dev/null | head -1)
    JQ="${WINGET_JQ:-jq}"
fi

input=$(cat)

dir_raw=$(echo "$input" | $JQ -r '.workspace.current_dir // .cwd // empty')
folder=$(echo "$dir_raw" | sed 's/.*[/\\]//')
branch=$(git -C "$dir_raw" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
model=$(echo "$input" | $JQ -r '.model.display_name // empty')

pct=$(echo "$input" | $JQ -r '.rate_limits.five_hour.used_percentage // 0')
resets_at=$(echo "$input" | $JQ -r '.rate_limits.five_hour.resets_at // 0')

# Tiempo hasta reset
reset_info=""
if [ "$resets_at" -gt 0 ] 2>/dev/null; then
    now=$(date +%s)
    diff=$((resets_at - now))
    if [ $diff -gt 0 ]; then
        hrs=$(( diff / 3600 ))
        mins=$(( (diff % 3600) / 60 ))
        if [ $hrs -gt 0 ]; then
            reset_info="↺ ${hrs}h${mins}m"
        else
            reset_info="↺ ${mins}m"
        fi
    fi
fi

# Color del porcentaje segun uso
pct_colored=""
if [ "$pct" -ge 0 ] 2>/dev/null; then
    if   [ $pct -lt 60 ]; then col=""
    elif [ $pct -lt 80 ]; then col=$(printf "\033[38;5;221m")
    else                       col=$(printf "\033[38;5;203m")
    fi
    rst=$(printf "\033[0m")
    dim=$(printf "\033[2m")

    pct_str="${col}${pct}%${rst}"
    [ -n "$reset_info" ] && pct_str="${pct_str}  ${dim}${reset_info}${rst}"
    pct_colored="$pct_str"
fi

# Separador
SEP=$(printf "  \033[2m│\033[0m  ")
DIM=$(printf "\033[2m")
RST=$(printf "\033[0m")

# Ensamblar
line=""
[ -n "$folder"      ] && line="${DIM}${folder}${RST}"
[ -n "$branch"      ] && line="${line}${SEP}${branch}"
[ -n "$model"       ] && line="${line}${SEP}${model}"
[ -n "$pct_colored" ] && line="${line}${SEP}${pct_colored}"

printf "%s" "$line"
