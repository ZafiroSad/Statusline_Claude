#!/bin/sh

# Detectar jq: primero en PATH, luego en WinGet
if command -v jq >/dev/null 2>&1; then
    JQ="jq"
else
    WINGET_JQ=$(find "/c/Users/$USERNAME/AppData/Local/Microsoft/WinGet/Packages" -name "jq.exe" 2>/dev/null | head -1)
    JQ="${WINGET_JQ:-jq}"
fi

input=$(cat)

# Info existente
folder=$(echo "$input" | $JQ -r '.workspace.current_dir // .cwd // empty' | sed 's/.*[/\\]//')
branch=$(git -C "$(echo "$input" | $JQ -r '.workspace.current_dir // .cwd // empty')" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
model=$(echo "$input" | $JQ -r '.model.display_name // empty')

# Rate limit de 5 horas
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
            reset_info=" ~${hrs}h${mins}m"
        else
            reset_info=" ~${mins}m"
        fi
    fi
fi

# Barra de progreso
progress=""
if [ "$pct" -ge 0 ] 2>/dev/null; then
    filled=$((pct * 16 / 100))
    empty=$((16 - filled))

    bar=""
    i=0; while [ $i -lt $filled ]; do bar="${bar}█"; i=$((i+1)); done
    i=0; while [ $i -lt $empty  ]; do bar="${bar}░"; i=$((i+1)); done

    if   [ $pct -lt 60 ]; then color="\033[32m"
    elif [ $pct -lt 80 ]; then color="\033[33m"
    else                       color="\033[31m"
    fi

    progress=$(printf "${color}[${bar}] ${pct}%%%s\033[0m" "$reset_info")
fi

# Armar línea
parts=""
[ -n "$folder"   ] && parts="$folder"
[ -n "$branch"   ] && parts="$parts  $branch"
[ -n "$model"    ] && parts="$parts  $model"
[ -n "$progress" ] && parts="$parts   $progress"

printf "%s" "$parts"
