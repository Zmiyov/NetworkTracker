# Configuration options:

You can setup the project changing these properties in the Constants struct of the Constants file:
1. requestFilter - A String representing the domain to filter network requests
2. appGroupIdentifier - A String that used as a group identifier in the whole app

# Troubleshooting tips and common issues.
If you don't recieve notifications or Face ID don't work you can try to turn them on in the system settings.
Also you can handle state of notification and filtering services from settings in the app.

# Brief overview of the code structure and important modules.

### The architechture of the app is MVVM.
Core Data is used as a database. 

Combine is used for binding a viewmodel to a view.

### The app has 3 screens.
1. Safety: used to limit access to the app database using Face ID verification.
2. Main: used for displaying data about all requests saved in the database using Collection View with Diffable Data Source.
3. Settings: there are two options for handle state of both notification and filter services.

### The app use two network extensions:
1. Filter Data Extension for tracking all flows with a certain filter(in the app it is "google.com") and firing Filter Control Extension
2. Filter Control Extension for saving data in the database and firing notifications.
