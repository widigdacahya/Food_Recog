# 🍔 Food Recognizer App

App to identify food from images, provide recipe references, and estimate nutritional facts using AI. This developed as a task for assignment on [Course Dicoding](https://www.dicoding.com/academies/758) . This project using TensorFlow Lite with Cloud Storage(to store the model), and utilizes generative AI (Gemini) for dynamic data generation about estimation of nutrition facts.

## ✨ Features
*   **📷 Image Capture & Crop:** Pick images from the gallery or capture with camera.
*   **🤖 ML Model - Food Clasification Model:** Classifies food images into one of 2,000+ categories from [Kaggle - google/aiy](https://www.kaggle.com/models/google/aiy/tfLite/vision-classifier-food-v1).
*   **☁️ Dynamic Model Downloading:** Downloads the TFLite model (~21MB) from Firebase Cloud Storage on the first run to keep the initial app size light.
*   **🍲 Recipe Fallback Search:** Fetches matching recipes, ingredients, and instructions from [TheMealDB API](https://www.themealdb.com/api.php).
*   **✨ AI Nutritional Estimation:** Generates estimation of nutritional facts (Calories, Carbs, Fat, Fiber, Protein) using the **Gemini 3.1-flash-lite**.

## 🎥 App Preview
[**👉 Watch the Demo Video Here**](https://drive.google.com/file/d/1fXP9g-Kd45FzKobQWdYIbLTk8YeuxrGu/view?usp=drive_link)

---

## 🚀 Getting Started
1. Update .env with gemini API key
2. Connect to firebase, put the model on storage(Update firebase connection)
