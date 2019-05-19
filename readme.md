# GpsSignalAcquisition

Acquisition of GPS C/A signal with coarse resolution to serve as a first guess for a tracking loop.

The acquisition is implemented using 5MHz as sampling time and 1.1kHz for Doppler resolution using 1ms for the total coherent integration time. The process is performed using Coded Match Filter and Circular Cross-correlation.

Present and missing satellites can readily be observed from the resulting, and the delay and frequency initial guesses can be readily identified:

![Missing satellite for PRN1](/output/CX1.png)
![Present satellite for PRN4](/output/CX4.png)
![Low SNR satellite for PRN9](/output/CX9.png)
