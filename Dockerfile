# Use the official PHP image with Apache, based on Alpine
FROM php:8.1-apache-alpine
# Install necessary dependencies and PHP extensions
RUN apk add --no-cache \
    bash \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    zlib-dev \
    libxpm-dev \
    freetype-dev \
    oniguruma-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install gd mysqli pdo pdo_mysql mbstring
# Copy the current directory contents into the container at /var/www/html
COPY . /var/www/html
# Enable Apache mod_rewrite
RUN sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf \
    && sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/httpd.conf
# Set the working directory to /var/www/html
WORKDIR /var/www/html
# Ensure the necessary permissions
RUN chown -R www-data:www-data /var/www/html
# Expose port 80
EXPOSE 80
# Run Apache in the foreground
CMD ["httpd", "-D", "FOREGROUND"]
