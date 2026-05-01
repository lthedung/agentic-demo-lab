# Coffee Landing Page Design

## Goal

Build a single-page Next.js landing page using Tailwind CSS to introduce a premium coffee brand inspired by the Starbucks-style design reference in `DESIGN.md`.

## Visual Direction

Use a warm premium coffee aesthetic with deep green, cream, off-white, and restrained gold accents. The page should feel polished, friendly, and brand-forward rather than purely sales-focused.

## Architecture

Create a Next.js App Router application in the current repository with Tailwind CSS enabled. The landing page will be componentized so each section is easy to understand and modify independently.

Primary structure:

- `app/page.tsx` renders the landing page.
- `app/globals.css` holds global Tailwind styles and base colors if needed.
- `components/` contains focused landing page sections.

## Page Sections

### Hero

Use a split premium hero layout. The left side contains the main headline, short supporting copy, and CTA. The right side uses a coffee cup/product visual treatment created with CSS or simple layout elements.

Suggested copy:

- Headline: “Cà phê rang mới mỗi ngày”
- Supporting text: “Hương vị đậm đà từ những hạt cà phê được chọn lọc và rang thủ công.”
- CTA: “Khám phá menu”

### Brand Story

Introduce the coffee experience and brand promise: selected beans, careful roasting, and warm café moments.

### Featured Products

Show three product cards:

- Arabica Selection
- Espresso Blend
- Cold Brew

Each card includes a short description and flavor notes.

### Brew Process

Show three simple steps:

1. Chọn hạt
2. Rang thủ công
3. Pha chuẩn vị

### Final CTA

End with a strong invitation to discover the coffee menu or start a morning ritual.

## Data Flow

No backend or API is required. Product and process content can live as arrays in the page or a nearby component file for simple editing.

## Accessibility

Use semantic sections, readable contrast, accessible button/link labels, and responsive layout for mobile and desktop.

## Verification

After implementation:

- Run the available lint/build command from the generated Next.js project.
- Start the dev server.
- Inspect the page in browser on desktop and mobile widths.
- Check that there are no visible runtime or console errors.
