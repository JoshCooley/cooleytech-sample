FROM python:3.8
ADD . cooley.tech
WORKDIR cooley.tech

RUN ["pip","install","-r","requirements.txt"]

ENTRYPOINT ["python","-u"]
CMD ["site.py"]