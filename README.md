# Claude Statusline

Barra de progreso en tiempo real para Claude Code que muestra el uso del **rate limit de 5 horas** — el límite que, al llegar al 100%, requiere esperar antes de seguir usando Claude.

```
kevin  Sonnet 4.6   [░░░░░░░░░░░░░░░░]  3% ~4h36m    ← verde,   sin problema
kevin  Sonnet 4.6   [██████████░░░░░░] 62% ~2h10m    ← amarillo, moderado
kevin  Sonnet 4.6   [████████████████] 95% ~0h22m    ← rojo,     casi al límite
```

La barra también muestra el tiempo restante para que el contador se resetee.

---

## Requisitos

- [Claude Code](https://claude.ai/download) instalado
- Windows 10 / 11
- PowerShell 5.1 o superior
- Git Bash (incluido con [Git for Windows](https://git-scm.com))

---

## Instalación

**1. Clona o descarga el repositorio**

```bash
git clone https://github.com/kevingilarevalo/claude-statusline.git
```

O descarga el ZIP desde el botón verde **Code → Download ZIP** y extráelo.

**2. Ejecuta el instalador**

Abre PowerShell en la carpeta descargada y corre:

```powershell
.\install.ps1
```

El instalador hace todo automáticamente:
- Verifica que Claude Code esté instalado
- Instala `jq` si no lo tienes
- Copia el script a `~/.claude/`
- Configura `settings.json`

**3. Reinicia Claude Code**

Cierra y vuelve a abrir Claude Code. La barra aparece en la parte inferior.

---

## Desinstalación

```powershell
.\install.ps1 -Uninstall
```

Elimina el script y restaura `settings.json` al estado original.

---

## Cómo funciona

Claude Code permite configurar un comando personalizado para la barra de estado inferior (`statusLine` en `settings.json`). El comando recibe un JSON con datos de la sesión — incluyendo `rate_limits.five_hour.used_percentage` — y devuelve el texto a mostrar con colores ANSI.

```
settings.json → statusline-command.sh → barra coloreada
```

| Porcentaje | Color    |
|------------|----------|
| 0 – 59 %   | Verde    |
| 60 – 79 %  | Amarillo |
| 80 – 100 % | Rojo     |

---

## Archivos

```
claude-statusline/
├── statusline-command.sh   Script de la barra (bash)
├── install.ps1             Instalador / desinstalador
└── README.md               Este archivo
```

---

## Autor

Kevin Gil Arévalo — [@kevingilarevalo](https://github.com/kevingilarevalo)
