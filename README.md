# 📱 JobMatch

A modern mobile application built with **Flutter**, providing a seamless and intuitive user experience.  
The app integrates authentication, profile management, and privacy policy functionalities, designed with 
scalability, maintainability, and clean architecture in mind.
it integrates also a small AI-powered recommendation system to suggest the most relevant jobs, ensuring a 
personalized career path.

---

## 🚀 Features

- **Authentication System**  
  - User registration and login with validation.
  - Secure password handling.
  - Form validation with error messages.

- **Profile Management**  
  - Editable profile information.
  - Avatar/image upload.
  - User-friendly layout and design.

- **Privacy Policy Integration**  
  - Privacy policy generated via an external generator.
  - Content accessible through an **external link**.
  - Embedded display in the `privacy_policy_screen.dart` for in-app viewing.
 
- **AI Job Recommendations**
  – Get job suggestions tailored to your skills, education, and career goals.

- **Favorites & Saved Jobs**
  – Save job offers to review later.

- **Modern UI/UX**  
  - Clean and minimalistic design.
  - Adaptive layout for different screen sizes.
  - Smooth navigation between screens.

- **Performance-Oriented**  
  - Lightweight and fast-loading.
  - Optimized for both Android and iOS.

---

## 🧠 AI Backend – Recommendation System

The AI backend is implemented as a **separate service** that processes job data and user profiles to generate recommendations.

### **Architecture Overview**
1. **Data Processing**
   - Job dataset preprocessing (cleaning, tokenization, TF-IDF vectorization)
   - User profile data encoding
2. **Recommendation Model**
   - Content-based filtering using job descriptions & skill matching
   - Cosine similarity to rank relevant jobs
3. **API Integration**
   - REST API built with **FastAPI** (Python) serving job recommendations to the Flutter app
4. **Dataset**
   - Based on LinkedIn Job Dataset (Kaggle) with additional curated data

---

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **State Management:** Provider / Riverpod (depending on implementation)
- **Backend API:**
   - Python
   - scikit-learn, pandas, NumPy
   - Job dataset (Kaggle)
- **Database:** Firebase Firestore, Cloudinary
- **Version Control:** Git & GitHub

---

## 📂 Project Structure

**front**

```plaintext
lib/
│
├── main.dart                # App entry point
├── pages/
│   ├── more_infos_page.dart
├── screens/                 # UI screens
│   ├── job_seekers/                 # job_seeker's related screens
│   ├── recruiters/              # recruiter's related screens
│   └── privacy_security_screen.dart
│   └── ...
│
├── models/                  # Data models
├── services/                # API & database handling
```

**back**

```plaintext
│
├── main.py               # FastAPI main server
├── clean_jobs.csv        # dataset
├── job_recommender_model.pkl
│
```

---

## 📸 Screenshots

| Welcome Screen                         | Home Screen                                | Settings Screen                            | Recommendations Screen                     |
| -------------------------------------- | ------------------------------------------ | ------------------------------------------ | ------------------------------------------ |
| ![Welcome](https://github.com/user-attachments/assets/90d8e533-1a5f-46fc-becb-da26adffaedf) | ![Home](https://github.com/user-attachments/assets/88444a94-f545-4ad1-a246-5f9224a9a8e2) | ![Settings](https://github.com/user-attachments/assets/d8acd019-2a40-4154-8efe-3a433f8658d7) | ![Recommendations](https://github.com/user-attachments/assets/aaf20047-701c-4182-9d1b-74c5433b016e) | 


---
      
## ⚙️ Installation
**1. Clone the repository**
```
git clone https://github.com/yourusername/yourproject.git
```
**2. Navigate to the project folder**
```
cd yourproject
```
**3. Install dependencies**
```
flutter pub get
```
**4. Run the application**
```
flutter run
```
**5. Run AI Backend**
```
cd back
pip install
uvicorn main:app --reload      # url set for the android emulator
```

---

## 🔗 Privacy Policy
-**External Link:** [View Privacy Policy](https://www.termsfeed.com/live/f8069637-31d9-4ccb-b677-2dcd9688b003)                            

-**In-App:** Accessible under Privacy Policy section in settings.

---

## 🤝 Contributing
**1.** Fork the repository

**2.** Create a new branch: git checkout -b feature-branch

**3.** Commit your changes: git commit -m 'Add new feature'

**4.** Push to the branch: git push origin feature-branch

**5.** Open a Pull Request

---

## 📜 License
This project is under no License - is a simple study project.

---

## 👥 Authors
Nermine Chennaoui – [GitHub Profile](https://github.com/Nermine2001)
