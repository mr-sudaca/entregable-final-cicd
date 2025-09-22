1. Hacer build de imagen Docker
```bash
docker build -t horoscopo-local .
```

2. Crear archivo .env con las variables de entorno
```env
CHATGPT_KEY=tu_api_key_aqui
SESSION_SECRET=tu_secreto_aqui
```

3. Correr contenedor Docker
```bash
docker run -d --name horoscopo-container --env-file .env  -p 15000:8000 horoscopo-local
```

4. Acceder a la aplicación en el navegador
```
http://localhost:15000
```
