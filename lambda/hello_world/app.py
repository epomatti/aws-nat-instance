import json
import boto3
import pg8000.native
import requests
# import ssl


ssm_client = boto3.client('ssm')

ssm_prefix = '/litware/lambda/postgresql'
ssm_postgresql_address = f"{ssm_prefix}/address"
ssm_postgresql_username = f"{ssm_prefix}/username"
ssm_postgresql_password = f"{ssm_prefix}/password"

# ca_bundle = "us-east-2-bundle.pem"

# # Create SSL context with your bundle
# ctx = ssl.create_default_context(
#     purpose=ssl.Purpose.SERVER_AUTH,
#     cafile=ca_bundle
# )

# ctx.check_hostname = False
# ctx.verify_mode = ssl.CERT_REQUIRED


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

    conn = pg8000.native.Connection(
        user=username,
        password=password,
        host=address,
        port=5432,
        database="appdb",
        ssl_context=True  # use default SSL context, no cert checks
    )

    print(conn.run("SELECT current_date")[0][0])
    conn.close()


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
