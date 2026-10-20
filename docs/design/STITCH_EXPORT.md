# AutoPulse — Google Stitch Screen Exports & Design Tokens

AutoPulse UI designs generated using **Google Stitch** via the Stitch MCP with our custom semantic `DESIGN.md` design system (`assets/dfed04bc3f334527883033a5184ff1da`) in Project `14346551546531553546`.

---

## 1. Generated Stitch Screens

### A. Home Dashboard / Car Health (Dark Cockpit Theme)
- **Screen ID**: `e4391ffcdd704c06af50b12e061a144e`
- **Device Type**: Mobile (390 x 844 / 780 x 2488 pt)
- **Screenshot Asset**: [Stitch Preview URL](https://lh3.googleusercontent.com/aida/AEtjO1UsrEADANWjCURTIFjG4Uxm708aRS6L6znimGTqqeqUmyB6Bvf8o31mWV0n7LP7kCiUemSfpgsmvDsSGhZCruYFIWdDoYo-TYfgP1yZSzN4IQonz0G9PngFbUBvPYeGhSmeW7ZQpZSQqH5JSoFjUwJh_QTwvKRUccZEETbcJs1rZfwd7DlCpA3djFRcVcfBwV4_frZX_i0tsArqCfWThodA3cQPZhWF_JeZkCVZ3M31zsxNXGBYKSNyLoE8)
- **Core Elements**:
  - Live OBD-II online pulsing indicator.
  - Car info badge: Maruti Swift 2016 (64,280 km).
  - Circular overall health ring showing score 68/100 (Amber).
  - Urgent forecast hero card: "Battery fails in ~9 days" (91% confidence, 0.6V idle drop over 12 days) with primary "Book Service" CTA.
  - Subsystem chips: Alternator (88%), Cooling (79%), O2 Sensor (82%), Spark Plugs (74%).
  - Bottom navigation bar: Health, Live OBD, Alerts, Fleet, Settings.

---

### B. Home Dashboard (Light Daylight Theme)
- **Screen ID**: `d53fc4c4952d46adb35a11d371d6be30`
- **Device Type**: Mobile
- **Screenshot Asset**: [Stitch Preview URL](https://lh3.googleusercontent.com/aida/AEtjO1VIytGIy3ds8_UAUDIzlysroMWbhDB1YeDuXDQvDLqdumlABvkbP4x_VX4iFcliQ5KwQN4b94Lcl7nYw70SUVa0Knf-0QmfwftkMfo3ypupZXPbCt6GdS8mfCQhvhY5wEpTn4Dl7sfBveSwT4pYmDREp7PPfrJY73ksAWPCmZVyPDo11Go_8uTB2E0vnQ524IYswuR6CM_zBEicjY8oJbekgrc-fDy1AnAWYdb9wp4vwe-pJlbBAdt0InGR)
- **Core Elements**:
  - Alabaster canvas (`#F8FAFC`) with crisp pure white cards (`#FFFFFF`) and hairline borders (`#E2E8F0`).
  - Charcoal ink typography (`#0F172A`) for glare-free daytime reading on windshield mount.
  - Aegean cyan accent (`#00838F`) for primary actions.

---

### C. Live OBD-II Telemetry Stream (Dark Theme)
- **Screen ID**: `abcdd44b1bf44fd191ae2e295b185a76`
- **Device Type**: Mobile
- **Screenshot Asset**: [Stitch Preview URL](https://lh3.googleusercontent.com/aida/AEtjO1XzLOhzA44JUvDk6q_Qir1sbt82_iDixWYtqlH2xCC50mTiqmH0-6AhwXKEOycDgGi9XWLLxpa4prIEI5UQfDSS_i63lsQ4uQfsdP9olCB_zgg-StXeRxTwXzgZ5nSo14OsVnr1cwRT5RvvXuoZuRg7B-f08vhJgpz-DoCnJwj6v-Fu4XRj7BSYDKg3tOEmUyk-V6XTDS4L48B-Y1uExDUVoOhprMXW1ViWz-zAoFnaUdy0od_u--yZBWvx)
- **Core Elements**:
  - Dual prominent digital gauges: Engine RPM (780 RPM idle) and Speed (0 km/h).
  - Live sparklines: Battery Voltage (11.8V with crank dip wave), Coolant Temp (92°C with optimal band 85-95°C), Engine Load (22%), Intake Air Temp (34°C), MAF (2.4 g/s), O2 sensor voltage (0.45V sine wave).
  - Diagnostic actions: "Freeze-Frame Snapshot" and "Log CSV Session".

---

### D. Component Diagnostic & Prediction Detail (Battery)
- **Screen ID**: `500b23572c17429eba97125b27d64adb`
- **Device Type**: Mobile
- **Screenshot Asset**: [Stitch Preview URL](https://lh3.googleusercontent.com/aida/AEtjO1UoESupfW08_ekLEuu_tl0ecAHB0OTqGJNmNWwCYgpEytTj7tWBuk8VDPTweppxtSbD2w2fh1PBnegVsm16xX4OOqYJjTQMHRTQUdzCdFMgauPh_LhofhkXzmi62gIcPMC1-CBIoN9GQRT8XBBqB6qLWIIWMmhU3oSFm3eVWjJ31Jh_oAJBu51qzJfIhcljdPdJ3eblSR6nXPdK05TiCKcsvTWdGSG_p1N0xspsr3DR4MGqT0yW_LglDVQ)
- **Core Elements**:
  - 54/100 Health Score with "Estimated Failure in ~9 Days" (Confidence: 91% ±2 days).
  - 30-Day Health trajectory timeline chart showing degradation from 95% down to 54% with projected failure line at Day 39.
  - "Why AutoPulse Predicted This" causal diagnosis:
    1. Cranking voltage dip to 9.2V.
    2. Idle resting voltage decayed by 0.6V across 12 days.
    3. Internal cell resistance increased +38%.
  - Cost comparison card: **₹4,500 Saved** (₹3,200 planned swap vs ₹7,700 highway emergency breakdown & towing).
  - Primary CTA: "Book Battery Service at Partner Garage" with partner "Bosch Car Service • 2.4 km".

---

### E. Fleet Intelligence — Garage & Dealer Dashboard
- **Screen ID**: `017d2d164e0b411f8b6b57eecdbb2c6e`
- **Device Type**: Tablet / Desktop Responsive (2560 x 2346 pt)
- **Screenshot Asset**: [Stitch Preview URL](https://lh3.googleusercontent.com/aida/AEtjO1VeDtmFnAZgZzfH7X6zKo26ur0JGCPgo57pG_KdJ9VvsVBobh2xcvHMYWvuvdZXNRIEglVKObWWLO7NSVTMB9H3vYsX7tbVxjVXtHh2XVCFF_mq5wJ39V-pHA5ComIiuATI8B9ZyRK5ViT28p005bCoVkvIRLlZcwAJtTu6HUotY11eVRpUpi_IHxLf8chDVgnsxZ6FZ1vOq92gwNoyhirVcD9x1WLwObaNGViqh0_seKh0Oi_fPBLl4-g)
- **Core Elements**:
  - Top summary stats: Critical Failure Imminent (3 cars), Potential Breakdowns Prevented (14), Estimated Customer Savings (₹68,500), Active Fleet Health Average (81%).
  - Risk-sorted fleet table: Swift (54 - Battery ~9d), i20 (61 - Coolant creep), City (65 - O2 drift), Nexon (72 - Spark plug jitter), XUV500 (94 - Healthy).
  - Right-side live inspection drawer for active vehicle.

---

## 2. Design Tokens Export (For Flutter Implementation)

```dart
// AutoPulse Design System Tokens (Generated from Stitch DESIGN.md)

import 'package:flutter/material.dart';

abstract class AutoPulseColors {
  // Dark Palette (Cockpit In-Car)
  static const darkBackground = Color(0xFF0B0F17);
  static const darkSurface = Color(0xFF141A23);
  static const darkSurfaceElevated = Color(0xFF1A2230);
  static const darkBorder = Color(0xFF1E293B);
  static const darkTextPrimary = Color(0xFFF1F5F9);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkAccent = Color(0xFF00E5FF); // Electric Cyan Pulse

  // Light Palette (Daylight Glare-Free)
  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceElevated = Color(0xFFF1F5F9);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);
  static const lightAccent = Color(0xFF00838F); // Aegean Cyan

  // Semantic Status Colors (WCAG AA)
  static const statusHealthy = Color(0xFF10B981); // Emerald
  static const statusWatch = Color(0xFFF59E0B);   // Amber
  static const statusWarning = Color(0xFFF97316); // Warm Orange
  static const statusCritical = Color(0xFFEF4444); // Crimson
}
```
