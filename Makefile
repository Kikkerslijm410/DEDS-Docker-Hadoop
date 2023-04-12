DOCKER_NETWORK = hadoop_hadoop_network
ENV_FILE = hadoop.env
current_branch = master
CLASS_TO_RUN = WordCount
PARAMS = /input/user-input /output
HADOOP_HOME = /opt/hadoop-3.2.1
JAR_FILEPATH = ${HADOOP_HOME}/applications/WordCount.jar

build:
	docker build -t bde2020/hadoop-base:$(current_branch) ./base
	docker build -t bde2020/hadoop-namenode:$(current_branch) ./namenode
	docker build -t bde2020/hadoop-datanode:$(current_branch) ./datanode
	docker build -t bde2020/hadoop-resourcemanager:$(current_branch) ./resourcemanager
	docker build -t bde2020/hadoop-nodemanager:$(current_branch) ./nodemanager
	docker build -t bde2020/hadoop-historyserver:$(current_branch) ./historyserver
	docker build -t bde2020/hadoop-submit:$(current_branch) ./submit

wordcount:
	docker build -t hadoop-wordcount ./submit
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-wordcount hdfs dfs -mkdir -p /input/
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-wordcount hdfs dfs -copyFromLocal -f /user-input/input.txt /input/
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-wordcount
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-wordcount hdfs dfs -cat /output/*
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-wordcount hdfs dfs -rm -r /output
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-wordcount hdfs dfs -rm -r /input
clear:
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-wordcount hdfs dfs -rm -r /output
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-wordcount hdfs dfs -rm -r /input

installwordcount:
	docker exec -it namenode mkdir ${HADOOP_HOME}/applications
	docker cp submit/WordCount.jar namenode:${HADOOP_HOME}/applications/WordCount.jar

woord:
	docker exec -it namenode hdfs dfs -mkdir -p /input/
	docker cp submit/input/. namenode:/user-input/
	docker exec -it namenode hdfs dfs -copyFromLocal -f /user-input/ /input/
	docker exec -it namenode ${HADOOP_HOME}/bin/hadoop jar ${JAR_FILEPATH} ${CLASS_TO_RUN} ${PARAMS}
	docker exec -it namenode hdfs dfs -cat /output/*
	docker exec -it namenode hdfs dfs -rm -r /output
	docker exec -it namenode hdfs dfs -rm -r /input
clearwoord:
	docker exec -it namenode hdfs dfs -rm -r /output
	docker exec -it namenode hdfs dfs -rm -r /input

custom:
	docker-compose up -d
	py ../Scrapers/Bever/BeverBot.py
	powershell cp ../Scrapers/Bever/output ./scraper/input/ -Recurse
	docker build -t hadoop-scraper ./scraper
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-scraper hdfs dfs -mkdir -p /data/
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-scraper hdfs dfs -copyFromLocal /scraper/ /data/
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-scraper

customHadoopOnly:
	docker build -t hadoop-scraper ./scraper
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-scraper hdfs dfs -mkdir -p /data/
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-scraper hdfs dfs -copyFromLocal /scraper/ /data/
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-scraper
customclean:
	docker exec -it namenode hdfs dfs -rm -r /data
