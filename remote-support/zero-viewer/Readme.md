# ZeroViewer remote desktop
(based on reverse SSH-server in the Docker)

[About ZeroViewer solutions](https://null.la)


## Set up

### Server settings

- `settings/constants.conf`
- `settings/sshd/security.conf`
- `settings/sshd/whitelist.conf`


### Generate SSH Logins/Passwords (on the server)

1. Generate SSH password hash with the following command:

```bash
openssl passwd -6 'PLAIN_PASSWORD'
```

and remove the `$6` and `$rounds=???` because these will be added automatically.

2. Store credentials in the `LOGIN:PASSWORD_HASH` format in the following files:
- `passwords/clients.txt`
- `passwords/operators.txt`


### Store SSH login/password (in the client's Windows software)

Windows' GUI program stores passwords in `.ini`-file as encrypted (not hashed!).

On the client, type **plain password** in the `Settings > Retranslation server > Client > Password` menu.
The program itself will save encrypted password into `.ini`.


## Run

`build-and-run.sh` - it also can re-run the container
