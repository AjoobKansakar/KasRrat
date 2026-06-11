# KasRrat: AI-Powered Biomechanics Coach 🏋️‍♂️🤖

KasRrat is a high-performance, privacy-centric mobile application designed to provide real-time biomechanical analysis and automated form correction for home fitness enthusiasts.

## Key Features

- **Real-time Skeletal Tracking:** Leverages Google ML Kit to analyze 33 body landmarks on-device (Edge Computing).
- **Automated Rep Counting:** Precise tracking for Squats, Pushups, Bicep Curls, and Lateral Raises.
- **Instant Form Correction:** Multimodal feedback via Visual Skeleton Overlays and Audio TTS Coaching.
- **Environmental Intelligence:** Built-in Luma analysis to ensure optimal lighting for AI accuracy.
- **Secure Backend:** Cloud synchronization via Supabase (PostgreSQL) with Deep-Linked authentication.

## Tech Stack

- **Frontend:** Flutter & Dart
- **AI Engine:** Google ML Kit Pose Detection
- **Backend:** Supabase (Auth, Database, PostgREST)
- **Architecture:** Client-Server / Modular Counter Logic

## The Logic

The application utilizes trigonometric calculations (specifically the **atan2** function) to monitor joint angles in real-time.

- **Squats:** Depth validation at < 100° knee angle.
- **Pushups:** Body-sag detection and horizontal orientation validation.
- **Optimization:** Implemented Frame Throttling (processing every 3rd frame) to prevent thermal throttling on mobile hardware.

## Screenshots & Demos

_(Tip: Drag and drop your best screenshots/GIFs here)_

## Installation & Setup

1. **Clone the repo:**
   ```bash
   git clone https://github.com/AjoobKansakar/KasRrat.git
   ```
