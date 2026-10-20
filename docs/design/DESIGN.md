---
name: AutoPulse Automotive Intelligence
colors:
  surface: '#0B0F17'
  surface-dim: '#070A0F'
  surface-bright: '#141A23'
  surface-container-lowest: '#05070B'
  surface-container-low: '#0E131C'
  surface-container: '#141A23'
  surface-container-high: '#1A2230'
  surface-container-highest: '#222C3D'
  on-surface: '#F1F5F9'
  on-surface-variant: '#94A3B8'
  inverse-surface: '#F8FAFC'
  inverse-on-surface: '#0F172A'
  outline: '#334155'
  outline-variant: '#1E293B'
  surface-tint: '#00E5FF'
  primary: '#00E5FF'
  on-primary: '#00363D'
  primary-container: '#004F58'
  on-primary-container: '#97F0FF'
  inverse-primary: '#006874'
  secondary: '#38BDF8'
  on-secondary: '#082F49'
  secondary-container: '#075985'
  on-secondary-container: '#BAE6FD'
  tertiary: '#A78BFA'
  on-tertiary: '#2E1065'
  tertiary-container: '#4C1D95'
  on-tertiary-container: '#DDD6FE'
  error: '#EF4444'
  on-error: '#FFFFFF'
  error-container: '#7F1D1D'
  on-error-container: '#FECACA'
  background: '#0B0F17'
  on-background: '#F1F5F9'
  surface-variant: '#1E293B'
typography:
  display-lg:
    fontFamily: Outfit
    fontSize: 44px
    fontWeight: '700'
    lineHeight: 52px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Outfit
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.01em
  headline-xl:
    fontFamily: Outfit
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.015em
  headline-lg:
    fontFamily: Outfit
    fontSize: 26px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Outfit
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 26px
  headline-sm:
    fontFamily: Outfit
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Outfit
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.04em
  numeric-stat:
    fontFamily: Outfit
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 42px
rounded:
  sm: 0.375rem
  DEFAULT: 0.75rem
  md: 1rem
  lg: 1.25rem
  xl: 1.75rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## 1. Visual Theme & Atmosphere
AutoPulse is a high-conviction, calm automotive intelligence system. It merges clinical telemetry with modern consumer luxury.
The atmosphere is purposeful, cockpit-dense yet uncluttered. Large, glanceable numbers allow safe reading while the mobile device is in a car windshield mount.
The dark theme relies on Deep Graphite (`#0B0F17`) with crisp hairline borders (`#1E293B`) and an Electric Cyan Pulse (`#00E5FF`).
The light theme transforms into a pure, daylight-optimized Alabaster canvas (`#F8FAFC`) with crisp Charcoal Ink typography (`#0F172A`) and deep Aegean Cyan accents (`#00838F`).

## 2. Color Palette & Functional Roles
- **Electric Cyan Pulse (`#00E5FF` Dark / `#00838F` Light)**: The signature heartbeat accent. Signifies active Bluetooth connection, primary CTAs, and active telemetry streams.
- **Deep Graphite (`#0B0F17`)**: Root canvas for Dark Theme. Prevents OLED glare during night driving.
- **Cockpit Card Surface (`#141A23` Dark / `#FFFFFF` Light)**: Elevated surface for prediction cards and telemetry readouts.
- **Hairline Border (`#1E293B` Dark / `#E2E8F0` Light)**: 1px structural framing.
- **High-Contrast Text (`#F1F5F9` Dark / `#0F172A` Light)**: Primary readability ink.
- **Subdued Text (`#94A3B8` Dark / `#64748B` Light)**: Secondary descriptions and metadata.
- **Status Colors (WCAG AA Compliant)**:
  - **Healthy / Optimal**: `#10B981` (Emerald)
  - **Watch / Trend Drift**: `#F59E0B` (Amber)
  - **Warning / Fault Expected**: `#F97316` (Warm Orange)
  - **Critical Failure Imminent**: `#EF4444` (Crimson)

## 3. Typographic Architecture
- **Display & Headings**: `Outfit` — Geometric, confident, high legibility.
- **Body & Controls**: `Inter` — Dense, precise x-height, comfortable leading.
- **Telemetry & Time Figures**: Monospaced tabular numerals (`Outfit` with tabular figures or `JetBrains Mono`) so live gauges do not jitter during updates.

## 4. Component Stylings
- **Overall Health Ring**: A prominent 160px circular gauge with dynamic stroke gradient mapping from Emerald (100-80) to Amber (79-60) to Orange (59-40) to Crimson (<40). Centered health score with trend indicator.
- **Urgent Forecast Hero Card**: Highest priority card. Features days-to-failure countdown pill ("Battery fails in ~9 days"), component icon, confidence badge, and immediate "Book Service" CTA.
- **Live Telemetry Sparklines**: Mini real-time graphs for RPM, Speed, Coolant Temp, and Battery Voltage with subtle gradient fill below line.
- **Component Status Grid**: 2-column asymmetric cards displaying Component Name, Health Bar, Status Badge, and Failure Days Forecast.
- **Service Booking Slots**: Interactive date pills and time chips with clear selection state and garage distance tags (e.g., "Bosch Car Service • 2.4 km").

## 5. Layout & In-Car Ergonomics
- Minimum touch target is 48px for one-handed operation.
- Primary CTA buttons anchored to bottom sheet / safe area for thumb ergonomics.
- Responsive fleet dashboard for tablet/web with split-pane risk sorting.

## 6. Motion Philosophy
- Spring physics for transitions (`stiffness: 120, damping: 18`).
- Smooth interpolation on live sensor updates (300ms tweening) to eliminate jitter.
- Tactile haptic feedback on button presses and fault alerts.
- Respects `prefers-reduced-motion` by replacing continuous gauges with instant state snapshots.

## 7. Anti-Patterns (Banned)
- No generic AI purple gradients or neon button glow slop.
- No cluttered 10-widget dashboards with tiny unreadable text.
- No pure `#000000` black or washed-out gray text.
- No round placeholder numbers (e.g. "99.9%"). Every value reflects realistic OBD-II PIDs.
- No emojis as iconography — use clean SVG monoline automotive symbols.
