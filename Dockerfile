# Dockerfile for a Static HTML Page
# Use a lightweight web server as the base image
FROM nginx:alpine
# Remove the default index.html provided by Nginx
RUN rm /usr/share/nginx/html/index.html
# Copy your local index.html into the Nginx web root
COPY index.html /usr/share/nginx/html/
# Expose port 80 (standard for Nginx/web traffic)
EXPOSE 80
# Nginx starts automatically as the main command