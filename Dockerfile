FROM python:3.8

ARG PROJECT_NAME=cooleytech_sample
ENV PROJECT_NAME ${PROJECT_NAME}

COPY . ${PROJECT_NAME}
WORKDIR /${PROJECT_NAME}

RUN ["pip","install","-r","requirements.txt"]

ENTRYPOINT ["python","-u"]
CMD ["cooleytech_sample.py"]