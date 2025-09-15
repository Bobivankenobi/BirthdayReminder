# Birthday Reminder App

## Overview
Birthday Reminder is an iOS application that helps users keep track of birthdays. 
Users can create and manage birthday groups, add birthdays to groups, view upcoming birthdays in a calendar view, and receive notifications for birthdays.

## Features
- **Birthday Management**: Create, edit, and delete birthdays.
- **Group Management**: Create, edit, and delete groups to organize birthdays.
- **Calendar View**: Visualize all birthdays in a calendar view.
- **Notifications**: Receive local notifications for upcoming birthdays.
- **Birthday Messages**: Fetch and display random birthday messages.

## Requirements
- Xcode 12.0 or later
- iOS 13.0 or later
- Swift 5.0 or later

## Installation

1. **Clone the repository:**

   ```bash
   git@github.com:Bobivankenobi/BirthdayReminder.git

2. **Navigate to the project directory::**

   ```bash
   cd BirthdayReminder

3. **Open the Xcode project:**

   ```bash
   open BirthdayReminder.xcodeproj

4. **Install dependencies using CocoaPods:**

   ```bash
   pod install

5. **Build and run the project on your simulator or device.:**


---------------------------------------------------------------
# Usage

## Adding a Group

- Tap the "+" button on the top right corner of the Tags screen.
- Enter the group name.
- Select an icon and color for the group.
- Tap "Create" to save the group.


## Adding a Birthday

- Navigate to the desired group.
- Tap the "+" button on the top right corner of the Birthdays screen.
- Enter the birthday details including name, date, and comment.
- Tap "Create" to save the birthday.


## Viewing Birthdays in Calendar

- Navigate to the Calendar tab.
- Birthdays are marked with dots on the respective dates.
- Tap on a date to see the list of birthdays for that day.

## Deleting a Group or Birthday

- Tap the trash icon on the group or birthday item to remove it.

## Local Notifications

- You will receive a notification at 9 AM on the day of someone's birthday.
- Make sure to allow notifications for the app in your device settings.

## Fetching Random Birthday Messages
- When you tap on a birthday, the app fetches and displays a random birthday message using RapidAPI.

## Integration with RapidAPI
- The app uses the ajith-messages API from RapidAPI to fetch random birthday messages. The integration works as follows:
- When a birthday is selected, a network request is made to the API. A random birthday message is fetched and displayed in the BirthdayMessageVC.

1. **Example API request:**

   ```bash
   GET https://ajith-messages.p.rapidapi.com/getMsgs?category=birthdaypod install

# Code Structure

## View Controllers

- TagVC: Manages groups and displays them in a table view.
- BirthdayVC: Manages birthdays within a group and displays them in a table view.
- CalendarVC: Displays all birthdays in a calendar view.
- AddNewGroupVC: Modal view controller for creating a new group.
- AddNewBirthdayVC: Modal view controller for creating a new birthday.
- BirthdayMessageVC: Displays a random birthday message.

## Models

- Group: Core Data entity representing a group of birthdays.
- Birthday: Core Data entity representing an individual birthday.

## Utilities

- UIColor+Extensions: Utility extensions for UIColor to handle hex strings.

## Notification Center

- BirthdayAdded: Posted when a new birthday is added.
- BirthdayDeleted: Posted when a birthday is deleted.
- GroupDeleted: Posted when a group (and its associated birthdays) is deleted.

## Contact

- For any questions or feedback, please reach out to boban32522@its.edu.rs.


## App Screenshots: ![IMG_4416](https://github.com/Bobivankenobi/BirthdayReminder/assets/58746326/7efa2b9d-ec5f-4458-8328-033faa67949c)

![Simulator Screenshot - iPhone 15 Pro - 2024-06-21 at 00 21 24](https://github.com/Bobivankenobi/BirthdayReminder/assets/58746326/1e194ba6-ab5d-4fe2-b631-ef3ca3a2673a)
<img width="1290" height="2796" alt="Simulator Screenshot - iPhone 16 Plus - 2025-09-15 at 20 51 23" src="https://github.com/user-attachments/assets/d54aa6ba-5766-4c9c-a8ad-ec0d113c09bf" />
<img width="1290" height="2796" alt="Simulator Screenshot - iPhone 16 Plus - 2025-09-15 at 20 51 32" src="https://github.com/user-attachments/assets/ff4fadf0-67d5-4d56-bb31-83c23fcdb5c7" />
<img width="1290" height="2796" alt="Simulator Screenshot - iPhone 16 Plus - 2025-09-15 at 20 51 42" src="https://github.com/user-attachments/assets/2a1a36d1-2c68-4cda-8ae9-2fc36197c093" />
<img width="1290" height="2796" alt="Simulator Screenshot - iPhone 16 Plus - 2025-09-15 at 20 51 50" src="https://github.com/user-attachments/assets/278bd8df-4dcf-478b-be6f-643dea1991db" />
<img width="1290" height="2796" alt="Simulator Screenshot - iPhone 16 Plus - 2025-09-15 at 20 51 58" src="https://github.com/user-attachments/assets/bfb241ea-3ceb-4637-9add-02ec158af5b2" />
<img width="1290" height="2796" alt="Simulator Screenshot - iPhone 16 Plus - 2025-09-15 at 20 52 08" src="https://github.com/user-attachments/assets/61cedf9f-ca14-4d6f-8bc4-b9c2de503573" />
<img width="1277" height="711" alt="Screenshot 2025-09-15 at 20 52 42" src="https://github.com/user-attachments/assets/df2a10d2-041d-4830-8443-f206a978cf04" />
<img width="1290" height="2796" alt="Simulator Screenshot - iPhone 16 Plus - 2025-09-15 at 20 53 53" src="https://github.com/user-attachments/assets/c30ebc0c-c1d3-49d1-80ae-e65ee18f0685" />
<img width="1290" height="2796" alt="Simulator Screenshot - iPhone 16 Plus - 2025-09-15 at 20 54 10" src="https://github.com/user-attachments/assets/36354ada-d0a8-4223-a4b9-ec6b9c04241c" />


