# 🚺 SAFEHER – Women Safety Alert System

[![GitHub Repo Size](https://img.shields.io/github/repo-size/dharanishvijayakumar7-lgtm/SAFEHER-women-safety-alert-system)](https://github.com/dharanishvijayakumar7-lgtm/SAFEHER-women-safety-alert-system)
[![Tech Stack](https://img.shields.io/badge/Tech-Flutter%20%7C%20Firebase-brightgreen)]()
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue)]()

## 🚨 Overview

**SAFEHER** is a mobile application designed to enhance personal safety for women by providing fast, reliable emergency alerts, live location sharing, and smart triggering methods. It acts as a **trusted companion in critical situations** and empowers users with proactive safety tools.:contentReference[oaicite:1]{index=1}

---

## ⭐ Key Features

### 🔥 Core Safety Alerts
- **SOS/Panic Button:** Send instant alerts to emergency contacts.:contentReference[oaicite:2]{index=2}  
- **Multi-Trigger Activation:** Long press, shake detection, or dedicated UI button.:contentReference[oaicite:3]{index=3}  
- **Auto Message with GPS:** Sends current location in real-time when alert is triggered.:contentReference[oaicite:4]{index=4}

### 📍 Real-Time Tracking
- **Live Location Sharing:** Shared with contacts for timely help.:contentReference[oaicite:5]{index=5}  
- **Continuous GPS Updates:** Contacts can follow user movement until safe.:contentReference[oaicite:6]{index=6}

### 📞 Emergency Preparedness
- **Emergency Contacts List** — Add trusted guardians/family.:contentReference[oaicite:7]{index=7}  
- **Automatic Notifications:** SMS, Email, or push alerts sent instantly.:contentReference[oaicite:8]{index=8}

### 🛡️ Optional Extensions (Future Enhancements)
> *AI threat detection, self-defense content, safe routes, incident recording.*:contentReference[oaicite:9]{index=9}

---

## 📊 Impact & Outcomes

SAFEHER helps achieve:

- ⏱️ **Faster Help Response** – Immediate alerts minimize delay.  
- 🧭 **Increased Situational Awareness** – Contacts see live movement.  
- 📱 **Confidence & Peace of Mind** – Easy one-touch safety support.

---

## 🧠 How It Works — Workflow

```mermaid
flowchart TD
    A[User Launches SAFEHER App] --> B{Logged In?}
    B -->|No| C[Login / Register]
    B -->|Yes| D[Home Dashboard]
    D --> E[Setup Emergency Contacts]
    D --> F[SOS Trigger (Button / Shake / Press)]
    F --> G[Send Alert]
    G --> H[Attach Live GPS Location]
    H --> I[Notify Contacts]
    I --> J{Follow-Up?}
    J -->|Yes| K[Track Real Time Location]
    J -->|No| L[Alert Logged]
