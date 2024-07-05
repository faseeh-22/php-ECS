# Use an official PHP image with Apache
FROM php:7.4-apache
# Install any necessary dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd
# Copy the current directory contents into the container at /var/www/html
COPY . /var/www/html/
# Set the working directory
WORKDIR /var/www/html
# Set the server name to suppress the warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
# Expose port 80 to the outside world
EXPOSE 80
# Start Apache in the foreground
CMD ["apache2-foreground"]
