# 🏃‍♂️ FitPulse Intelligent Tracker

## 📌 Overview

**FitPulse Intelligent Tracker** is an intelligent fitness monitoring system developed in **MATLAB** for hackathons and health analytics applications. The system integrates smartphone sensors to track physical activity, calculate health metrics, and provide personalized health insights.

The project uses **mobile sensor integration, signal processing, adaptive step detection, GPS tracking, and personalized fitness analysis** to monitor user activity in real time.

If mobile sensors are unavailable, the system automatically switches to a **simulation fallback mode**, ensuring smooth execution.

---

## 🚀 Features

### ✅ Real-Time Sensor Integration

* Connects to smartphone sensors using MATLAB `mobiledev`
* Collects:

  * Accelerometer data
  * GPS location
  * Speed tracking

### ✅ Adaptive Step Detection

* Uses **adaptive thresholding**
* Reduces false step detection caused by noise
* Detects walking/running motion more accurately

### ✅ Distance Estimation

* GPS-based speed calculation
* Walking speed fallback when GPS is unavailable
* Accurate movement estimation

### ✅ Activity Classification

The system classifies user activity into:

* **Idle**
* **Walking**
* **Running**

based on motion intensity and detected steps.

### ✅ Calorie Burn Estimation

Calories burned are estimated using:

* User weight
* Activity MET values
* Session duration

### ✅ Personalized Health Status

Health status is generated based on historical performance:

* **EXCELLENT**
* **AVERAGE**
* **BELOW AVERAGE**

using previous fitness records.

### ✅ Historical Data Tracking

The system stores session data in:

`fitness_history_v5.mat`

including:

* Time
* Steps
* Distance
* Calories burned
* Activity type

### ✅ Smart Visualization Dashboard

Interactive dashboard includes:

* 📍 GPS route tracking
* 📈 Fitness progress history
* 👣 Motion signal with detected steps
* 🩺 Intelligent health report
* 📋 Session history table

---

## 🛠️ Technologies Used

* **MATLAB**
* **Signal Processing**
* **Mobile Sensor Integration (`mobiledev`)**
* **GPS Tracking**
* **Data Visualization**
* **Adaptive Peak Detection**
* **Health Analytics**

---

## 📂 Project Structure

```text
FitPulse-Intelligent-Tracker/
│── fitpulse_tracker.m
│── fitness_history_v5.mat
│── README.md
```

---

## ⚙️ How to Run the Project

### Step 1: Install MATLAB

Ensure MATLAB is installed with:

* Signal Processing Toolbox
* Mobile Sensor Support Package

### Step 2: Connect Mobile Device

Install **MATLAB Mobile App** on your smartphone.

Enable:

* Accelerometer
* GPS
* Sensor logging

### Step 3: Run the Script

Run the MATLAB script:

```matlab
fitpulse_tracker
```

The program will:

1. Initialize phone sensors
2. Record activity data
3. Extract motion features
4. Detect steps
5. Estimate calories and distance
6. Classify activity
7. Generate health report dashboard

---

## 📊 Output Dashboard

The dashboard displays:

* **GPS Path**
* **Calories Progress History**
* **Processed Motion Signal**
* **Detected Steps**
* **Intelligent Health Report**
* **Historical Activity Table**

---

## 🔍 Key Improvements (Fixed Edition)

### Fix 1: Adaptive Step Detection

Improved threshold logic:

```matlab
threshold = max(0.2, 0.15 * max(mag_f));
```

This improves robustness and avoids false peak detection.

### Fix 2: Improved Distance Logic

Added realistic walking speed fallback:

```matlab
avg_spd_ms = 1.2;
```

when GPS speed is unavailable but movement is detected.

---

## 💡 Future Enhancements

* AI-based activity prediction
* Heart-rate sensor integration
* Sleep monitoring
* Cloud data storage
* Real-time mobile notifications
* Fitness recommendation system

---

## 👨‍💻 Author

**Mohd Rayanuddin**
B.Tech Final Year – Electronics and Communication Engineering (ECE)

---

## 📜 License

This project is developed for **educational and hackathon purposes**.
