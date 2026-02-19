# API REST - Choque de Leyendas

**Base URL:** `https://leyendas.espadasdeceniza.com/api/v1`

Todos los endpoints aceptan el query parameter `?locale=es|en` (por defecto `es`).
El backend usa **Laravel Translations**: los campos traducibles (name, lore_text, effect, etc.)
se devuelven ya en el idioma solicitado (no como JSON multi-idioma).
Todos los endpoints devuelven `{ "data": [...] }` excepto `game-data` y `config/hero-attributes`.

---

## Endpoints

### GET /game-data

Devuelve **todos los datos del juego en una sola peticion**. Util para carga inicial.

**Respuesta:** Objeto con todas las colecciones como claves:
```json
{
  "factions": [...],
  "heroes": [...],
  "cards": [...],
  "hero_abilities": [...],
  "card_types": [...],
  "card_subtypes": [...],
  "hero_superclasses": [...],
  "hero_classes": [...],
  "hero_races": [...],
  "equipment_types": [...],
  "attack_ranges": [...],
  "attack_subtypes": [...],
  "counters": [...],
  "game_modes": [...],
  "faction_decks": [...],
  "config": { "hero_attributes": {...} }
}
```

---

### GET /factions

Lista las facciones publicadas (bandos del juego).

| Campo           | Tipo    | Descripcion                                           |
|-----------------|---------|-------------------------------------------------------|
| id              | int     | ID unico                                              |
| name            | string  | Nombre de la faccion                                  |
| lore_text       | string  | Texto de ambientacion                                 |
| color           | string  | Color en hex (#00695C)                                |
| icon_url        | ?string | URL de la imagen/icono de la faccion (JPEG)           |
| text_is_dark    | bool    | Si el texto sobre el color de fondo debe ser oscuro   |
| is_mercenaries  | bool    | Si es la faccion de mercenarios (cartas neutrales)    |

**Ejemplo de respuesta:**
```json
{
  "data": [
	{
	  "id": 3,
	  "name": "Guardabosques de Thenân",
	  "lore_text": "El Bosque de Thenân es un lugar de belleza y peligro...",
	  "color": "#00695C",
	  "icon_url": "https://leyendas.espadasdeceniza.com/storage/images/factions/guardabosques-de-thenan.jpeg",
	  "text_is_dark": false,
	  "is_mercenaries": false
	}
  ]
}
```

**Facciones actuales:**
- **Defensores de Terik** (id:2) — Color #29b8f0 (azul), texto oscuro
- **Guardabosques de Thenân** (id:3) — Color #00695C (verde oscuro), texto claro
- **Tribu Llama Furiosa** (id:4) — Color #212121 (casi negro), texto claro

---

### GET /heroes

Lista los heroes publicados con sus habilidades.

| Campo               | Tipo    | Descripcion                                              |
|---------------------|---------|----------------------------------------------------------|
| id                  | int     | ID unico                                                 |
| name                | string  | Nombre del heroe                                         |
| lore_text           | string  | Texto de ambientacion (HTML)                             |
| passive_name        | string  | Nombre de la habilidad pasiva                            |
| passive_description | string  | Descripcion de la pasiva (HTML)                          |
| faction_id          | int     | FK → factions.id                                         |
| hero_race_id        | int     | FK → hero_races.id                                       |
| hero_class_id       | int     | FK → hero_classes.id                                     |
| gender              | string  | "male" o "female"                                        |
| agility             | int     | Atributo agilidad (1-5)                                  |
| mental              | int     | Atributo mental (1-5)                                    |
| will                | int     | Atributo voluntad (1-5)                                  |
| strength            | int     | Atributo fuerza (1-5)                                    |
| armor               | int     | Atributo armadura (1-5)                                  |
| health              | int     | Vida total (calculada con formula)                       |
| total_attributes    | int     | Suma de todos los atributos                              |
| abilities           | array   | Habilidades del heroe [{id, position}]                   |
| image_url           | ?string | URL de la ilustracion del heroe                          |
| preview_image_url   | ?string | URL de la preview renderizada (en el idioma del locale)  |

**Relaciones de abilities:**
- `id` → hero_abilities.id
- `position` → Posicion de la habilidad en el heroe (1, 2)

---

### GET /cards

Lista las cartas publicadas.

| Campo              | Tipo    | Descripcion                                                |
|--------------------|---------|------------------------------------------------------------|
| id                 | int     | ID unico                                                   |
| name               | string  | Nombre de la carta                                         |
| lore_text          | string  | Texto de ambientacion (HTML)                               |
| faction_id         | int     | FK → factions.id                                           |
| card_type_id       | int     | FK → card_types.id                                         |
| card_subtype_id    | ?int    | FK → card_subtypes.id (nullable)                           |
| equipment_type_id  | ?int    | FK → equipment_types.id (solo para Equipos)                |
| attack_range_id    | ?int    | FK → attack_ranges.id (para cartas con ataque)             |
| attack_subtype_id  | ?int    | FK → attack_subtypes.id (para cartas con ataque)           |
| hero_ability_id    | ?int    | FK → hero_abilities.id (si la carta activa una habilidad)  |
| attack_type        | ?string | Tipo de ataque ("physical", "magical", null)               |
| hands              | ?int    | Manos requeridas (para Equipos arma: 1 o 2)                |
| cost               | string  | Coste en dados de color (ej: "RG", "BBB", "RRR")          |
| parsed_cost        | object  | Coste desglosado: {red: int, green: int, blue: int}        |
| total_cost         | int     | Coste total (suma de dados)                                |
| effect             | string  | Efecto de la carta (HTML)                                  |
| restriction        | string  | Restricciones de uso (texto, puede estar vacio)            |
| area               | bool    | Si el efecto es en area                                    |
| is_unique          | bool    | Si la carta es unica (max 1 copia en mazo)                 |
| image_url          | ?string | URL de la ilustracion de la carta                          |
| preview_image_url  | ?string | URL de la preview renderizada (en el idioma del locale)    |

**Sistema de costes:**
Los costes usan letras que representan colores de dados:
- `R` = Rojo (dados rojos)
- `G` = Verde (dados verdes)
- `B` = Azul (dados azules)

Ejemplo: `"RG"` = 1 dado rojo + 1 dado verde (total_cost: 2)

---

### GET /hero-abilities

Lista todas las habilidades de heroes.

| Campo            | Tipo    | Descripcion                                         |
|------------------|---------|-----------------------------------------------------|
| id               | int     | ID unico                                            |
| name             | string  | Nombre de la habilidad                              |
| description      | string  | Descripcion del efecto (HTML)                       |
| attack_type      | ?string | "physical", "magical" o null (si no es ataque)      |
| attack_range_id  | ?int    | FK → attack_ranges.id                               |
| attack_subtype_id| ?int    | FK → attack_subtypes.id                             |
| area             | bool    | Si afecta en area                                   |
| cost             | string  | Coste en dados (ej: "RR", "G")                     |
| parsed_cost      | object  | Coste desglosado: {red, green, blue}                |
| total_cost       | int     | Coste total                                         |

---

### GET /card-types

Tipos de carta disponibles.

| Campo              | Tipo | Descripcion                                     |
|--------------------|------|-------------------------------------------------|
| id                 | int  | ID unico                                        |
| name               | str  | Nombre del tipo                                 |
| hero_superclass_id | ?int | FK → hero_superclasses.id (que superclase lo usa) |

**Tipos actuales:**

| id | Nombre   | Superclase asociada                          |
|----|----------|----------------------------------------------|
| 1  | Equipo   | null (todas las superclases)                 |
| 2  | Apoyo    | null (todas las superclases)                 |
| 4  | Tecnica  | Marcial (id:1)                               |
| 5  | Hechizo  | Mistico (id:2)                               |
| 6  | Letania  | Devoto (id:3)                                |

---

### GET /card-subtypes

Subtipos de carta (especializacion dentro de un tipo).

| Campo | Tipo | Descripcion      |
|-------|------|------------------|
| id    | int  | ID unico         |
| name  | str  | Nombre           |

**Subtipos actuales:**
Asalto, Tactica, Subterfugio, Baluarte, Presion, Arcano, Elemental, Ilusion, Rezo, Oracion, Punicion, Penitencia

---

### GET /hero-classes

Clases de heroe (especializacion de combate).

| Campo              | Tipo   | Descripcion                                   |
|--------------------|--------|-----------------------------------------------|
| id                 | int    | ID unico                                      |
| name               | string | Nombre de la clase                             |
| passive            | string | Descripcion de la pasiva de clase (HTML)       |
| hero_superclass_id | int    | FK → hero_superclasses.id                      |

**Clases actuales:**

| Superclase | Clases                                                   |
|------------|----------------------------------------------------------|
| Marcial    | Vanguardia, Paragon, Hostigador, Acechador               |
| Mistico    | Arcanista, Elementalista, Ilusionista, Spellblade         |
| Devoto     | Adalid, Elegido, Fanatico, Inquisidor                     |

---

### GET /hero-races

Razas de heroes.

| Campo | Tipo | Descripcion      |
|-------|------|------------------|
| id    | int  | ID unico         |
| name  | str  | Nombre           |

**Razas actuales:** Humano (1), Elfo (2), Orco (3), Leonino (4)

---

### GET /equipment-types

Tipos de equipamiento.

| Campo    | Tipo   | Descripcion                        |
|----------|--------|------------------------------------|
| id       | int    | ID unico                           |
| name     | string | Nombre del tipo de equipo          |
| category | string | "weapon" o "armor"                 |

**Armas:** Espada, Hacha, Maza, Daga, Lanza, Escudo, Estandarte, Arco, Cetro, Baculo
**Armaduras:** Grevas, Peto, Guanteletes, Yelmo, Amuleto, Capa

---

### GET /attack-ranges

Alcances de ataque.

| Campo | Tipo | Descripcion      |
|-------|------|------------------|
| id    | int  | ID unico         |
| name  | str  | Nombre           |

**Alcances actuales:** Melee (1), A Distancia (3), Aura (4), Propio (5)

---

### GET /attack-subtypes

Subtipos de ataque (tipo de dano).

| Campo | Tipo | Descripcion      |
|-------|------|------------------|
| id    | int  | ID unico         |
| name  | str  | Nombre           |

**Subtipos actuales:**

| Categoria | Tipos                                          |
|-----------|-------------------------------------------------|
| Fisicos   | Cortante (1), Perforante (2), Contundente (3), Lacerante (4) |
| Magicos   | Fuego (5), Electricidad (6), Agua (7), Tierra (8), Aire (9), Luz (10), Oscuridad (11) |

---

### GET /counters

Lista los contadores publicados (buffs y debuffs que se colocan sobre heroes).

| Campo    | Tipo    | Descripcion                                    |
|----------|---------|------------------------------------------------|
| id       | int     | ID unico                                       |
| name     | string  | Nombre del contador                            |
| effect   | string  | Descripcion del efecto (HTML)                  |
| type     | string  | "boon" (beneficio) o "bane" (perjuicio)        |
| icon_url | ?string | URL del icono del contador (PNG)               |

**Contadores de beneficio (boon):**
- Exaltado — Preparar 1 dado mas
- Presteza — +2 en tirada de Iniciativa
- Inspirado — 1 repeticion mas al preparar dados
- Determinado — Guardar 1 dado obligatorio menos
- Vigorizado — Robar 1 carta si 3+ dados del mismo color
- Regeneracion — Curar 2 de vida al limpiar contadores
- Escurridizo — Intercambiar heroe con adyacente

**Contadores de perjuicio (bane):**
- Exhausto — Preparar 1 dado menos
- Entumecido — -2 en tirada de Iniciativa
- Aterrado — 1 repeticion menos al preparar dados
- Ofuscado — Guardar 1 dado obligatorio mas
- Debilitado — Descartar 1 carta si 3+ dados del mismo color
- Dolorido — Recibir 2 danos al limpiar contadores
- Aturdido — Rival puede intercambiar este heroe con adyacente

---

### GET /game-modes

Modos de juego con su configuracion de mazo.

| Campo              | Tipo    | Descripcion                     |
|--------------------|---------|---------------------------------|
| id                 | int     | ID unico                        |
| name               | string  | Nombre del modo                  |
| description        | string  | Descripcion (HTML)               |
| deck_configuration | object  | Configuracion del mazo           |

**deck_configuration:**
| Campo               | Tipo | Descripcion                          |
|---------------------|------|--------------------------------------|
| min_cards           | int  | Minimo de cartas en mazo             |
| max_cards           | int  | Maximo de cartas en mazo             |
| max_copies_per_card | int  | Copias maximas por carta             |
| required_heroes     | int  | Heroes requeridos en el equipo       |

**Modo actual:**
- **Clasico** (id:1) — 30-40 cartas, max 2 copias por carta, 5 heroes requeridos

---

### GET /faction-decks

Mazos predefinidos de faccion (mazos de inicio listos para jugar).

| Campo       | Tipo    | Descripcion                                    |
|-------------|---------|------------------------------------------------|
| id          | int     | ID unico                                       |
| name        | string  | Nombre del mazo                                |
| description | string  | Descripcion tematica (HTML)                    |
| game_mode_id| int     | FK → game_modes.id                             |
| faction_ids | int[]   | IDs de facciones del mazo                      |
| hero_ids    | int[]   | IDs de los 5 heroes del mazo                   |
| cards       | array   | Cartas: [{card_id, copies}]                    |
| icon_url    | ?string | URL de la imagen del mazo (JPEG)               |

**Mazos actuales:**

| Faccion                  | Mazos                                     |
|--------------------------|-------------------------------------------|
| Defensores de Terik      | Forja de Acero, Muro de Luz               |
| Guardabosques de Thenan  | Cuchillas de Tormenta, Hojas Danzantes    |
| Tribu Llama Furiosa      | Ceniza que Respira, Gritos en la Niebla   |

---

### GET /config/hero-attributes

Configuracion del sistema de atributos de heroes.

| Campo                | Tipo  | Descripcion                                |
|----------------------|-------|--------------------------------------------|
| min_attribute_value  | int   | Valor minimo por atributo (1)              |
| max_attribute_value  | int   | Valor maximo por atributo (5)              |
| min_total_attributes | int   | Minimo de la suma de atributos (12)        |
| max_total_attributes | int   | Maximo de la suma de atributos (18)        |
| agility_multiplier   | int   | Multiplicador de agilidad para vida (-1)   |
| mental_multiplier    | int   | Multiplicador de mental para vida (-1)     |
| will_multiplier      | int   | Multiplicador de voluntad para vida (0)    |
| strength_multiplier  | int   | Multiplicador de fuerza para vida (-1)     |
| armor_multiplier     | int   | Multiplicador de armadura para vida (0)    |
| total_health_base    | int   | Base de vida total (35)                    |

**Formula de vida:**
```
health = total_health_base
	   + (agility * agility_multiplier)
	   + (mental * mental_multiplier)
	   + (will * will_multiplier)
	   + (strength * strength_multiplier)
	   + (armor * armor_multiplier)
```

Ejemplo: Un heroe con AGI:3, MEN:2, VOL:2, FUE:4, ARM:3
```
health = 35 + (3*-1) + (2*-1) + (2*0) + (4*-1) + (3*0) = 35 - 3 - 2 - 4 = 26
```

---

## Relaciones entre entidades

```
factions ──────────┬──→ heroes (faction_id)
				   ├──→ cards (faction_id)
				   └──→ faction_decks (faction_ids[])

hero_superclasses ─┬──→ hero_classes (hero_superclass_id)
				   └──→ card_types (hero_superclass_id)

hero_races ────────→ heroes (hero_race_id)
hero_classes ──────→ heroes (hero_class_id)

card_types ────────→ cards (card_type_id)
card_subtypes ─────→ cards (card_subtype_id)
equipment_types ───→ cards (equipment_type_id)
attack_ranges ─────→ cards (attack_range_id), hero_abilities
attack_subtypes ───→ cards (attack_subtype_id), hero_abilities

hero_abilities ────→ heroes (abilities[]), cards (hero_ability_id)

game_modes ────────→ faction_decks (game_mode_id)
```

---

## Imagenes

Las imagenes se sirven desde `https://leyendas.espadasdeceniza.com/storage/`.

| Entidad       | Campo(s) de imagen                 | Formato    |
|---------------|-------------------------------------|-----------|
| Factions      | icon_url                            | JPEG      |
| Heroes        | image_url, preview_image_url        | PNG       |
| Cards         | image_url, preview_image_url        | PNG       |
| Counters      | icon_url                            | PNG       |
| Faction Decks | icon_url                            | JPEG      |

**Nota sobre preview_image_url:** La API devuelve directamente la URL de la preview
en el idioma solicitado via `?locale=`. No es un JSON multi-idioma, es una URL directa:
```
https://leyendas.espadasdeceniza.com/storage/images/previews/cards/es/alerta-preview.png
```

---

## Jerarquia del juego

### Superclases → Clases → Tipos de carta

| Superclase | Clases                                    | Cartas que usan            |
|------------|-------------------------------------------|----------------------------|
| Marcial    | Vanguardia, Paragon, Hostigador, Acechador| Tecnicas                   |
| Mistico    | Arcanista, Elementalista, Ilusionista, Spellblade | Hechizos            |
| Devoto     | Adalid, Elegido, Fanatico, Inquisidor     | Letanias                   |
| (todas)    | (todas)                                   | Equipos, Apoyos            |

### Facciones → Razas tipicas

| Faccion                  | Razas habituales    |
|--------------------------|---------------------|
| Defensores de Terik      | Humano, Leonino     |
| Guardabosques de Thenan  | Elfo                |
| Tribu Llama Furiosa      | Orco                |
