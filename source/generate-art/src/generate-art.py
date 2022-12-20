import json
import boto3
import os
import io
import warnings
from PIL import Image
from stability_sdk import client
import stability_sdk.interfaces.gooseai.generation.generation_pb2 as generation
#from dotenv import load_dotenv
#load_dotenv()

toots_table_name = os.getenv('TOOTS_TABLE_NAME')
s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(toots_table_name)
bucket = 'ai-art-tooter-img'
stability_host = os.getenv('STABILITY_HOST')
stability_key = os.getenv('STABILITY_KEY')


def generate_art(prompt_from_toot, file_name):
    stability_api = client.StabilityInference(
        key = stability_key,
        verbose=True,
        engine='stable-diffusion-v1-5', # Set the engine to use for generation. 
        # Available engines: stable-diffusion-v1 stable-diffusion-v1-5 stable-diffusion-512-v2-0 stable-diffusion-768-v2-0 stable-inpainting-v1-0 stable-inpainting-512-v2-0
    )
    # Set up our initial generation parameters.
    answers = stability_api.generate(
        prompt = prompt_from_toot,
        seed=992446758,
        steps=50,
        cfg_scale=8.0,
        width=512,
        height=512,
        samples=1,
        sampler=generation.SAMPLER_K_DPM_2_ANCESTRAL
    )
    # Set up our warning to print to the console if the adult content classifier is tripped.
    # If adult content classifier is not tripped, save generated images.
    for resp in answers:
        for artifact in resp.artifacts:
            if artifact.finish_reason == generation.FILTER:
                warnings.warn(
                    'Your request activated the APIs safety filters and could not be processed.'
                    'Please modify the prompt and try again.')
            if artifact.type == generation.ARTIFACT_IMAGE:
                img = Image.open(io.BytesIO(artifact.binary))
                file_path = '/tmp/'+ str(artifact.seed)+ '.png'
                img.save(file_path)
                s3_upload(file_path, file_name)


def s3_upload(file_path, file_name):
    s3.upload_file(file_path, bucket, file_name)


def handle_new_image(newImage):
    id = int(newImage['id']['N'])
    response = table.get_item(
    Key={
        'id' : id 
        }
    )
    file_name = response['Item']['filename']
    prompt = response['Item']['prompt']
    generate_art(prompt, file_name)


def handle_record(record):
    if "INSERT" in record['eventName']:
        handle_new_image(record['dynamodb']['Keys'])

        
def handler(event, context):
    for record in event['Records']:
        handle_record(record)
    