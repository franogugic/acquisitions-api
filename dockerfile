
FROM node:20-alpine AS base

# dir za nasu apl u imageu
WORKDIR /app

# kopiramo dependencie prvo, da ne mroamo ih svaki put iznova instaliravat
COPY package*.json ./

# koristimo clean install umjesto obicnog installa
#   ne mjenja package-lock.json
#       package-lock npm automatski generia i sadrzi verziju svega, svih dependenciesa i sub dep...
#        cilj je da node_modules bude isti na svakom racunalu
#
#   brise node_modules prije isntalacije
#       jer psotoji sansa da lokalni node_model ima neke stare verzije
#       koristi package-lock.json za instaliravanje verzija koje su tamo zapisane
#
# only production instalira samo dependencies izbjegavajucei devDependenciese

# npm cuva preuzete packagese u cachu, a cache se defaultno kopira u image
# brisemo taj cache kako bi image bio manji, ali brise nakon npm ci

# ovo radi za buildanje imagea
RUN npm ci --only=production && npm cache clean --force

#kopiramo ostatak koda
COPY . .

# kreiramoo novu grupu i korisnika, oboje nodejs
# -g je gid grupid -s je system grup
# odnosno -system user, -u je id usera
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# dajemo ownership /app grupi i useru nodejs
# R znaci rekurzivno,d a vrati sve datoteke i pdofoldere
RUN chown -R nodejs:nodejs /app

USER nodejs

# Expose the port
EXPOSE 3000

# Health check isntrukcija koja prati da li je cotnainer zdrav
#   provjerava se svako 30 sek da radi
#   ako ne zavrsi u 3 sek to je fail
#   ceka se 5 sec nakon starta containera za pocetak checka
#   proba se 3 puta prije no sto se container oznaci kao unhealty

# radi se http request na endpoint
#   ako se vrati 0 onda radi, a ako 1 onda ne
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => { process.exit(1) })"

# Development stage
# nasdljeduje sve iz base "faze"
FROM base AS development
USER root
# instalirava i dev depenenciesee
RUN npm ci && npm cache clean --force
USER nodejs
CMD ["npm", "run", "dev"]

# Production stage
FROM base AS production
CMD ["npm", "start"]