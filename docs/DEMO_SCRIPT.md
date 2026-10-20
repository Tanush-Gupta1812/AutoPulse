# AutoPulse — 3-Minute Demo Script & Pitch Walkthrough

> **Setting:** Demo Day / Investor & Judge Pitch  
> **Speaker:** Founder & Lead Product Engineer  
> **Target Audience:** Automotive Seed Investors, Mobility Judges, Partner Garage Owners  
> **Device:** iPhone / Android Phone running AutoPulse Flutter App (or Chrome desktop simulator)  
> **Total Time:** Exactly 3:00 Minutes

---

## ⏱️ Minute 0:00 – 0:45 | The Hook: Used Car Anxiety & The Smart Dongle

| Time | Visual / Screen Action | Voiceover / Script |
| :--- | :--- | :--- |
| **0:00** | Open app on **Onboarding Screen**. Dark cockpit aesthetic with Electric Cyan glow (`#00E5FF`). | *"In India, over 4.5 million used cars change hands every year. But for owners of 3 to 10-year-old Swifts, i20s, and Citys, every highway trip is shadowed by one fear: sudden breakdown."* |
| **0:15** | Swipe through the 3 pitch cards: <br>1. *Predictive AI*<br>2. *₹999 Dongle + ₹999/yr*<br>3. *Trusted Garage Network* | *"Traditional OBD-II scanners on Amazon are dumb code-readers: they illuminate a check engine light only **after** your alternator burns out or your engine overheats, costing ₹15,000 to ₹40,000 in emergency towing and engine repairs."* |
| **0:30** | Tap **"Pair Your Dongle"**. Blue radar circle pulses with live signal waves. Tap **"AutoPulse-BLE-89F2"**. Instant haptic feedback & checkmark transition. | *"AutoPulse changes that paradigm. With our plug-and-play BLE dongle priced at just **₹999** and an annual subscription of **₹999/yr**, we turn any standard OBD-II port into an edge telemetry stream, feeding our predictive health engine."* |

---

## ⏱️ Minute 0:45 – 1:30 | The "Aha!" Moment: Days-in-Advance Prediction

| Time | Visual / Screen Action | Voiceover / Script |
| :--- | :--- | :--- |
| **0:45** | Transition into **Home Dashboard** (Swift VXi 2018, DL-08-CC-4421). Visual: 160px circular gauge with **Health Score: 64/100 (Amber Glow)**. | *"Here is the AutoPulse live cockpit for a 2018 Maruti Suzuki Swift with 78,000 km. Notice what stands out instantly:"* |
| **1:00** | Point to the **Urgent Hero Banner Card** styled in Warning Amber gradient: <br>**"Battery Failure in ~9 Days"**<br>*"Cranking voltage dropping 0.08V/day under thermal stress."* | *"We don't show cryptic error codes like 'P0562'. We give the driver plain, actionable foresight: **'Battery failure in ~9 days.'** We predict failures before you're stranded in monsoon traffic or a highway toll plaza."* |
| **1:15** | Scroll through the **Subsystem Chips**: <br>• Cooling: 82% (Normal)<br>• Spark Plugs: 71% (Fair)<br>• Alternator: 88% (Good)<br>• O2 Sensor: 91% (Optimal) | *"Every key mechanical subsystem is scored continuously. Drivers know exactly what needs attention and what is running in peak condition."* |

---

## ⏱️ Minute 1:30 – 2:15 | Deep Diagnostics, Causal Proof & Monetization

