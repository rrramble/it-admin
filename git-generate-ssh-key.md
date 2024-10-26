# Set up an SSH key pair for GitHub

## 1. Generate key pair

### In MS Windows
```cmd
ssh-keygen -t rsa -b 4096 -C "EMAIL"
```

the program usually is inside the folder:
`...git/usr/bin/ssh-keygen.exe```

### In MacOS
```zsh
ssh-keygen -t rsa -b 4096 -C "EMAIL"
```

by default it saves to:
- Private file `~/.ssh/id_rsa`
- Public file `~/.ssh/id_rsa.pub`

## 2. Save the SSH public key to your account on GitHub.com

### In MS Windows
Copy the public key to the clipboard:
```cmd
clip < ~/.ssh/id_rsa.pub
```

Insert copied clipboard to `github.com > settings > ssh > New SSH Key`

### In MacOS
Copy the public key to the clipboard:
```zsh
pbcopy < ~/.ssh/id_rsa.pub
```

Insert copied clipboard to `github.com > settings > ssh > New SSH Key`

```zsh
ssh-add ~/.ssh/id_rsa
```
This will show: `Identity added: /Users/r/.ssh/id_rsa (EMAIL)`

## 3. Check an SSH connection with GitHub

```bash
ssh -T -i ~/.ssh/id_rsa.pub git@github.com
ssh -T -i id_rsa git@github.com
```

## 4. Configure SSH config

### In MS Windows
Create (upade) the file:
```cmd
%UserProfile%\.ssh\config
```

add the following content:
```txt
Host github.com
    IdentityFile c:\users\USER_PROFILE\id_rsa
```

### In MacOS
```zsh
touch ~/.ssh/config
```

add the following content:

```txt
Host github.com
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile /Users/USER_PROFILE/id_rsa
```

## 5. Check the connection

```cmd
ssh -T git@github.com
```

This will go:

```txt
The authenticity of host 'github.com (192.30.253.112)' can't be established.
RSA key fingerprint is SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8.
Are you sure you want to continue connecting (yes/no)?
```

Type: `yes`

## 6. Set up username and email

```cmd
git config --global user.name "FIRST_NAME LAST_NAME"
git config --global user.email "NAME@example.com"
```
