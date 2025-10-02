import json
import boto3
import postgresql
import requests


ssm_client = boto3.client('ssm')

ssm_prefix = '/litware/lambda/postgresql'
ssm_postgresql_address = f"{ssm_prefix}/address"
ssm_postgresql_username = f"{ssm_prefix}/username"
ssm_postgresql_password = f"{ssm_prefix}/password"


def lambda_handler(event, context):
    _connect_to_postgresql()
    _make_http_request()

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "hello world",
            # "location": ip.text.replace("\n", "")
        }),
    }


def _connect_to_postgresql():
    address = _get_parameter(ssm_postgresql_address)
    username = _get_parameter(ssm_postgresql_username)
    password = _get_parameter(ssm_postgresql_password, True)

    db = postgresql.open(f'pq://{username}:{password}@{address}:5432/appdb')

    get_table = db.prepare("SELECT * from information_schema.tables WHERE table_name = $1")
    print(get_table("tables"))

    # Streaming, in a transaction.
    with db.xact():
        for x in get_table.rows("tables"):
            print(x)
    db.close()


def _make_http_request():
    url = "https://jsonplaceholder.typicode.com/posts/1"  # Example API endpoint
    response = requests.get(url)
    print(f"Status Code: {response.status_code}")


def _get_parameter(name: str, with_decryption: bool = False) -> str:

    response = ssm_client.get_parameter(
        Name=name,
        # Set to False if not a SecureString or decryption is not needed
        WithDecryption=with_decryption
    )

    # Extract the parameter value
    return response['Parameter']['Value']
