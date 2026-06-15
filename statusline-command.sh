#!/bin/sh

# Detectar jq: primero en PATH, luego en WinGet
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

# Barra de progreso — estilo ▰▱, ancho 12
bar_width=12
progress_part=""
if [ "$pct" -ge 0 ] 2>/dev/null; then
    filled=$((pct * bar_width / 100))
    empty=$((bar_width - filled))

    bar=""
    i=0; while [ $i -lt $filled ]; do bar="${bar}▰"; i=$((i+1)); done
    i=0; while [ $i -lt $empty  ]; do bar="${bar}▱"; i=$((i+1)); done

    if   [ $pct -lt 60 ]; then col="38;5;114"   # verde suave
    elif [ $pct -lt 80 ]; then col="38;5;221"   # amarillo cálido
    else                       col="38;5;203"   # coral
    fi

    pct_label="${pct}%"
    [ -n "$reset_info" ] && pct_label="${pct_label}  ${reset_info}"

    progress_part=$(printf "\033[${col}m%s\033[0m  \033[2m%s\033[0m" "$bar" "$pct_label")
fi

# Separador elegante
SEP=$(printf "  \033[2m·\033[0m  ")

# Ensamblar línea
line=""
[ -n "$folder" ] && line=$(printf "\033[2m%s\033[0m" "$folder")
[ -n "$branch" ] && line="${line}${SEP}$(printf "⎇  %s" "$branch")"
[ -n "$model"  ] && line="${line}${SEP}$(printf "◆  %s" "$model")"
[ -n "$progress_part" ] && line="${line}    ${progress_part}"

printf "%s" "$line"
