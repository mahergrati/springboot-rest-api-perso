# Étape 1 : Build Maven
FROM maven:3.9.5-eclipse-temurin-17 AS builder
WORKDIR /app

# Copie du pom.xml et téléchargement des dépendances
COPY pom.xml .
RUN mvn dependency:go-offline

# Copie du code source
COPY src ./src

# Compilation du projet
RUN mvn clean package -DskipTests

# Étape 2 : Image finale
FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app

# Copie du jar depuis l'étape précédente
COPY --from=builder /app/target/*.jar app.jar

# Exposition du port de ton application
EXPOSE 8080

# Commande de démarrage
ENTRYPOINT ["java", "-jar", "app.jar"]
