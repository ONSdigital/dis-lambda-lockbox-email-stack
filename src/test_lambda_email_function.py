import os
import unittest
from unittest.mock import patch, MagicMock
from lambda_email_function import lambda_handler

os.environ['EMAIL_SOURCE'] = 'test@test.com'
os.environ['BUCKET_NAME'] = 'test-bucket'
os.environ['DOWNLOAD_URL'] = 'download-url'
os.environ['EMAIL_RECIPIENT'] = 'recipient@test.com'
os.environ['AWS_DEFAULT_REGION'] = 'eu-west-2'

class Context:
    def __init__(self):
        self.function_name = "test_lambda"
        self.memory_limit_in_mb = 128
        self.invoked_function_arn = (
            "arn:aws:lambda:eu-west-2:111111111:function:test_lambda"
        )
        self.aws_request_id = "test_request_id"

context = Context()

class TestLambdaFunction(unittest.TestCase):
    @patch('lambda_email_function.ses_client')
    def test_lambda_handler(self, mock_ses_client):
        mock_ses_client.send_email = MagicMock(return_value={'MessageId': 'test_message_id'})
        
        event = {
            "Records": [
                {
                    "s3": {
                        "bucket": {"name": "test-bucket"},
                        "object": {"key": "test-file.csv"}
                    }
                }
            ]
        }

        response = lambda_handler(event, context)
        
        mock_ses_client.send_email.assert_called_once()
        
        self.assertEqual(response['statusCode'], 200)

if __name__ == '__main__':
    unittest.main()
    