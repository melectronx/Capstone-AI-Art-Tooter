# without sandbox please move creation of the bucket to terraform
sh setup_src_bucket.sh


mkdir infrastructure/build

cd get-toot/src
zip -r ../../infrastructure/build/get-toot.zip .
cd ../..

cd post-toot/src
zip -r ../../infrastructure/build/post-toot.zip .
cd ../..

cd requests-layer
pip3 install -r requirements.txt --target python/lib/python3.9/site-packages
zip -r ../build/requests-layer.zip .
cd ..

echo  "upload to s3"
aws s3 cp build/requests-layer.zip s3://ai-art-tooter-src-bucket/