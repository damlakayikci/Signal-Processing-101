# CMPE362 Homework 3: Noise Removal using Digital Filters



## Objective

The objective of this assignment is to design and analyze digital bandstop filters to remove narrowband noise from an audio signal. I explore both FIR and IIR filter design techniques in MATLAB and evaluate their effectiveness based on their frequency response, spectrograms, and subjective performance.


## 1. Spectrogram Analysis

To identify the noise frequency band, I analyzed the spectrogram of the original audio signal using the MATLAB function `spectrogram()`. The spectrogram revealed a persistent horizontal band of noise between approximately **3.8 kHz and 4.9 kHz**, especially visible during silent regions of the recording.

**Estimated Noise Band:** [3800 Hz, 4900 Hz]
<div align="center">
  <img src="https://github.com/user-attachments/assets/d5addf57-f65f-4df8-aadb-d6a9f6ff7678" alt="Spectrogram of the original noisy signal. Noise is most visible in the 3.8–4.8 kHz range." width="600"/>
</div>


## 2. FIR Filter Design

A 256th-order FIR bandstop filter was designed using the `fir1()` function with normalized cutoff frequencies defined as:
Wn = [ (f₁ - 500) / (fs/2), (f₂ + 500) / (fs/2) ]
where `f₁ = 3800 Hz`, `f₂ = 4800 Hz`, and `fs` is the sampling frequency. This FIR filter effectively attenuates the target frequency band while preserving linear phase characteristics.



## 3. IIR Filter Design

I designed three IIR bandstop filters for the same frequency range using the following methods:

- **Butterworth filter** using `butter()`, with order **n = 7**
- **Chebyshev Type I filter** using `cheby1()`, with order **n = 6** and passband ripple **Rp = 0.1 dB**
- **Elliptic filter** using `ellip()`, with order **n = 6**, passband ripple **Rp = 0.1 dB**, and stopband attenuation **40 dB**

I chose these values to obtain the lowest possible order at which the noise becomes almost inaudible in the audio.



## 4. Frequency Response and Pole-Zero Plots

I plotted the log-magnitude frequency responses of each filter using `freqz()`, and pole-zero diagrams of the IIR filters using `zplane()`. The frequency responses show that all IIR filters achieved effective attenuation around the noise band, with the elliptic filter offering the sharpest roll-off.

<div align="center">
  <img src="https://github.com/user-attachments/assets/8299935f-b8d1-4d21-9b3e-07f7084d8c1d" alt="Frequency response comparison for selected filter orders." width="600"/>
</div>

<div align="center">
  <img src="https://github.com/user-attachments/assets/147de647-7cfa-48fd-85f6-89fde4c44079" alt="Pole-zero plots of Butterworth, Chebyshev I, and Elliptic filters." width="600"/>
</div>



## 5. Spectrograms After Filtering

After applying each filter to the audio signal, I generated the spectrograms of the filtered signals. The FIR filter achieved the most uniform suppression. Among IIR designs, Chebyshev Type I and Elliptic filters closely matched FIR performance while using significantly lower orders. Butterworth required a slightly higher order to reach comparable suppression.

<div align="center">
  <img src="https://github.com/user-attachments/assets/38614244-a387-413b-a3c5-3645d63c9e10" alt="Spectrograms after filtering with FIR and IIR filters." width="600"/>
</div>


## 6. Stability Analysis of IIR Filters

To assess numerical stability, I increased the order for each IIR filter until instability or audio corruption was observed. The smallest unstable orders were:

- Butterworth: **13**
- Chebyshev Type I: **12**
- Elliptic: **10**

The frequency responses at these orders show excessive gain fluctuation and loss of stopband selectivity, confirming instability.

<div align="center">
  <img src="https://github.com/user-attachments/assets/798bb9ca-b945-40ea-bb82-d11bc8e7905c" alt="Frequency responses of IIR filters near instability threshold." width="600"/>
</div>



## Conclusion

Through spectrogram analysis and filter design, I successfully identified and removed a narrowband noise between **3.8–4.9 kHz**. FIR filtering with order 256 provided excellent suppression with linear phase. Among IIR filters, Chebyshev and Elliptic achieved comparable suppression using lower orders. Final chosen parameters were:

- Butterworth: **7**
- Chebyshev Type I: **6**
- Elliptic: **6**

These choices offered a strong balance between performance, efficiency, and numerical stability.
