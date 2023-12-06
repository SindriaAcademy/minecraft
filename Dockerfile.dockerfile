# Usa l'immagine di base specificata
FROM nome_immagine_minecraft:tag

# Esempi di configurazione personalizzata
ENV MOTD="Benvenuto nel server Minecraft"
ENV MAX_PLAYERS=20
ENV JAVA_XMS=512M
ENV JAVA_XMX=2G
ENV DIFFICULTY=normal
ENV VIEW_DISTANCE=10


# Espone la porta del server Minecraft
EXPOSE 25565

# Crea la directory del server e imposta il percorso di lavoro
WORKDIR /minecraft

# Per preservare i dati del server Minecraft tra riavvii del container, puoi utilizzare un volume Docker. 
VOLUME ["/minecraft/world"]

# Se il server Minecraft utilizza altri file di configurazione, assicurati di copiarli nel tuo Dockerfile.
COPY server.properties /minecraft/server.properties

# Copia i file del server Minecraft nell'immagine
COPY server /minecraft

# Comando di avvio del server
CMD ["java", "-Xms$JAVA_XMS", "-Xmx$JAVA_XMX", "-jar", "minecraft_server.jar", "nogui"]
