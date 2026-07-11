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
openssl passwd -6 "PLAIN_PASSWORD"
```

2. Store SSH logins with passwords in the following files:
- `passwords/clients.txt`
- `passwords/operators.txt`

in the following format:

```txt
LOGIN1:6$rounds=5000$PASSWORD_HASH
```


### Store SSH login/password (in the client's Windows software)

Windows' GUI program stores passwords in `.ini`-file as encrypted (not hashed!).

On the client, type **plain password** in the `Settings > Retranslation server > Client > Password` menu.
The program itself will save encrypted password into `.ini`.


## Run

`build-and-run.sh` - it also can re-run the container
