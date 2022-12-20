from mastodon import Mastodon
import boto3
import os


toots_table_name = os.getenv('TOOTS_TABLE_NAME')
s3               = boto3.resource('s3')
dynamodb         = boto3.resource('dynamodb')
table            = dynamodb.Table(toots_table_name)

mastodon = Mastodon(
    access_token = os.getenv('MASTODON_ACCESS_TOKEN'),
    api_base_url = 'https://techhub.social'
)

def post_toot(record):
    s3_data = record['s3']
    bucket_name = s3_data['bucket']['name']
    file_name = s3_data['object']['key']
    id = int(file_name[0:-4])
    response = table.get_item(Key={ 'id' : id })
    username = response['Item']['username']
    in_reply_to_id = response['Item']['id']
    status = username + ' here is your AI-ART!'
    s3.meta.client.download_file(bucket_name , file_name, '/tmp/'+file_name)
    media_file = '/tmp/'+file_name
    
    aiimg = mastodon.media_post(media_file, mime_type=None, description=None, focus=None, file_name=None, thumbnail=None, thumbnail_mime_type=None, synchronous=False)
    mastodon.status_post(status, in_reply_to_id=None, media_ids=aiimg, sensitive=False, visibility=None, spoiler_text=None, language=None, idempotency_key=None, content_type=None, scheduled_at=None, poll=None, quote_id=None)

def handler(event, context):
    
    for record in event['Records']:
        post_toot(record)
    

if __name__ == '__main__':      
    handler({},{})
