#LATCH INSTALLATION GUIDE FOR REDMINE


##PREREQUISITES
* Redmine version 2 or superior.

* Ruby, RubyGems and Ruby on Rails installed your server.

* To get the **"Application ID"** and **"Secret"**, (fundamental values for integrating Latch in any application), it’s necessary to register a developer account in [Latch's website](https://latch.elevenpaths.com). On the upper right side, click on **"Developer area"**.


##DOWNLOADING THE REDMINE PLUGIN
 * When the account is activated, the user will be able to create applications with Latch and access to developer documentation, including existing SDKs and plugins. The user has to access again to [Developer area](https://latch.elevenpaths.com/www/developerArea), and browse his applications from **"My applications"** section in the side menu.

* When creating an application, two fundamental fields are shown: **"Application ID"** and **"Secret"**, keep these for later use. There are some additional parameters to be chosen, as the application icon (that will be shown in Latch) and whether the application will support OTP  (One Time Password) or not.

* From the side menu in developers area, the user can access the **"Documentation & SDKs"** section. Inside it, there is a **"SDKs and Plugins"** menu. Links to different SDKs in different programming languages and plugins developed so far, are shown.


##INSTALLING THE PLUGIN IN REDMINE
* Add the **"latch"** folder inside this repository to the **"plugins"** folder of your redmine.

* Go to **"Administration"** in the up side menu, then click **"plugins"** and go to **"configure"**. Set your Application Id and Secret properly.

* Now the module is installed correctly, a new **"Latch"** button will be shown for every user on the top right corner. The token generated by the Latch app can be introduced there.


##UNINSTALLING THE PLUGIN IN REDMINE
* Go to Latch [Developer area](https://latch.elevenpaths.com/www/developerArea) and browse applications from **"My applications"** section in the side menu. Click the "Remove Application" button.

* Remove the **"latch"** folder inside the **"plugins"** folder of your redmine.

