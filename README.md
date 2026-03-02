# 🏋️‍♂️ Fitness Training Management App

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Supabase](https://img.shields.io/badge/Supabase-Backend-green?logo=supabase)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-blue?logo=postgresql)
![License](https://img.shields.io/badge/License-MIT-orange)

A modern **role-based fitness training management mobile application** built using **Flutter** and **Supabase**.

This system allows trainers to create and assign workouts while members can track, complete, and monitor their fitness progress.

---

# 🚀 Features

## 👤 Member
- Secure authentication (Sign Up / Login)
- View trainer-assigned workouts
- Mark workouts as completed
- Visual completion indicators
- Track completion date
- Profile editing
- Upload profile picture (Supabase Storage)
- Persistent avatar system

## 🧑‍🏫 Trainer
- Create custom workouts
- Assign workouts to members
- View member progress
- Track completion statistics
- Manage members
- Dedicated trainer dashboard

---

# 🛠️ Tech Stack

### Frontend
- Flutter
- Dart

### Backend
- Supabase
  - Authentication
  - PostgreSQL Database
  - Storage (Profile Avatars)

### Database
- PostgreSQL with Row-Level Security (RLS)

---

# 🔐 System Architecture

- Role-based authentication (Member / Trainer)
- Secure Row-Level Security policies
- Relational workout assignment structure
- Status-based workout completion tracking
- Cloud-based avatar storage
- Clean Future-based state handling

---
# 📂 Project Structure


  lib/
  │
  ├── member/
  │ ├── workout_view.dart
  │ ├── profile_screen.dart
  │ └── assigned_workouts_screen.dart
  │
  ├── trainer/
  │ ├── trainer_home_screen.dart
  │ ├── members_screen.dart
  │ ├── assign_workout_screen.dart
  │ └── create_workout_screen.dart
  │
  ├── services/
  │ ├── auth_service.dart
  │ ├── member_workout_service.dart
  │ ├── trainer_service.dart
  │ └── assignment_service.dart
  │
  └── main.dart


---
---

# ⚙️ Setup Instructions

## 1️⃣ Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/fitness-app.git
cd fitness-app


# 📂 Project Structure
