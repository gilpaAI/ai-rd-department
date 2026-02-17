---
name: inventure-redesign
description: Modern Japanese-inspired redesign of in-venture.com
status: backlog
created: 2026-02-17T14:19:57Z
updated: 2026-02-17T14:19:57Z
---

# IN Venture Website Redesign

## Overview

Redesign the IN Venture venture capital website (in-venture.com) as a modern, static multi-page site with a Japanese-inspired brand aesthetic. The site preserves all original content and data while delivering a premium, contemporary visual experience.

## Problem Statement

The current in-venture.com site is functional but visually dated. It doesn't fully leverage the firm's unique Japan-Israel identity (Sumitomo Corporation backing). A redesign with intentional Japanese design language would strengthen brand differentiation and create a more memorable impression for founders and LPs visiting the site.

## Target Users

- **Startup founders** evaluating IN Venture as a potential investor
- **Limited Partners (LPs)** reviewing the firm's portfolio and team
- **Sumitomo Corporation stakeholders** seeing the venture arm's public presence
- **Prospective team members** researching the firm

## Success Criteria

1. Demo site renders correctly in modern browsers (Chrome, Firefox, Safari, Edge)
2. All original content is preserved — no data loss
3. Japanese-inspired aesthetic is clearly visible (not just a generic modern template)
4. Responsive design works on desktop and mobile
5. Gil approves the demo for potential live deployment

## Scope

### In Scope

**5 pages matching original site structure:**

1. **Home** — Hero section with tagline, firm overview, key value props
2. **Team** — 5 team members with photos, names, titles, bios, and role categories (Managing Partners, Venture Partner, Advisory Board)
3. **Portfolio** — 15 companies (12 active, 3 acquired) with names, descriptions, sectors, and active/acquired status
4. **Value Creation** — Sumitomo partnership model, global market access, commercial validation, resource access
5. **Contact** — Tel Aviv office address, email, social links (LinkedIn, Twitter)

**Design direction:**
- Japanese minimalism: generous whitespace, clean typography, subtle grid systems
- Wabi-sabi texture elements (paper grain, soft shadows, natural materials feel)
- Japanese typography accents (e.g., section headers with Japanese characters as decorative elements)
- Color palette: deep indigo/navy, warm whites, accent gold or vermillion
- Smooth scroll transitions between sections
- Subtle micro-animations on hover/scroll

### Out of Scope

- CMS or backend functionality
- Working contact form submission
- Japanese language translation
- SEO optimization
- Analytics integration
- Blog/news section
- Individual team member detail pages
- Individual portfolio company detail pages

## Content Data

### Team Members

| Name | Role | Category |
|------|------|----------|
| Eitan Naor | Managing Partner | Managing Partners |
| Eyal Rosner | Managing Partner | Managing Partners |
| Gil Paz | Venture Partner | Venture Partners |
| Toshikazu Nambu | Advisory Board | Advisory Board |
| Yair Cohen | Advisory Board | Advisory Board |

### Portfolio Companies (Active)

| Company | Description | Sector |
|---------|-------------|--------|
| Alta | Operating system for AI driven revenue workforce | AI/Enterprise |
| Onfire | Transform intent data into revenue opportunities | Sales/AI |
| Cypago | Visualize, Automate, And Manage Cyber GRC | Cybersecurity |
| Litebc | Blood analysis for the 21st Century | Healthcare/Biotech |
| PORT0 | Seamless micro-segmentation | Cybersecurity |
| CardinalOps | Detect the threats that matter most | Cybersecurity |
| Faireez | Residential Lifestyle Platform | Real Estate/Lifestyle |
| Confetti | Corporate Team Building Platform | HR/Enterprise |
| BRIA | Visual Content Creation via Generative AI | AI/Creative |
| Classiq | Quantum Algorithm Design | Quantum Computing |
| Ottopia | Remote Operation of Vehicles | Autonomous Tech |
| H2Pro | Hydrogen Fuel Production | Clean Energy |

### Portfolio Companies (Acquired)

| Company | Description | Sector |
|---------|-------------|--------|
| GK8 | Safeguarding Digital Assets | Cybersecurity/Blockchain |
| Anagog | Personalized and Private Consumer Engagement | Data/Analytics |
| Genoox | Translates Genetic Data into Clinical Results | Genomics/Healthcare |

### Contact Information

- **Address:** 94 Yigal Alon, Alon Tower 2, Floor 26, Tel Aviv, Israel 6789156
- **Email:** contact@in-venture.com
- **LinkedIn:** https://www.linkedin.com/company/in-venture-sc/about/
- **Twitter:** https://twitter.com/INVenture12

### Key Messaging

- Main tagline: "We partner with ambitious entrepreneurs disrupting large markets, leveraging global presence powered by Sumitomo Corporation"
- Team description: "Combines the access of insiders in the Israeli high-tech ecosystem and in Sumitomo Corporation, drawing off decades of experience in investment, technology and business development"
- Value creation: "An engaged corporate partner can significantly accelerate growth"
- Sumitomo access: "Thousand subsidiary and corporate affiliates" across global markets

## Technical Approach

- **Delivery:** Static HTML + CSS (+ minimal JS for interactions)
- **Single directory** with index.html and page files, CSS, and assets
- **No build tools required** — opens directly in browser
- **Responsive:** Mobile-first CSS with breakpoints for tablet and desktop
- **Images:** Placeholder approach for team photos (CSS-styled initials or geometric avatars)

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Japanese aesthetic feels like a stereotype | Medium | High | Use subtle, authentic design principles — not cherry blossoms and temples |
| Content gaps (missing bios, detailed descriptions) | Low | Low | Use available data, leave clean placeholders |
| Demo doesn't convey "live site" quality | Medium | Medium | Focus on polish — typography, spacing, transitions |