| Time | Visual / Screen Action | Voiceover / Script |
| :--- | :--- | :--- |
| **1:30** | Tap the **Battery Card**. Screen slides into **Component Diagnostic View**. | *"Judges always ask: how do you prove it's not a hallucination? Let's drill into the causal proof."* |
| **1:42** | Show the **30-Day Degradation Sparkline**: Line descends from 12.6V to 11.4V, projecting the critical redline drop at Day 9. | *"Our regression model tracks cold-cranking sag. Over the last 21 cold starts, terminal voltage has degraded linearly. The algorithm calculates with 94% statistical confidence that cold-crank will fail in 9 days."* |
| **1:55** | Highlight the **Value Proposition Card**: <br>**Cost to Replace Now:** ₹4,200 (Partner Garage)<br>**Breakdown Cost:** ₹8,700 (Towing + Dealer Markup)<br>**Net Savings:** **₹4,500 Saved** | *"By warning the user early, we don't just prevent danger—we save them **₹4,500** compared to roadside emergency replacement."* |
| **2:05** | Tap **"Book Authorized Exide Partner"** -> Bottom sheet opens showing nearby verified garages in Jaipur/Delhi with available 10:00 AM slot. Tap **"Confirm Booking"**. | *"With one tap, the replacement battery is reserved at a verified partner garage. AutoPulse captures a 15% booking commission from the garage, creating our second recurring revenue stream."* |

---

## ⏱️ Minute 2:15 – 2:45 | Secret Judge Demo Panel: Live Fault Injection

| Time | Visual / Screen Action | Voiceover / Script |
| :--- | :--- | :--- |
| **2:15** | Navigate to **Settings** or **Long-press the AutoPulse Logo** for 2 seconds. The **Judge Demo Control Dialog** pops up. | *"To prove this is live software and not a video mock, let's open our secret testbench panel built specifically for this evaluation."* |
| **2:25** | Select **"Inject Fault: Coolant Temperature Spike (108°C Overheat)"** and tap **"Trigger & Fast Forward 3 Days"**. | *"I'm injecting a simulated thermostat valve failure into our async telemetry engine right now..."* |
| **2:35** | Switch back to **Live Telemetry Stream Tab** (`/telemetry`). Dials animate in real-time at 1 Hz via WebSocket: Coolant temp climbing to 104°C, RPM fluctuating, Red Alert banner flashes. | *"Instantaneously over WebSocket, the dashboard catches the temperature escalation. The health index updates, warning the driver before cylinder head warping occurs."* |

---

## ⏱️ Minute 2:45 – 3:00 | B2B Fleet Intelligence & Business Model Closing

| Time | Visual / Screen Action | Voiceover / Script |
| :--- | :--- | :--- |
| **2:45** | Tap **Fleet Tab** (`/fleet`). Responsive risk-prioritized matrix showing 12 vehicles (Swifts, i20s, Innovas, XUV500s). High-risk cars flagged at top with 1-click bay dispatch. | *"For used-car dealerships, cab aggregators, and corporate fleets, AutoPulse Fleet provides a bird's-eye view of vehicle risk across hundreds of assets, reducing maintenance downtime by 38%."* |
| **2:55** | Switch to **Plans Screen** (`/plans`) showing ₹999 Hardware + ₹999/yr vs Free Scanner comparison table. | *"We are launching our 100-car pilot right here in Rajasthan with 4 partner garages. AutoPulse is how India's 40 million used car owners drive with absolute peace of mind. Thank you!"* |

---

## 🛠️ Quick Reference: Demo Hotkeys & Shortcuts

- **Secret Judge Panel:** Long-press the `AutoPulse` logo in the top App Bar on Home or Settings.
- **Fast Vehicle Switch:** Toggle between 5 real vehicles:
  1. `CAR-DL-08-CC-4421` (Maruti Swift VXi - Failing Battery)
  2. `CAR-HR-26-DK-8832` (Hyundai i20 Asta - Overheating Coolant)
  3. `CAR-MH-02-EE-1920` (Honda City V - Worn Spark Plugs)
  4. `CAR-UP-16-BZ-9011` (Tata Nexon XZ - Alternator Voltage Drop)
  5. `CAR-KA-03-MM-5514` (Mahindra XUV500 - Failing O2 Sensor / High Emissions)
  6. `CAR-RJ-14-AA-1001` (Maruti Baleno - Healthy Benchmark Control)
- **Fast Day Advance:** Tap `+5 Days` or `+10 Days` inside Demo Panel to show multi-week wear progression.
