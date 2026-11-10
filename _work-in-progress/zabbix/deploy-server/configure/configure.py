# deploy-server/configure/configure.py
import json
import os
import sys
import time
import getpass
import urllib.request
import urllib.error


DEFAULT_ADMIN_LOGIN: str = 'Admin'
DEFAULT_ADMIN_PASSWORD: str = 'zabbix'
PASSWORD_LETTER_COUNT_MIN_THRESHOLD: int = len(DEFAULT_ADMIN_PASSWORD)

API_URL = os.environ.get(
    "ZABBIX_API_URL",
    "http://localhost:8080/api_jsonrpc.php"
)

REQUEST_ID = 0


def api_call(method, params, auth=None):
    global REQUEST_ID
    REQUEST_ID += 1

    payload = {
        "jsonrpc": "2.0",
        "method": method,
        "params": params,
        "id": REQUEST_ID
    }

    if auth:
        payload["auth"] = auth

    request = urllib.request.Request(
        API_URL,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json-rpc"}
    )

    try:
        with urllib.request.urlopen(request, timeout=10) as response:
            json_result = response.read().decode('utf-8')
            result = json.loads(json_result)
    except Exception as exc:
        raise RuntimeError(f'API connection failed: {exc}')

    if 'error' in result:
        print(str(result))
        raise RuntimeError(
            f'Zabbix API error: {result['error']}'
        )

    return result["result"]


def wait_for_api(attempt_count: int = 30):
    print("Waiting for Zabbix API...")

    for _attempt in range(attempt_count):
        try:
            api_call("apiinfo.version", {})
            print("Zabbix API is available.")
            return
        except Exception:
            print('Zabbix API call failed.')
            time.sleep(5)

    raise RuntimeError("Zabbix API did not become available.")


def main():
    wait_for_api(50)

    print('\nInitial Zabbix administrator configuration')
    print('-' * 30)

    print(f'Login: {DEFAULT_ADMIN_LOGIN}')
    entered_password = getpass.getpass(
            f'Current administrator password [{DEFAULT_ADMIN_PASSWORD}]: '
        )
    password = entered_password or DEFAULT_ADMIN_PASSWORD
    token = authenticate(DEFAULT_ADMIN_LOGIN, password)
    print("Administrator authenticated.")

    new_password = ask_for_new_password()

    users = api_call("user.get", {
        "output": ["userid", "username"],
        "filter": {"username": [DEFAULT_ADMIN_LOGIN]}
    }, token)

    if not users:
        raise RuntimeError("Administrator account not found.")

    api_call('user.update', {
        'userid': users[0]['userid'],
        'passwd': new_password
    }, token)

    print('Administrator password updated.')


    # Authenticate again with the new password.
    token = authenticate(DEFAULT_ADMIN_LOGIN, new_password)

    groups = [
        "Infrastructure",
        "Linux servers",
        "Windows servers",
        "Network devices",
        "Virtualization",
        "Databases",
        "Applications"
    ]

    existing = api_call("hostgroup.get", {
        "output": ["groupid", "name"]
    }, token)

    existing_names = {
        item["name"] for item in existing
    }

    print("\nCreating predefined host groups...")

    for name in groups:
        if name in existing_names:
            print(f"[EXISTS] {name}")
            continue

        api_call("hostgroup.create", {
            "name": name
        }, token)

        print(f"[CREATED] {name}")

    print()
    print("======================================")
    print(" INITIAL CONFIGURATION COMPLETED")
    print("======================================")
    print(f'Administrator: {DEFAULT_ADMIN_LOGIN}')
    print("Host groups: 7")
    print("Next step: Configure automatic registration.")
    print("======================================")


def authenticate(login: str, password: str):
    token = api_call("user.login", {
            "username": login,
            "password": password,
        })
    return token


def ask_for_new_password() -> str:
    new_password = getpass.getpass(
        "Set NEW administrator password: "
    )

    if len(new_password) < PASSWORD_LETTER_COUNT_MIN_THRESHOLD:
        raise RuntimeError(
            f'Password must contain at least {PASSWORD_LETTER_COUNT_MIN_THRESHOLD} characters.'
        )

    confirmation = getpass.getpass(
        "Confirm NEW administrator password: "
    )

    if new_password != confirmation:
        raise RuntimeError("Passwords do not match.")

    return new_password


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(f"\nERROR: {error}", file=sys.stderr)
        sys.exit(1)
