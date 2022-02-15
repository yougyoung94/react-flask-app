# Build step #1: build the React front end
FROM node:16-alpine as build-step
WORKDIR /app
RUN mkdir ./frontend
ENV PATH /app/frontend/node_modules/.bin:$PATH
COPY ./frontend/package.json ./frontend/yarn.lock ./frontend
COPY ./frontend/src ./frontend/src
COPY ./frontend/public ./frontend/public
WORKDIR frontend
RUN yarn install
RUN yarn build

# Build step #2: build the API with the client as static files
FROM python:3.9
WORKDIR /app
COPY --from=build-step /app/frontend/build ./build

RUN mkdir ./api
COPY api/requirements.txt api/api.py api/.flaskenv ./api
RUN pip install -r ./api/requirements.txt
ENV FLASK_ENV production

EXPOSE 3000
WORKDIR /app/api
CMD ["gunicorn", "-b", ":3000", "api:app"]

