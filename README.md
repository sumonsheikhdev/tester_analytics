# tester_analytics

A lightweight **Flutter analytics module** designed specifically for **Google Play Closed Testing (14 days)**.  
It tracks tester engagement, sessions, events, crashes, and feedback using **Firebase Cloud Firestore**.

This package helps you **prove real user activity** during closed testing — similar to MoEngage or Firebase Analytics, but fully customizable and transparent.

---

## ✨ Features

- 📱 **Tester Registration**  
  Automatic registration with device and app information

- 📊 **Activity Tracking**  
  Comprehensive event tracking (screen views, button clicks, feature usage)

- ⏱️ **Session Management**  
  Track app sessions with duration analytics

- 🐛 **Crash Reporting**  
  Automated crash logging with stack traces

- 💬 **Feedback Collection**  
  Built-in feedback submission system

- 🌐 **Real-time Analytics**  
  Live monitoring of tester activities

- 📱 **Device Information**  
  Collects detailed device and app metadata

- ☁️ **Firebase Integration**  
  Secure cloud storage using Cloud Firestore

- 📈 **Analytics Dashboard Ready**  
  Structured data for summarized analytics dashboards

- 🔒 **Security**  
  Firebase Security Rules support

- 🔄 **Multi-platform Support**  
  Android, iOS, and Web

---

## 🎯 Why tester_analytics?

Google Play requires **real engagement from testers for at least 14 days** during closed testing.  
This package helps you:

- Prove real tester activity
- Track daily active users
- Measure session duration
- Track feature usage
- Generate analytics proof if needed

Ideal for **Play Console approval**.

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  tester_analytics:
    path: lib/tester_analytics
