# 🎯 BINGO Detection System
### Automated Bingo Board Recognition & Line Detection in MATLAB

## 📌 Overview

A compact MATLAB pipeline that processes a raw bingo card image to:

* Mask brightness
* Correct rotation using FFT
* Detect grid lines & stamped circles
* Build a 5×5 binary matrix
* Evaluate row/column/diagonal BINGO
* Produce optional debug visualizations

## ✨ Features

* **FFT-based** rotation estimation
* **HSV brightness** masking
* **Hough line & circle** detection
* **Line clustering** for 6×6 grid extraction
* **5×5 stamp mapping** (free center auto-filled)
* Full **BINGO detection** logic
* Multi-panel diagnostic **visualization**
