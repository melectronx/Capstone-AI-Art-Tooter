from mastodon import Mastodon, CallbackStreamListener
import json
import os
import boto3
from datetime import datetime
from dotenv import load_dotenv
load_dotenv()

mastodon = Mastodon(
    access_token = os.getenv('MASTODON_ACCESS_TOKEN'),
    api_base_url = 'https://techhub.social'
)
dynamodb = boto3.resource('dynamodb')
toots_table_name = os.getenv('TOOTS_TABLE_NAME')
toots_table = dynamodb.Table(toots_table_name)

tag = "aiarttooter"

def save_toot(toot_data):
    content = toot_data['content']
    tootdate = toot_data['created_at']
    datetoot = tootdate.strftime("%m/%d/%Y, %H:%M:%S")
    prompt = content[content.find('prompt')+7:-4]
    toot = {
            "id": toot_data["id"],
            "date": datetoot,
            "prompt": prompt,
            "username": toot_data["account"]["username"],
            "filename": str(toot_data['id'])+'.jpeg'
            }    
    toots_table.put_item(Item = toot)
    
def handler(event, context):
    listener = CallbackStreamListener(save_toot)    
    mastodon.stream_hashtag(tag, listener, local=False, run_async=False, timeout=300, reconnect_async=False, reconnect_async_wait_sec=5)

if __name__ == "__main__":      
    handler({},{})
    
