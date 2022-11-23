FROM python:2.7
COPY app.py test.py /app/
WORKDIR /app
RUN pip install flask pytest
CMD ["python", "app.py"]