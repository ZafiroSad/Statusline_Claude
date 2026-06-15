# Claude Statusline

![Platform](https://img.shields.io/badge/platform-Windows-blue?logo=windows)
![Shell](https://img.shields.io/badge/shell-bash-green?logo=gnubash)
![Claude Code](https://img.shields.io/badge/Claude_Code-compatible-orange?logo=anthropic)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

Barra de estado minimalista en tiempo real para **Claude Code**. Muestra contexto de sesión, uso del rate limit de 5 horas y tiempo de reset — todo en una línea limpia con colores ANSI.

```
STICK-PROJECTS  ·  Opus 4.8  ·  ▬▬▬▬▬▬──────  ·  50%  ·  ↺ 2h30m  ·  ↺ 04:15 PM
```

---

## Qué muestra

| Campo | Descripción |
|---|---|
| `STICK-PROJECTS` | Nombre del repositorio git activo. Si no hay repo, muestra un mensaje contextual según el nivel de uso |
| `Opus 4.8` | Modelo activo en la sesión |
| `▬▬▬▬▬▬──────` | Barra de uso del rate limit. `▬` relleno con color, `─` en gris |
| `50%` | Porcentaje exacto consumido |
| `↺ 2h30m` | Tiempo restante hasta el reset |
| `↺ 04:15 PM` | Hora exacta en la que se recarga el límite |

### Mensajes contextuales (sin repo activo)

| Uso | Mensaje |
|---|---|
| 0 – 39 % | `Aguardando órdenes` |
| 40 – 59 % | `Sesión en curso` |
| 60 – 79 % | `Trabajando a buen ritmo` |
| 80 – 100 % | `Límite próximo` |

### Colores de la barra

| Porcentaje | Color | Significado |
|---|---|---|
| 0 – 59 % | Verde suave | Sin problema |
| 60 – 79 % | Amarillo cálido | Uso moderado |
| 80 – 100 % | Coral + `▲` | Cerca del límite |

---

## Requisitos

| Requisito | Versión mínima |
|---|---|
| [Claude Code](https://claude.ai/download) | cualquiera |
| Windows | 10 / 11 |
| PowerShell | 5.1+ |
| [Git for Windows](https://git-scm.com) | cualquiera |

---

## Instalación

**1. Clona el repositorio**

```bash
git clone https://github.com/ZafiroSad/Statusline_Claude.git
cd Statusline_Claude
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

Los campos utilizados del JSON:

| Campo JSON | Uso |
|---|---|
| `rate_limits.five_hour.used_percentage` | Porcentaje de uso y color de barra |
| `rate_limits.five_hour.resets_at` | Cálculo de tiempo restante y hora de reset |
| `model.display_name` | Nombre del modelo activo |
| `workspace.current_dir` | Ruta para detectar el repo git activo |

---

## Archivos

```
Statusline_Claude/
├── statusline-command.sh   Script de la barra (bash)
├── install.ps1             Instalador / desinstalador (PowerShell)
└── README.md               Documentación
```

---

## Licencia

MIT © [Kevin Gil Arévalo](https://github.com/ZafiroSad)
