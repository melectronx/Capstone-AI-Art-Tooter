FROM public.ecr.aws/lambda/python:3.9.2022.12.14.07-x86_64

COPY requirements.txt  .
RUN  pip3 install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

COPY generate-art.py ${LAMBDA_TASK_ROOT}

CMD [ "generate-art.handler" ] 
