# Design System Documentation: The Hyperlocal Curator

## 1. Overview & Creative North Star
This design system is built upon the North Star of **"Soft Minimalism."** For a hyperlocal marketplace, the interface must feel like a trusted concierge—invisible when not needed, yet authoritative and premium when engaged. 

We move away from the "grid-of-boxes" template common in service apps. Instead, we embrace an editorial layout characterized by **intentional asymmetry, expansive negative space, and tonal depth.** By utilizing extreme corner radii and a "No-Line" philosophy, we create a digital environment that feels organic and tactile, rather than rigid and technical.

## 2. Colors: Tonal Architecture
The palette is rooted in a high-contrast relationship between a pure, clinical white and a high-energy electric blue. However, the "premium" feel is generated in the neutrals—the subtle shifts between surface tiers.

### The Color Tokens
- **Primary / Brand:** `primary` (#004ac6) and `primary_container` (#2563eb). Use the container for large interactive areas and the base primary for high-contrast text or icons.
- **Surface Foundations:** `surface` (#f7f9fb) and `surface_container_lowest` (#ffffff).
- **Accents:** `secondary_container` (#dee3ec) for passive background elements and `tertiary` (#943700) for high-alert or promotional "Editorial Sparks."

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to section content. 
Structure must be achieved through:
1.  **Background Shifts:** Placing a `surface_container_lowest` card on a `surface` background.
2.  **Vertical Space:** Using the spacing scale to create distinct groupings.
3.  **Tonal Transitions:** Moving from a `surface_container_low` section to a `surface_container_high` section to denote a change in context.

### Glass & Gradient Implementation
To move beyond a "flat" feel, use `surface_bright` with a 70% opacity and a 20px backdrop blur for floating navigation bars or sticky headers. For primary CTAs, apply a subtle linear gradient from `primary` to `primary_container` (top-left to bottom-right) to add a "liquid" depth that flat hex codes lack.

## 3. Typography: The Editorial Voice
We use a high-contrast pairing: **Plus Jakarta Sans** for expressive, editorial moments and **Inter** for functional, high-utility data.

- **Display & Headlines (Plus Jakarta Sans):** These are your "hooks." Use `display-lg` and `headline-lg` with tight tracking (-2%) to create a bold, confident presence. Layouts should often feature an oversized headline overlapping a soft-edged image.
- **Body & Labels (Inter):** For service descriptions and pricing. `body-md` is the workhorse. Ensure `line-height` is set to 1.5x for readability.
- **The Hierarchy Rule:** Never use two different font weights of the same size next to each other. Contrast should be achieved through scale (e.g., `headline-sm` next to `body-md`) or color (e.g., `on_surface` next to `on_surface_variant`).

## 4. Elevation & Depth: Tonal Layering
This system rejects traditional, muddy drop shadows. Instead, we utilize **Ambient Depth.**

### The Layering Principle
Depth is achieved by "stacking" the surface-container tiers. 
- **Level 0 (Base):** `surface`
- **Level 1 (Section):** `surface_container_low`
- **Level 2 (Interaction Card):** `surface_container_lowest` (Pure White)

### Ambient Shadows (Neumorphic-lite)
When an element must "float" (like a bottom-action sheet), use an 8dp blur shadow.
- **Shadow Color:** 6% opacity of `on_secondary_fixed_variant`.
- **Shadow Spread:** Large blur (16px to 24px) with 0 spread. This mimics natural light falling on a soft, matte surface.

### The "Ghost Border" Fallback
If a boundary is required for accessibility on a white background, use the `outline_variant` token at **15% opacity**. It should be felt, not seen.

## 5. Components

### Buttons
- **Primary:** Background `primary_container`, Text `on_primary`. Shape: `xl` (3rem/48px) radius. No border.
- **Secondary:** Background `secondary_container`, Text `on_secondary_fixed`. Shape: `xl`.
- **Tertiary/Ghost:** No background. Text `primary`. Use for low-emphasis actions like "View All."

### Cards (The Service Container)
- **Styling:** Use `surface_container_lowest` (White) with an `lg` (2rem) or `xl` (3rem) corner radius. 
- **Rule:** Never use dividers inside a card. Use `title-md` and `body-sm` typography to create separation. Use a `sm` (0.5rem) padding for inner elements to keep the "breathable" feel.

### Input Fields
- **Styling:** Use `surface_container_low` as the field background. Shape: `md` (1.5rem) radius.
- **States:** On focus, transition the background to `surface_container_lowest` and add a 1px "Ghost Border" using the `primary` color at 30% opacity.

### Chips (Service Categories)
- **Styling:** Pill-shaped (`full` radius). 
- **Inactive:** `surface_container_high` background.
- **Active:** `primary_container` background with `on_primary` text.

## 6. Do's and Don'ts

### Do:
- **Use "Aggressive" Rounding:** Use the `xl` (3rem) radius for main containers. It communicates safety and friendliness.
- **Embrace Asymmetry:** Place a `display-md` headline on the left with a floating `surface_container_lowest` card partially overlapping a hero image on the right.
- **Prioritize Breathing Room:** If a layout feels "busy," double the vertical padding between sections.

### Don't:
- **Don't use #000000:** Always use `on_surface` (#191c1e) for text to maintain a premium, soft-black look.
- **Don't use Dividers:** Never use a horizontal line to separate list items. Use a 4px-8px vertical gap and a slight shift in background tone instead.
- **Don't use Standard Shadows:** Avoid CSS defaults. Always tint your shadows with the primary or secondary blue hues to keep the "Electric Blue" energy alive even in the dark tones.