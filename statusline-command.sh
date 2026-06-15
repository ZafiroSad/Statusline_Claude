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
model=$(echo "$input"   | $JQ -r '.model.display_name // empty')

pct=$(echo "$input"      | $JQ -r '.rate_limits.five_hour.used_percentage // 0')
resets_at=$(echo "$input" | $JQ -r '.rate_limits.five_hour.resets_at // 0')

# Tiempo restante y hora de reset
time_left=""
reset_clock=""
if [ "$resets_at" -gt 0 ] 2>/dev/null; then
    now=$(date +%s)
    diff=$((resets_at - now))
    if [ $diff -gt 0 ]; then
        hrs=$(( diff / 3600 ))
        mins=$(( (diff % 3600) / 60 ))
        if [ $hrs -gt 0 ]; then
            time_left="${hrs}h${mins}m"
        else
            time_left="${mins}m"
        fi
    fi
    reset_clock=$(date -d "@$resets_at" "+%I:%M %p" 2>/dev/null)
fi

# Barra de progreso ▰▱ (ancho 12)
bar_width=12
bar=""
if [ "$pct" -ge 0 ] 2>/dev/null; then
    filled=$((pct * bar_width / 100))
    empty=$((bar_width - filled))
    fill=""; i=0; while [ $i -lt $filled ]; do fill="${fill}▬"; i=$((i+1)); done
    trail=""; i=0; while [ $i -lt $empty  ]; do trail="${trail}─"; i=$((i+1)); done
    gray=$(printf "\033[38;5;240m")
    bar=$(printf "%s%s${gray}%s\033[0m" "" "$fill" "$trail")
fi

# Color segun uso (solo barra y porcentaje)
if   [ "$pct" -lt 60 ] 2>/dev/null; then col=$(printf "\033[38;5;114m")
elif [ "$pct" -lt 80 ] 2>/dev/null; then col=$(printf "\033[38;5;221m")
else                                       col=$(printf "\033[38;5;203m")
fi
rst=$(printf "\033[0m")
dim=$(printf "\033[2m")
SEP=$(printf "  ${dim}·${rst}  ")

# Ensamblar segmentos
line=""
[ -n "$folder"      ] && line="${dim}${folder}${rst}"
[ -n "$model"       ] && line="${line}${SEP}${model}"
[ -n "$bar"         ] && line="${line}${SEP}${col}${bar}${rst}"
warn=""
[ "$pct" -ge 80 ] 2>/dev/null && warn=$(printf "  \033[38;5;203m▲\033[0m")
[ -n "$pct"         ] && line="${line}${SEP}${col}${pct}%${rst}${warn}"
[ -n "$time_left"   ] && line="${line}${SEP}${dim}↺ ${time_left}${rst}"
[ -n "$reset_clock" ] && line="${line}${SEP}${dim}↺ ${reset_clock}${rst}"

printf "%s" "$line"
