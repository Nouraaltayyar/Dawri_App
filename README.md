# dawri_app - a Queue Management Application

“Dawri” is a smart mobile application designed to manage queues electronically in public spaces such as restaurants, clinics, banks, cafés, and events. The app aims to reduce waiting times, enhance user satisfaction, and improve service quality by allowing users to book their place in line, receive real-time updates, and prioritize access for the elderly and people with special needs. In line with Saudi Vision 2030, “Dawri” supports digital transformation by offering efficient, accessible, and user-friendly solutions for everyday challenges.

## Features
- Prioritization of Special Cases: Gives priority to individuals with special needs and the elderly to ensure equitable service access.
- Accurate Wait Time Estimates: Provides real-time, reliable wait time data to reduce appointment cancellations and enhance planning.
- Real-Time Queue Notifications: Enhances user experience by sending timely updates about queue progress and position.
- Service Quality Feedback: Allows users to rate their experience, helping to evaluate staff performance and improve service accuracy.


## Screenshots
![Home Screen](screenshots/Screenshot_Home.png)
![Reservations](screenshots/Screenshot_Reservations.png)
![Notification](screenshots/Screenshot_Notification.png)
![Queue](screenshots/Screenshot_queue.png)
![Rate](screenshots/Screenshot_Rate.png)

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart
- Android Studio or VS Code

### Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/Nouraaltayyar/Dawri_App.git

2.	Navigate to the project directory:

```sh
cd Dawri_App
```
3.	Get the Flutter packages:

```sh
flutter pub get
```
### Running the App
1. Connect your device or start an emulator.
2. Run the app
   ```sh
   flutter run
   ```

   ## Usage

1. Launch the Dawri app on your device.
2. Sign in or create a new account.
3. Browse available queues for nearby locations.
4. Book your place in a queue with a single tap.
5. Monitor your position in real-time through notifications.
6. Use special case options if applicable (e.g., elderly or individuals with special needs).
7. After service, submit feedback to help improve service quality.

  ## Project Structure

The following summarizes the key files and folders in the lib/ directory:

### Folders:
	•	admin/ – Screens and logic for the system administrator.
	•	owner/ – Screens for business owners to manage queues and add+edit location and send notifications.
	•	services/ – Shared services such as Auth and Firebase .
	•	screenshots/ – Contains screenshots used in the README.

### Key Dart Files:
	•	main.dart – The entry point of the app.
	•	Home.dart – Main page with navigation for users.
	•	Login.dart / Signup.dart – User authentication screens.
	•	Welcome.dart – Welcome screen displayed on first launch.
	•	Onboarding_content.dart / Onboarding_screen.dart – Onboarding content and layout.
	•	My_reservation_page.dart – Displays the user’s current reservation.
	•	Notifications_page.dart / Notifications_details.dart – Displays notifications and their details.
	•	ReservPage.dart / UpdatePage.dart – Booking a queue and updating it.
	•	RatePage.dart / FeedBackPage.dart – Pages for submitting user reviews.
	•	Seeting.dart – App settings screen.
	•	UsersPage.dart – Displays user account information.
	•	AboutPage.dart – App information screen.
	•	forgot.dart – Password recovery screen.
	•	bankPage.dart / cafePage.dart / eventPage.dart / resturantPage.dart / 
      Halthcarepage.dart – Screens for individual places.
	•	bankPlacePage.dart / cafePlacePage.dart / eventPlacePage.dart / restaurantplacepage.dart / healthcareplacepage.dart – Lists of available places.
	•	CReservPage.dart – Reservation confirmation screen.
	•	DetailsReview.dart – Displays user review history and integrates the average rating calculation function.
	•	firebase_options.dart – Firebase project configuration.

## Contributing
1. Fork the repository.
2. Create your feature branch (git checkout -b feature/awesome-features).
3. Commit your changes (git commit -m 'Add awesome features').
4. Push to the branch (git push origin feature/awesome-features).
5. Open a Pull Request.

## License
Distributed under the MIT License. See LICENSE for more information.

## Contact
[dawri_app@gmail.com](mailto:dawri_app@gmail.com)

Project Link: [https://github.com/Nouraaltayyar/Dawri_App](https://github.com/Nouraaltayyar/Dawri_App)
