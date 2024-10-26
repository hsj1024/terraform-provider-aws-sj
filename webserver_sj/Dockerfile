FROM python:3.8

# 기본 패키지 업데이트 및 필수 패키지 설치
RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Flask, httplib2, requests 패키지를 설치
RUN pip install --upgrade pip setuptools \
    && pip install flask httplib2 requests

# 작업 디렉터리를 /app으로 설정
WORKDIR /app

# 로컬의 server.py 파일을 컨테이너의 /app 디렉터리로 추가
ADD server.py .

# 컨테이너가 실행될 때 실행할 명령어
CMD ["python3", "-u", "server.py"]
