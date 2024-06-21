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
![Simulator Screenshot - iPhone 15 Pro - 2024-06-21 at 00 21 55](https://github.com/Bobivankenobi/BirthdayReminder/assets/58746326/7102d44e-7c40-4cca-a3bb-973dcbc35e0a)
![Simulator Screenshot - iPhone 15 Pro - 2024-06-21 at 00 22 14](https://github.com/Bobivankenobi/BirthdayReminder/assets/58746326/706796d0-01ae-4b44-b242-8266e67f539c)
![Simulator Screenshot - iPhone 15 Pro - 2024-06-21 at 00 21 02](https://github.com/Bobivankenobi/BirthdayReminder/assets/58746326/09914805-dc89-4199-b570-2929aa46c319)
![Simulator Screenshot - iPhone 15 Pro - 2024-06-21 at 00 19 42](https://github.com/Bobivankenobi/BirthdayReminder/assets/58746326/7e8ef1e7-fe83-4b85-89f5-7a78c2c4fc32)
![Simulator Screenshot - iPhone 15 Pro - 2024-06-21 at 00 13 31](https://github.com/Bobivankenobi/BirthdayReminder/assets/58746326/37a9b999-1071-4b43-a4f2-73a73446b29d)
![Simulator Screenshot - iPhone 15 Pro - 2024-06-21 at 00 24 38](https://github.com/Bobivankenobi/BirthdayReminder/assets/58746326/45bf8de5-03d1-44e1-86dd-63970344e13c)
![Simulator Screenshot - iPhone 15 Pro - 2024-06-21 at 00 22 47](https://github.com/Bobivankenobi/BirthdayReminder/assets/58746326/b02f2310-4ceb-46a5-8ec1-136057537a93)
![Simulator Screenshot - iPhone 15 Pro - 2024-06-21 at 00 21 13](https://github.com/Bobivankenobi/BirthdayReminder/assets/58746326/33dddf50-20bf-4049-8e9a-6b892848bc40)
![Simulator Screenshot - iPhone 15 Pro - 2024-06-21 at 00 21 42](https://github.com/Bobivankenobi/BirthdayReminder/assets/58746326/09c69369-e8f3-440e-9b0c-6d31bdce3380)
![Simulator Screenshot - iPhone 15 Pro - 2024-06-21 at 00 20 44](https://github.com/Bobivankenobi/BirthdayReminder/assets/58746326/6913b575-f49c-413c-80bf-4f9a155a012c)
![Simulator Screenshot - iPhone 15 Pro - 2024-06-21 at 00 12 17](https://github.com/Bobivankenobi/BirthdayReminder/assets/58746326/20b9606c-9a66-43ac-9e24-b56092b68406)
![Simulator Screenshot - iPhone 15 Pro - 2024-06-21 at 00 24 20](https://github.com/Bobivankenobi/BirthdayReminder/assets/58746326/c21f4708-b9b5-491e-b386-5742fb6498ce)



