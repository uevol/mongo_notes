reset_password_when_email_is_not_configured



## 1. Request a password reset from your browser:
Click on forgot password? from the Ops Manager login page
Input the username and click on "RESET PASSWORD"


## 2. Connect to the Primary of your Ops Manager database and run the following commands
```
use mmsdbconfig

# Replace YOURUSERNAME with the user that needs the password reset
db.config.passwordReset.find({"username": "YOURUSERNAME"})

# The output should be similar to this:

{ "_id" : "xxx", "resetType" : "PASSWORD", "userId" : ObjectId("yyy"), "username" : "username@emailaddress.com", "created" : ISODate("2015-MM-DDT08:51:20.015Z") }
```


## 3. Copy the _id field and navigate to the following link, replacing the replace_with_the_id with the _id field value
```
http://MMS_server_ip_address:MMS_server_port/user/reset/password/replace_with_the_id

# For example:
http://localhost:8080/user/reset/password/2fb2463ace5c4a54e55fc4914dda8d5d
```