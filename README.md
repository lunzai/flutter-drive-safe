# Safe Drive Monitor
A Flutter-based driving monitoring application developed as a Proof of Concept (POC) through AI pair programming using Cursor AI. This project serves as an experimental exploration into AI-assisted development, highlighting both the potential and limitations of AI pair programming.
## Motivation
This project was inspired by a tragic incident in Malaysia where a high school teenager, driving a family car, was involved in a fatal accident that resulted in multiple casualties. This heartbreaking event sparked several realizations:
- Parents and guardians need better ways to monitor and understand their children's driving habits
- Physical presence for monitoring and mentoring isn't always feasible
- We need practical, accessible solutions for real-time driving behavior monitoring
- Initially, an IoT approach was considered (using ESP8266/ESP32 + Sensors + 4G), but while technically interesting, it posed significant deployment and installation challenges.
- The solution became clear: leverage the device we always carry - our smartphones. Modern phones come equipped with all necessary components:
  - GPS for location and speed monitoring
  - Accelerometers for movement detection
  - Built-in data connectivity
  - No additional hardware required
### Vision
The ultimate goal is to release this application for free, helping parents:
 Monitor their children's driving behavior in real-time
 Receive immediate notifications of potentially dangerous driving patterns
 Prevent accidents before they happen
 Ensure everyone returns safely to their families
Remember: Every life lost on the road is one too many. If this tool can help prevent even one accident, it will have served its purpose.
## About
This application monitors driving behavior using:
 Real-time GPS speed tracking
 Accelerometer data for motion detection
 Sudden movement detection
 Location tracking
## Purpose
This project was developed to:
. Explore AI pair programming capabilities
. Test real-time sensor integration in Flutter
. Understand the practical implications of AI-assisted development
. Document the strengths and limitations of current AI coding tools
## Features
- [x] Real-time speed monitoring
- [x] Accelerometer data visualization
- [x] Location tracking
- [x] Permission handling
- [ ] Telegram notifications
## Technical Stack
- Flutter
- Dart
- Android SDK
- Geolocator
- Sensors Plus
## Development Notes
This project was developed through conversation-based programming with Cursor AI.

## License

This project is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License - see the [LICENSE.md](LICENSE.md) file for details.