# Rename a Windows User Account and Its Folder Path


## Step 1: Log In as administrator, log off other users
- Restart the computer. Simple logoff might not be enough because some system sessions can still run under user’s account (e.g., antivirus, OneDrive, etc.).


## Step 2: Rename the Account Name

- Run `lusrmgr.msc`, click the `Users` folder in the left pane.
- Right-click the account you want to change and rename it with the new login name.
- Right-click the account again, select `Properties`, and set a display name in the Full Name box (e.g., `John Doe`).
- In File Explorer, rename the folder inside `C:\Users\...` with the new username.


## Step 3: Update the Windows Registry Path

- Run `regedit` and open the path `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList`
- Click through the long numbered folders (`S-1-5-21-...`) in the left column.
- Look at `ProfileImagePath` on the right side (e.g., `C:\Users\user1`) and change it.


## Step 4: Verify

- Restart the computer.
- Have the user log into their newly named account.
