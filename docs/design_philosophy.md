# Design Philosophy: Minimalist & Adaptive

This document outlines the design philosophy for Silo Night. It is intended to guide developers and automated agents in maintaining a consistent, functional, and aesthetically pleasing user interface that scales across all device types.

## Core Objective
The fundamental goal of Silo Night's design is to **simplify the interface by removing unnecessary elements or content that does not directly support the user's task of managing their show schedule.** Every element must serve a clear, functional purpose.

## I. Minimalist Characteristics
Based on industry standards (Nielsen Norman Group), our design adheres to the following "Big Five" characteristics:

### 1. Flat Patterns and Textures
*   **Principle:** Avoid skeuomorphic elements like heavy shadows, 3D gradients, or lifelike textures.
*   **Implementation:** Use "Flat 2.0"—clean, digital-first representations with subtle visual cues (like slight color shifts on hover) to indicate interactivity.

### 2. Limited & Strategic Color Palette
*   **Principle:** Use a primarily monochromatic or grayscale palette (white, black, gray) with a single, bold accent color.
*   **Implementation:** Use the accent color exclusively for primary actions (e.g., "Add Show," "Save Schedule") and critical information. Color is a functional tool, not a decorative one.

### 3. Restricted Features and Elements
*   **Principle:** "Subtract it until it breaks."
*   **Implementation:** Eliminate gratuitous graphics, unnecessary borders, and redundant menu items. If removing an element doesn't hinder the user journey, remove it.

### 4. Maximized Negative Space
*   **Principle:** Use "white space" as a structural component.
*   **Implementation:** Surround core content (like the daily schedule) with ample empty space to reduce cognitive load and direct the eye toward the most important information.

### 5. Dramatic Typography
*   **Principle:** Typography replaces graphics as the primary vehicle for hierarchy.
*   **Implementation:** Use variations in font size, weight (bold vs. light), and style to communicate importance. Headlines should be clear and high-contrast.

## II. Adaptability & Responsiveness
Silo Night must be equally usable on a mobile phone as it is on a large desktop display.

### Mobile-First Approach
*   **Touch Targets:** Interactive elements must be large enough for reliable touch input (minimum 44x44px).
*   **Vertical Flow:** On small screens, the schedule should stack vertically for easy scrolling.
*   **Hidden Navigation:** Use overlays or "hamburger" menus on mobile to preserve screen real estate for the schedule content.

### Desktop Optimization
*   **Grid Layouts:** On larger displays, utilize the extra width to show the full weekly schedule side-by-side.
*   **Visual Scaffolding:** Use the grid to organize homogeneous content without adding extra visual "noise" like heavy lines or boxes.
*   **Hover States:** Leverage hover effects to provide additional context without cluttering the initial view.

## III. Implementation Guidelines for Coding Agents
When modifying templates (`template/*.slim`) or stylesheets (`public/stylesheets/*.css`), follow these rules:

1.  **Check Usability First:** Never sacrifice a functional feature for a "cleaner" look. If a button is necessary for a task, it stays.
2.  **Verify Clickability:** Ensure that interactive elements (buttons, links) are easily recognizable as such, even in a flat design.
3.  **Performance Priority:** Minimalism extends to technical efficiency. Minimize large assets and complex CSS selectors to ensure fast load times.
4.  **Consistency:** Match the existing typography and spacing found in `default.css`. Do not introduce new font families or divergent color schemes without explicit instruction.
5.  **Intentionality:** Before adding a new UI element, ask: "Does this support the core user task?" If the answer is not a definitive "yes," find a way to achieve the goal using existing elements.

## IV. References
*   [NN/g: Characteristics of Minimalism in Web Design](https://www.nngroup.com/articles/characteristics-minimalism/)
*   [Silo Night User Journey](./user_journey.md)
