#!/bin/sh
echo "UPLOAD TO GOOGLE STORAGE SCRIPT RUNNING ..."

# Add the required data from your JSON key file
json_file="googlestorage_credintials_json_file.json"

TOKEN_URI=$(awk -F'"' '/"token_uri":/{print $(NF-1)}' "$json_file")
CLIENT_EMAIL=$(awk -F'"' '/"client_email":/{print $(NF-1)}' "$json_file")
PRIVATE_KEY=$(awk -F'"' '/"private_key":/{print $(NF-1)}' "$json_file")

if [ ! -e "${_path}/tmp_private_key.pem" ]; then
  printf "%b" "$PRIVATE_KEY" > "${_path}/tmp_private_key.pem"
fi

# Create JWT header
header=$(echo -n '{"alg":"RS256","typ":"JWT"}' | openssl base64 -A | tr -d '\n=' | tr '+/' '-_')

# Create JWT claim set
now=$(date +%s)
claim_set=$(printf '{"iss":"%s","scope":"https://www.googleapis.com/auth/devstorage.full_control","aud":"%s","exp":%d,"iat":%d}' "$CLIENT_EMAIL" "$TOKEN_URI" $(($now + 3600)) $now)
claim_set=$(echo -n "$claim_set" | openssl base64 -A | tr -d '\n=' | tr '+/' '-_')

# Sign the JWT
signature=$(echo -n "$header.$claim_set" | openssl dgst -sha256 -sign ${_path}/tmp_private_key.pem | openssl base64 -A | tr -d '\n=' | tr '+/' '-_')

# Create the signed JWT
jwt="${header}.${claim_set}.${signature}"

# Request the access token
API_RESPONSE=$(curl -s -d "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$jwt" "$TOKEN_URI")
echo "API response: $API_RESPONSE"

# Extract the access token from the API response
ACCESS_TOKEN=$(echo "$API_RESPONSE" | sed -n 's/.*"access_token" *: *"\([^"]*\)".*/\1/p')

UPLOAD_ARCHIVE="path_to_your_file_to_upload"

# #### End of configuration variables

echo "Sending..." $UPLOAD_ARCHIVE

# Upload to Google Storage
upload_to_google_storage() {
  local bucket_name="your_bucket_name" # Replace with your bucket name
  local file_path="$1"
  local file_name="$(basename "$file_path")"
  local access_token="$2"

  response=$(curl -s -o /dev/null -w '%{http_code}' -X POST -L "https://storage.googleapis.com/upload/storage/v1/b/${bucket_name}/o?uploadType=multipart" \
    -H "Authorization: Bearer $access_token" \
    -F "metadata={\"name\": \"$file_name\"};type=application/json;charset=UTF-8" \
    -F "file=@$file_path;type=application/octet-stream")

  echo "$response"
}

response_code=$(upload_to_google_storage "$UPLOAD_ARCHIVE" "$ACCESS_TOKEN")
echo "response_code: $response_code"

if [ "$response_code" -eq 200 ]; then
  echo "Upload successful"
else
  echo "Upload failed with status code: $response_code"
fi

rc=$?
if test "$rc" != "0"; then
  echo "Send failed with return code: $rc"
else
  echo "OK"
fi

