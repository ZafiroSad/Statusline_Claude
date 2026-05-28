# Claude Statusline

![Platform](https://img.shields.io/badge/platform-Windows-blue?logo=windows)
![Shell](https://img.shields.io/badge/shell-bash-green?logo=gnubash)
![Claude Code](https://img.shields.io/badge/Claude_Code-compatible-orange?logo=anthropic)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

Barra de progreso en tiempo real para **Claude Code** que muestra el uso del rate limit de 5 horas — el límite que, al llegar al 100%, requiere esperar antes de seguir usando Claude.

```
kevin  Sonnet 4.6   [░░░░░░░░░░░░░░░░]  3% ~4h36m    ← verde,   sin problema
kevin  Sonnet 4.6   [██████████░░░░░░] 62% ~2h10m    ← amarillo, moderado
kevin  Sonnet 4.6   [████████████████] 95% ~0h22m    ← rojo,     casi al límite
```

---

## Requisitos

| Requisito | Versión mínima |
|-----------|----------------|
| [Claude Code](https://claude.ai/download) | cualquiera |
| Windows | 10 / 11 |
| PowerShell | 5.1+ |
| [Git for Windows](https://git-scm.com) | cualquiera |

---

## Instalación

**1. Clona el repositorio**

```bash
git clone https://github.com/ZafiroSad/Statuslin_Claude.git
cd Statuslin_Claude
```

**2. Ejecuta el instalador**

```powershell
.\install.ps1
```

El instalador hace todo automáticamente:
- Verifica que Claude Code esté instalado
- Instala `jq` si no lo tienes (via winget)
- Copia el script a `~/.claude/`
- Configura `settings.json`

**3. Reinicia Claude Code**

La barra aparece en la parte inferior de la terminal.

---

## Desinstalación

```powershell
.\install.ps1 -Uninstall
```

---

## Cómo funciona

Claude Code permite configurar un comando personalizado para la barra de estado inferior via `statusLine` en `settings.json`. El comando recibe un JSON con datos de la sesión en cada mensaje y devuelve texto con colores ANSI.

```
settings.json → statusline-command.sh → barra coloreada
```

El campo usado es `rate_limits.five_hour.used_percentage` — el mismo contador que comparten todas las sesiones abiertas de Claude Code simultáneamente.

| Porcentaje | Color    | Significado        |
|------------|----------|--------------------|
| 0 – 59 %   | 🟢 Verde  | Sin problema       |
| 60 – 79 %  | 🟡 Amarillo | Uso moderado     |
| 80 – 100 % | 🔴 Rojo   | Cerca del límite   |

---

## Archivos

```
Statuslin_Claude/
├── statusline-command.sh   Script de la barra (bash)
├── install.ps1             Instalador / desinstalador (PowerShell)
└── README.md               Documentación
```

---

## Licencia

MIT © [Kevin Gil Arévalo](https://github.com/ZafiroSad)
