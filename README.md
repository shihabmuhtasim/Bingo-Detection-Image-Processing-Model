# 🎯 Bingo Detection – Image Processing Model

## Automated Bingo Card Recognition & Validation in MATLAB

---

## 📌 Project Overview

This project is an **image processing–based Bingo card detection and validation system**, developed as part of an academic assignment. The system analyzes an input image of a Bingo card, detects stamped cells, corrects rotation if necessary, digitizes the card into a logical grid, and determines whether a valid **Bingo pattern** exists.

The project demonstrates practical use of **MATLAB image processing techniques**, including frequency-domain analysis, geometric correction, shape detection, and logical validation. The solution is designed in a **modular and readable way**, making the processing pipeline transparent and easy to understand.

---

## 🧠 Problem Description

Scanned or photographed Bingo cards often suffer from:
- Rotation or skew
- Uneven lighting
- Background noise
- Imperfect stamp placement

The objective of this assignment is to build a custom optical recognition system that can:
- Automatically **straighten a rotated Bingo card**
- **Detect circular stamps** placed by the player
- Map visual detections to a **5×5 digital grid**
- Check for a **Bingo** (row, column, or diagonal)
- Display intermediate processing steps visually

The output includes both **terminal output** (digitized array + Bingo status) and **graphical visualization**.

---

## 🖼️ Visual Processing Stages (Instructor-Style Explanation)

The assignment requires the processing function to present a figure composed of multiple subplots, each illustrating a key step of the pipeline.

<img width="2915" height="1648" alt="image" src="https://github.com/user-attachments/assets/3026201a-f4f4-4893-a219-be7e67bf52f9" />


---

### Subplot Breakdown

1. **Original Image**  
   Raw input image of the Bingo card.

2. **Fourier Magnitude of Edge Image**  
   Shows frequency-domain representation used to estimate the card’s rotation angle.

3. **Straightened and Cropped Image**  
   The image after rotation correction and cropping to the Bingo grid.

4. **Hough Space – Line Detection**  
   Visualization of detected grid lines used to infer the Bingo grid structure.

5. **Hough Space – Circle Detection**  
   Visualization of detected circular stamps.

6. **Final Overlay Visualization**  
   Grayscale image with detected circles marked. If a Bingo exists, the winning row/column/diagonal is drawn with a green line.

---

## ⚙️ System Workflow

The system processes each image using the following steps:

1. **Preprocessing & Masking**  
   Filters out unnecessary image regions and enhances relevant features.

2. **Rotation Estimation (FFT-based)**  
   Uses Fourier transform magnitude to detect dominant orientation.

3. **Rotation Correction & Cropping**  
   Aligns the Bingo card to a canonical orientation.

4. **Grid Line Detection**  
   Applies a Hough-like transformation to detect grid lines.

5. **Circle Detection**  
   Detects circular Bingo stamps using geometric and Hough-based methods.

6. **Digitization**  
   Maps detected circles to a **5×5 logical matrix**.

7. **Bingo Validation**  
   Checks rows, columns, and diagonals for a valid Bingo pattern.

---

## ▶️ How to Run the Project

### Main Entry Point

The **main script of the project is:**

```
main.m
```

> Note: In the original submission, this file was named `a01_V1AM6K.m`. It can safely be renamed to `main.m`.

### Steps
1. Open MATLAB
2. Set the project root directory as the current folder
3. Run:

```matlab
main
```

The script automatically loops through all images in the input folder and processes them sequentially.

---

## 📂 File Structure

```
├── main.m                 % Main controller script
├── scanner.m              % Core processing function
├── findRotationAngle.m    % Rotation estimation using FFT
├── findCircle.m           % Circular stamp detection
├── findBingoLine.m        % Identifies winning Bingo line
├── checkBingo.m           % Validates Bingo rules
├── README.md              % Project documentation
└── input/                 % Folder containing Bingo card images
```

---

## 🧩 File Responsibilities

### `main.m`
- Iterates through the input image folder
- Calls the processing pipeline
- Displays results and prints output

### `scanner.m`
- Core required function
- Input: image matrix
- Output: 5×5 digitized matrix + Bingo boolean
- Produces visualization subplots

### `findRotationAngle.m`
- Estimates image rotation using frequency-domain analysis

### `findCircle.m`
- Detects circular Bingo stamps

### `findBingoLine.m`
- Determines which row/column/diagonal forms a Bingo

### `checkBingo.m`
- Applies logical Bingo rules and returns final decision

---

## 🧪 Output

For each processed image, the system:
- Prints the digitized 5×5 matrix to the terminal
- Prints whether a Bingo exists
- Displays a multi-panel visualization of processing steps

---

## 🎓 Evaluation

This project **received full marks (100/100)** for successfully fulfilling all functional, visual, and structural requirements of the assignment, including correct digitization, rotation handling, Bingo detection, and clear visual presentation.

---

**Author:** Shihab Muhtasim
**Course:** Image Processing  
**Language:** MATLAB
