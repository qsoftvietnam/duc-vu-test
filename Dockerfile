FROM python:3
RUN  mkdir WORK_REPO
RUN  cd  WORK_REPO
WORKDIR  /WORK_REPO
RUN  python -m venv .venv
ADD  requirements.txt .
ADD app.py .
COPY . /WORK_REPO
EXPOSE 5000
RUN  python -m venv .venv
RUN  chmod 777 env.sh
RUN  . .venv/bin/activate
RUN  pip install -r requirements.txt
RUN  python -m pip install flask
CMD ["python", "-u", "app.py", "--host=0.0.0.0", "--port=5000"]
