# Stock Trading Using DSP Techniques

This project explores the use of **Digital Signal Processing (DSP)** techniques to design a simple **stock trading strategy**. It was completed as part of coursework and focuses on applying smoothing methods and custom filters to stock price data.

## Project Description

The tasks are outlined in the `description.pdf` file. They include:
- Applying **Simple Moving Average (SMA)** and **Exponential Moving Average (EMA)** to stock price series.
- Designing and implementing a **custom smoothing method**.
- Analyzing the effect of different smoothing techniques on the trading strategy performance.
- Building and evaluating a basic **buy/sell strategy** based on these signals.

## How the Code Works

The main code file is `main.m`, which:
1. Loads historical stock price data for selected banks.
2. Applies SMA, EMA, and a custom smoothing method to the price series.
3. Generates trading signals based on smoothed data.
4. Simulates a trading strategy by buying and selling according to the signals.
5. Logs performance metrics such as return and volatility.

The script is designed to run sequentially and produce performance plots and metrics automatically.

## Summary of Results

The results are summarized in `report.pdf`. Key findings:
- **EMA-based** strategies generally outperformed **SMA-based** ones in terms of reactivity to price changes.
- The **custom method** achieved smoother price curves, but sometimes lagged behind fast-moving price changes, impacting responsiveness.
- The trading strategy based on smoothed signals showed improved returns compared to a naive "buy and hold" approach, though it also introduced additional risk depending on the smoothing method used.

Overall, DSP techniques provided useful insights for trend-following strategies.

---

## Files
- `description.pdf`: Task description and project requirements.
- `main.m`: MATLAB code implementing the smoothing techniques and trading simulation.
- `report.pdf`: Analysis and summary of results.
