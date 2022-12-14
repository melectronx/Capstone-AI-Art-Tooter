# without sandbox please move creation of the bucket to terraform
sh setup_bucket.sh terraform-state-ai-art-tooter 
sh setup_bucket.sh ai-art-tooter-src-bucket
sh setup_bucket.sh ai-art-tooter-img

mkdir infrastructure/build

cd mastodon-layer
pip3 install -r requirements.txt --target python/lib/python3.9/site-packages
zip -r ../infrastructure/build/mastodon-layer.zip .
cd ..

echo  "upload to s3"
aws s3 cp infrastructure/build/mastodon-layer.zip s3://ai-art-tooter-src-bucket/
