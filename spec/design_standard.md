---
title: Semantic HTML & Typography Standards
author: Nikolay Voynov
date: 2026-07-14
description: Architectural Constraints 
---

This document establishes the universal semantic markup constraints, document outline guidelines, and cryptographic layout rules required to build high-end, responsive digital publishing platforms. These standards guarantee data isolation, clean readability, accessibility (a11y), and reliable SEO token processing.

# 1. Document Outline Constraints

To secure a clean, valid Document Object Model (DOM) outline for screen readers and machine search crawlers, every layout tree must enforce strict structural encapsulation.

```
┌────────────────────────────────────────────────────────┐
│ <header class="global-header">                         │
│   <div class="site-branding">Brand/Author</div>        │
└────────────────────────────────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│ <main id="main-content">                               │
│   <h1>Contextual Primary Title</h1>                    │
│   <h2>Section Subheading</h2>                          │
└────────────────────────────────────────────────────────┘
```

## The Shared Global Branding Rule

- **Constraint**: The overarching site identity or global branding block inside the universal <header> framework must never utilize heading tags (<h1> through <h6>).
- **Implementation**: It must be wrapped in a non-heading structural block element (e.g., <div class="site-branding"> or <span class="logo-text">).
- **Rationale**: Header tags signify page-specific contextual importance. Placing static header tags in a global navigation shell pollutes the semantic nesting index of every single deep page across the platform routing graph.

## The Single Primary Viewport Rule

- **Constraint**: Every isolated document body must contain exactly one primary <h1> element nested strictly inside the main content container.
- **Implementation**: The <h1> must act as the unique thematic declaration of the active view (e.g., article title, configuration index header, or discrete view category).
- **Rationale**: The <h1> represents the root document declaration. Multiple instances break the clean heading hierarchy outline.

# 2. Document Tree Linear Flow

Headings must maintain a logical, unbroken descending path throughout the document tree. Jumping or skipping heading levels to achieve visual styling side-effects is an architectural violation.

## Structural Flow Rules

- **Sequential Degradation**: An <h2> can only be introduced if an <h1> already exists. An <h3> requires an active <h2> parent block.
- **Prohibited Nesting Steps**: Skipping levels (e.g., <h1> immediately followed by an <h3>) breaks accessibility flow and screen-reader indexing.
- **Typographic Separation**: Visual formatting parameters (font size, weight, tracking) must be completely decoupled from semantic tag levels. If a smaller subtitle is required at the document root, it must be styled via explicit CSS utility classes rather than shifting the semantic heading level.

## Spatial Affinity Constraint

- **Heading-to-Text Proximity**: Headings must visually belong to the content blocks they introduce.
- **Implementation**: The top margin of a subheading should always be significantly larger than its bottom margin (margin-top > margin-bottom). This locks the heading block to its succeeding paragraphs and prevents visual floating anomalies between distinct content sections.

# 3. Layout Scoping & Style Isolation Constraints

To prevent global typography pollution and layout collapse when running automated third-party processors (such as Pandoc, CommonMark, or headless CMS feeds), themes must maintain strict data container scoping.

```css
/* Forbidden Architecture: Alters third-party engine output universally */
p { font-size: 1rem; line-height: 1.6; }

/* Constrained Architecture: Strictly isolated context */
.narrative-editorial-container p { font-size: 0.95rem; line-height: 1.8; }
.informational-utility-container p { font-size: 0.875rem; line-height: 1.6; }
```

- **Constraint**: Global HTML base tag styling for text blocks (p, ul, li, h2) must be minimal or limited to a universal baseline reset.
- **Downstream Selector Scoping**: Distinct functional layouts (e.g., spacious narrative columns vs. dense metadata blocks) must encapsulate their rules downstream from explicit parent container classes.
- **Rationale**: Prevents unexpected text collision and sizing corruption across different structural layout modules.

# 4. Typography Scale & Fluid Unit Constraints

Platform layouts must scale mathematically relative to a single root font anchor. Hardcoded pixel tracking (px) for responsive font sheets is strictly prohibited.

## Core Unit Enforcement

- **The Root Anchor Rule**: The core layout must assume a deterministic pixel root baseline: html { font-size: 16px; }. No nested styling layer may modify this absolute metric outside of explicit responsive break gates.
- **The Rem Standard**: All text dimensions (font-size), horizontal gaps (gap), content padding, and modular whitespace parameters must be declared using relative Root Em (rem) units.
- **Fluid Interline Spacing**: Line heights (line-height) must be expressed as unitless multiplier ratios (e.g., 1.6, 1.8) to ensure line tracking expands and shrinks proportionally when font sizes change.
- **Rationale**: Guarantees consistent typography rendering across screen sizes and protects layout integrity during hardware zooming or native system text adjustments.

# 5. Media Grid Native Structural Constraints

Markup engines often wrap asset nodes (such as inline images or graphic fragments) inside standard paragraph tags (<p>) during automated token compilation. This behavior disrupts flexbox or grid parent alignment logic.

```css
/* Structural Media Integration Pattern */
.editorial-media-grid p {
  display: contents; 
}
```

- **Constraint**: When injecting media components inside explicit parent layout matrices (display: grid or display: flex), the stylesheet must mitigate implicit paragraph wrappers.
- **Implementation**: Use the CSS rule display: contents; on text wrappers enveloping raw layout media elements.
- **Rationale**: This parameter strips the physical layout dimensions of the intermediary paragraph shell without deleting its child elements, allowing raw media assets to align directly with the parent design framework.
