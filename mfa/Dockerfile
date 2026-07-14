FROM mmcauliffe/montreal-forced-aligner:latest AS build

RUN mfa model download acoustic portuguese_mfa
RUN mfa model download dictionary portuguese_brazil_mfa
RUN mfa model download g2p portuguese_brazil_mfa
RUN pip install textgrid

COPY ./main.py .

CMD [ "python", "main.py" ]