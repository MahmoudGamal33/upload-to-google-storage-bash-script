# Upload to Google Storage Bash Script

This bash script allows you to upload a file to Google Cloud Storage using a Service Account JSON key file.

## Prerequisites

- A Google Cloud Platform project with a Cloud Storage bucket
- A Service Account with the necessary permissions and a JSON key file
- curl and openssl installed on your system

## Usage

1. Save the bash script as `upload_to_google_storage.sh`.

2. Replace the `json_file` variable value with the path to your Service Account JSON key file:

   ```bash
   json_file="googlestorage_credentials_json_file.json"
   
3. Replace the UPLOAD_ARCHIVE variable value with the path to the file you want to upload:
   
   UPLOAD_ARCHIVE="path_to_your_file_to_upload"

4. Make the script executable:
   chmod +x upload_to_google_storage.sh

5. Run the script:
   ./upload_to_google_storage.sh

   The script will output the HTTP status code indicating the success or failure of the upload. If the upload is successful, you will see a "200" status code.

## Troubleshooting
If you encounter any issues during the execution, double-check the following:

	. Ensure you have the correct path to your Service Account JSON key file
	. Verify that the Service Account has the necessary permissions to upload to the specified Cloud Storage bucket
	. Make sure your file path is correct and the file exists
	
If you continue to have issues, inspect the API response or response code for more information on the error.
