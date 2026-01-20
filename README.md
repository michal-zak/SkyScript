#  SkyScript

**SkyScript** is a cosmic dashboard iOS application that blends science and spirituality. It orchestrates real-time data from **NASA's APOD API** and a **Horoscope API** to deliver a personalized daily snapshot of the universe.

Built with **SwiftUI** and heavy usage of **Combine** for reactive state management and asynchronous event handling.

<img width="100" height="100" alt="1024" src="https://github.com/user-attachments/assets/1e2d14e1-c514-4ab3-9765-6a2141c2e2e4" />
<br>
<img width="294.75" height="639" alt="Simulator Screenshot - iPhone 16 - 2026-01-19 at 14 14 12" src="https://github.com/user-attachments/assets/b02869fa-807f-48b3-80ae-615694b3de95" />
<img width="294.75" height="639" alt="Simulator Screenshot - iPhone 16 - 2026-01-19 at 14 13 45" src="https://github.com/user-attachments/assets/1b67ebad-c31b-4401-a18d-dc1c68668636" />
<img width="294.75" height="639" alt="Simulator Screenshot - iPhone 16 - 2026-01-19 at 14 14 03" src="https://github.com/user-attachments/assets/b8acba7a-c20e-4214-92e3-74e33579f718" />

##  Features

* **Cosmic Daily Dashboard:** View the Astronomy Picture of the Day alongside a daily horoscope.
* **Time Travel :** Users can select any past date to view historical cosmic data (changing the date updates both the NASA image and the planetary alignment).
* **Reactive Search:** Real-time updates based on Zodiac sign and Date selection.
* **Localization 🇮🇱:** Full support for Hebrew (RTL) and English.
* **Robust Error Handling:** graceful degradation with user-friendly alerts.

##  Tech Stack & Architecture

* **Language:** Swift
* **UI:** SwiftUI
* **State Management:** Combine
* **Architecture:** MVVM (Model-View-ViewModel)
* **Networking:** `URLSession` with Combine extensions (`dataTaskPublisher`)

##  Key Technical Highlights

This project demonstrates advanced usage of the **Combine framework** to handle asynchronous data streams and orchestration.

### 1. Complex Stream Orchestration (`Zip`)
The app requires data from two independent APIs (NASA & Horoscope) to be presented simultaneously. I used `Publishers.Zip` to ensure the UI only updates when *both* calls succeed, preventing partial UI states.

### 2. Reactive "Time Travel" Pipeline
To handle date changes efficiently, the `ViewModel` implements a sophisticated pipeline using `CombineLatest`.

**The Challenge:** A user might scroll through dates quickly. We don't want to fire a network request for every millisecond of scrolling.

**The Solution:**
1.  **`debounce`**: Waits for the user to stop scrolling.
2.  **`removeDuplicates`**: Ensures we don't fetch the same data twice.
3.  **`switchToLatest`**: If a new request starts before the old one finishes, the old one is automatically cancelled.

### 3. Fail-Safe Error Handling
The pipeline uses catch inside the inner stream (the flatMap phase). This ensures that a network error (e.g., 404 or No Internet) is handled gracefully without terminating the main subscription, allowing the app to recover immediately when the user tries a different date.



