# Guia de Estilos - Choque de Leyendas

Referencia visual para mantener consistencia entre la app web (Laravel) y el cliente Godot.

---

## Colores

### Colores primarios del juego

Los tres colores primarios representan los tres tipos de dados y recursos del juego.

| Color   | Hex       | Claro     | Oscuro    | Uso                                      |
|---------|-----------|-----------|-----------|------------------------------------------|
| Verde   | `#29ab5f` | `#5fcb8a` | `#1a7440` | Dados verdes, atributos Will y Mental     |
| Azul    | `#408cfd` | `#6fadfe` | `#195ec0` | Dados azules, atributos Strength y Armor  |
| Rojo    | `#f15959` | `#f58080` | `#c62121` | Dados rojos, atributo Health              |

### Colores intermedios

Combinaciones de los colores primarios, usados para dados mixtos y elementos UI.

| Color    | Hex       | Claro     | Oscuro    | Combinacion |
|----------|-----------|-----------|-----------|-------------|
| Teal     | `#31a28e` | `#59b290` | `#1a7464` | Verde-Azul  |
| Cyan     | `#3999cd` | `#59b8e6` | `#1f6d96` | Verde-Azul  |
| Purple   | `#7a64c8` | `#9a81e6` | `#534994` | Azul-Rojo   |
| Magenta  | `#a75da5` | `#c76cc0` | `#773d75` | Azul-Rojo   |
| Orange   | `#f1753a` | `#f58a5c` | `#c65623` | Rojo-Verde  |
| Lime     | `#88b033` | `#a5c84a` | `#647f1e` | Rojo-Verde  |

### Colores de fondo

| Rol        | Hex       |
|------------|-----------|
| Primario   | `#1a1a1a` |
| Secundario | `#262626` |
| Terciario  | `#333333` |

### Colores de texto

| Rol       | Hex       |
|-----------|-----------|
| Claro     | `#fafafa` |
| Claro dim | `#d0d0d0` |
| Muted     | `#808080` |
| Oscuro    | `#0a0a0a` |

### Opacidades estandar

| Nombre  | Valor |
|---------|-------|
| Hard    | 0.8   |
| Semi    | 0.5   |
| Light   | 0.2   |
| Lighter | 0.1   |

### Uso en GDScript

Todos los colores estan disponibles como constantes en `assets/theme/colors.gd` (class_name: `GameColors`):

```gdscript
var color = GameColors.COLOR_GREEN
var bg = GameColors.COLOR_BG_DARK_PRIMARY
```

---

## Fuentes

| Fuente           | Archivos                                    | Uso                                               |
|------------------|---------------------------------------------|----------------------------------------------------|
| Roboto           | `assets/fonts/roboto/Roboto-*.ttf`          | Texto general, cuerpo, UI                           |
| IM Fell English  | `assets/fonts/imfellenglish/IMFellEnglish-*.ttf` | Encabezados, botones, textos destacados, "Choque de Leyendas" |
| Italianno        | `assets/fonts/italianno/Italianno-Regular.ttf`   | Texto del logo "Espadas de Ceniza", usos puntuales   |

### Variantes disponibles

- **Roboto:** Regular, Bold, Italic, BoldItalic
- **IM Fell English:** Regular, Italic
- **Italianno:** Regular

---

## Iconos

### Atributos de heroes

Iconos SVG en `assets/icons/attributes/`. Estilo: stroke sin relleno (outline).

| Atributo | Archivo          | Color     | Icono         |
|----------|------------------|-----------|---------------|
| Will     | `will.svg`       | `#29ab5f` | Mano abierta  |
| Strength | `strength.svg`   | `#408cfd` | Espadas cruzadas |
| Mental   | `mental.svg`     | `#29ab5f` | Cabeza/cerebro |
| Health   | `health.svg`     | `#f15959` | Corazon        |
| Armor    | `armor.svg`      | `#408cfd` | Escudo         |
| Agility  | `agility.svg`    | `#f1c40f` | Bota           |

### Dados

SVGs en `assets/icons/dices/`. Hexagonos 3D coloreados por cara.

| Archivo                     | Colores            |
|-----------------------------|--------------------|
| `dice_red.svg`              | Rojo               |
| `dice_green.svg`            | Verde              |
| `dice_blue.svg`             | Azul               |
| `dice_red_green.svg`        | Rojo + Verde       |
| `dice_red_blue.svg`         | Rojo + Azul        |
| `dice_green_blue.svg`       | Verde + Azul       |
| `dice_red_green_blue.svg`   | Rojo + Verde + Azul|

---

## Logos

Archivos en `assets/logos/`.

| Archivo             | Contenido                                    | Formato |
|---------------------|----------------------------------------------|---------|
| `logo_icon.svg`     | Hada (icono independiente)                   | SVG     |
| `logo_full_es.svg`  | Hada + "Choque de Leyendas" + "Espadas de Ceniza" | SVG |
| `logo_full_en.svg`  | Hada + "Clash of Legends" + "Blades of Ash"  | SVG     |
| `logo_small_es.png` | Icono compacto (dado+hada+texto) ES          | PNG     |
| `logo_small_en.png` | Icono compacto (dado+hada+texto) EN          | PNG     |
| `favicon.ico`       | Dado tricolor (icono minimo)                 | ICO     |

### Composicion del logo

El logo completo se compone de:
1. **Hada** (logo_icon.svg) - elemento grafico principal
2. **Titulo** - "Choque de Leyendas" / "Clash of Legends" (fuente IM Fell English)
3. **Subtitulo** - "Espadas de Ceniza" / "Blades of Ash" (fuente Italianno)

---

## Colores de facciones

Cada faccion tiene su color propio (viene de la API):

| Faccion                   | Color     | Texto   |
|---------------------------|-----------|---------|
| Defensores de Terik       | `#29b8f0` | Oscuro  |
| Guardabosques de Thenan   | `#00695C` | Claro   |
| Tribu Llama Furiosa       | `#212121` | Claro   |
