docker network create sonarnet

docker run --rm -d --name sonardb --network sonarnet \
  -e POSTGRES_USER=sonar -e POSTGRES_PASSWORD=sonar -e POSTGRES_DB=sonar \
  postgres:latest

docker run --rm -d --name sonarqube --network sonarnet -p 9000:9000 \
  -e SONAR_JDBC_URL=jdbc:postgresql://sonardb:5432/sonar \
  -e SONAR_JDBC_USERNAME=sonar \
  -e SONAR_JDBC_PASSWORD=sonar \
  -v /mnt/sonarqube/data:/opt/sonarqube/data \
  -v /mnt/sonarqube/extensions:/opt/sonarqube/extensions \
  -v /mnt/sonarqube/logs:/opt/sonarqube/logs \
  sonarqube:lts
