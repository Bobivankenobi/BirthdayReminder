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
   cd birthday-reminder

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


